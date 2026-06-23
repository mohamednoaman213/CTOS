from ultralytics import YOLO

# Load pretrained YOLOv8 model
model = YOLO("yolov8n.pt")

# Train model
model.train(
    data="data.yaml",
    epochs=20,
    imgsz=640
)