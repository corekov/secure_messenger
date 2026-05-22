# Role & Context
You are an elite Software Architect, Senior Flutter/Dart Developer, and Mobile Security Specialist. Your task is to build a secure, real-time, production-grade cross-platform messenger application (iOS & Android) that connects to an existing high-performance Go backend.

## Absolute Directives & Source of Truth
To ensure consistency, you must strictly follow the local configuration files, guidelines, and assets provided in this repository. Before generating any architecture or code, you must read and align with:

1. **Agent Behavior & Rules (`/.agents`):** Check this directory for `rules`, `workflows`, and `skills` configurations. You must strictly mimic the designated workflows, utilize the listed skills, and avoid any patterns explicitly forbidden by the rules.
2. **Application Design (`/design`):** Read the design specs or layout structure in this folder. The UI must follow a ultra-minimalistic, high-performance design language inspired directly by **Telegram** and **Signal**. Focus strictly on core, essential messenger functionality with absolute clarity—no visual clutter, no redundant elements. Lean, purposeful interfaces only.

---

## Backend Infrastructure & Architecture
The Go backend is already running and fully functional. The Flutter client must consume its services flawlessly based on the following architectural pillars:

### 1. Cryptographically Secure Authentication (JWT)
- **Endpoints:** `/api/v1/auth/register`, `/api/v1/auth/login`, `/api/v1/auth/refresh`, `/api/v1/auth/logout`.
- **Token Flow:** Successful authentication returns an `access_token` (short-lived) and a `refresh_token` (long-lived).
- **Security & Lifecycle:**
  - Tokens must be securely stored using hardware-backed storage (e.g., `flutter_secure_storage`).
  - Implement a centralized HTTP client/interceptor. Every protected request must automatically append the `Authorization: Bearer <access_token>` header.
  - **Silent Re-authentication:** The interceptor must catch `401 Unauthorized` errors, pause the request queue, call the refresh endpoint to obtain a new access token, update the storage, and seamlessly retry the failed request(s).

### 2. REST API & Data Hydration
- **Base URL:** `http://localhost:8080/api/v1` (Must be dynamically injectable via environment variables/flavor configuration).
- **Users:** Endpoints for profile retrieval (`/me`) and search-by-username.
- **Messaging:** Endpoints to fetch active 1-on-1 chat lists, paginated message history, and marking messages as read.

### 3. Persistent Real-Time Communication (WebSocket)
- **Connection:** Establish a long-lived, persistent WebSocket connection immediately after a successful login cycle.
- **Protocol:** Exchange JSON payloads containing an explicit `type` discriminator (e.g., `chat_message`, `typing_indicator`, `user_presence`).
- **State Integration:** The app must reactively process incoming payloads to update the UI instantly. Implement automatic reconnection strategies with exponential backoff for network drops. Send lightweight "typing..." packets upstream as the user interacts with the input field.

### 4. Zero-Knowledge End-to-End Encryption (E2EE)
- The Go server acts purely as an untrusted, zero-knowledge relay and database. It cannot read message content.
- **Client Implementation:** Implement client-side cryptographic key generation and management.
  - Outbound payloads must be encrypted locally *before* hitting the WebSocket or REST network layer.
  - Inbound payloads must be decrypted locally within an isolated service/layer before being committed to state or the local database.

---

## Technical Stack Requirements for the Flutter MVP
To match the robustness of the backend, the Flutter client must use a highly scalable, predictable stack:
1. **State Management:** Use BLoC (with `flutter_bloc`) or Riverpod. Choose one, ensure absolute separation of business logic from UI, and strictly follow the patterns defined in `/.agents`.
2. **Routing:** Implement `go_router` for declarative navigation, deep-linking readiness, and robust route guarding (redirecting unauthenticated users to login).
3. **Local Database & Caching:** Use `isar` or `sqflite` to build an offline-first experience. Cache message history locally, allowing instant rendering on app launch and smooth syncing when coming back online.
4. **UI/UX Excellence:** Based on the minimalist philosophy of Telegram/Signal and the `/design` assets, implement a dark-mode UI with flawless, native-like micro-animations, physics-based scrolling, and instant optimistic UI updates (render sent messages immediately before server confirmation).

---

## Testing Strategy & Quality Assurance
The application must be fully verified using a comprehensive testing pyramid. Every feature must be built with testability in mind (clean dependency injection, mocked external channels, and predictable state transitions).

### 1. Unit Tests (Business Logic & Core Services)
- **Target:** BLoC/Riverpod states, repositories, JWT authentication services, and cryptographic E2EE engines.
- **Requirements:**
  - Achieve high coverage for the network interceptor (test token expiration, simultaneous requests queuing, and successful/failed silent refreshes).
  - Use `bloc_test` for BLoC or strict container overrides for Riverpod to verify state emissions.
  - Mock all network components using `mockito` or `mocktail`. Absolutely no real HTTP/WebSocket traffic during unit testing.

### 2. Widget Tests (Component UI & Design Fidelity)
- **Target:** Minimalist UI elements, custom input components, chat bubbles, and layout responsiveness.
- **Requirements:**
  - Test critical component interactions: entering text into inputs, firing "typing" events, and rendering custom micro-animations without throwing layout overflows.
  - Provide necessary mocked environments (Mock Material/Cupertino App wrappers, injected theme states) to isolate the widget under test.

### 3. Integration Tests (End-to-End & Offline Flows)
- **Target:** Complete user journeys (Login Flow ➔ Chat List ➔ Real-time Messaging ➔ Offline Caching Sync).
- **Requirements:**
  - Use the native `integration_test` package to simulate end-to-end (E2E) flows on actual simulators or real devices.
  - Test edge cases for real-time networking: abrupt WebSocket disconnection, network switching (Wi-Fi to Cellular), and ensuring data seamlessly falls back to the Local Database (`isar` / `sqflite`).
  - Verify the end-to-end zero-knowledge flow: check that encrypted data is stored correctly in the database and decrypts properly in the view layer without memory leaks.

---

## Your First Task
Do not attempt to write the entire application at once. We will build this system systematically, ensuring each layer is perfectly covered by tests and conforms to the project's rules.

**Step 1:** 
1. Map out a clean, feature-first (or layer-first, depending on `/.agents` guidelines) folder architecture for this project, including the dedicated `/test` folder mirroring.
2. Recommend the exact production-ready pub.dev packages to use for HTTP client, WebSockets, Secure Storage, Local Database, State Management, and Testing/Mocking.
3. Provide the robust initial code for the **Authentication Service** and its HTTP Interceptor/Client that handles the complete JWT login, secure storage, and silent refresh cycle. Ensure it is thread-safe and properly handles concurrent failed requests during a token refresh.
4. Provide a complete **Unit Test suite** for this Authentication Service and Interceptor, demonstrating how you mock secure storage and token refresh flows.

Please read `/.agents` and `/design` first, acknowledge your understanding of the architecture, and begin with Step 1.