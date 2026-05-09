# Lab 05 — Todo Studio Architecture

## Overview
This repository contains a two-tier Todo application:

- **Backend**: Node.js + Express API with MongoDB for persistence.
- **Frontend**: Flutter app that authenticates users and manages todo items.

The Flutter client talks directly to the Express API; the API reads/writes data in
MongoDB using Mongoose models.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `backend/` | Express API server and MongoDB data models |
| `nguyenminhnghi_2224802010934_lab05/` | Flutter application (mobile/web UI) |

## Backend Architecture (Node.js + Express)

**Entry points**
- `backend/index.js`: Bootstraps the server, connects to MongoDB, listens on port `3000`.
- `backend/app.js`: Express app setup, JSON parsing, and route registration.

**Configuration**
- `backend/config/db.js`: Mongoose connection using `MONGO_URI` from environment.

**Routing**
- `backend/routes/user.route.js`: Authentication endpoints.
- `backend/routes/todo.route.js`: Todo CRUD endpoints.

**Controllers**
- `backend/controllers/user.controller.js`: Validates inputs, handles login/register.
- `backend/controllers/todo.controller.js`: Validates inputs and orchestrates todo actions.

**Services**
- `backend/services/user.service.js`: User registration, lookup, JWT creation.
- `backend/services/todo.service.js`: CRUD operations for todos.

**Data models**
- `backend/models/user.model.js`: User schema with bcrypt password hashing.
- `backend/models/todo.model.js`: Todo schema linked to user by `userId`.

**API surface**
- `POST /register` — create user
- `POST /login` — authenticate and return JWT
- `POST /createToDo` — create a todo
- `GET /getUserTodoList?userId=...` — list todos for a user
- `PUT /updateTodo` — update a todo
- `POST /deleteTodo` — delete a todo

## Frontend Architecture (Flutter)

**Entry points**
- `lib/main.dart`: Initializes Flutter and runs the app.
- `lib/src/app.dart`: Sets up Material theme and the initial navigation gate.

**State bootstrapping**
- `SplashGate` checks `AuthStorage.hasSession()` to decide between login and todo list.

**Screens**
- `lib/src/screens/login_screen.dart`: Login form and session creation.
- `lib/src/screens/register_screen.dart`: Registration form.
- `lib/src/screens/todo_list_screen.dart`: Todo list, create/edit/delete flows.

**Networking**
- `lib/src/api/api_client.dart`: REST client for the Express API.
  - Uses `http://localhost:3000` on web, `http://10.0.2.2:3000` on Android emulator.
  - Parses JWT to extract `userId` for subsequent todo requests.

**Local session storage**
- `lib/src/storage/auth_storage.dart`: Persists `token` and `userId` in SharedPreferences.

**Models**
- `lib/src/models/todo_item.dart`: Strongly-typed todo model from API responses.

## End-to-End Data Flow

1. User logs in or registers in Flutter.
2. `ApiClient` calls the Express API.
3. `user.controller` / `todo.controller` validates input and delegates to services.
4. Services call Mongoose models to read/write MongoDB.
5. API responses are mapped to Flutter models and rendered in UI.

## Deployment Notes

- Backend expects `MONGO_URI` to be set.
- Express server listens on `http://localhost:3000`.
- Flutter client assumes the API is reachable at the configured base URL.
