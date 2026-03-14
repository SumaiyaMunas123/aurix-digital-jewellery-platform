import { supabase } from '../config/supabaseClient.js';

const DESIGN_BUCKET = 'designs';

export const toSafeFileSegment = (value) =>
  String(value || 'unknown')
    .replace(/[^a-zA-Z0-9-_]/g, '-')
    .replace(/-+/g, '-')
    .toLowerCase();

export const parseBase64Image = (value) => {
  if (!value || typeof value !== 'string') return null;
  const clean = value.includes(',') ? value.split(',')[1] : value;
  try {
    return Buffer.from(clean, 'base64');
  } catch {
    return null;
  }
};

export const uploadBufferToDesigns = async ({ path, buffer, contentType = 'image/png' }) => {
  const { error } = await supabase.storage.from(DESIGN_BUCKET).upload(path, buffer, {
    contentType,
    upsert: false,
  });

  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }

  const { data } = supabase.storage.from(DESIGN_BUCKET).getPublicUrl(path);
  return {
    path,
    publicUrl: data.publicUrl,
  };
};

export const extractDesignStoragePath = (publicUrl) => {
  if (!publicUrl) return null;
  const marker = '/storage/v1/object/public/designs/';
  const idx = publicUrl.indexOf(marker);
  if (idx === -1) return null;
  return decodeURIComponent(publicUrl.substring(idx + marker.length));
};

export const removeDesignObjects = async (urls = []) => {
  const paths = urls
    .map((u) => extractDesignStoragePath(u))
    .filter(Boolean);

  if (!paths.length) return;

  const { error } = await supabase.storage.from(DESIGN_BUCKET).remove(paths);
  if (error) {
    throw new Error(`Storage remove failed: ${error.message}`);
  }
};
