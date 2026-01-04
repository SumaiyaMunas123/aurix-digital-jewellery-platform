import bcrypt from 'bcrypt';
import { supabase } from '../config/supabase.js';

// ==================== SIGNUP ====================
export const signup = async (req, res) => {
  try {
    console.log('📝 Signup request received');
    
    // Get data from request body
    const { email, password, name, role } = req.body;

    // Step 1: Check if all fields provided
    if (!email || !password || !name || !role) {
      console.log('❌ Missing fields');
      return res.status(400).json({
        success: false,
        message: 'Please provide email, password, name, and role'
      });
    }

    // Step 2: Check if role is valid
    if (role !== 'customer' && role !== 'jeweller') {
      console.log('❌ Invalid role:', role);
      return res.status(400).json({
        success: false,
        message: 'Role must be either "customer" or "jeweller"'
      });
    }

    // Step 3: Check if email already exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('email')
      .eq('email', email)
      .single();

    if (existingUser) {
      console.log('❌ Email already exists:', email);
      return res.status(400).json({
        success: false,
        message: 'Email already registered'
      });
    }

    // Step 4: Hash the password
    console.log('🔐 Hashing password...');
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Step 5: Save user to database
    console.log('💾 Saving user to database...');
    const { data: newUser, error } = await supabase
      .from('users')
      .insert([
        {
          email: email,
          password: hashedPassword,
          name: name,
          role: role,
          verified: role === 'customer' ? true : false  // Customers auto-verified, jewellers need admin approval
        }
      ])
      .select()
      .single();

    if (error) {
      console.error('❌ Database error:', error);
      throw error;
    }

    console.log('✅ User created successfully:', newUser.email);

    // Step 6: Send success response (don't send password back!)
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      user: {
        id: newUser.id,
        email: newUser.email,
        name: newUser.name,
        role: newUser.role,
        verified: newUser.verified
      }
    });

  } catch (error) {
    console.error('❌ Signup error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during signup',
      error: error.message
    });
  }
};
// ==================== LOGIN ====================
export const login = async (req, res) => {
  try {
    console.log('🔐 Login request received');
    
    // Get data from request body
    const { email, password } = req.body;

    // Step 1: Check if email and password provided
    if (!email || !password) {
      console.log('❌ Missing email or password');
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Step 2: Find user in database
    console.log('🔍 Looking for user:', email);
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error || !user) {
      console.log('❌ User not found:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Step 3: Compare password with hashed password
    console.log('🔐 Checking password...');
    const passwordMatch = await bcrypt.compare(password, user.password);

    if (!passwordMatch) {
      console.log('❌ Password incorrect for:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Step 4: Check if jeweller is verified
    if (user.role === 'jeweller' && !user.verified) {
      console.log('⚠️ Jeweller not verified yet:', email);
      return res.status(403).json({
        success: false,
        message: 'Your account is pending admin approval'
      });
    }

    console.log('✅ Login successful:', user.email);

    // Step 5: Send success response (don't send password!)
    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        verified: user.verified,
        phone: user.phone
      },
      token: 'dummy_token_' + user.id  // For now, just a dummy token
    });

  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login',
      error: error.message
    });
  }
};