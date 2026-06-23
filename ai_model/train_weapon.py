from ultralytics import YOLO

model = YOLO("yolov8n.pt")

model.train(
    data="weapon_data.yaml",
    epochs=20,
    imgsz=640
)   