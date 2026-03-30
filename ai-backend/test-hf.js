import { HfInference } from '@huggingface/inference';

async function testHF() {
  try {
    const hf = new HfInference('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');
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