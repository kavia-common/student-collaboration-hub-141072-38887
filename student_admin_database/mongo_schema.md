# MongoDB Initial Schema Design for Student Administration System

## Overview

This document defines the initial MongoDB schema (collections and indexes) for the student administration platform, inspired by Microsoft Teams. The schema is designed to support key features including user data, assignments, groups/classrooms, real-time messaging, and notifications.

---

## Collections and Document Structure

### 1. Users (`users`)

**Purpose:** Store all students, teachers, and admins.

```json
{
  "_id": ObjectId,
  "email": "user@email.com",             // unique
  "displayName": "John Doe",
  "passwordHash": "hashed_pw",           // for backend, not exposed to frontend
  "role": "student" | "teacher" | "admin",
  "profilePicUrl": "string?",
  "bio": "string?",
  "groups": [ObjectId],                  // References to groups/classes the user is part of
  "createdAt": ISODate,
  "updatedAt": ISODate,
  "notifications": [                      // Notification IDs (for quick unread, optional optimization)
    ObjectId
  ]
}
```
**Indexes:**  
- `email` (unique)
- `role`
- `groups`

---

### 2. Groups / Classrooms (`groups`)

**Purpose:** Represent a classroom or group.

```json
{
  "_id": ObjectId,
  "name": "Math 101",
  "description": "First grade math class",
  "ownerId": ObjectId,             // Teacher/admin user
  "members": [ObjectId],           // User IDs
  "assignmentIds": [ObjectId],     // List of assignments for this group
  "createdAt": ISODate,
  "updatedAt": ISODate
}
```
**Indexes:**  
- `ownerId`
- `members`
- `name` (optional, for search)

---

### 3. Assignments (`assignments`)

**Purpose:** Store assignments with submissions.

```json
{
  "_id": ObjectId,
  "title": "Homework 1",
  "description": "Algebra questions",
  "groupId": ObjectId,                // The classroom
  "createdBy": ObjectId,              // Teacher/admin user
  "dueDate": ISODate,
  "attachmentUrl": "string?",
  "submissions": [                    // Embedded submissions, can be split for large scale.
    {
      "userId": ObjectId,
      "submittedAt": ISODate,
      "content": "Answer or attachment link",
      "grade": "A" | "B" | "C" | null,
      "feedback": "string?",
      "gradedAt": ISODate?
    }
  ],
  "createdAt": ISODate,
  "updatedAt": ISODate
}
```
**Indexes:**  
- `groupId`
- `createdBy`
- `dueDate`
- `submissions.userId`

---

### 4. Messages (`messages`)

**Purpose:** Store real-time chat/messages for groups, direct messages, or assignment threads.

```json
{
  "_id": ObjectId,
  "groupId": ObjectId?,                // Null for DM, groupId for group chat
  "senderId": ObjectId,
  "recipientId": ObjectId?,            // For direct messages
  "text": "Message content",
  "attachmentUrl": "string?",
  "timestamp": ISODate,
  "readBy": [ObjectId],                // Users who have read the message
  "threadRootId": ObjectId?,           // For message threads e.g. assignment or comments
  "reactions": [                       // Emoji/like reactions
    {
      "userId": ObjectId,
      "reaction": "👍"
    }
  ]
}
```
**Indexes:**  
- `groupId`
- `recipientId`
- `senderId`
- `threadRootId`
- `timestamp` (desc)

---

### 5. Notifications (`notifications`)

**Purpose:** Store in-app (and ideally push/email) notifications for users.

```json
{
  "_id": ObjectId,
  "userId": ObjectId,
  "type": "assignment_due" | "grade_posted" | "message_received" | "group_invite" | ...,
  "title": "Assignment Graded!",
  "body": "Your assignment has been graded by Mrs. Smith.",
  "data": { /* additional metadata, assignmentId, groupId, etc. */ },
  "read": Boolean,
  "createdAt": ISODate
}
```
**Indexes:**  
- `userId`
- `type`
- `createdAt` (desc)
- `read`

---

## General Design Notes

- All timestamp fields use `ISODate` (MongoDB date).
- All inter-collection relations use direct `ObjectId` references.
- For submissions or reactions, embedded documents are used for simplicity and performance (unless scale dictates splitting to separate collections).
- All frequently searched fields are indexed.
- Use capped or TTL indexes for logs, if needed in future.

---

## Index Creation Example (MongoDB Shell)

```js
db.users.createIndex({ email: 1 }, { unique: true });
db.groups.createIndex({ ownerId: 1 });
db.groups.createIndex({ members: 1 });
db.assignments.createIndex({ groupId: 1 });
db.assignments.createIndex({ dueDate: 1 });
db.messages.createIndex({ groupId: 1, timestamp: -1 });
db.messages.createIndex({ recipientId: 1 });
db.notifications.createIndex({ userId: 1, createdAt: -1 });
```

---

## Seed/Starter Data (Recommended for Dev/Test)

- At least one teacher/admin user, 2 test students, 2 groups/classes, and 1-2 assignments per group.

---

## Future Optimization

- Consider splitting submissions into a separate `submissions` collection if assignment document gets too large.
- Store message attachments externally, only store reference URLs.
- Add full-text search index (Atlas Search) for messages.
- Consider ACL/permission fields if fine-grained access is required.

---

## Contact

Schema designed by code-generation AI 2024. Adapt as needed per evolving requirements.
