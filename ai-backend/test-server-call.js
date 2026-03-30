import jwt from 'jsonwebtoken';

async function testApi() {
  const token = jwt.sign(
    { sub: 'test-user-id', role: 'customer', email: 'test@example.com' },
    'aurix_prod_jwt_2026_4f2e9a1b7c3d8e6f91a24b7cde9832af'
  );

  const fetch = (await import('node-fetch')).default;
  const FormData = (await import('form-data')).default;

  const form = new FormData();
  form.append('mode', '0');
  form.append('prompt', 'Ruby necklace');
  form.append('user_type', 'customer');

  try {
    const response = await fetch('http://localhost:7000/api/ai/generate', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: form
    });
    const data = await response.json();
    console.log(data);
  } catch (err) {
    console.error('Fetch error:', err.message);
  }
}

testApi();