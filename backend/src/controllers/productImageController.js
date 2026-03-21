import { supabase } from '../config/supabaseClient.js';

const BUCKET = 'product-images';

// ==================== ADD IMAGE ====================
// Called after the frontend uploads the file directly to Supabase Storage.
// Body: { url, storage_path, is_primary, sort_order }
export const addProductImage = async (req, res) => {
  try {
    const { id: product_id } = req.params;
    const { url, storage_path, is_primary = false, sort_order = 0 } = req.body;

    if (!url || !storage_path) {
      return res.status(400).json({ success: false, message: 'url and storage_path are required' });
    }

    // Verify product belongs to this jeweller
    const { data: product, error: fetchError } = await supabase
      .from('products')
      .select('id, jeweller_id')
      .eq('id', product_id)
      .single();

    if (fetchError || !product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    if (req.user.role === 'jeweller' && product.jeweller_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'You can only add images to your own products' });
    }

    const { data: image, error } = await supabase
      .from('product_images')
      .insert([{
        product_id,
        jeweller_id: product.jeweller_id,
        url,
        storage_path,
        is_primary,
        sort_order,
      }])
      .select()
      .single();

    if (error) throw error;

    return res.status(201).json({
      success: true,
      message: 'Image added successfully',
      image,
    });

  } catch (error) {
    console.error('addProductImage error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== GET IMAGES FOR A PRODUCT ====================
export const getProductImages = async (req, res) => {
  try {
    const { id: product_id } = req.params;

    const { data: images, error } = await supabase
      .from('product_images')
      .select('*')
      .eq('product_id', product_id)
      .order('is_primary', { ascending: false })
      .order('sort_order', { ascending: true });

    if (error) throw error;

    return res.status(200).json({ success: true, images: images || [] });

  } catch (error) {
    console.error('getProductImages error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== SET PRIMARY IMAGE ====================
export const setPrimaryImage = async (req, res) => {
  try {
    const { id: product_id, image_id } = req.params;

    const { data: image, error: fetchError } = await supabase
      .from('product_images')
      .select('id, jeweller_id')
      .eq('id', image_id)
      .eq('product_id', product_id)
      .single();

    if (fetchError || !image) {
      return res.status(404).json({ success: false, message: 'Image not found' });
    }

    if (req.user.role === 'jeweller' && image.jeweller_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'You can only update your own images' });
    }

    const { data: updated, error } = await supabase
      .from('product_images')
      .update({ is_primary: true })
      .eq('id', image_id)
      .select()
      .single();

    if (error) throw error;

    return res.status(200).json({ success: true, message: 'Primary image updated', image: updated });

  } catch (error) {
    console.error('setPrimaryImage error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// ==================== DELETE IMAGE ====================
// Deletes both the DB row and the file from Supabase Storage.
export const deleteProductImage = async (req, res) => {
  try {
    const { id: product_id, image_id } = req.params;

    const { data: image, error: fetchError } = await supabase
      .from('product_images')
      .select('id, jeweller_id, storage_path, is_primary')
      .eq('id', image_id)
      .eq('product_id', product_id)
      .single();

    if (fetchError || !image) {
      return res.status(404).json({ success: false, message: 'Image not found' });
    }

    if (req.user.role === 'jeweller' && image.jeweller_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'You can only delete your own images' });
    }

    // Delete DB row first — trigger will update products.primary_image_url
    const { error: dbError } = await supabase
      .from('product_images')
      .delete()
      .eq('id', image_id);

    if (dbError) throw dbError;

    // Delete the actual file from Storage
    const { error: storageError } = await supabase.storage
      .from(BUCKET)
      .remove([image.storage_path]);

    if (storageError) {
      // Log but don't fail — DB row is already gone
      console.warn('Storage delete warning:', storageError.message);
    }

    return res.status(200).json({ success: true, message: 'Image deleted successfully' });

  } catch (error) {
    console.error('deleteProductImage error:', error.message);
    return res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};