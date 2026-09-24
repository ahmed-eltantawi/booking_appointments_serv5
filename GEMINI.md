# Flutter `core/` Folder — AI Agent Rules

> **Source of truth**: Derived from deep analysis of `mathcIn_flutter` (the developer's latest project).
> These rules must be followed exactly. Do not deviate toward generic Flutter conventions unless explicitly stated.

---

## Phase 1 — Pattern Analysis & Classification

### Discovered Patterns

#### File & Folder Organization
- `core/` contains exactly these top-level folders: `cache/`, `errors/`, `functions/`, `networking/`, `routing/`, `services/`, `theme/`, `utils/`, `widgets/`.
- No `di/`, `helpers/`, `extensions/`, or `constants/` folders exist — those concepts are absorbed into `utils/`, `cache/`, and `services/`.
- Each sub-folder is flat (zero nesting inside). No sub-sub-folders.
- One class per file, with very rare exceptions (e.g., `AuthEventBus` + `AuthEvent` enum in the same file as the interceptor, because they are tightly coupled).

#### Naming Conventions
- **Abstract classes used as namespaces** (no instances): `abstract class AppColors`, `abstract class AppConstants`, `abstract class AppTextStyles`, `abstract class CacheKey`, `abstract class EndPoint`, `abstract class ApiKey`, `abstract class ApiHeaderKey`.
- **`abstract final class` for routing**: `abstract final class AppRouter`, `abstract final class AppRoutes`.
- **Regular `class`** for concrete services, helpers, models: `DioConsumer`, `SecureStorageHelper`, `SharedPreferencesHelper`, etc.
- **Suffix patterns**:
  - `*Service` → high-level domain service (e.g., `SecureStorageService`, `SharedPreferencesService`).
  - `*Helper` → low-level wrapper around an external package (e.g., `SecureStorageHelper`, `SharedPreferencesHelper`).
  - `*Interceptor` → Dio interceptors (e.g., `ApiInterceptor`).
  - `*Consumer` → concrete API client (e.g., `DioConsumer`).
  - `*Failure` → failure classes (e.g., `ServerFailure`, `OfflineFailure`).
  - `*Exception` → exception classes (e.g., `ServerException`, `OfflineException`).
  - `*Model` → data/error models (e.g., `ErrorModel`).
  - `*Router` → GoRouter container (e.g., `AppRouter`).
  - `*Routes` → route path constants (e.g., `AppRoutes`).
  - `*Theme` → ThemeData container (e.g., `AppTheme`).
- **Route path constants** are prefixed with `k`: `kSplashView`, `kHomeView`, `kLoginView`.
- **File names** use `snake_case` matching the class name: `api_consumer.dart`, `dio_consumer.dart`, `app_colors.dart`.
- **Private members** use `_` prefix: `_secureStorageHelper`, `_storage`, `_refreshCompleter`, `_streamController`.
- **GetIt instance** is a top-level `final` variable named `getIt`: `final getIt = GetIt.instance`.
- **Assets class** uses a private constructor to prevent instantiation: `Assets._()`.

#### Dart Code Style
- Constructors are placed **first** in the class body (enforced by linter: `sort_constructors_first`).
- Named parameters with `required` are preferred for constructors that take more than one argument.
- `const` constructors are used wherever possible (enforced by linter: `prefer_const_constructors`).
- `final` is used for all fields that are not mutated (enforced by: `prefer_final_fields`, `prefer_final_locals`).
- `super.key` / `super.message` shorthand is used (enforced by: `use_super_parameters`).
- Single quotes only (enforced by: `prefer_single_quotes`).
- Trailing commas always (enforced by: `require_trailing_commas`).
- `avoid_print` is enforced — never use `print()`.
- `use_build_context_synchronously` is enforced.

#### Comment Style
- Section separators use one of these styles:
  - `//! ===== Section Title =====` (primary heading inside a class)
  - `//! ─── Section Title ───────` (secondary heading inside a helper)
  - `//? ---------- Method Name ----------` (method separator inside `DioConsumer`)
  - `///! ======================= Section =======================` (major section in interceptor)
  - `///* Summary comment` (file-level or class-level documentation using `///*`)
  - `// --- Short inline comment ---` (inline description for a block of code)
- `///* ` (triple-slash with asterisk) is used for documenting abstract classes and top-level functions.
- `///` doc comments are used on classes that need description.
- `// TODO: change these values` is used as a marker for template values to be customized.
- `//TODO:` is used for placeholder registration slots in DI (e.g., `//TODO: Put here all your features`).
- Comments explain **why** or **what the block does**, not restating the code line-by-line.

#### Import Style
- **Package imports only** — never relative imports (e.g., `import 'package:MatchIn/core/...'`).
- Import ordering (when multiple imports present):
  1. `dart:` imports
  2. `package:flutter/...` imports
  3. Third-party package imports
  4. Project package imports (`package:MatchIn/...`)
- No `show` or `hide` is used, except for aliased imports (`as`).
- File-level aliased imports are used when two files export the same symbol: `import '...' as LightTheme`.

#### Dependency Injection (GetIt)
- `registerLazySingleton` is the **default** registration type for all core dependencies.
- `registerSingleton` is **not used** (no eager singletons observed).
- `registerFactory` is reserved for feature-specific Cubits/Blocs (not core).
- Registration order inside `setupServiceLocator()`:
  1. Features (placeholder section with `//TODO:`)
  2. External dependencies (e.g., `SharedPreferences`)
  3. Core Storage Helpers
  4. Core Services
  5. Network Info
  6. Network Client (Dio)
  7. ApiConsumer (registered against the abstract type)
- **Abstract types are always registered**, not concrete types: `getIt.registerLazySingleton<ApiConsumer>(() => DioConsumer(...))`.
- Dependencies are resolved with `getIt()` (type inference), not `getIt<Type>()`, inside the factory lambda.
- External packages requiring async initialization (like `SharedPreferences`) are awaited before registration.
- The function is `Future<void> setupServiceLocator()` and is called with `await` in `main()`.
- `getIt` is a **top-level variable**, not inside a class.

#### Networking
- `ApiConsumer` is the abstract interface with 4 methods: `get`, `post`, `put`, `delete`.
- `DioConsumer` is the single concrete implementation.
- All methods return `Future<dynamic>` (not typed generics).
- All methods accept: `String path`, `Map<String, dynamic>? queryParameters`, `Object? data`, `bool isFormData = false`.
- `isFormData` parameter wraps `data` with `FormData.fromMap(data)` when true.
- Dio is configured inside the `DioConsumer` constructor, not in the DI setup.
- `LogInterceptor` is always added with: `request: true`, `requestBody: true`, `responseBody: true`, `requestHeader: false`, `responseHeader: false`.
- All endpoint constants live in `EndPoint`, API response key names in `ApiKey`, header key names in `ApiHeaderKey`.
- `ApiHeaderKey` contains a static method `getAuthorizationValue({required String? accessToken})` that builds the `Bearer <token>` string.
- Token refresh logic lives in `ApiInterceptor.onError` and uses a `static Completer<bool>?` to prevent concurrent refresh races.
- A separate `Dio` instance (`refreshDio`) is used for the refresh token request to avoid interceptor loops.
- Public routes (`login`, `register`, `refreshToken`) are whitelisted in `_isPublicRequest()` to skip refresh logic.
- `AuthEventBus` is a singleton that emits `AuthEvent.logout` when refresh fails — placed in the same file as `ApiInterceptor`.
- `NetworkInfo` is an abstract interface; `NetworkInfoImpl` implements it using DNS lookup fallback across multiple hosts.

#### Error Handling
- **Two-layer error system**: `Exception` → caught at data layer; `Failure` → propagated to domain/presentation.
- Exception classes are simple: `class OfflineException implements Exception {}`.
- `ServerException` carries an `ErrorModel` with `statusCode` and `errorMessage`.
- `ErrorModel` is a plain class (not Equatable), with a `fromJson` factory constructor using `ApiKey` constants.
- `Failure` is an `abstract class extends Equatable` with a required `message` field.
- Concrete failures have default messages: `const OfflineFailure({super.message = 'You are offline'})`.
- `handleDioExceptions(DioException e)` is a top-level function (not a method) in `exceptions.dart`.
- It switches on `e.type` and throws the appropriate exception.
- `_extractErrorModel` and `_fallbackErrorModel` are private top-level helper functions inside `exceptions.dart`.
- All `DioExceptionType` cases are handled explicitly in the switch.
- `badResponse` further switches on HTTP status codes with inline comments (e.g., `case 400: // bad request`).

#### Routing (GoRouter)
- `AppRouter` is `abstract final class` with a single `static final router = GoRouter(...)`.
- A private static `_buildTransitionPage` method provides a reusable `FadeTransition` page.
- Route paths are `static const String` in `abstract final class AppRoutes`, prefixed with `k`.
- Root route is always `kSplashView = '/'`.

#### Theme & Constants
- `AppTheme` (`abstract class`) exposes `static ThemeData get lightTheme` and `static ThemeData get darkTheme`.
- Each theme (`light_theme.dart`, `dark_theme.dart`) is a top-level `final ThemeData` variable, **not** a class.
- Both themes reference `AppConstants.appFamilyFont` for the font family.
- Light theme uses `AppColors` constants; dark theme may use inline hex `Color(0xFF...)` values.
- `AppColors` is `abstract class` with named `static const Color` fields.
- Color naming follows semantic groups: Primary, Secondary, Backgrounds, Text Colors, Borders & Divider, Status Colors.
- `AppConstants` is `abstract class` with app-wide strings: `appFamilyFont`, `languageCode`, `defaultAvatarUrl`, etc.
- `AppTextStyles` is `abstract class` with `static TextStyle` fields named by weight+size: `semiBold20`, `regular14`.
- Text style names follow pattern: `{weight}{size}` e.g., `semiBold20`, `regular14`, `bold16`.
- Assets are auto-generated into `Assets` class (private constructor `Assets._()`) in `core/utils/app_assets.dart`.
- `useMaterial3: true` is always set.
- `elevation: 0` is the default for buttons and cards.
- AppBar: `elevation: 0`, `centerTitle: true`.

#### Cache Layer
- **Two distinct helpers** for storage: `SharedPreferencesHelper` (non-sensitive) and `SecureStorageHelper` (sensitive/encrypted).
- **Two distinct services** built on top of those helpers: `SharedPreferencesService` and `SecureStorageService`.
- `CacheKey` is `abstract class` with `static const String` keys.
- `SharedPreferencesHelper.saveData` uses `dynamic value` with type-dispatching pattern.
- `SecureStorageHelper` accepts an optional `FlutterSecureStorage?` in its constructor for testability.
- Services are injected with their respective helpers via constructor.
- Services expose semantic methods (e.g., `saveTokens`, `isLoggedIn`, `onBoardingViewed`), not raw key/value methods.
- Auth-related cache cleanup is grouped into `clearAuthData()` in `SharedPreferencesService`.

#### Core Services
- Services are concrete classes (not abstract).
- Services use `const` constructors where possible.
- Static services (like `LocalNotificationService`, `PushNotificationsService`) use only `static` members — no instance needed.
- Push/local notification services use `///!` section comments for major methods.

#### Functions (`core/functions/`)
- Shared UI utilities that are not widgets are top-level functions in `core/functions/`.
- Named with the verb-first convention: `showCustomDialog`, `showSnackBar`, `showImage`, `showNoInternetConnectionDialog`.
- Convenience variants of a function (e.g., `showNoInternetConnectionDialog`) live in the **same file** as the base function.
- `showImage` handles SVG, network, and asset image rendering in a single function.

#### Shared Widgets (`core/widgets/`)
- Shared widgets are named `*Screen` or `*View` only if they are full-screen composites (e.g., `MainNavigationScreen`).
- `StatefulWidget` + private `State` class pattern for stateful shared widgets.
- `const` constructors with `{super.key}` on all widgets.
- Feature-specific screen references (e.g., `HomeView`, `ProfileView`) are imported from `features/` into shared widgets only when that widget is the composition root (like `MainNavigationScreen`).

---

### KEEP / IMPROVE / AVOID Classification

| Pattern | Classification | Reason |
|---|---|---|
| `abstract class` as namespace for constants/colors/routes | **KEEP** | Intentional, consistent, prevents instantiation |
| `abstract final class` for Router/Routes | **KEEP** | Strongly typed, compile-safe |
| Two-layer error system (Exception → Failure) | **KEEP** | Clean separation between data and domain layers |
| `handleDioExceptions` as a top-level function | **KEEP** | Reusable, not tied to a class |
| `registerLazySingleton` as the default DI strategy | **KEEP** | Efficient, consistent |
| Abstract type registration in GetIt (`<ApiConsumer>`) | **KEEP** | Correct dependency inversion |
| Constructor injection for all services | **KEEP** | Testable, explicit |
| `//! ===`, `///* `, `// ---` comment styles | **KEEP** | Organizes long files effectively |
| Package imports only (no relative imports) | **KEEP** | Enforced by convention |
| `single_quotes`, `trailing_commas`, `final_fields` linter rules | **KEEP** | Enforced, consistent |
| `static Completer<bool>?` for refresh token race prevention | **KEEP** | Sophisticated, intentional pattern |
| `AuthEventBus` singleton for logout events | **KEEP** | Clean event-driven logout |
| Flat folder structure (no nesting inside sub-folders) | **KEEP** | Simple, easy to navigate |
| `showImage()` multi-format dispatcher | **KEEP** | Useful utility, DRY |
| Inline `TODO:` markers on template values | **KEEP** | Scaffolding intent is clear |
| `AppTextStyles` named by weight+size (`semiBold20`) | **IMPROVE** | Good pattern but should be exhaustive; currently only 2 styles defined |
| Dark theme using inline `Color(0xFF...)` instead of `AppColors` | **IMPROVE** | Should reference `AppColors` for consistency, same as light theme |
| `app.dart` importing `dark_theme.dart` directly instead of `AppTheme` | **IMPROVE** | Should use `AppTheme.darkTheme` instead of direct import |
| `main_navigation_screen.dart` importing feature screens directly | **IMPROVE** | Acceptable at composition root but feature views should not bleed into other shared widgets |
| `MainNavigationScreen` hardcoding `Colors.grey` and `Colors.black` | **IMPROVE** | Should use `AppColors` tokens |
| `remove_me.dart` file in `core/widgets/` | **AVOID** | Scaffold/placeholder files should not be committed; delete before shipping |
| `local_notifications_service.dart` and `push_notifications_service.dart` being fully commented out | **AVOID** as permanent state | Commented-out files should either be active or deleted; use Git for history |
| `app.dart` using alias imports for theme files directly | **AVOID** | Prefer using `AppTheme.lightTheme` / `AppTheme.darkTheme` through the facade class |

---

## Final Rules — AI Agent Instructions for `core/`

---

### General Principles

1. The `core/` folder contains only shared, reusable, feature-agnostic infrastructure.
2. Never place feature-specific business logic, repositories, Cubits, or UI inside `core/`.
3. When in doubt whether something belongs in `core/`, ask: "Would every feature in the app potentially need this?" If yes → `core/`. If no → the specific feature.
4. Each file in `core/` must contain one primary class or one cohesive group of tightly coupled declarations (e.g., `AuthEventBus` + `AuthEvent` in the same file as `ApiInterceptor` because they are architecturally coupled).

---

### Folder Structure

5. The canonical sub-folder structure of `core/` is:
   ```
   core/
   ├── cache/          # Storage helpers and cache key constants
   ├── errors/         # Exceptions, Failures, ErrorModel
   ├── functions/      # Top-level shared utility functions (show*, handle*)
   ├── networking/     # ApiConsumer, DioConsumer, ApiInterceptor, NetworkInfo, EndPoints
   ├── routing/        # AppRouter, AppRoutes
   ├── services/       # Domain-level services + services_locator.dart
   ├── theme/          # app_theme.dart, light_theme.dart, dark_theme.dart
   ├── utils/          # AppColors, AppConstants, AppTextStyles, AppAssets
   └── widgets/        # Shared reusable widgets
   ```
6. BuildContext Extensions (`core/extensions/context_extensions.dart`, `snack_bar_extensions.dart`, `bottom_sheet_extensions.dart`):
   - `context.theme` → Access `ThemeData`
   - `context.colors` → Access `ColorScheme`
   - `context.textTheme` → Access `TextTheme`
   - `context.l10n` → Access localized strings via `S.of(this)`
   - `context.showSuccessSnackBar()`, `context.showErrorSnackBar()`, `context.showInfoSnackBar()`, `context.showWarningSnackBar()`
   - `context.showAppBottomSheet()`
7. Theme System & Color Scheme:
   - Always derive colors using `context.colors` / `Theme.of(context).colorScheme`.
   - Populated ColorScheme slots: `primary`, `secondary`, `tertiary`, `surface`, `surfaceContainerHighest`, `onSurface`, `onSurfaceVariant`, `outline`, `error`.
   - Never reference raw `AppColors` directly in presentation widgets when theme extension access is available.
8. App-wide Navigation Standard:
   - Always navigate using `AppRoutes` constants (e.g., `AppRoutes.kHomeView`, `AppRoutes.kJobsSearchView`) with GoRouter (`context.push` or `context.go`).
   - Never hardcode route paths or use direct `Navigator.push` for view transitions.
9. Strict Cubit / UI Separation:
   - Presentation widgets must only focus on rendering UI layout and capturing user inputs.
   - All state mutations, data fetching, and business operations belong inside Cubits/Blocs.
10. Granular Widget Decomposition:
   - Break down complex presentation files into small, single-responsibility sub-widgets.
   - Avoid monolithic `build()` methods by extracting inner sections into modular sub-widgets (e.g., `_TaskHeaderRow`, `_TaskExpandedDetails`, `_TreasureBoxArtwork`).
11. Cubit vs. Widget Boundaries:
   - **Cubit / State Management**: Business logic, roadmap state, node status/state changes, unlock logic, treasure claiming logic, data transformations, API/repository calls, state updates.
   - **Widgets**: `BuildContext`, `GlobalKey`, `RenderBox`, `setState`, Layout calculations, `Positioned`, `Transform`, `CustomPaint`, Bottom Sheet presentation, SnackBar presentation, UI callbacks.
   - Do NOT put Flutter rendering/layout concerns inside Cubits (`GlobalKey`, `RenderBox`, `BuildContext`, `setState`, `showBottomSheet`, `SnackBar`).
12. Centralized Assets & Magic Numbers:
   - Use centralized asset constants (`Assets.lottieGraduationHat`, `Assets.lottieBooks1Lottie`, etc.) instead of hardcoded asset string paths.
   - Replace layout magic numbers with named, descriptive constants (e.g., `_minSpaceRatio`, `_lottieSizeRatio`, `_taskHalfWidth`).

---

## Cubit Responsibility & Dependency Injection Rules

### 1. One Cubit = One Cohesive Responsibility
- Never create a God Cubit.
- Each Cubit must own one cohesive feature/state responsibility.
- A Cubit may contain business logic, state transitions, validation, repository calls, service calls, and feature-specific state mutations.
- Do not place unrelated feature logic in the same Cubit.

### 2. Constructor Dependency Injection is Mandatory
- All Cubit dependencies must be provided through the Cubit's constructor.
- Cubits must never resolve their own dependencies using `getIt` inside business methods or class bodies.
- `services_locator.dart` is the central composition root responsible for constructing Cubits and resolving their constructor dependencies.

### 3. Centralized Services Locator Registration
- All feature Cubits must be registered centrally in `lib/core/services/services_locator.dart`.
- Do not instantiate feature Cubits manually throughout the application UI (avoid `SomeCubit()`).
- Feature Cubits use `registerFactory` as their registration lifecycle strategy unless a documented exception exists.

### 4. UI vs. Cubit vs. BlocProvider Boundaries
- `services_locator.dart` constructs Cubits and injects dependencies via GetIt.
- `BlocProvider` / `MultiBlocProvider` provides the Cubit instance to the widget subtree via `create: (_) => getIt<SomeCubit>()`.
- Widgets access already-provided Cubits via `context.read<T>()`, `context.watch<T>()`, `BlocBuilder`, `BlocListener`, or `BlocConsumer`.
- Do not call `getIt<T>()` inside descendant widgets when the Cubit is already available through `BlocProvider`.
- Keep rendering, `BuildContext`, `GlobalKey`, `RenderBox`, navigation, `SnackBar`, `BottomSheet`, `Dialog`, `Positioned`, and `CustomPaint` in the UI layer.

---


## No Unnecessary Hardcoding

> Do not hardcode reusable, shared, configurable, or semantic values directly inside widgets, screens, repositories, services, Cubits, or feature implementations when the project already has, or should have, a centralized source of truth.
>
> Reusable values must have a single source of truth.

This applies to:
* Asset paths
* Route paths
* Route names
* API endpoints
* API keys
* API response keys
* HTTP header keys
* Cache keys
* App-wide strings
* Localization strings
* Theme colors
* Design-system colors
* Shared text styles
* Configuration values
* Feature flags
* Repeated animation values
* Repeated durations
* Repeated business constants
* Repeated UI constants
* Reusable Lottie configuration
* Other duplicated configuration values

Use the project's existing systems:
- `Assets`
- `AppConstants`
- `AppColors`
- `AppTextStyles`
- `AppRoutes`
- `EndPoint`
- `ApiKey`
- `ApiHeaderKey`
- `CacheKey`
- `Theme` / `ThemeExtensions`
- `Localization`
- Feature-specific constants / configuration
when appropriate.

---

### Naming Conventions

9. Name abstract constant-holder classes: `abstract class App{Domain}` (e.g., `AppColors`, `AppConstants`, `AppTextStyles`, `AppTextStyles`).
10. Name Router/Routes containers: `abstract final class AppRouter` and `abstract final class AppRoutes`.
11. Name route path constants with the `k` prefix: `static const kHomeView = '/home'`.
12. Name high-level domain services with `*Service` suffix: `SecureStorageService`, `SharedPreferencesService`.
13. Name low-level external-package wrappers with `*Helper` suffix: `SecureStorageHelper`, `SharedPreferencesHelper`.
14. Name concrete API client `DioConsumer`; name the abstract interface `ApiConsumer`.
15. Name Dio interceptors `*Interceptor`: `ApiInterceptor`.
16. Name failure classes `*Failure`: `ServerFailure`, `OfflineFailure`, `CacheFailure`, `EmptyCacheFailure`.
17. Name exception classes `*Exception`: `ServerException`, `OfflineException`, `CacheException`, `EmptyCacheException`.
18. Name error data models `*Model`: `ErrorModel`.
19. Use `snake_case` for all file names. The file name must match the primary class it contains.
20. All private fields must be prefixed with `_`.
21. Top-level shared functions use verb-first naming: `showCustomDialog`, `showSnackBar`, `showImage`.
22. Text style constants in `AppTextStyles` follow the pattern `{weightDescription}{fontSize}`: `semiBold20`, `regular14`, `bold16`, `medium12`.
23. Cache key constants in `CacheKey` use `camelCase` string names: `static const String accessToken = 'accessToken'`.

---

### Dart Code Style

24. Always declare the constructor first in any class body.
25. Use `const` constructors on all classes where possible.
26. Use named parameters with `required` for all constructor parameters except when there is only one positional parameter.
27. Use `final` for all fields that are not mutated after initialization.
28. Use `final` for all local variables that are not reassigned.
29. Always use `super.key` and `super.message` shorthand — never `key: key` or explicit `super(message: message)`.
30. Use single quotes for all string literals.
31. Always include trailing commas after the last argument/element in multi-line lists, maps, and function calls.
32. Never use `print()`. Use logging solutions or remove debug output before committing.
33. Never use `dynamic` unless the type genuinely cannot be known at compile time (e.g., `SharedPreferences.getData` dispatch).
34. Use `abstract class` for classes that serve as namespaces for static members only (constants, colors, text styles).
35. Use `abstract final class` for classes that contain only static members and must never be extended or instantiated.
36. Use `sealed class` only when exhaustive pattern matching is needed.
37. Place `@override` on its own line before the method signature.

---

### Imports

38. Use only **package imports** (`package:AppName/...`). Never use relative imports (`../`).
39. Order imports as: `dart:` → `package:flutter/` → third-party packages → project packages (`package:AppName/`).
40. Do not use `show` or `hide` qualifiers on imports.
41. Use aliased imports (`as`) only when two imports would create name collisions.
42. Do not add a blank line between imports within the same group.
43. Add a blank line between import groups.

---

### Dependency Injection

44. Declare `final getIt = GetIt.instance` as a top-level variable in `core/services/services_locator.dart`.
45. Use `Future<void> setupServiceLocator()` as the single initialization function, called with `await` in `main()`.
46. Use `registerLazySingleton` as the default registration type for all core dependencies.
47. Never use `registerSingleton` for core dependencies unless async initialization is required and must complete before the app starts.
48. Register all abstract interfaces against their abstract type, not the concrete type: `getIt.registerLazySingleton<ApiConsumer>(() => DioConsumer(...))`.
49. Resolve dependencies inside factory lambdas using `getIt()` (type inference): `() => MyService(getIt())`.
50. Register dependencies in this order: (1) Features placeholder, (2) External packages, (3) Core Storage Helpers, (4) Core Services, (5) NetworkInfo, (6) Dio, (7) ApiConsumer.
51. Await async external dependencies before registration (e.g., `SharedPreferences.getInstance()`).
52. Add `//TODO: Put here all your features` as a placeholder comment at the top of the Features section.
53. Group registrations with `//! ========= Section =========` section comments.

> **See also**: Section "6. Service Locator Rules — Extended Domain-Layer Variant" below for the fuller registration pattern to apply once a feature grows a real `domain/` layer (UseCases + split DataSources) instead of the leaner `mathcIn_flutter` structure.

---

### Networking

54. `ApiConsumer` (`abstract class`) is the only networking interface. Define exactly these 4 methods: `get`, `post`, `put`, `delete`.
55. Every method in `ApiConsumer` returns `Future<dynamic>` and accepts: `String path`, `Map<String, dynamic>? queryParameters`, `Object? data`, `bool isFormData = false`.
56. `DioConsumer` is the only concrete implementation of `ApiConsumer`.
57. Configure the Dio instance (`baseUrl`, interceptors) inside the `DioConsumer` constructor — not in the DI setup.
58. Always add `ApiInterceptor` first, then `LogInterceptor` in the constructor.
59. Configure `LogInterceptor` with: `request: true`, `requestBody: true`, `responseBody: true`, `requestHeader: false`, `responseHeader: false`.
60. All API endpoint path strings live in `abstract class EndPoint` as `static const String`.
61. All API JSON response key strings live in `abstract class ApiKey` as `static const String`.
62. All HTTP header key strings live in `abstract class ApiHeaderKey` as `static const String`.
63. The `getAuthorizationValue` factory method belongs on `ApiHeaderKey` as a `static String` method.
64. Token refresh logic lives exclusively inside `ApiInterceptor.onError`.
65. Use a `static Completer<bool>?` field on `ApiInterceptor` to prevent concurrent token refresh requests.
66. Create a new `Dio(BaseOptions(baseUrl: EndPoint.baseUrl))` instance for refresh token requests to avoid recursive interceptor calls.
67. Place `AuthEventBus` class and `AuthEvent` enum in the same file as `ApiInterceptor` (`api_interceptor.dart`).
68. `AuthEventBus` must be a singleton using a private constructor: `AuthEventBus._()`.
69. `NetworkInfo` is an `abstract class`; `NetworkInfoImpl` is its concrete class, placed in the same file.
70. `NetworkInfoImpl` checks connectivity by trying DNS lookup on multiple fallback hosts (never rely on a single host).

---

### Error Handling

71. Use a two-layer error system: `Exception` at the data layer, `Failure` at the domain/presentation layer.
72. All exception classes implement `Exception` interface.
73. Simple exceptions (no data) use `class OfflineException implements Exception {}`.
74. `ServerException` must carry an `ErrorModel` field.
75. `ErrorModel` is a plain (non-Equatable) class with `statusCode` and `errorMessage` fields and a `fromJson` factory.
76. `ErrorModel.fromJson` reads keys from `ApiKey` constants — never from inline string literals.
77. `Failure` is an `abstract class extends Equatable` with `required this.message`.
78. All concrete `Failure` subclasses have a `const` constructor with a default `message` value.
79. `handleDioExceptions(DioException e)` is a **top-level function** in `core/errors/exceptions.dart`.
80. `handleDioExceptions` switches on `DioExceptionType` and covers every case explicitly.
81. `badResponse` cases further switch on HTTP status code with inline comments for each code.
82. `_extractErrorModel` and `_fallbackErrorModel` are private top-level helper functions inside `exceptions.dart`.
83. Never catch generic `Exception` or `Object` in networking code — always catch `DioException` specifically.
84. Expose errors to the upper layers using `Either<Failure, T>` (from `dartz`) in repositories.

---

### Routing

85. `AppRoutes` is `abstract final class` containing only `static const String` route paths.
86. All route paths are prefixed with `k`: `static const kSplashView = '/'`.
87. The root route is always `kSplashView = '/'`.
88. `AppRouter` is `abstract final class` containing `static final router = GoRouter(...)`.
89. Custom transitions use a private `static CustomTransitionPage _buildTransitionPage(...)` method on `AppRouter`.
90. The default global transition is `FadeTransition`.
91. Do not add route parameters or extra data to `AppRoutes`; use GoRouter's `GoRouterState` for that.

---

### Theme & Constants

92. `AppTheme` (`abstract class`) exposes exactly two static getters: `lightTheme` and `darkTheme`.
93. Each theme is a top-level `final ThemeData` variable in its own file (`light_theme.dart`, `dark_theme.dart`).
94. Always set `useMaterial3: true` in both themes.
95. Always set `fontFamily: AppConstants.appFamilyFont` in both themes.
96. Always set `elevation: 0` for `ElevatedButton`, `Card`, and `AppBar`.
97. Always set `centerTitle: true` on `AppBarTheme`.
98. Light theme uses `AppColors` constants for all color values. Dark theme may use inline hex `Color(0xFF...)` values.
99. `AppColors` is `abstract class` with named `static const Color` fields grouped by semantic category (Primary, Secondary, Backgrounds, Text, Borders, Status).
100. Status colors: `success`, `warning`, `error`, `info` must always be present in `AppColors`.
101. `AppConstants` is `abstract class` holding app-wide string constants: `appFamilyFont`, `languageCode`, `defaultAvatarUrl`.
102. `AppTextStyles` is `abstract class` with `static TextStyle` fields named `{weight}{size}` (e.g., `semiBold20`, `regular14`).
103. Text styles use `flutter_screenutil`'s `.sp` for font sizes.
104. `Assets` class uses a private constructor `Assets._()` to prevent instantiation and is auto-generated into `core/utils/app_assets.dart`.

---

### Cache Layer

105. Separate storage concerns into two distinct layers: `*Helper` (raw key/value wrapper) and `*Service` (domain-semantic API).
106. `SharedPreferencesHelper` wraps `SharedPreferences` for non-sensitive, non-encrypted data.
107. `SecureStorageHelper` wraps `FlutterSecureStorage` for sensitive, encrypted data (tokens).
108. `CacheKey` is `abstract class` with all cache key strings as `static const String` constants.
109. Never use raw string literals as cache keys; always reference `CacheKey.*`.
110. `SharedPreferencesHelper.saveData` accepts `dynamic value` and dispatches by type (`String`, `int`, `bool`, `double`, `List<String>`); it throws `UnsupportedError` for unrecognized types.
111. `SecureStorageHelper` accepts an optional `FlutterSecureStorage?` in its constructor to support testing.
112. Domain services (`*Service`) must only expose semantic methods: `saveTokens`, `isLoggedIn`, `clearAuthData`, `onBoardingViewed`. Never expose raw key/value calls.
113. Group logically related cache operations into a single method when they always happen together (e.g., `clearAuthData` deletes multiple keys at once).

---

### Core Services

114. All core services live in `core/services/`.
115. `services_locator.dart` lives in `core/services/` and is the single GetIt configuration file.
116. Instance-based services use constructor injection and `const` constructors.
117. Static-only services (e.g., notification services) use only `static` members — no instance is ever created.
118. Static service initialization methods are named `init()` and return `Future<void>`.

---

### Functions (`core/functions/`)

119. Place standalone utility functions (not widgets) that are used across features in `core/functions/`.
120. Name files after the primary function they contain: `show_custom_dialog.dart`, `show_image.dart`, `show_snack_bar_function.dart`.
121. Place convenience wrappers of a base function in the **same file** as the base (e.g., `showNoInternetConnectionDialog` in `show_custom_dialog.dart`).
122. `showImage` must handle SVG, network URL, and asset path in a single function with fallback error states.
123. Core functions must not reference any feature-specific code.

---

### Shared Widgets (`core/widgets/`)

124. Place only widgets that are genuinely reused across multiple features in `core/widgets/`.
125. Use `const` constructor with `{super.key}` on every widget.
126. `StatefulWidget` must have a private `State` class: `class _MyWidgetState extends State<MyWidget>`.
127. `MainNavigationScreen` is the composition root for bottom navigation and may import feature views.
128. No other shared widget may import from `features/`.
129. Never hardcode `Colors.grey` or `Colors.black` in shared widgets — always use `AppColors` tokens.
130. Placeholder/scaffold files (e.g., `remove_me.dart`) must be deleted before release; do not commit them.

---

### Responsive UI & ScreenUtil Standards (`flutter_screenutil`)

131. **Mandatory ScreenUtil Usage**: All UI dimensions, paddings, margins, font sizes, icon sizes, and border radii MUST use `flutter_screenutil` extension methods to ensure uniform responsive design across all screen resolutions and aspect ratios.
132. **Extension Mapping**:
    - `.w` → Widths, horizontal paddings, horizontal margins, `SizedBox(width: ...)`:
      - `width: 120.w`, `padding: EdgeInsets.symmetric(horizontal: 16.w)`, `SizedBox(width: 8.w)`
    - `.h` → Heights, vertical paddings, vertical margins, `SizedBox(height: ...)`:
      - `height: 48.h`, `padding: EdgeInsets.symmetric(vertical: 12.h)`, `SizedBox(height: 16.h)`
    - `.sp` → All font sizes in `TextStyle` definitions:
      - `fontSize: 16.sp`, `fontSize: 14.sp`
    - `.r` → Radius for `BorderRadius`, circular containers, avatars, and rounded corners:
      - `BorderRadius.circular(12.r)`, `Radius.circular(8.r)`, `padding: EdgeInsets.all(16.r)`
    - `.sw` / `.sh` → Screen width/height fraction offsets:
      - `width: 0.85.sw` (85% of viewport width), `height: 0.3.sh` (30% of viewport height)
133. **Avoid Hardcoded Raw Pixel Values**: Never hardcode raw numeric literals for UI dimensions without ScreenUtil extensions inside widget `build()` methods.
134. **ScreenUtil Initialization**: Root `ScreenUtilInit` must wrap the main app in `main.dart` configured with standard design dimensions (e.g., `Size(375, 812)`), `minTextAdapt: true`, and `splitScreenMode: true`.

---

### Comments & Documentation

131. Use `///* Short description` at the top of abstract class files and top-level functions.
132. Use `///! ======================= Section =======================` for major sections inside long files (e.g., `ApiInterceptor`).
133. Use `//! ===== Section Title =====` for section headers inside a class body.
134. Use `//! ─── Section Title ───` for sub-section headers inside helper classes.
135. Use `//? ---------- Method Name ----------` to visually separate methods inside implementation classes (e.g., `DioConsumer`).
136. Use `// --- inline comment ---` to annotate blocks of code within a method body.
137. Comments must explain **intent or context**, not restate what the code does.
138. Use `//TODO: change these values` as a marker on every template value (colors, URLs, endpoints) that the developer must customize.
139. Never leave commented-out code in production files. Use Git history instead.

---

### Reusability

140. Every class in `core/` must be feature-agnostic. If you find yourself referencing a feature-specific model or Cubit inside `core/`, move the logic to the feature.
141. When a utility function or widget grows feature-specific logic over time, extract the feature-specific part back into the relevant feature module.
142. Prefer extending existing `core/` classes (e.g., adding a method to `SharedPreferencesService`) over creating a new service in a feature.

---

### Clean Code & SOLID

143. Each class has a single responsibility. `SharedPreferencesHelper` only wraps the package; `SharedPreferencesService` only provides domain-level operations. Never merge these.
144. Depend on abstractions, not concretions: register `ApiConsumer` in GetIt, not `DioConsumer`. Inject `NetworkInfo`, not `NetworkInfoImpl`.
145. Constructor injection is mandatory for all classes that depend on other services. Never use `getIt<...>()` inside a service/helper class body — only in the DI setup lambda.
146. Open/Closed: Add new HTTP methods by extending `ApiConsumer` and implementing in `DioConsumer`; do not modify existing methods.
147. Liskov Substitution: `DioConsumer` must be a perfect drop-in replacement for `ApiConsumer`. `NetworkInfoImpl` must be a perfect drop-in for `NetworkInfo`.
148. Interface Segregation: Do not add unrelated methods to `ApiConsumer`. If a new protocol is needed (e.g., WebSocket), create a separate abstract interface.

---

### What to Avoid

- **AVOID** relative imports. Always use `package:AppName/...`.
- **AVOID** `registerSingleton`. Prefer `registerLazySingleton`.
- **AVOID** resolving `getIt<T>()` inside service/helper class bodies. Use constructor injection.
- **AVOID** placing feature-specific screens, Cubits, or repositories inside `core/`.
- **AVOID** hardcoded `Color(0xFF...)` hex values in the light theme. Use `AppColors.*` constants.
- **AVOID** hardcoded string literals as cache keys. Use `CacheKey.*`.
- **AVOID** creating new `Dio()` instances anywhere except in the DI setup and the refresh token sub-request in `ApiInterceptor`.
- **AVOID** `print()` statements. The `avoid_print` lint rule enforces this.
- **AVOID** committing placeholder files (e.g., `remove_me.dart`, fully commented-out service files).
- **AVOID** catching generic `Exception` or `Object` in networking code. Catch `DioException` specifically.
- **AVOID** placing business logic inside theme files, color files, or constant files.
- **AVOID** unnecessary abstractions. If there is only one implementation and swapping is not a real requirement, a plain class is acceptable.
- **AVOID** accessing `BuildContext` after async gaps without checking `mounted` (enforced by `use_build_context_synchronously`).

---

### Decision Rules

- **If adding a new color** → add it to `AppColors` in `core/utils/app_colors.dart` with a semantic name in the appropriate group.
- **If adding a new text style** → add it to `AppTextStyles` in `core/utils/app_text_styles.dart` named `{weight}{size}`.
- **If adding a new string constant** → add it to `AppConstants` in `core/utils/app_constants.dart`.
- **If adding a new asset path** → it belongs in the auto-generated `Assets` class in `core/utils/app_assets.dart`.
- **If adding a new API endpoint** → add a `static const String` to `EndPoint` in `core/networking/api_end_points.dart`.
- **If adding a new JSON response key** → add a `static const String` to `ApiKey` in `core/networking/api_end_points.dart`.
- **If adding a new HTTP header key** → add a `static const String` to `ApiHeaderKey` in `core/networking/api_end_points.dart`.
- **If adding a new cache key** → add a `static const String` to `CacheKey` in `core/cache/cache_key.dart`.
- **If adding a new sensitive data operation** → add a semantic method to `SecureStorageService` that delegates to `SecureStorageHelper`.
- **If adding a new non-sensitive data operation** → add a semantic method to `SharedPreferencesService` that delegates to `SharedPreferencesHelper`.
- **If adding a new core infrastructure dependency** → register it as `registerLazySingleton` in `setupServiceLocator()` in the appropriate section.
- **If adding a new failure type** → create a new `*Failure` class in `core/errors/failures.dart` extending `Failure`.
- **If adding a new exception type** → create a new `*Exception` class in `core/errors/exceptions.dart` implementing `Exception`.
- **If adding a new route** → add `static const kMyView = '/myView'` to `AppRoutes` and a `GoRoute` entry in `AppRouter.router`.
- **If adding a shared UI utility function** → place it in `core/functions/` as a top-level function.
- **If a shared function has a convenience variant** → place the variant in the same file as the base function.
- **If adding a reusable widget** → place it in `core/widgets/` only if it is used in 2+ features. Otherwise, keep it in the feature.
- **Never place feature-specific logic inside `core/`** — extract it to the feature even if it creates a tiny amount of duplication.
- **Prefer `abstract class` over top-level constants** when grouping related constants. Never use a plain class with a private constructor for constants (except for the auto-generated `Assets` class).
- **When a service becomes too large**, split it into focused methods within the same class before splitting into multiple services.
- **When in doubt about registration type**, use `registerLazySingleton`. Only use `registerFactory` for feature-level Cubits/Blocs.

---

# Features Folder Coding & Architecture Rules

## Scope
These rules apply to code inside `lib/features`.

## 1. Clean Architecture Layer Responsibilities

### Presentation
- **Pages / Screens**: Top-level route widgets must be named with the `View` suffix (e.g., `LoginView`, `HomeView`, `OnboardingView`, `SplashView`) and placed under `presentation/views/`. Page widgets should be concise containers returning a `Scaffold` with `SafeArea` wrapping a body widget.
  - *Evidence (`Auth` feature, `lib/features/Auth/presentation/views/login_view.dart`):*
    ```dart
    class LoginView extends StatelessWidget {
      const LoginView({super.key});

      @override
      Widget build(BuildContext context) {
        return Scaffold(body: SafeArea(child: LoginViewBody()));
      }
    }
    ```

- **Widgets**: Component widgets must be extracted into standalone classes placed inside `presentation/widgets/` (or `presentation/views/widgets/`). Main screen content must be structured in a `<Name>ViewBody` widget (e.g., `LoginViewBody`, `HomeViewBody`).
  - *Evidence (`home` feature, `lib/features/home/presentation/views/widgets/home_view_body.dart`):*
    ```dart
    class HomeViewBody extends StatefulWidget {
      const HomeViewBody({super.key});

      @override
      State<HomeViewBody> createState() => _HomeViewBodyState();
    }
    ```

- **State Management**: Use `flutter_bloc` with **Cubit** for feature state management, placed under `presentation/manager/` or `presentation/manager/cubit/`. Cubit classes must extend `Cubit<StateClass>`. Controllers (`TextEditingController`, `GlobalKey<FormState>`) are defined inside the Cubit.
  - *Evidence (`Auth` feature, `lib/features/Auth/presentation/manager/signin_cubit/signin_cubit.dart`):*
    ```dart
    class SigninCubit extends Cubit<SigninState> {
      final AuthRepoImplementation authRepo;
      TextEditingController emailSigninController = TextEditingController();
      TextEditingController passwordSigninController = TextEditingController();
      GlobalKey<FormState> formKeySignin = GlobalKey<FormState>();

      SigninCubit({required this.authRepo}) : super(SigninInitial());
    ```

- **UI State / View Models**: State classes must be defined as Dart 3 `sealed class` hierarchies in a separate `<name>_state.dart` file using `part of '<name>_cubit.dart';`. States must model specific outcomes (e.g., `Initial`, `Loading`, `Success`, `Failure`, `NoInternetConnection`). `freezed` is NOT used.
  - *Evidence (`Auth` feature, `lib/features/Auth/presentation/manager/signin_cubit/signin_state.dart`):*
    ```dart
    part of 'signin_cubit.dart';

    @immutable
    sealed class SigninState {}

    final class SigninInitial extends SigninState {}

    final class SignInSuccess extends SigninState {
      final SignInResponseModel signinModel;
      SignInSuccess({required this.signinModel});
    }
    ```

### Domain
- **Domain Layer Missing**: Do NOT create a separate `domain/` folder for features in this codebase.
- **Entities**: Business entities are omitted as separate domain classes; data models (`UserModel`, `ProductModel`) act as both domain entities and data models.
- **Repository Interfaces**: Abstract repository interfaces live directly in `data/repositories/` (or `data/repos/`), NOT in a domain folder. Methods must return `Future<Either<Failure, T>>` using the `dartz` package and use required named parameters.
  - *Evidence (`Auth` feature, `lib/features/Auth/data/repositories/auth_repo.dart`):*
    ```dart
    abstract class AuthRepo {
      Future<Either<Failure, SignInResponseModel>> singIn({
        required String email,
        required String password,
      });
    }
    ```
- **Use Cases**: Use case / interactor classes are omitted entirely. Blocs/Cubits directly invoke repository methods.

> **Note**: This "no domain layer" convention is the default for this codebase. See Section 6 below for the alternate, fuller registration pattern (with `domain/`, UseCases, and split DataSources) to use only when a feature explicitly requires that structure (e.g., offline-first features).

### Data
- **Models**: Models are plain Dart classes with explicit constructor parameters, `factory Model.fromJson(Map<String, dynamic> json)` constructors, and `Map<String, dynamic> toJson()` methods. Do NOT use `freezed` or `json_serializable`.
  - *Evidence (`home` feature, `lib/features/home/data/models/product_model/product_model.dart`):*
    ```dart
    factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as num,
      title: json['title'] as String,
      price: json['price'] as num,
      description: json['description'] as String,
      images: List<String>.from(json['images']),
    );
    ```

- **Repository Implementations**: Implement abstract repositories in `data/repositories/` (or `data/repos/`) with the suffix `RepoImpl` or `RepoImplementation`. Map errors to `Left(Failure(errorMessage: ...))` and data to `Right(...)`. Check internet connectivity using `InternetConnection()` before network calls.
  - *Evidence (`Auth` feature, `lib/features/Auth/data/repositories/auth_repo_implementation.dart`):*
    ```dart
    class AuthRepoImplementation extends AuthRepo {
      AuthRepoImplementation({required this.dioConsumer});
      final DioConsumer dioConsumer;
      
      @override
      Future<Either<Failure, SignInResponseModel>> singIn({
        required String email,
        required String password,
      }) async {
        if (!await _isConnectedToInternet()) {
          return const Left(Failure(errorMessage: AppConstants.noInternetConnection));
        }
    ```

- **Data Sources**: Separate data source classes (`remote_data_source.dart`, `local_data_source.dart`) are omitted. Repository implementations interact directly with `DioConsumer`, `SecureStorageService`, `SharedPreferencesService`, and `CacheHelper`.

### Dependency Injection
- Register feature repositories centrally inside `lib/config/services/services_locator.dart` using `GetIt`.
- Concrete implementation classes are registered as singletons:
  - *Evidence (`lib/config/services/services_locator.dart`):*
    ```dart
    getIt.registerSingleton<AuthRepoImplementation>(
      AuthRepoImplementation(dioConsumer: DioConsumer(dio: getIt<Dio>())),
    );
    getIt.registerSingleton<ProductsRepoImpl>(
      ProductsRepoImpl(dioConsumer: DioConsumer(dio: getIt<Dio>())),
    );
    ```

---

## 2. Widget Structure Conventions

1. **Composition Style**: Keep `build()` methods clean by delegating layout sections to extracted widget classes in standalone files. Avoid `_build...` helper methods inside the view class.
   - *Evidence (`Auth` feature, `lib/features/Auth/presentation/widgets/login_view_body.dart`):*
     ```dart
     CustomTitleScreenWidget(title: S.of(context).welcomeBack),
     SizedBox(height: 36.h),
     LoginFormWidget(),
     SizedBox(height: 9.h),
     ForgetPasswordTextWidget(),
     ```

2. **StatelessWidget vs. StatefulWidget**:
   - Default to `StatelessWidget` whenever possible.
   - Use `StatefulWidget` only when managing local animation/page controllers, `initState()` triggers (e.g. initial data fetch), or ephemeral UI state.
   - *Evidence (`home` feature, `lib/features/home/presentation/views/widgets/home_view_body.dart`):*
     ```dart
     @override
     void initState() {
       super.initState();
       context.read<ProductsCubit>().fetchProducts();
     }
     ```

3. **Constructors**: Use `const` constructors with `super.key` shorthand. Pass required parameters as named arguments.
   - *Evidence (`home` feature, `lib/features/home/presentation/views/widgets/big_ad_banner.dart`):*
     ```dart
     const BigAdBanner({
       super.key,
       required this.image,
       required this.title,
       required this.subtitle,
       required this.action,
     });
     ```

4. **Styling Approach & Responsive Design (`flutter_screenutil`)**:
   - Access colors via `AppColors.<colorName>` tokens from `core/utils/app_colors.dart`.
   - Apply `flutter_screenutil` extension methods (`.w`, `.h`, `.sp`, `.r`, `.sw`, `.sh`) on ALL dimensions, paddings, margins, border radii, and font sizes:
     - `.w` for width, horizontal padding, horizontal margin, `SizedBox(width: ...)`
     - `.h` for height, vertical padding, vertical margin, `SizedBox(height: ...)`
     - `.sp` for font sizes in `TextStyle` and icon sizes
     - `.r` for `BorderRadius.circular(...)`, circular containers, and icon radii
     - `.sw` / `.sh` for screen width/height percentages (e.g., `0.8.sw` for 80% screen width)
   - Access localized strings via `S.of(context).<key>`.
   - *Evidence (`Auth` feature, `lib/features/Auth/presentation/widgets/login_view_body.dart`):*
     ```dart
     padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
     CustomTitleScreenWidget(title: S.of(context).welcomeBack),
     ```

5. **Layout & Spacing**:
   - Preferred layout containers are `Column`, `Row`, `ListView`, and `PageView`.
   - Use `SizedBox(height: xx.h)` for vertical spacing between widgets. Private local helper widgets like `_StaticSizedBox` may be used for uniform list item gaps.
   - *Evidence (`home` feature, `lib/features/home/presentation/views/widgets/home_view_body.dart`):*
     ```dart
     class _StaticSizedBox extends StatelessWidget {
       const _StaticSizedBox();
       final double height = 16;
       @override
       Widget build(BuildContext context) {
         return SizedBox(height: height.h);
       }
     }
     ```

6. **Reusable Widget Extraction**:
   - Extract widgets into standalone files inside `widgets/` as soon as they form a logical section (form section, header, banner, tile, item card).

7. **Widget Naming Conventions**:
   - Top-level routes: `<Feature>View` (e.g. `LoginView`, `HomeView`).
   - Screen main bodies: `<Feature>ViewBody` (e.g. `LoginViewBody`, `HomeViewBody`).
   - Functional UI units: `*Widget` (e.g. `LoginFormWidget`, `UpperBarWidget`), `*Bar` (e.g. `CategoriesBar`, `CustomFilterBar`), `*Banner` (e.g. `BigAdBanner`, `SpecialOfferBanner`), `*Card` (e.g. `PromoBannerCard`).

---

## 3. Method Conventions

1. **Method Granularity**: Keep methods concise (10–30 lines) with single responsibility.
2. **Parameter Style**: Use named parameters with `required` for 2+ arguments.
3. **Return Types**: Always declare explicit return types (`Future<Either<Failure, T>>`, `Future<void>`, `void`). Do not rely on type inference for method signatures.
   - *Evidence (`home` feature, `lib/features/home/data/repos/products_repo.dart`):*
     ```dart
     Future<Either<Failure, List<ProductModel>>> getProducts({
       required int limit,
       required int offset,
     });
     ```
4. **Async Patterns**:
   - Use `async`/`await` exclusively. Do NOT use `.then()`.
   - Handle exceptions with `try ... on ServerException catch (e)` or `on DioException catch (e)`.
   - Process `Either` results in Cubits using `.fold()`:
   - *Evidence (`Auth` feature, `lib/features/Auth/presentation/manager/signin_cubit/signin_cubit.dart`):*
     ```dart
     response.fold(
       (leftSide) {
         emit(SignInFailure(errorMessage: leftSide.errorMessage));
       },
       (rightSide) {
         emit(SignInSuccess(signinModel: rightSide));
       },
     );
     ```
5. **Extension Methods**:
   - Use `flutter_screenutil` num extensions (`.w`, `.h`, `.sp`, `.r`) for layout numbers.
6. **Helper & Utility Placement**:
   - Shared UI functions (dialogs, snackbars, image loaders) live in `core/functions/`.
   - Feature-specific helpers live in `presentation/helpers/` or within the feature file.

---

## 4. Package Usage

| Package | Purpose | Usage Pattern | Notes / Inconsistencies |
|---|---|---|---|
| `flutter_bloc` | State Management | `Cubit<StateClass>` used per feature view. `BlocConsumer` handles UI rebuilds (`builder`) and side-effects like navigation/snackbars (`listener`). | Blocs with events are not used; Cubits with direct method invocation are preferred. |
| `dartz` | Functional Error Handling | Repositories return `Future<Either<Failure, T>>`. Calling code uses `.fold()` or `.isRight()`. | Used consistently across data and presentation layers. |
| `dio` | HTTP Client | Network requests executed via `DioConsumer` wrapper from `core/networking/dio_consumer.dart`. | Low-level `Dio` is injected via `GetIt`. |
| `flutter_screenutil` | Responsive Layout | Sizing applied with extensions (`.w`, `.h`, `.sp`, `.r`). Top-level `ScreenUtilInit` configured in `main.dart`. | Standardized across all widget views. |
| `go_router` | Routing & Navigation | `context.go(AppRoutes.kHomeView)` used for screen transitions. | Path constants defined in `AppRoutes`. |
| `get_it` | Service Locator | Repositories registered as singletons in `services_locator.dart`. | Concrete implementations are registered rather than abstract interfaces. |
| `internet_connection_checker_plus` | Internet Check | `InternetConnection().hasInternetAccess` checked in repository implementations before making Dio requests. | Wrapped in private repo helper `_isConnectedToInternet()`. |
| `jwt_decoder` | Token Parsing | `JwtDecoder.decode(accessToken)` used in `AuthRepoImplementation` to extract user ID. | Used in `Auth` feature repository. |

---

## 5. Notes & Inconsistencies

1. **Feature Directory Naming Casing**:
   - `lib/features/Auth` uses PascalCase (`Auth`), whereas `lib/features/home`, `lib/features/onboarding`, and `lib/features/splash` use lowercase.
   - *Standardization Rule*: Standardize all feature folder names to **lowercase** (e.g., `lib/features/auth`).

2. **Widgets Subfolder Path Variance**:
   - `Auth` and `onboarding` place widgets in `presentation/widgets/`.
   - `home` places widgets in `presentation/views/widgets/`.
   - *Standardization Rule*: Standardize widget folder placement to `presentation/widgets/`.

3. **Repository Subfolder Naming Variance**:
   - `Auth` uses `data/repositories/` while `home` uses `data/repos/`.
   - *Standardization Rule*: Standardize folder name to `data/repos/` (or `data/repositories/`).

4. **Widget Filename Casing**:
   - `Second_big_ad_banner.dart` and `Products_list_loading.dart` in `home` use mixed Pascal/snake_case filenames.
   - *Standardization Rule*: Enforce strict `snake_case` for all dart filenames (e.g., `second_big_ad_banner.dart`, `products_list_loading.dart`).

5. **DI Registration Pattern**:
   - `services_locator.dart` registers concrete repo implementations (`AuthRepoImplementation`, `ProductsRepoImpl`) with `registerSingleton`.
   - *Standardization Rule*: Register abstract types with `registerLazySingleton<ProductsRepo>(() => ProductsRepoImpl(...))` to align with `core` DI conventions.

6. **Hardcoded Mock Data in View Body**:
   - In `home_view_body.dart` (lines 160-200), static `ProductModel` objects are instantiated inside `HorizontalProductList` rather than fetched through a Cubit.
   - *Standardization Rule*: All dynamic list data must be provided by a Cubit state.

---

## 6. Service Locator Rules — Extended Domain-Layer Variant

> **Source**: Derived from a separate reference project's `service_locator.dart` (Clean Architecture with a real `domain/` layer, UseCases, and split remote/local data sources — e.g. `clean_architecutre_posts_app`). Apply this variant **instead of** the leaner Section 1 "Domain Layer Missing" convention only when a feature explicitly needs a `domain/` folder, UseCases, and/or offline caching via split data sources. Otherwise, default to the leaner `mathcIn_flutter` convention above.

### Structure & Section Ordering

1. Organize `setupServiceLocator()` into exactly three top-level blocks, each opened with a `//! ========= Section Name ==========` comment, in this order:
   1. `Features - <FeatureName>` (one block per feature, repeated as features are added)
   2. `Core`
   3. `External`
2. Within a feature's block, register in this exact sub-order, each sub-group separated by a `// ---> SubGroup <---` comment:
   1. `// ---> Bloc <---`
   2. `// ---> Usecases <---`
   3. `// ---> Repository <---`
   4. `// ---> Data Source <---` (remote first, then local, each with a short lowercase inline comment: `//remote`, `//local`)
3. Under the `Core` block, register infrastructure shared across features but not bootstrapped by `core/services/services_locator.dart` itself (e.g., `Connectivity`, `NetworkInfo`).
4. Under the `External` block, register third-party package instances last, in this order: async-initialized packages first (e.g., `SharedPreferences.getInstance()`, awaited before registration), then the cache wrapper built on top of them (e.g., `CacheHelper`), then the raw HTTP client (`Dio()`), then the API consumer wrapper (`DioConsumer`) last, since it depends on `Dio`.

### Registration Types by Layer

5. Register Blocs with `registerFactory` — never `registerLazySingleton` or `registerSingleton` — so each screen/subscription gets a fresh instance.
6. Split a feature's Bloc by responsibility when reads and writes are logically distinct: a `Get<Feature>Bloc` for fetching/listing, and a separate `AddDeleteUpdate<Feature>Bloc` for create/delete/update, each registered as its own `registerFactory`.
7. Register UseCases with `registerLazySingleton`, one class per domain operation (e.g., `GetAllPostsUsecase`, `CreatePostUsecase`, `DeletePostUsecase`, `UpdatePostUsecase`), each resolving its repository dependency via `getIt()` inside the factory lambda.
8. Register the Repository against its **abstract type** (e.g., `PostRepo`), never the concrete `*RepoImpl`, injecting `networkInfo` plus both local and remote data sources via `getIt()`.
9. When a feature supports offline access, split data access into two abstract interfaces — `<Feature>RemoteDataSource` and `<Feature>LocalDataSource` — and register each against its abstract type with `registerLazySingleton`.
10. Register `NetworkInfo` against its abstract type with `registerLazySingleton`, injecting a `registerLazySingleton(() => Connectivity())` instance.
11. Register `SharedPreferences` only after `await`-ing `SharedPreferences.getInstance()`; never register the unresolved `Future`.
12. Register the feature-facing cache wrapper (`CacheHelper`) with `registerLazySingleton`, injecting `SharedPreferences` via `getIt()`. `CacheHelper` plays the same architectural role here as `SharedPreferencesHelper`/`SharedPreferencesService` do in the leaner `core/` convention.
13. Register `Dio()` bare (no `BaseOptions`) with `registerLazySingleton`, then register `DioConsumer` against its own type last, injecting `Dio` via `getIt()`.

### Naming Conventions for This Variant

14. Name UseCase classes `<Verb><Feature>Usecase` (e.g., `GetAllPostsUsecase`, `CreatePostUsecase`, `DeletePostUsecase`, `UpdatePostUsecase`).
15. Name split Blocs `Get<Feature>Bloc` (read) and `AddDeleteUpdate<Feature>Bloc` (write), not a single monolithic `<Feature>Bloc`.
16. Name remote data source implementations with an explicit client suffix when the client could be swapped, e.g., `<Feature>RemoteDataSourceImplWithDio`.
17. Name local data source implementations `<Feature>LocalDataSourceImpl`, injecting the shared `CacheHelper`.
930: 18. Name the abstract data source interfaces `<Feature>RemoteDataSource` and `<Feature>LocalDataSource`.
931: 
932: ### What to Avoid in This Variant
933: 
934: - **AVOID** registering Blocs with anything other than `registerFactory`.
935: - **AVOID** registering `SharedPreferences` before awaiting `getInstance()`.
936: - **AVOID** collapsing remote and local data sources into the repository implementation directly — keep them as separate injected classes so the repository stays a pure coordinator.
937: - **AVOID** mixing this variant's three-block (`Features` / `Core` / `External`) section structure with the leaner `core/` convention's seven-step flat ordering in the same file — pick one structure per project and apply it consistently.
938: 
939: ---
940: 
941: ## File Size & Widget Separation Rules
942: 
943: - **Small Files**: Keep Dart files small and focused.
944: - **One Responsibility Per File**: A file should primarily represent one meaningful widget/component or one focused responsibility.
945: - **Extract Meaningful Widgets**: If a UI section has a meaningful name or independent responsibility, extract it into its own file in `widgets/`.
946: - **Avoid Giant `build()` Methods**: Avoid large `build()` methods and deeply nested widget trees by extracting child sections into modular widgets.
947: - **Avoid Widget Dump Files**: Do not put many private widgets into a single large screen file. Move meaningful sub-widgets to separate files.
948: - **Do Not Over-Split**: Do not create separate files for meaningless tiny fragments or simple inline UI details. The goal is small meaningful files, not maximum file count.
949: - **Separate UI From Business Logic**: Keep Cubit/Bloc/domain business logic separate from reusable presentation widgets.
950: - **Reusable Widgets Must Be Decoupled**: Reusable widgets must receive data and callbacks via constructor parameters rather than directly accessing feature-specific Cubits.
951: - **Use File Size as a Warning Signal**:
952:   - Files approaching **150–200 lines** should be reviewed for extraction opportunities.
953:   - Files over **250 lines** should generally be refactored unless there is a clear architectural reason.
954: - **Follow Project Architecture & System Patterns**:
955:   - New widgets must follow the feature-based folder structure (`presentation/widgets/`).
956:   - Preserve Clean Architecture, SOLID principles, localization (`S.of(context)`), theme system (`Theme.of(context)`), and responsive layout (`flutter_screenutil`).
957: - **Composition-First Views**: Top-level page views should primarily act as screen composers, composing extracted sub-widgets rather than implementing long UI trees inline.
958: - **Before Modifying Large Files**: Check whether new or existing UI sections should be extracted into separate files rather than increasing file complexity.