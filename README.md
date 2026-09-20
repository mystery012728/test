# ShopEase — Laza E-Commerce Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com)
[![BLoC](https://img.shields.io/badge/BLoC-8A4FFF?style=for-the-badge&logo=flutter&logoColor=white)](https://bloclibrary.dev)
[![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)](#)

A modern, production-grade e-commerce application built with **Flutter**, **BLoC State Management**, **Firebase Authentication & Cloud Firestore**, and a **Dio REST API** integration using [DummyJSON](https://dummyjson.com/docs/products). Designed and engineered according to the **Laza E-commerce Figma UI Kit** specifications.

---

## 📌 Table of Contents
1. [Architecture & Design Decisions](#-architecture--design-decisions)
2. [Features & Completed Screens](#-features--completed-screens)
3. [Cloud Firestore Data Schema](#-cloud-firestore-data-schema)
4. [DummyJSON REST API Endpoints](#-dummyjson-rest-api-endpoints)
5. [State Management (BLoC)](#-state-management-bloc)
6. [Design System & Reusable Components](#-design-system--reusable-components)
7. [Getting Started & Installation](#-getting-started--installation)
8. [Firebase Configuration](#-firebase-configuration)
9. [Running Tests & Quality Assurance](#-running-tests--quality-assurance)
10. [Folder Structure](#-folder-structure)

---

## 🏗 Architecture & Design Decisions

The application adheres to a clean, decoupled, **feature-first (modular) layered architecture** to ensure maintainability, scalability, and testability.

### Layered Data Flow
```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Views, Screens, Reusable Widgets, Toast, Dialogs)   │
└───────────────────────────▲────────────────────────────┘
                            │ Emits Events / Listens to States
┌───────────────────────────▼────────────────────────────┐
│                  Business Logic Layer                  │
│                (BLoC / Events / States)                │
└───────────────────────────▲────────────────────────────┘
                            │ Calls Methods
┌───────────────────────────▼────────────────────────────┐
│                    Repository Layer                    │
│   (Data Aggregation, Local Cache + Remote Syncing)     │
└───────────────────────────▲────────────────────────────┘
                            │ Executes Requests
┌───────────────────────────▼────────────────────────────┐
│                    Data Source Layer                   │
│    • Dio REST API (DummyJSON)                          │
│    • Cloud Firestore & Firebase Auth                   │
│    • SharedPreferences (Local Caching)                 │
└────────────────────────────────────────────────────────┘
```

### Why BLoC (Business Logic Component)?
- **Unidirectional Data Flow**: State transitions are strictly governed by explicit events, eliminating UI side-effects and race conditions.
- **Separation of Concerns**: Views are completely free from business logic and database queries; they simply dispatch events and render corresponding states.
- **Enterprise Scalability**: Tested and certified state management recommended by Google and top mobile teams for complex, enterprise-level applications.
- **Testability**: Event-driven BLoC allows 100% deterministic unit testing without needing to mock UI bindings.

---

## 📱 Features & Completed Screens

### 1. Authentication & Onboarding
- **Splash Screen**: Checks authenticated session from local persistence (`LocalPreference`) and routes seamlessly to Home or Login.
- **Login Screen**: Email/password authentication with validation, password visibility toggle, error handling, and remember-me session persistence.
- **Register Screen**: Full registration form with password confirmation, client-side validation, and automatic creation of the `users/{uid}` Firestore document.
- **Forgot Password**: Password reset flow with cloud verification.
- **Onboarding (Personalization)**: Interactive category chips (Electronics, Fashion, Shoes, Beauty, Sports, etc.) allowing users to pick 3–5 interests, immediately synced to Firestore `users/{uid}.favoriteCategories`.

### 2. Catalog & Discovery
- **Home Screen**:
  - Carousel banner promoting sales and curated drops.
  - Quick category selector chips.
  - **"Recommended for you" Section**: Dynamically fetches and displays products tailored to the user's selected interests from onboarding.
  - **"Popular Products" Grid**: Fetches trending products from DummyJSON.
- **Product Listing with Infinite Scroll Pagination**:
  - `GET /products?limit=10&skip=X` with pagination triggered automatically upon scrolling near the bottom.
  - Sorting bottom sheet: *Recommended, Price: Low to High, Price: High to Low, Highest Rated*.
  - Pull-to-refresh to fetch updated catalog items.
- **Search Screen**:
  - Live search debounced input querying DummyJSON REST API.
  - Persistent recent searches saved in `SharedPreferences`.
  - Empty search state and error states with retry.
- **Product Details Screen**:
  - Smooth multi-image carousel with interactive thumbnail selection.
  - Product specs (Brand, Category, Rating, Stock availability, Discount badge).
  - One-tap Add to Cart and Wishlist toggling with interactive toast notifications.

### 3. Commerce & Transactions
- **Wishlist Screen**:
  - Cloud Firestore-backed wishlist (`users/{uid}/wishlist`).
  - Offline-first cache of wishlist IDs in `SharedPreferences` for instantaneous UI response.
  - One-tap move to Cart with undo support.
- **Cart Screen**:
  - Real-time quantity adjustment (`+` / `-`).
  - Automatic calculation of subtotal, shipping fee, taxes, and grand total.
  - Clear cart confirmation modal.
- **Checkout Screen**:
  - Delivery address input with validation.
  - Mock payment method selection (Cash on Delivery, Credit Card, Apple Pay).
  - Mock order placement storing complete order records in Firestore.
- **Order History Screen**:
  - Real-time order tracking list loaded from `users/{uid}/orders`.
  - Displays Order ID, timestamp, item count, total price, and real-time processing status.

### 4. User Profile & Analytics
- **Profile Screen**:
  - Displays avatar, name, email, phone, gender, and selected category interests.
  - Pull-to-refresh to sync latest Firestore data.
- **Edit Profile**:
  - Updates `name`, `phone`, `gender`, `dateOfBirth`, and `profileImage`.
  - Profile image selection with Cloudinary cloud upload support and fallback.
  - Immediately updates app state without requiring an app reinstall.
- **Dynamic Analytics & Insights Dashboard**:
  - **Real-Time Cloud Metrics**: Automatically computes total spending, total order count, and saved wishlist count directly from the user's Firestore order records.
  - **Weekly Purchasing Activity Bar Chart**: Visual bar chart aggregating spend by day of week (Monday through Sunday).
  - **Category Distribution**: Visual progress breakdown of user spend by category.
  - Pull-to-refresh to recompute metrics on demand.

---

## ☁️ Cloud Firestore Data Schema

```
firestore/
├── users/
│   └── {uid}/
│       ├── email: string
│       ├── name: string
│       ├── phone: string
│       ├── gender: string
│       ├── dateOfBirth: string
│       ├── profileImage: string
│       ├── favoriteCategories: string[]  // Selected during onboarding
│       ├── createdAt: timestamp
│       ├── updatedAt: timestamp
│       │
│       ├── cart/                          // Subcollection
│       │   └── {productId}/
│       │       ├── productId: int
│       │       ├── title: string
│       │       ├── price: double
│       │       ├── quantity: int
│       │       ├── thumbnail: string
│       │       └── addedAt: timestamp
│       │
│       ├── wishlist/                      // Subcollection
│       │   └── {productId}/
│       │       ├── productId: int
│       │       ├── title: string
│       │       ├── price: double
│       │       ├── thumbnail: string
│       │       └── addedAt: timestamp
│       │
│       └── orders/                        // Subcollection
│           └── {orderId}/
│               ├── orderId: string
│               ├── userId: string
│               ├── items: CartItemModel[]
│               ├── subtotal: double
│               ├── shippingFee: double
│               ├── tax: double
│               ├── totalAmount: double
│               ├── shippingAddress: string
│               ├── paymentMethod: string
│               ├── status: string ("Processing", "Shipped", "Delivered")
│               └── createdAt: timestamp
```

---

## 🌐 DummyJSON REST API Endpoints

The Dio client communicates directly with the DummyJSON products API:

| Feature | Method | Endpoint | Query Parameters |
| :--- | :--- | :--- | :--- |
| **All Products** | `GET` | `/products` | `limit=10`, `skip=0` |
| **Pagination** | `GET` | `/products` | `limit=10`, `skip={skipCount}` |
| **Product Details**| `GET` | `/products/{id}` | — |
| **Search** | `GET` | `/products/search` | `q={searchQuery}` |
| **Categories** | `GET` | `/products/categories` | — |
| **Filter by Category** | `GET` | `/products/category/{category}` | `limit=10` |
| **Sort Products** | `GET` | `/products` | `sortBy={field}&order={asc\|desc}` |

---

## 🧩 State Management (BLoC)

Every feature is encapsulated in a dedicated BLoC subfolder containing:
1. `*_bloc.dart` — Handles events and emits immutable states.
2. `*_event.dart` — Defines all user actions and lifecycle triggers.
3. `*_state.dart` — Represents UI states (`Initial`, `Loading`, `Loaded`, `Empty`, `Error`).

```
lib/core/all_bloc_providers/
├── all_bloc_providers.dart    # Global MultiBlocProvider registration
```

---

## 🎨 Design System & Reusable Components

Located in `lib/core/widgets/`:
- **`CustomToastBar`**: Floating interactive pill replacing standard SnackBars. Features a **3-second auto-removal** timer, sleek dark theme (`#1E1F24`), accent icons, and optional action callbacks.
- **`CommonErrorState`**: Centralized error widget with default heading **"Oops! Something went wrong"**, detailed error message, and a **"Try Again"** retry CTA button.
- **`CommonEmptyState`**: Minimalist empty state featuring circular badge icons, clear descriptions, and contextual action buttons (e.g. "Start Shopping").
- **`CustomSkeletonLoader`**: Smooth shimmering placeholder loader preventing layout shift during asynchronous data fetches.
- **`CustomButton` & `CustomTextField`**: Reusable inputs adhering to Laza design specifications.

---

## 🚀 Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.12.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>=3.0.0`)
- Xcode (for iOS simulator/device testing) or Android Studio (for Android emulator)

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone <YOUR_REPOSITORY_URL>
   cd <REPOSITORY_FOLDER>
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Flutter environment**:
   ```bash
   flutter doctor
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 🔐 Firebase Configuration

> [!NOTE]
> For security, production Firebase credentials and service account secrets should not be checked into public version control.

To connect your own Firebase project:
1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password** in Firebase Authentication.
3. Create a **Cloud Firestore Database** in test mode or with appropriate security rules.
4. Run the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This will automatically update `lib/firebase_options.dart` and register your iOS/Android application bundle IDs.

---

## 🧪 Running Tests & Quality Assurance

### Run Static Analysis
Ensure code cleanliness and adherence to recommended lint rules:
```bash
flutter analyze
```
*Current status: **0 issues found!***

### Run Automated Unit & Widget Tests
Execute all test suites covering models, repositories, routes, and custom widgets:
```bash
flutter test
```
*Current status: **All 14 tests passing successfully!***

---

## 📂 Folder Structure

```
lib/
├── core/
│   ├── all_bloc_providers/      # Global MultiBlocProvider registry
│   ├── constants/               # AppColors, AppUrls, CloudinaryConfig
│   ├── local/                   # LocalPreference (SharedPreferences wrapper)
│   ├── network/                 # DioClient & HTTP configuration
│   ├── routes/                  # AppRoutes & dynamic route generators
│   ├── services/                # CloudinaryService & media utilities
│   ├── theme/                   # AppTheme & Typography
│   └── widgets/                 # CustomToastBar, CommonErrorState, CommonEmptyState
│
├── modules/
│   ├── auth/                    # Login, Register, Forgot Password, Splash
│   ├── onboarding/              # Category Interests & Personalization
│   ├── home/                    # Personalized Recommendations & Carousel
│   ├── product/                 # Product List (Infinite Scroll), Detail, Search
│   ├── cart/                    # Cart & Wishlist (Firestore backed)
│   ├── order/                   # Checkout & Order History
│   ├── profile/                 # View & Edit User Profile
│   └── analytics/               # Dynamic Analytics & Metrics Dashboard
│
├── firebase_options.dart        # Firebase configuration
└── main.dart                    # App entry point
```
