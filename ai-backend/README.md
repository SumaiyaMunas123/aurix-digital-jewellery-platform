# Aurix AI Backend

Standalone AI service for Aurix. This is intentionally outside the `backend/` folder.

## Features

- `POST /api/ai/generate` text-to-image via Hugging Face SDXL
- `POST /api/ai/chat` and `POST /api/ai/suggestions` via Groq
- `GET /api/designs`, `GET /api/designs/:id`, `DELETE /api/designs/:id`
- `PATCH /api/designs/:id/favorite`
- `POST /api/designs/generate-styled`
- `POST /api/designs/sketch-to-image`
- Saves generated files in Supabase Storage bucket: `designs`
- Saves metadata in Supabase `designs` table

## Setup

1. Copy `.env.example` to `.env`
2. Add values for:
   - `HF_TOKEN`
   - `GROQ_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY` (recommended)
3. Run SQL in `sql/001_create_designs.sql`
4. Install and run:

```bash
cd ai-backend
npm install
npm start
```

Default port is `7000`.
