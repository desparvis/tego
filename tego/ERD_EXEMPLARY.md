# Exemplary Entity Relationship Diagram (ERD) - Tego App

## Database Architecture Overview

```
Firestore Database (tego-d918b)
├── users/{userId} [Document]
│   ├── email: string
│   ├── displayName: string
│   ├── lastSignIn: timestamp
│   ├── totalSalesCount: number (Cloud Function maintained)
│   ├── totalAmount: number (Cloud Function maintained)
│   ├── todaySalesCount: number (Cloud Function maintained)
│   └── lastSaleAt: timestamp (Cloud Function maintained)
│
├── users/{userId}/sales/{saleId} [Subcollection]
│   ├── amount: number (positive, required)
│   ├── date: string (DD-MM-YYYY format, required)
│   ├── timestamp: timestamp (server timestamp)
│   └── userId: string (ownership field)
│
└── users/{userId}/expenses/{expenseId} [Subcollection]
    ├── amount: number (positive, required)
    ├── category: string (predefined categories, required)
    ├── description: string (required)
    ├── date: string (DD-MM-YYYY format, required)
    └── timestamp: timestamp (server timestamp)
```

## Entity Specifications

### 1. Users Collection
- **Collection Path**: `users`
- **Document ID**: `{userId}` (Firebase Auth UID)
- **Security**: Owner-only access
- **Fields**:
  - `email`: string - User's authentication email
  - `displayName`: string - User's display name
  - `lastSignIn`: timestamp - Last authentication timestamp
  - `totalSalesCount`: number - Aggregate count (Cloud Function)
  - `totalAmount`: number - Aggregate sales total (Cloud Function)
  - `todaySalesCount`: number - Daily sales count (Cloud Function)
  - `lastSaleAt`: timestamp - Last sale timestamp (Cloud Function)

### 2. Sales Subcollection
- **Collection Path**: `users/{userId}/sales`
- **Document ID**: `{saleId}` (auto-generated)
- **Parent**: User document
- **Security**: Owner-only access with validation
- **Fields**:
  - `amount`: number - Sale amount in RWF (positive, required)
  - `date`: string - Sale date in DD-MM-YYYY format (required)
  - `timestamp`: timestamp - Server timestamp for ordering
  - `userId`: string - Ownership verification field

### 3. Expenses Subcollection
- **Collection Path**: `users/{userId}/expenses`
- **Document ID**: `{expenseId}` (auto-generated)
- **Parent**: User document
- **Security**: Owner-only access with validation
- **Fields**:
  - `amount`: number - Expense amount in RWF (positive, required)
  - `category`: string - Expense category (required, validated)
  - `description`: string - Expense description (required)
  - `date`: string - Expense date in DD-MM-YYYY format (required)
  - `timestamp`: timestamp - Server timestamp for ordering

## Relationships & Constraints

### Primary Relationships
1. **User ← Sales** (One-to-Many)
   - One user owns multiple sales records
   - Subcollection ensures data isolation
   - Cascade delete on user deletion

2. **User ← Expenses** (One-to-Many)
   - One user owns multiple expense records
   - Subcollection ensures data isolation
   - Cascade delete on user deletion

### Data Constraints
- **Authentication**: All operations require valid Firebase Auth
- **Ownership**: Users can only access their own data
- **Validation**: Required fields enforced at security rule level
- **Positive Amounts**: All monetary values must be > 0
- **Date Format**: Consistent DD-MM-YYYY string format
- **Categories**: Expenses limited to predefined categories

## Security Rules Implementation

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents: owner-only access
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Sales subcollection with validation
      match /sales/{saleId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        allow create: if request.auth != null
                      && request.auth.uid == userId
                      && request.resource.data.keys().hasAll(['amount', 'date'])
                      && request.resource.data.amount is number
                      && request.resource.data.amount > 0
                      && request.resource.data.date is string
                      && request.resource.data.date.matches('^[0-9]{2}-[0-9]{2}-[0-9]{4}$');
      }

      // Expenses subcollection with validation
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        allow create: if request.auth != null
                      && request.auth.uid == userId
                      && request.resource.data.keys().hasAll(['amount', 'category', 'description', 'date'])
                      && request.resource.data.amount is number
                      && request.resource.data.amount > 0
                      && request.resource.data.category in ['Rent', 'Utilities', 'Supplies', 'Marketing', 'Transport', 'Other']
                      && request.resource.data.description is string
                      && request.resource.data.date is string
                      && request.resource.data.date.matches('^[0-9]{2}-[0-9]{2}-[0-9]{4}$');
      }
    }
  }
}
```

## Required Firestore Indexes

### Composite Indexes
1. **Sales Collection**:
   - Collection: `users/{userId}/sales`
   - Fields: `timestamp` (Descending)
   - Purpose: Pagination and real-time ordering

2. **Expenses Collection**:
   - Collection: `users/{userId}/expenses`
   - Fields: `timestamp` (Descending)
   - Purpose: Pagination and real-time ordering

3. **Expenses by Category**:
   - Collection: `users/{userId}/expenses`
   - Fields: `category` (Ascending), `timestamp` (Descending)
   - Purpose: Category filtering with date ordering

### Single Field Indexes
- `timestamp` fields (auto-created)
- `category` field for expenses (for filtering)

## Cloud Functions Integration

### Triggers
1. **onSaleCreate**: Increments user aggregates
2. **onSaleDelete**: Decrements user aggregates
3. **onSaleUpdate**: Adjusts aggregates by delta
4. **resetTodaySalesCount**: Daily scheduled reset

### Maintained Fields
- `totalSalesCount`: Real-time sales count
- `totalAmount`: Real-time sales total
- `todaySalesCount`: Daily sales count
- `lastSaleAt`: Last sale timestamp

## Data Consistency Features

### No Duplicated Data
- User profile stored once in user document
- Sales/expenses use subcollections (no duplication)
- Aggregates computed by Cloud Functions
- No redundant user data in subcollections

### Referential Integrity
- Subcollections automatically deleted with parent
- userId field ensures ownership verification
- Server timestamps prevent client manipulation
- Atomic operations via Cloud Functions

## Performance Optimizations

### Indexing Strategy
- Composite indexes for common query patterns
- Single field indexes for filtering
- Descending timestamp for recent-first ordering

### Query Patterns
- Paginated queries using `startAfter`
- Real-time listeners for live updates
- Efficient filtering by category and date range

### Offline Support
- Firestore offline persistence enabled
- Local cache for read operations
- Automatic sync when online

## Validation & Error Handling

### Client-Side Validation
- Required field validation in domain entities
- Type safety with Dart strong typing
- Input sanitization before submission

### Server-Side Validation
- Security rules enforce data integrity
- Cloud Functions validate business logic
- Automatic rollback on validation failures

### Error Recovery
- Retry mechanisms for network failures
- Graceful degradation for offline scenarios
- User-friendly error messages

## Scalability Considerations

### Collection Design
- Subcollections scale independently
- No hot-spotting with auto-generated IDs
- Efficient pagination with cursor-based queries

### Performance Monitoring
- Cloud Function execution metrics
- Query performance tracking
- Real-time error monitoring

### Future Extensibility
- Schema allows for additional fields
- Subcollection pattern supports new entity types
- Cloud Functions enable complex business logic