const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');

dotenv.config();

// Dummy user data (replace with database logic in real scenarios)
const users = [
  {
    email: 'user@example.com',
    password: '$2a$12$Je3NBMzT5ytvIBMQxYxdVOTtq/6sP9ArC1Vk07yMsaZVoHCnUF23O', // Password: "Password@123"
  },
];

// Login function
exports.login = (req, res) => {
  const { email, password } = req.body;

  // Check if email and password are provided
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and Password are required' });
  }

  // Find the user
  const user = users.find((u) => u.email === email);

  // If user is not found
  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  // Check the password using bcrypt compare
  bcrypt.compare(password, user.password, (err, result) => {
    if (err || !result) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate JWT token if credentials are correct
    const token = jwt.sign({ email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });

    return res.status(200).json({ message: 'Login successful', token });
  });
};
