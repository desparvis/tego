# Project Structure and Organization

The project follows a strict folder structure to maintain the Clean Architecture separation.

```
lib/
├── core/                   # Core functionality
│   ├── constants/          # App constants and configuration
│   ├── error/              # Failure definitions
│   ├── navigation/         # App routing and navigation
│   ├── services/           # External services (Firestore, Auth)
│   ├── state/              # State management utilities
│   └── utils/              # Constants and helpers
├── data/                   # Data Layer
│   └── repositories/       # Repository implementations
├── domain/                 # Domain Layer
│   ├── entities/           # Business objects
│   ├── repositories/       # Interfaces
│   └── usecases/           # Business logic units
├── presentation/           # Presentation Layer
│   ├── bloc/               # State management (BLoC)
│   ├── pages/              # Screens
│   └── widgets/            # Reusable components
├── l10n/                   # Internationalization
│   ├── app_en.arb          # English translations
│   ├── app_rw.arb          # Kinyarwanda translations
│   └── app_localizations.dart
├── firebase_options.dart   # Firebase configuration
└── main.dart               # Entry point
```

## Clean Architecture Layers

### Core Layer (`lib/core/`)
- **constants/**: Application-wide constants and configuration
- **error/**: Custom failure and error definitions
- **navigation/**: App routing and navigation logic
- **services/**: External service integrations (Firebase, Auth)
- **state/**: State management utilities and observers
- **utils/**: Helper functions, validators, formatters

### Data Layer (`lib/data/`)
- **repositories/**: Concrete implementations of repository interfaces
  - `expense_repository_impl.dart`
  - `sales_repository_impl.dart`

### Domain Layer (`lib/domain/`)
- **entities/**: Pure business objects without external dependencies
  - `sale.dart`, `expense.dart`, `user.dart`, `inventory_item.dart`
- **repositories/**: Abstract repository interfaces
- **usecases/**: Business logic units and use cases

### Presentation Layer (`lib/presentation/`)
- **bloc/**: BLoC state management classes
- **pages/**: Screen/page widgets
- **widgets/**: Reusable UI components

### Internationalization (`lib/l10n/`)
- Multi-language support (English and Kinyarwanda)
- ARB files for translations
- Generated localization classes

## Architecture Benefits

1. **Separation of Concerns**: Each layer has distinct responsibilities
2. **Testability**: Easy to unit test business logic independently
3. **Maintainability**: Clear structure makes code easy to maintain
4. **Scalability**: Easy to add new features without affecting existing code
5. **Independence**: Domain layer is independent of external frameworks
6. **Flexibility**: Easy to swap implementations (e.g., different databases)

## Dependency Flow

```
Presentation → Domain ← Data
     ↓           ↑        ↑
   Core ←────────┴────────┘
```

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Core** is used by all layers
- **Domain** has no dependencies on other layers