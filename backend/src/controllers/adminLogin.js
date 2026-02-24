import supabase from "../config/supabaseClient.js"; 

export const adminLogin = async (req, res) => {
  try {
    console.log('Admin login request received');
    const { email, password } = req.body;   

    if (!email || !password) {
      console.log('Missing email or password');
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    //  DUMMY ADMIN 
    if (email === "admin@test.com" && password === "123456") {
      console.log("Dummy admin login successful");

      return res.status(200).json({
        success: true,
        message: "Admin login successful (Dummy)",
        user: {
          id: "dummy-id-001",
          email: "admin@test.com",
          name: "Test Admin",
          role: "admin"
        }
      });
    }

    //Database check
    const { data: admin, error } = await supabase
      .from('users')
      .select('id, email, name, role')
      .eq('email', email)
      .single();    

    if (error || !admin) {
      console.log('Admin not found:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    if (admin.role !== 'admin') {
      console.log('User is not an admin:', email);
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }  

    return res.status(200).json({
      success: true,
      message: 'Admin login successful',
      user: {
        id: admin.id,
        email: admin.email,
        name: admin.name,
        role: admin.role
      }
    });

  } catch (error) {
    console.error('Error during admin login:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during admin login',
      error: error.message
    });
  }
};