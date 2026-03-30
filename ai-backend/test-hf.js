import 'dotenv/config';
import { HfInference } from '@huggingface/inference';

async function testHF() {
  try {
    const token = process.env.HF_TOKEN;
    if (!token) throw new Error('HF_TOKEN is missing from .env file');
    
    const hf = new HfInference(token);
    console.log('Testing HF token...');
    const result = await hf.textToImage({
      model: 'stabilityai/stable-diffusion-xl-base-1.0',
      inputs: 'A diamond ring',
    });
    console.log('Success! Got blob size:', result.size);
  } catch (err) {
    console.error('Error:', err.message);
  }
}

testHF();