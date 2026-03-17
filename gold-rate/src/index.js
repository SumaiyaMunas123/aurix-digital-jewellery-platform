import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import goldRateRoutes from './routes/goldRate.js';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

// API routes
app.use('/api/gold-rate', goldRateRoutes);

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Aurix gold rate service is running',
    timestamp: new Date().toISOString(),
    endpoints: {
      goldRate: '/api/gold-rate',
    },
  });
});

const PORT = process.env.PORT || 6000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Gold rate service listening on http://localhost:${PORT}`);
});
