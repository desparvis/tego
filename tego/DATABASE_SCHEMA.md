# Tego Database Schema Documentation

## Overview
This document provides the complete database schema for the Tego mobile ledger application, ensuring exemplary compliance with Firestore best practices.

## Collection Structure

### 1. Users Collection (`users/{userId}`)

**Purpose**: Store user profile and aggregate data
**Document ID**: Firebase Auth UID
**Access**: Owner-only

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `email` | string | Yes | User's email address | Valid email format |
| `displayName` | string | Yes | User's display name | Non-empty string |
| `lastSignIn` | timestamp | No | Last authentication time | Server timestamp |
| `totalSalesCount` | number | No | Total sales count | Non-negative integer |
| `totalAmount` | number | No | Total sales amount | Non-negative number |
| `todaySalesCount` | number | No | Today's sales count | Non-negative integer |
| `lastSaleAt` | timestamp | No | Last sale timestamp | Server timestamp |

### 2. Sales Subcollection (`users/{userId}/sales/{saleId}`)

**Purpose**: Store individual sale transactions
**Document ID**: Auto-generated
**Access**: Owner-only with validation

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `amount` | number | Yes | Sale amount in RWF | Positive number > 0 |
| `date` | string | Yes | Sale date | DD-MM-YYYY format |
| `timestamp` | timestamp | Auto | Server timestamp | Auto-generated |
| `userId` | string | Auto | Owner verification | Matches auth UID |

### 3. Expenses Subcollection (`users/{userId}/expenses/{expenseId}`)

**Purpose**: Store individual expense transactions
**Document ID**: Auto-generated
**Access**: Owner-only with validation

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `amount` | number | Yes | Expense amount in RWF | Positive number > 0 |
| `category` | string | Yes | Expense category | Predefined categories |
| `description` | string | Yes | Expense description | Non-empty string |
| `date` | string | Yes | Expense date | DD-MM-YYYY format |
| `timestamp` | timestamp | Auto | Server timestamp | Auto-generated |

## Predefined Categories

Expense categories are restricted to:
- `Rent`
- `Utilities`
- `Supplies`
- `Marketing`
- `Transport`
- `Other`

## Security Rules

### Authentication Requirements
- All operations require valid Firebase Authentication
- Users can only access their own data
- No cross-user data access permitted

### Field Validation
- **Amount fields**: Must be positive numbers
- **Date fields**: Must match DD-MM-YYYY format
- **Category fields**: Must be from predefined list
- **Description fields**: Must be non-empty strings

### Operation Permissions
- **Read**: Owner-only access to all collections
- **Write**: Owner-only with field validation
- **Create**: Requires all mandatory fields
- **Update**: Maintains field validation
- **Delete**: Owner-only access

## Indexes Configuration

### Composite Indexes
1. **Sales by timestamp**: `timestamp DESC` for pagination
2. **Expenses by timestamp**: `timestamp DESC` for pagination
3. **Expenses by category**: `category ASC, timestamp DESC` for filtering
4. **Sales by date**: `date ASC, timestamp DESC` for date queries
5. **Expenses by date**: `date ASC, timestamp DESC` for date queries

### Single Field Indexes
- `timestamp` fields (ascending/descending)
- `category` field (ascending)
- `date` fields (ascending)

## Cloud Functions

### Triggers
1. **onSaleCreate**: Increments user aggregates when sale is added
2. **onSaleDelete**: Decrements user aggregates when sale is removed
3. **onSaleUpdate**: Adjusts aggregates when sale amount changes
4. **resetTodaySalesCount**: Daily reset of today's sales count

### Maintained Fields
- `totalSalesCount`: Real-time count of all sales
- `totalAmount`: Real-time sum of all sales amounts
- `todaySalesCount`: Count of sales for current day
- `lastSaleAt`: Timestamp of most recent sale

## Data Consistency

### No Duplication
- User data stored once in user document
- Sales/expenses use subcollections (no redundancy)
- Aggregates computed by Cloud Functions
- No user data duplicated in subcollections

### Referential Integrity
- Subcollections cascade delete with parent
- `userId` field ensures ownership verification
- Server timestamps prevent client manipulation
- Atomic operations via Cloud Functions

## Performance Optimizations

### Query Patterns
- Paginated queries using cursor-based pagination
- Real-time listeners for live data updates
- Efficient filtering by category and date
- Optimized ordering by timestamp

### Caching Strategy
- Firestore offline persistence enabled
- Local cache for frequently accessed data
- Automatic synchronization when online
- Optimistic updates for better UX

## Deployment

### Prerequisites
- Firebase CLI installed and authenticated
- Project configured: `tego-d918b`
- Proper permissions for Firestore deployment

### Deployment Commands
```bash
# Deploy security rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# Deploy Cloud Functions
firebase deploy --only functions

# Deploy all Firestore configuration
firebase deploy --only firestore,functions
```

### Verification
1. **Security Rules**: Check Firebase Console → Firestore → Rules
2. **Indexes**: Check Firebase Console → Firestore → Indexes
3. **Functions**: Check Firebase Console → Functions → Dashboard

## Monitoring & Maintenance

### Performance Monitoring
- Query performance tracking
- Index usage analysis
- Cloud Function execution metrics
- Error rate monitoring

### Data Integrity Checks
- Regular validation of aggregate fields
- Orphaned document detection
- Data consistency verification
- Security rule compliance audits

## Migration & Backup

### Data Export
- Firestore export for backup purposes
- Scheduled exports for disaster recovery
- Data anonymization for development

### Schema Evolution
- Backward-compatible field additions
- Gradual migration strategies
- Version-controlled schema changes
- Rollback procedures

## Compliance & Security

### Data Privacy
- User data isolation via subcollections
- No cross-user data leakage
- Secure authentication requirements
- GDPR-compliant data handling

### Access Control
- Role-based access via security rules
- Owner-only data access patterns
- Audit trail via Cloud Functions
- Secure API endpoints

This schema ensures exemplary compliance with Firestore best practices, providing a scalable, secure, and performant database structure for the Tego application.