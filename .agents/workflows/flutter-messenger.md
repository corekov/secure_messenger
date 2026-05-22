---
description: Automates Flutter messenger initialization. Scaffolds feature-first layers, injects standard packages, secures JWT storage (Keychain/Keystore), and deploys a Dio interceptor for transparent 401 token refresh linked to a Go backend API.
---

# Workflow: Create Secure Flutter Messenger App MVP
---
description: This workflow guides the Antigravity Agent through step-by-step implementation of a secure Flutter messenger client that interacts with an existing Go backend.
tags: [flutter, dart, architecture, security]
---

## Phase 1: Architecture, Packages, and Base Authentication Service

### Step 1: Environment Analysis and Architecture Layout
**Instructions for Agent:**
1. Analyze the current workspace structure. If this is a fresh Flutter project, ensure the project is correctly initialized.
2. Design and create the recommended directory layout using a feature-first or layer-first architecture suitable for clean architecture (e.g., `lib/features/auth`, `lib/core/network`, `lib/core/storage`).
3. Output the exact final folder layout as an Artifact for user verification.

### Step 2: Dependency Configuration
**Instructions for Agent:**
1. Open `pubspec.yaml`.
2. Add the best-practice packages for the required stack:
   - State Management: `flutter_riverpod` or `flutter_bloc` (default to Riverpod unless BLoC is already detected in the repo) and `riverpod_annotation`.
   - Routing: `go_router`.
   - HTTP & Networking: `dio` (preferred for its interceptor support).
   - WebSockets: `web_socket_channel`.
   - Local Storage / Cache: `flutter_secure_storage` (for JWT) and `isar` or `sqflite` (for offline caching).
3. Run `flutter pub get` in the terminal to fetch all dependencies. Ensure there are no dependency version conflicts.

### Step 3: Secure Local Storage Wrapper
**Instructions for Agent:**
1. Create a secure storage utility class (e.g., `lib/core/storage/secure_storage_service.dart`).
2. Implement methods using `flutter_secure_storage` to write, read, and delete the `access_token` and `refresh_token`.
3. Provide robust error handling for OS-level secure storage failures.

### Step 4: Dio Network Client & JWT Interceptor
**Instructions for Agent:**
1. Create a base network service configuration (e.g., `lib/core/network/dio_client.dart`).
2. Implement a custom Dio Interceptor that automatically injects the `Authorization: Bearer <access_token>` header into protected requests.
3. In the interceptor's `onError` block, catch `401 Unauthorized` responses. Implement the automated token refresh mechanism:
   - Call `/api/v1/auth/refresh` using the stored `refresh_token`.
   - Save the new tokens using the secure storage wrapper.
   - Retry the initial failed request transparently.
   - If the refresh token is also invalid/expired, trigger a logout/auth state update.

### Step 5: Authentication Service Implementation
**Instructions for Agent:**
1. Create the Core Authentication Repository/Service (e.g., `lib/features/auth/services/auth_service.dart`).
2. Implement specific Dart methods for:
   - `register(String username, String password)` -> POST to `/api/v1/auth/register`
   - `login(String username, String password)` -> POST to `/api/v1/auth/login`
   - `logout()` -> POST to `/api/v1/auth/logout` and clear local storage.
3. Implement the initial Auth State Provider using the chosen state management solution.

### Step 6: Verification and Automated Code Check
**Instructions for Agent:**
1. Run `dart analyze` in the terminal to verify that there are no syntax, type, or architectural issues in the newly created code.
2. Generate a structural summary Artifact documenting how the security token cycle flows through the newly created files. Do not close the task until `dart analyze` passes perfectly.