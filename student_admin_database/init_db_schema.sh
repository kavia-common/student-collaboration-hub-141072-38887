#!/bin/bash

# Script to initialize MongoDB collections and indexes for student admin system

MONGO_HOST="localhost"
MONGO_PORT="5000"
MONGO_DB="myapp"
MONGO_USER="appuser"
MONGO_PASSWORD="dbuser123"

echo "Initializing MongoDB schema on ${MONGO_DB}..."

mongosh "mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}?authSource=admin" <<'EOF'
use myapp;

// USERS
db.createCollection("users");
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ role: 1 });
db.users.createIndex({ groups: 1 });

// GROUPS
db.createCollection("groups");
db.groups.createIndex({ ownerId: 1 });
db.groups.createIndex({ members: 1 });

// ASSIGNMENTS
db.createCollection("assignments");
db.assignments.createIndex({ groupId: 1 });
db.assignments.createIndex({ createdBy: 1 });
db.assignments.createIndex({ dueDate: 1 });
db.assignments.createIndex({ "submissions.userId": 1 });

// MESSAGES
db.createCollection("messages");
db.messages.createIndex({ groupId: 1 });
db.messages.createIndex({ recipientId: 1 });
db.messages.createIndex({ senderId: 1 });
db.messages.createIndex({ threadRootId: 1 });
db.messages.createIndex({ timestamp: -1 });

// NOTIFICATIONS
db.createCollection("notifications");
db.notifications.createIndex({ userId: 1 });
db.notifications.createIndex({ type: 1 });
db.notifications.createIndex({ createdAt: -1 });
db.notifications.createIndex({ read: 1 });

print("MongoDB schema and indexes initialized.");

// Insert default user "Jo" with bcrypt-hashed password "Jo01"
//
// Hash generated with Node.js: 
// const bcrypt = require('bcrypt'); bcrypt.hashSync('Jo01', 10)
// Example result: $2b$10$dkaDJDnChpgyEtxnnzt1IO6Atf3CgKWQb6NADi5pFOYKaajNAvYBO

var bcryptHash = "$2b$10$dkaDJDnChpgyEtxnnzt1IO6Atf3CgKWQb6NADi5pFOYKaajNAvYBO"; // Jo01

if (!db.users.findOne({ email: "jo@email.com" })) {
  db.users.insertOne({
    email: "jo@email.com",
    displayName: "Jo",
    passwordHash: bcryptHash,
    role: "student",
    profilePicUrl: null,
    bio: "",
    groups: [],
    createdAt: new Date(),
    updatedAt: new Date(),
    notifications: []
  });
  print("Default user 'Jo' inserted (email: jo@email.com, password: Jo01)");
} else {
  print("Default user 'Jo' already exists.");
}

EOF

echo "MongoDB schema initialization complete."
