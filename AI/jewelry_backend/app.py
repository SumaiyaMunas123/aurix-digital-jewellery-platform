from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import requests
import base64
import os

load_dotenv()

app = Flask(__name__)
CORS(app)

HF_TOKEN = os.getenv("HF_TOKEN")
if not HF_TOKEN:
    print("❌ ERROR: HF_TOKEN not found in .env file!")
    exit(1)

HF_URL = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"
HEADERS = {"Authorization": f"Bearer {HF_TOKEN}"}

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/generate", methods=["POST"])
def generate():
    data = request.get_json()
    if not data or not data.get("prompt", "").strip():
        return jsonify({"success": False, "error": "prompt is required"}), 400
    prompt = data["prompt"].strip()
    full_prompt = f"professional jewelry photography, {prompt}, studio lighting, white background, 8k, photorealistic"
    payload = {"inputs": full_prompt, "parameters": {"num_inference_steps": 30, "guidance_scale": 7.5, "width": 512, "height": 512}}
    try:
        print(f"Generating: {prompt[:60]}...")
        response = requests.post(HF_URL, headers=HEADERS, json=payload, timeout=120)
        if response.status_code == 200:
            image_base64 = base64.b64encode(response.content).decode("utf-8")
            print("Image generated successfully")
            return jsonify({"success": True, "image_base64": image_base64}), 200
        elif response.status_code == 503:
            return jsonify({"success": False, "error": "Model is loading, wait 30 seconds and try again"}), 503
        else:
            error = response.json().get("error", "Unknown error")
            return jsonify({"success": False, "error": error}), 500
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    print("💎 Jewelry AI Backend Starting...")
    print("📡 Running on http://0.0.0.0:7000")
    print("✅ Test: http://localhost:7000/health")
    app.run(host="0.0.0.0", port=7000, debug=True)
