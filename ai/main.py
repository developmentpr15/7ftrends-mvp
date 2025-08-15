from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict
import base64
import numpy as np
from PIL import Image
import torch
from detectron2.engine import DefaultPredictor
from detectron2.config import get_cfg
from detectron2.data import MetadataCatalog
from detectron2.utils.visualizer import Visualizer

app = FastAPI()

# Initialize Detectron2 model
cfg = get_cfg()
cfg.merge_from_file("detectron2/configs/COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x.yaml")
cfg.MODEL.WEIGHTS = "detectron2://COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x/137849600/model_final_f10217.pkl"
cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.5
cfg.MODEL.DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
predictor = DefaultPredictor(cfg)

class GarmentRequest(BaseModel):
    image: str

class GarmentResponse(BaseModel):
    mask: str
    texture: str
    uv: str

@app.post("/extract-garment", response_model=GarmentResponse)
def extract_garment(request: GarmentRequest):
    try:
        # Decode the base64 image
        image_data = base64.b64decode(request.image)
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
        image_np = np.array(image)

        # Run Detectron2 prediction
        outputs = predictor(image_np)
        masks = outputs["instances"].pred_masks.cpu().numpy()

        if len(masks) == 0:
            raise HTTPException(status_code=400, detail="No garments detected.")

        # Use the first detected mask
        mask = masks[0]
        mask_image = Image.fromarray((mask * 255).astype(np.uint8))

        # Generate UV texture (placeholder logic)
        uv_texture = np.zeros((512, 512, 3), dtype=np.uint8)
        uv_image = Image.fromarray(uv_texture)

        # Encode results to base64
        mask_base64 = base64.b64encode(mask_image.tobytes()).decode("utf-8")
        uv_base64 = base64.b64encode(uv_image.tobytes()).decode("utf-8")

        return GarmentResponse(mask=mask_base64, texture=mask_base64, uv=uv_base64)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
