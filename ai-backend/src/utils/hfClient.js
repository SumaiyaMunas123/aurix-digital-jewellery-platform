const HF_URL = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';

export const buildBaseJewelryPrompt = (prompt) =>
  `professional jewelry photography, ${prompt}, studio lighting, white background, 8k, photorealistic`;

export const generateImageWithHuggingFace = async (fullPrompt) => {
  const HF_TOKEN = process.env.HF_TOKEN;

  if (!HF_TOKEN) {
    const error = new Error('AI service not configured. HF_TOKEN missing from .env');
    error.statusCode = 500;
    throw error;
  }

  const response = await fetch(HF_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${HF_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      inputs: fullPrompt,
      parameters: {
        num_inference_steps: 30,
        guidance_scale: 7.5,
        width: 512,
        height: 512,
      },
    }),
  });

  if (response.ok) {
    const arrayBuffer = await response.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    return {
      buffer,
      imageBase64: buffer.toString('base64'),
    };
  }

  if (response.status === 503) {
    const data = await response.json().catch(() => ({}));
    const estimatedTime = data.estimated_time ? Math.ceil(data.estimated_time) : 30;
    const error = new Error(`Model is loading. Please wait ${estimatedTime} seconds and try again.`);
    error.statusCode = 503;
    throw error;
  }

  const errorData = await response.json().catch(() => ({}));
  const error = new Error(errorData.error || `Hugging Face API error (${response.status})`);
  error.statusCode = 500;
  throw error;
};
