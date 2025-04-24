// middleware/authMiddleware.js

const jwt = require("jsonwebtoken");

const authenticateToken = (req, res, next) => {
  const token = req.headers["authorization"];

  if (!token) {
    return res.status(401).json({ message: "No token provided" });
  }

  // Assuming the token is sent as "Bearer <token>"
  const tokenWithoutBearer = token.split(" ")[1];  // Get token after "Bearer"

  if (!tokenWithoutBearer) {
    return res.status(401).json({ message: "Invalid token format" });
  }

  jwt.verify(tokenWithoutBearer, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      console.log("❌ Token verification failed:", err.message);
      return res.status(403).json({ message: "Token is not valid" });
    }

    req.user = decoded;  // Attach user info to req
    next();  // Proceed to the next middleware/route handler
  });
};

module.exports = authenticateToken;
