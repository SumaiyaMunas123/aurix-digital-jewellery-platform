// Import Express framework to create the backend server
import express from 'express';

// Import CORS middleware to allow requests from frontend apps
import cors from 'cors';

// Import dotenv to load environment variables from .env file
import dotenv from 'dotenv';

// supabase 
import { supabase } from './config/supabase.js';

// Load environment variables into process.env
dotenv.config();

// Create an Express application instance
const app = express();

// Enable CORS for all incoming requests
// This allows Flutter apps and admin panel to access APIs
app.use(cors());

// Enable JSON body parsing
// This allows the server to read JSON data sent in requests
app.use(express.json());

// Basic test route to check if backend is running
app.get('/test-db', async (req, res) => {
    console.log("Test DB route hit");
  const { data, error } = await supabase
    .from('users')
    .select('*');

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.json({ message: 'DB connected', data });
});

// Access: http://localhost:5000/
app.get('/', (req, res) => {
  res.send('Aurix Backend is running');
});

// Set server port from environment variable or default to 5000
const PORT = process.env.PORT || 5000;

// Start the server and listen for incoming requests
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
