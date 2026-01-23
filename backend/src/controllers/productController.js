import { supabase } from '../config/supabase.js';

// ==================== ADD PRODUCT (CREATE) ====================
export const addProduct = async (req, res) => {
  try {
    console.log('📦 Add product request received');
    
    // Get data from request body
    const { 
      jeweller_id, 
      name, 
      description, 
      price, 
      image_url,
      category,
      karat,
      weight,
      stock_quantity 
    } = req.body;

    // Validate required fields
    if (!jeweller_id || !name || !description || !price) {
      console.log('Missing required fields');
      return res.status(400).json({
        success: false,
        message: 'Please provide jeweller_id, name, description, and price'
      });
    }

    // Check if jeweller exists
    const { data: jeweller, error: jewellerError } = await supabase
      .from('users')
      .select('id, role')
      .eq('id', jeweller_id)
      .single();

    if (jewellerError || !jeweller) {
      console.log('Jeweller not found');
      return res.status(404).json({
        success: false,
        message: 'Jeweller not found'
      });
    }

    if (jeweller.role !== 'jeweller') {
      console.log('User is not a jeweller');
      return res.status(403).json({
        success: false,
        message: 'Only jewellers can add products'
      });
    }

    // Insert product into database
    console.log('Saving product to database');
    const { data: newProduct, error } = await supabase
      .from('products')
      .insert([
        {
          jeweller_id,
          name,
          description,
          price,
          image_url: image_url || null,
          category: category || null,
          karat: karat || null,
          weight: weight || null,
          stock_quantity: stock_quantity || 1
        }
      ])
      .select()
      .single();

    if (error) {
      console.error('Database error:', error);
      throw error;
    }

    console.log('Product added successfully:', newProduct.name);

    res.status(201).json({
      success: true,
      message: 'Product added successfully',
      product: newProduct
    });

  } catch (error) {
    console.error('Add product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while adding product',
      error: error.message
    });
  }
};

// ==================== GET ALL PRODUCTS (READ) ====================
export const getAllProducts = async (req, res) => {
  try {
    console.log('Get all products request');

    // Get all products from database
    const { data: products, error } = await supabase
      .from('products')
      .select(`
        *,
        users:jeweller_id (
          id,
          name,
          email
        )
      `)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Database error:', error);
      throw error;
    }

    console.log(`Found ${products.length} products`);

    res.status(200).json({
      success: true,
      count: products.length,
      products: products
    });

  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching products',
      error: error.message
    });
  }
};

// ==================== GET SINGLE PRODUCT (READ ONE) ====================
export const getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Get product by ID:', id);

    // Get single product from database
    const { data: product, error } = await supabase
      .from('products')
      .select(`
        *,
        users:jeweller_id (
          id,
          name,
          email,
          phone
        )
      `)
      .eq('id', id)
      .single();

    if (error || !product) {
      console.log('Product not found');
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    console.log('Product found:', product.name);

    res.status(200).json({
      success: true,
      product: product
    });

  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching product',
      error: error.message
    });
  }
};

// ==================== UPDATE PRODUCT ====================
export const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Update product request for ID:', id);

    const { 
      name, 
      description, 
      price, 
      image_url,
      category,
      karat,
      weight,
      stock_quantity 
    } = req.body;

    // Check if product exists
    const { data: existingProduct, error: fetchError } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError || !existingProduct) {
      console.log('Product not found');
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Update product
    console.log('Updating product...');
    const { data: updatedProduct, error } = await supabase
      .from('products')
      .update({
        name: name || existingProduct.name,
        description: description || existingProduct.description,
        price: price || existingProduct.price,
        image_url: image_url !== undefined ? image_url : existingProduct.image_url,
        category: category !== undefined ? category : existingProduct.category,
        karat: karat !== undefined ? karat : existingProduct.karat,
        weight: weight !== undefined ? weight : existingProduct.weight,
        stock_quantity: stock_quantity !== undefined ? stock_quantity : existingProduct.stock_quantity,
        updated_at: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      console.error('Update error:', error);
      throw error;
    }

    console.log('Product updated successfully');

    res.status(200).json({
      success: true,
      message: 'Product updated successfully',
      product: updatedProduct
    });

  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating product',
      error: error.message
    });
  }
};

// ==================== DELETE PRODUCT ====================
export const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Delete product request for ID:', id);

    // Check if product exists
    const { data: existingProduct, error: fetchError } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError || !existingProduct) {
      console.log('Product not found');
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Delete product
    console.log('Deleting product');
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('Delete error:', error);
      throw error;
    }

    console.log('Product deleted successfully');

    res.status(200).json({
      success: true,
      message: 'Product deleted successfully'
    });

  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting product',
      error: error.message
    });
  }
};