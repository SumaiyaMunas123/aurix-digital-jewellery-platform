const HF_URL = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';
const HF_IMG2IMG_URL = 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-refiner-1.0';

export const buildBaseJewelryPrompt = (prompt, styleContext = '') =>
  `professional jewelry photography, ${prompt}${styleContext ? `, ${styleContext}` : ''}, studio lighting, white background, 8k, photorealistic, high quality, detailed`;

export const generateImageWithHuggingFace = async (fullPrompt) => {
  const HF_TOKEN = process.env.HF_TOKEN;

  if (!HF_TOKEN) {
    const error = new Error('AI service not configured. HF_TOKEN missing from .env');
    error.statusCode = 500;
    throw error;
  }

  try {
    const response = await fetch(HF_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${HF_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: fullPrompt,
        parameters: {
          num_inference_steps: 35,
          guidance_scale: 7.5,
          width: 512,
          height: 512,
          negative_prompt: 'blurry, low quality, distorted, ugly',
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
  } catch (err) {
    console.error('Hugging Face text-to-image error:', err.message);
    throw err;
  }
};

export const generateImageFromSketch = async (sketchBase64, fullPrompt) => {
  const HF_TOKEN = process.env.HF_TOKEN;

  if (!HF_TOKEN) {
    const error = new Error('AI service not configured. HF_TOKEN missing from .env');
    error.statusCode = 500;
    throw error;
  }

  try {
    // Use img2img endpoint to refine sketch
    const response = await fetch(HF_IMG2IMG_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${HF_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: {
          image: sketchBase64,
          prompt: fullPrompt,
          negative_prompt: 'blurry, low quality, distorted, sketch, rough',
          num_inference_steps: 30,
          guidance_scale: 7.5,
          strength: 0.8, // How much to transform the sketch (0-1)
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

    // Fallback: if img2img fails, use text-to-image instead
    console.warn('⚠️ Sketch-to-image model not available, falling back to text-to-image refinement');
    return await generateImageWithHuggingFace(fullPrompt);
  } catch (err) {
    console.error('Hugging Face sketch-to-image error:', err.message);
    // Fallback to text-to-image
    console.log('📷 Falling back to text-to-image generation...');
    return await generateImageWithHuggingFace(fullPrompt);
  }
};
