from fastapi import FastAPI, File, UploadFile
from ultralytics import YOLO
import shutil

app = FastAPI()

# Load model once
model = YOLO("runs/detect/train-5/weights/best.pt")


@app.get("/")
def home():
    return {"message": "AI Threat Detection API Running"}


@app.post("/detect")
async def detect(file: UploadFile = File(...)):

    # Save uploaded image
    file_path = f"temp/{file.filename}"

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Run YOLO
    results = model(file_path)

    detections = []

    for box in results[0].boxes:
        cls = int(box.cls[0])
        conf = float(box.conf[0])

        label = results[0].names[cls]

        detections.append({
            "label": label,
            "confidence": conf
        })

    return {
        "detections": detections
    }

#