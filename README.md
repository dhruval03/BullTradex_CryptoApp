# 🚀 BullTradex

**BullTradex** is a full-stack cryptocurrency market tracking and trading app built using **Flutter** for the frontend and **Node.js with Express** for the backend. It integrates real-time crypto data using the **CoinMarketCap API** and provides a sleek, user-friendly UI for exploring market trends, managing watchlists, and updating profiles.

---

## 📱 Frontend – Flutter

### Features
- 🟣 **Splash & Welcome Screens** with onboarding state tracking using SharedPreferences.
- 🔐 **Authentication System**
  - Login/Register with JWT
  - Secure token storage
  - Persistent session handling
- 📈 **Market View**
  - Real-time coin data via CoinMarketCap API
  - Tap on coins to view detailed charts and information
- 🧑 **Profile Management**
  - Update name, email, password
  - View current profile data
- 📂 **Watchlist**
  - Add/remove coins to personal watchlist (WIP)
- 🌙 **Dark & Light Themes** with SharedPreferences + Riverpod
- ⬅️ **Navigation**
  - Managed by a `NavigationProvider`
  - Bottom navigation bar for primary screens
---

## 🌐 Backend – Node.js (Express + PostgreSQL)

### Features
- 🧾 **User Registration & Login**
  - Passwords securely hashed with bcrypt
  - JWT-based authentication
- 🛡️ **Protected Routes**
  - Middleware verifies JWT and attaches `userId` to requests
- 👤 **Profile Management**
  - Get/Update user profile (excluding password)
  - Secure password updates

### Key Routes
| Method | Endpoint            | Description                     |
|--------|---------------------|---------------------------------|
| POST   | `/api/register`     | Register new user               |
| POST   | `/api/login`        | Authenticate & receive token    |
| GET    | `/api/profile`      | Get current user profile        |
| PUT    | `/api/profile`      | Update profile info/password    |

---

## 🔐 Authentication Flow

- User registers or logs in → token received → stored in SharedPreferences
- On app start, Splash Screen checks `AuthService.isAuthenticated()`
- If valid token, user is routed to home; otherwise, to login/welcome

---

## 🔧 Tech Stack

### Frontend
- **Flutter**
- **Riverpod** – State Management
- **SharedPreferences** – Local Storage
- **Material Design** – Clean and intuitive UI

### Backend
- **Node.js + Express**
- **PostgreSQL**
- **JWT** – Authentication
- **bcrypt** – Password Hashing
- **dotenv** – Environment Variables

---

## 📦 API Integration

- **CoinMarketCap API**
  - Live market data
  - Coin listings & detailed info
  - Implemented with async calls in the `MarketScreen`

---

## 🚀 Getting Started

### Frontend
```bash
cd frontend
flutter pub get
flutter run
