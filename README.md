# Tego - Mobile Ledger for Small Businesses

A Flutter mobile application that serves as a digital ledger for informal and small businesses in Rwanda, helping them track income and expenses to build financial history for credit opportunities.

## Features

- **Sales Management**: Record and track daily sales
- **Expense Management**: Record expenses by category (Rent, Utilities, Supplies, etc.)
- **Dashboard Analytics**: View financial summaries and trends
- **User Authentication**: Email/password and Google Sign-in
- **Offline Support**: Works without internet connection
- **Data Synchronization**: Automatic sync when online
- **Multi-language Support**: English and Kinyarwanda

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/desparvis/tego.git
   cd tego/tego
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password and Google)
   - Enable Firestore Database
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place files in respective platform folders

4. **Run the app**
   ```bash
   flutter run
   ```

### Testing

Run unit tests:
```bash
flutter test test/unit_test.dart
```

Run widget tests:
```bash
flutter test test/widget_test_expense.dart
```

Run all tests:
```bash
flutter test
```

### Code Quality

Check code quality:
```bash
flutter analyze
```

Format code:
```bash
dart format .
```

## Architecture

The app follows Clean Architecture principles with BLoC state management:

```
lib/
├── core/
│   ├── constants/
│   ├── services/
│   └── utils/
├── data/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

## Database Structure

### Collections

- **users/{userId}**: User profile and settings
- **users/{userId}/sales**: Sales transactions
- **users/{userId}/expenses**: Expense transactions

### Security Rules

- Users can only access their own data
- Authentication required for all operations
- Read/write permissions based on user ownership

## Known Limitations

- Currently supports only RWF currency
- Limited to basic expense categories
- No data export functionality yet
- Requires internet for initial setup

## Future Work

- Add more currencies
- Implement data export (PDF/Excel)
- Add inventory management
- Customer management features
- Advanced analytics and reporting
- Backup and restore functionality

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Team

- Glory Ojimaojo Paul
- Desparvis Credo Gutabarwa
- Monica Akoi Dau Ahol
- Kayonga Elvis
