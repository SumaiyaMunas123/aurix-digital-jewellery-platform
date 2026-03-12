// AI Controller - Hugging Face Image Generation

const HF_URL = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0";

// POST /api/ai/generate
export const generateImage = async (req, res) => {
  const HF_TOKEN = process.env.HF_TOKEN;

  if (!HF_TOKEN) {
    console.error('❌ HF_TOKEN not set in .env');
    return res.status(500).json({
      success: false,
      error: 'AI service not configured. HF_TOKEN missing from .env'
    });
  }

  try {
    const { prompt } = req.body;

    if (!prompt || !prompt.trim()) {
      return res.status(400).json({
        success: false,
        error: 'prompt is required'
      });
    }

    const cleanPrompt = prompt.trim();
    const fullPrompt = `professional jewelry photography, ${cleanPrompt}, studio lighting, white background, 8k, photorealistic`;

    console.log(`💎 Generating image for: "${cleanPrompt.substring(0, 60)}..."`);

    const response = await fetch(HF_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${HF_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: fullPrompt,
        parameters: {
          num_inference_steps: 30,
          guidance_scale: 7.5,
          width: 512,
          height: 512,
        }
      }),
    });

    if (response.ok) {
      // Hugging Face returns raw image bytes on success
      const arrayBuffer = await response.arrayBuffer();
      const base64Image = Buffer.from(arrayBuffer).toString('base64');

      console.log('✅ Image generated successfully');
      return res.json({
        success: true,
        image_base64: base64Image,
      });
    }

    if (response.status === 503) {
      const data = await response.json().catch(() => ({}));
      const estimatedTime = data.estimated_time ? Math.ceil(data.estimated_time) : 30;
      console.log(`⏳ Model loading, estimated ${estimatedTime}s`);
      return res.status(503).json({
        success: false,
        error: `Model is loading. Please wait ${estimatedTime} seconds and try again.`,
      });
    }

    // Other error
    const errorData = await response.json().catch(() => ({}));
    const errorMsg = errorData.error || `Hugging Face API error (${response.status})`;
    console.error('❌ HF API error:', errorMsg);
    return res.status(500).json({
      success: false,
      error: errorMsg,
    });

  } catch (err) {
    console.error('❌ AI generation error:', err.message);
    return res.status(500).json({
      success: false,
      error: 'Server error: ' + err.message,
    });
  }
};

// GET /api/ai/health
export const healthCheck = (req, res) => {
  const hasToken = !!process.env.HF_TOKEN;
  res.json({
    status: hasToken ? 'ok' : 'misconfigured',
    service: 'Aurix AI Image Generation',
    model: 'stabilityai/stable-diffusion-xl-base-1.0',
    hf_token_set: hasToken,
  });
};
