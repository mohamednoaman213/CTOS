from ultralytics import YOLO

# Load trained model
model = YOLO("runs/detect/train-12/weights/best.pt")

# Run prediction
results = model("ahmew.jpeg")

# Show image with detections
results[0].show()

# Save result image
results[0].save(filename="result.jpg")

print(results)