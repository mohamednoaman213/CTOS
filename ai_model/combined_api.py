from fastapi import FastAPI, File, UploadFile
from ultralytics import YOLO
import shutil

app = FastAPI()

@app.get("/")
def home():
    return {"message":"AI Threat Detection API Running"}

# Load models
fire_model = YOLO("models/fire_model.pt")
weapon_model = YOLO("models/weapon_model.pt")


@app.post("/detect")
async def detect(file: UploadFile = File(...)):

    file_path = f"temp/{file.filename}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    detections=[]

    # Fire Detection
    fire_results = fire_model(file_path)

    for box in fire_results[0].boxes:

        cls = int(box.cls[0])
        conf = float(box.conf[0])

        label = fire_results[0].names[cls]

        detections.append({
            "label": label,
            "confidence": round(conf,3)
        })


    # Weapon Detection
    weapon_results = weapon_model(file_path)

    for box in weapon_results[0].boxes:

        cls = int(box.cls[0])
        conf = float(box.conf[0])

        label = weapon_results[0].names[cls]

        # ONLY keep threats
        if label in ["pistol","knife"]:

            detections.append({
                "label":label,
                "confidence":round(conf,3)
            })


    # Threat level logic
    threat="NO THREAT DETECTED"

    labels=[d["label"] for d in detections]

    if "fire" in labels:
        threat="HIGH"

    if "pistol" in labels or "knife" in labels:
        threat="HIGH"

    if ("fire" in labels) and ("pistol" in labels or "knife" in labels):
        threat="CRITICAL"


    # Action logic
    action="No action required"

    if threat=="HIGH":
        action="Alert Fire Department"

    elif threat=="CRITICAL":
        action="Immediate emergency dispatch"


    return {
        "detections": detections,
        "threat_level": threat,
        "recommended_action": action
    }
