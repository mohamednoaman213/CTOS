import base64
import cv2
from fastapi import FastAPI, File, UploadFile
from ultralytics import YOLO
import shutil

app = FastAPI()

@app.get("/")
def home():
    return {"message": "AI Threat Detection API Running"}

fire_model   = YOLO("models/fire_model.pt")
weapon_model = YOLO("models/weapon_model.pt")


@app.post("/detect")
async def detect(file: UploadFile = File(...)):
    file_path = f"temp/{file.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    img = cv2.imread(file_path)
    if img is None:
        return {"detections": [], "threat_level": "NO THREAT DETECTED",
                "recommended_action": "No action required", "annotated_image": None}

    detections = []

    # ── Fire detection ────────────────────────────────────────
    fire_results = fire_model(file_path)
    for box in fire_results[0].boxes:
        cls   = int(box.cls[0])
        conf  = float(box.conf[0])
        label = fire_results[0].names[cls]
        x1, y1, x2, y2 = [int(v) for v in box.xyxy[0]]
        cv2.rectangle(img, (x1, y1), (x2, y2), (0, 60, 255), 2)
        cv2.putText(img, f"{label} {conf:.2f}", (x1, max(y1 - 8, 10)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 60, 255), 2)
        detections.append({"label": label, "confidence": round(conf, 3)})

    # ── Weapon detection ──────────────────────────────────────
    weapon_results = weapon_model(file_path)
    for box in weapon_results[0].boxes:
        cls   = int(box.cls[0])
        conf  = float(box.conf[0])
        label = weapon_results[0].names[cls]
        if label in ["pistol", "knife"]:
            x1, y1, x2, y2 = [int(v) for v in box.xyxy[0]]
            cv2.rectangle(img, (x1, y1), (x2, y2), (255, 30, 30), 2)
            cv2.putText(img, f"{label} {conf:.2f}", (x1, max(y1 - 8, 10)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 30, 30), 2)
            detections.append({"label": label, "confidence": round(conf, 3)})

    # ── Threat level ──────────────────────────────────────────
    labels = [d["label"] for d in detections]
    if ("fire" in labels) and ("pistol" in labels or "knife" in labels):
        threat = "CRITICAL"
    elif "fire" in labels or "pistol" in labels or "knife" in labels:
        threat = "HIGH"
    else:
        threat = "NO THREAT DETECTED"

    action = {
        "CRITICAL": "Immediate emergency dispatch",
        "HIGH":     "Alert emergency services",
    }.get(threat, "No action required")

    # ── Encode annotated image as base64 ──────────────────────
    _, buffer       = cv2.imencode(".jpg", img, [cv2.IMWRITE_JPEG_QUALITY, 85])
    annotated_b64   = base64.b64encode(buffer).decode("utf-8")

    return {
        "detections":       detections,
        "threat_level":     threat,
        "recommended_action": action,
        "annotated_image":  annotated_b64,
    }
