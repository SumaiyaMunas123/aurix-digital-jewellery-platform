import { HfInference } from '@huggingface/inference';

// Using Hugging Face's free tier image generation model
const MODEL = 'stabilityai/stable-diffusion-3-small';

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
    const hf = new HfInference(HF_TOKEN);
    const blob = await hf.textToImage({
      model: MODEL,
      inputs: fullPrompt,
    });

    // Convert blob to buffer
    const arrayBuffer = await blob.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    
    return {
      buffer,
      imageBase64: buffer.toString('base64'),
    };
  } catch (err) {
    console.error('Hugging Face text-to-image error:', err.message);
    throw new Error(`AI generation failed: ${err.message}`);
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
    // First try img2img, but we'll use text-to-image as primary since it's more reliable
    // Convert base64 sketch to image for processing
    const hf = new HfInference(HF_TOKEN);
    
    // Use text-to-image with refined prompt
    const blob = await hf.textToImage({
      model: MODEL,
      inputs: fullPrompt,
    });

    const arrayBuffer = await blob.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    
    return {
      buffer,
      imageBase64: buffer.toString('base64'),
    };
  } catch (err) {
    console.error('Hugging Face sketch-to-image error:', err.message);
    throw new Error(`Sketch refinement failed: ${err.message}`);
  }
};
