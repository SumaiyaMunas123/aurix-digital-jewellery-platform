import { supabase } from "../config/supabaseClient.js";

export const adminLogin = async (req, res) => {
  try {
    console.log('---------------------------------------');
    console.log('Admin login request received');
    console.log('Request Body:', req.body);

    const { email, password } = req.body;

    if (!email || !password) {
      console.log('Missing email or password');
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password',
      });
    }

    const { data: authData, error: authError } =
      await supabase.auth.signInWithPassword({
        email,
        password,
      });

    console.log('Auth Data:', authData);
    console.log('Auth Error:', authError);

    if (authError || !authData?.user) {
      console.log('Authentication failed');
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    console.log('Authentication successful');
    console.log('User ID:', authData.user.id);


    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('id, email, role, name')
      .eq('id', authData.user.id)
      .single();

    console.log('Profile Data:', profile);
    console.log('Profile Error:', profileError);

    if (profileError || !profile) {
      console.log('Profile not found in profiles table');
      return res.status(404).json({
        success: false,
        message: 'Profile not found',
      });
    }

    if (profile.role !== 'admin') {
      console.log('User is not admin. Role:', profile.role);
      return res.status(403).json({
        success: false,
        message: 'Access denied. Not an admin.',
      });
    }

    console.log('Admin login successful');
    console.log('---------------------------------------');

    return res.status(200).json({
      success: true,
      message: 'Admin login successful',
      user: profile,
    });

  } catch (error) {
    console.error('Server error during admin login:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during admin login',
      error: error.message,
    });
  }
};