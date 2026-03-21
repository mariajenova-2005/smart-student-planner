# 📚 Student Planner Pro

A complete cross-platform academic planner with NeonDB cloud backend, Done button for tasks, and smart pending task notifications.

## Tech Stack
| Layer | Technology |
|---|---|
| Frontend | Flutter + Dart |
| State Management | Provider |
| Navigation | go_router |
| HTTP | http package |
| Token Storage | flutter_secure_storage |
| Backend | Node.js + Express |
| Database | NeonDB (PostgreSQL) |
| Auth | JWT + bcryptjs |
| Notifications | flutter_local_notifications |

## Features
- ✅ Done button on every task card (Pending → Done with animation)
- 🔔 Smart notifications: deadline reminders, morning/evening pending summaries with due times, overdue alerts
- 🔐 Secure JWT authentication
- 📊 Dashboard with stats and progress
- 📅 Calendar with task markers
- 📝 Subject-wise notes
- 🌙 Dark mode

## Setup

### Backend
```bash
cd backend
npm install
# .env is already configured with NeonDB connection
npm run db:migrate   # creates tables
npm run dev          # starts server on port 3000
```

### Flutter
```bash
cd flutter_app
flutter create .
flutter pub get
flutter run -d chrome   # for web
flutter run             # for Android emulator
```

### URL config
Open `flutter_app/lib/utils/app_constants.dart`:
- Chrome: `http://localhost:3000`
- Android emulator: `http://10.0.2.2:3000`
- Real phone: `http://YOUR-PC-IP:3000`
