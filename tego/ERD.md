# Entity Relationship Diagram (ERD) - Tego App

## Database Structure

### Collections Overview

```
Firestore Database
├── users/{userId}
│   ├── email: string
│   ├── displayName: string
│   ├── lastSignIn: timestamp
│   ├── totalSalesCount: number (maintained by Cloud Functions)
│   └── totalAmount: number (maintained by Cloud Functions)
│
├── users/{userId}/sales/{saleId}
│   ├── amount: number
│   ├── date: string (DD-MM-YYYY format)
│   └── timestamp: timestamp
│
└── users/{userId}/expenses/{expenseId}
    ├── amount: number
    ├── category: string
    ├── description: string
    ├── date: string (DD-MM-YYYY format)
    └── timestamp: timestamp
```

## Entity Details

### 1. Users Collection
- **Path**: `users/{userId}`
- **Primary Key**: userId (Firebase Auth UID)
- **Attributes**:
  - `email` (string): User's email address
  - `displayName` (string): User's display name
  - `lastSignIn` (timestamp): Last sign-in time
  - `totalSalesCount` (number): Total number of sales (computed)
  - `totalAmount` (number): Total sales amount (computed)

### 2. Sales Subcollection
- **Path**: `users/{userId}/sales/{saleId}`
- **Primary Key**: saleId (auto-generated)
- **Foreign Key**: userId (parent document)
- **Attributes**:
  - `amount` (number): Sale amount in RWF
  - `date` (string): Sale date in DD-MM-YYYY format
  - `timestamp` (timestamp): Server timestamp for ordering

### 3. Expenses Subcollection
- **Path**: `users/{userId}/expenses/{expenseId}`
- **Primary Key**: expenseId (auto-generated)
- **Foreign Key**: userId (parent document)
- **Attributes**:
  - `amount` (number): Expense amount in RWF
  - `category` (string): Expense category (Rent, Utilities, etc.)
  - `description` (string): Expense description
  - `date` (string): Expense date in DD-MM-YYYY format
  - `timestamp` (timestamp): Server timestamp for ordering

## Relationships

1. **One-to-Many**: User → Sales
   - One user can have many sales records
   - Sales are stored as subcollection under user document

2. **One-to-Many**: User → Expenses
   - One user can have many expense records
   - Expenses are stored as subcollection under user document

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Sales subcollection
      match /sales/{saleId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Expenses subcollection
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Indexes

- **Sales**: Composite index on `timestamp` (descending) for pagination
- **Expenses**: Composite index on `timestamp` (descending) for pagination
- **Expenses**: Single field index on `category` for filtering

## Data Validation

- All amounts must be positive numbers
- Dates must be in DD-MM-YYYY format
- Categories are restricted to predefined list
- Authentication required for all operations