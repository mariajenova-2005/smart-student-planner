# 📚 Student Planner Pro

A cross-platform academic planner app that helps students manage tasks, notes, deadlines and study schedules — built with Flutter and a real cloud backend powered by NeonDB.

---

## 📱 Platforms Supported

| Platform | Status |
|---|---|
| Android | ✅ Ready |
| Web (Chrome) | ✅ Ready |
| Windows Desktop | ✅ Ready |
| iOS | ✅ Code ready (needs Mac to build) |

---

## ✨ Features

- 🔐 Secure register and login with JWT authentication
- 📊 Smart dashboard with stats, progress bar and greeting
- ✅ Full task management — add, edit, delete, priority levels, categories
- ✔️ Done button on every task card — animates from Pending → Done instantly
- 🎯 Overdue badge and Completed badge on task cards
- 📅 Monthly calendar with task markers on due dates
- 📝 Subject-wise colour-coded notes
- 🔔 In-app notification bell with badge and full notification panel
- ⚙️ Notification settings — toggle alerts, set due-soon hours, upcoming days
- 🌙 Dark mode toggle that persists across restarts
- ☁️ All data synced to cloud — accessible from any device
- 👤 Profile management with name editing, password change and app info

---

## 🗂️ Project Structure

```
student_planner_pro/
├── backend/                    ← Node.js + Express REST API
│   ├── src/
│   │   ├── index.js            ← Server entry point
│   │   ├── db/
│   │   │   ├── index.js        ← NeonDB connection
│   │   │   └── migrate.js      ← Creates all database tables
│   │   ├── middleware/
│   │   │   └── auth.js         ← JWT token verification
│   │   └── routes/
│   │       ├── auth.js         ← Register / Login / Profile
│   │       ├── tasks.js        ← Task CRUD endpoints
│   │       └── notes.js        ← Notes CRUD endpoints
│   ├── package.json
│   └── .env.example
│
└── flutter_app/                ← Flutter cross-platform frontend
    └── lib/
        ├── main.dart
        ├── models/             ← TaskModel, NoteModel, UserModel
        ├── providers/          ← Auth, Task, Notes, Notification, Theme
        ├── screens/            ← All 8 app screens
        ├── services/
        │   ├── api_service.dart        ← All HTTP calls to backend
        │   └── notification_service.dart
        ├── utils/              ← Theme, Router, Constants
        └── widgets/            ← TaskCard, NotificationBell, MainShell
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter + Dart | Cross-platform UI |
| State Management | Provider | Reactive state |
| Navigation | go_router | URL-based routing |
| HTTP Client | http | API calls |
| Token Storage | flutter_secure_storage | Secure JWT storage |
| Backend | Node.js + Express | REST API server |
| Database | NeonDB (PostgreSQL) | Cloud data storage |
| Authentication | JWT + bcryptjs | Secure login |
| Notifications | flutter_local_notifications | Deadline reminders |

---

## 🌐 API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | /api/auth/register | No | Create new account |
| POST | /api/auth/login | No | Login and get JWT token |
| GET | /api/auth/me | Yes | Get current user info |
| PUT | /api/auth/profile | Yes | Update display name |
| GET | /api/tasks | Yes | Get all tasks |
| POST | /api/tasks | Yes | Create new task |
| PUT | /api/tasks/:id | Yes | Update task |
| PATCH | /api/tasks/:id/toggle | Yes | Toggle completed |
| DELETE | /api/tasks/:id | Yes | Delete task |
| GET | /api/notes | Yes | Get all notes |
| POST | /api/notes | Yes | Create new note |
| PUT | /api/notes/:id | Yes | Update note |
| DELETE | /api/notes/:id | Yes | Delete note |

---

## ⚙️ Setup Instructions

### Prerequisites
- [Node.js](https://nodejs.org) v18 or higher
- [Flutter](https://flutter.dev) 3.0 or higher
- A free [NeonDB](https://neon.tech) account

---

### Step 1 — Set Up Backend

```bash
cd backend
npm install
cp .env.example .env
```

Open `.env` and fill in your values:
```env
DATABASE_URL=postgresql://your-neondb-connection-string
JWT_SECRET=any-long-random-secret-string
PORT=3000
```

Create all database tables:
```bash
node src/db/migrate.js
```

Start the server:
```bash
npm run dev
```

Test it is working — open in browser:
```
http://localhost:3000/health
```
Expected: `{"status":"ok","message":"Student Planner Pro API is running"}`

---

### Step 2 — Set Up Flutter App

Open `flutter_app/lib/utils/app_constants.dart` and set the correct URL:

```dart
// Chrome / Web
static const String baseUrl = 'http://localhost:3000';

// Android emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// Real phone on same WiFi
static const String baseUrl = 'http://YOUR-PC-IP:3000';
```

Then run:
```bash
cd flutter_app
flutter create .
flutter pub get
flutter run -d chrome
```

---

### Step 3 — Deploy Backend Online (Railway)

To make the app work from anywhere without running a local server:

1. Push code to GitHub
2. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub repo
3. Set Root Directory to `backend`
4. Add environment variables: `DATABASE_URL`, `JWT_SECRET`, `NODE_ENV=production`
5. Deploy — you get a URL like `https://your-app.up.railway.app`
6. Update `flutter_app/lib/utils/app_constants.dart`:
   ```dart
   static const String baseUrl = 'https://your-app.up.railway.app';
   ```

---

## 🔒 Security Notes

- Passwords are hashed using **bcrypt** with a salt factor of 12
- Authentication uses **JWT tokens** with 30-day expiry
- Tokens are stored using **flutter_secure_storage** (Android Keystore / iOS Keychain)
- Each user can only access their own tasks and notes
- The `.env` file is never committed to GitHub

---


## 📄 License

This project was built as a college academic project.