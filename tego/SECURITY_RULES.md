# Firebase Security Rules Documentation

## Overview
This document explains the Firebase Security Rules implemented for the Tego mobile application to protect user data and ensure proper access control.

## Current Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Sales subcollection - user can only access their own sales
      match /sales/{saleId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Expenses subcollection - user can only access their own expenses
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Rule Explanations

### 1. Authentication Requirement
- **Rule**: `request.auth != null`
- **Purpose**: Ensures only authenticated users can access the database
- **Protection**: Prevents anonymous access to any data

### 2. User Data Isolation
- **Rule**: `request.auth.uid == userId`
- **Purpose**: Users can only access documents where the document ID matches their Firebase Auth UID
- **Protection**: Complete data isolation between users

### 3. Subcollection Access Control
- **Rule**: Applied to both `/sales/{saleId}` and `/expenses/{expenseId}`
- **Purpose**: Inherits parent document security while allowing CRUD operations
- **Protection**: Users can only manage their own financial records

## Security Features

### Data Privacy
- **User Isolation**: Each user's data is completely isolated from others
- **No Cross-User Access**: Users cannot read or write other users' financial data
- **Authentication Gate**: All operations require valid Firebase authentication

### Operation Control
- **Read Protection**: Users can only read their own data
- **Write Protection**: Users can only create/update/delete their own records
- **Bulk Operations**: Prevented unauthorized bulk data access

### Attack Prevention
- **SQL Injection**: Not applicable (NoSQL database)
- **Data Leakage**: Prevented by user ID matching
- **Unauthorized Access**: Blocked by authentication requirement
- **Privilege Escalation**: Prevented by strict user ID validation

## Implementation Benefits

1. **Compliance**: Meets data protection requirements
2. **Scalability**: Rules scale automatically with user base
3. **Performance**: Efficient rule evaluation
4. **Maintainability**: Simple and clear rule structure

## Testing Security Rules

### Valid Operations
```javascript
// User can read their own data
/users/user123 (when auth.uid = user123) ✅

// User can write their own sales
/users/user123/sales/sale456 (when auth.uid = user123) ✅
```

### Blocked Operations
```javascript
// User cannot read other user's data
/users/user456 (when auth.uid = user123) ❌

// Unauthenticated access
/users/user123 (when auth = null) ❌
```

## Future Enhancements

1. **Role-Based Access**: Admin roles for support
2. **Field-Level Security**: Protect sensitive fields
3. **Rate Limiting**: Prevent abuse
4. **Audit Logging**: Track access patterns