@echo off
echo Deploying Firestore configuration...
echo.

echo 1. Deploying Security Rules...
firebase deploy --only firestore:rules

echo.
echo 2. Deploying Indexes...
firebase deploy --only firestore:indexes

echo.
echo 3. Deploying Cloud Functions...
firebase deploy --only functions

echo.
echo Deployment complete!
echo.
echo Verify deployment:
echo - Security Rules: https://console.firebase.google.com/project/tego-d918b/firestore/rules
echo - Indexes: https://console.firebase.google.com/project/tego-d918b/firestore/indexes
echo - Functions: https://console.firebase.google.com/project/tego-d918b/functions/list
pause