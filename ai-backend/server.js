import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';

import aiRoutes from './src/routes/ai.js';
import designRoutes from './src/routes/designs.js';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json({ limit: '20mb' }));

app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    data: {
      service: 'Aurix AI Backend',
      status: 'ok',
      timestamp: new Date().toISOString(),
    },
  });
});

app.use('/api/ai', aiRoutes);
app.use('/api/designs', designRoutes);

const PORT = Number(process.env.PORT || 7001);

app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('========================================');
  console.log('||      AURIX AI BACKEND RUNNING      ||');
  console.log('========================================');
  console.log(` Server: http://localhost:${PORT}`);
  console.log(' Endpoints: /api/ai , /api/designs');
  console.log('========================================');
  console.log('');
});
