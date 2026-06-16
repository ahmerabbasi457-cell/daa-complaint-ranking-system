# Dynamic Top-K Complaint Ranking System

A full-stack complaint management platform that dynamically ranks complaints using Data Structures & Algorithms concepts such as Min Heap optimization, time decay ranking, clustering, and spam detection.

## Overview

Universities and organizations receive large numbers of complaints daily. Traditional complaint systems simply store complaints without intelligent prioritization.

This project dynamically maintains the Top-K most important complaints using efficient ranking algorithms and real-time updates.

The system consists of:

* Flask Backend
* SQLite Database
* Web Frontend (HTML, CSS, JavaScript)
* Flutter Mobile Application
* Admin Dashboard
* Dynamic Ranking Engine

---

## Key Features

* Dynamic Top-K complaint ranking
* Min Heap / Priority Queue optimization
* Time Decay scoring
* Complaint clustering
* Spam detection
* Like / Upvote system
* Admin analytics dashboard
* REST APIs
* Flutter mobile app integration

---

## Algorithms Implemented

### Top-K Optimization

Uses a Min Heap to maintain the most important complaints efficiently.

Complexity:

O(n log k)

### Time Decay

Older complaints gradually lose ranking importance.

### Clustering

Similar complaints are grouped together to identify recurring issues.

### Spam Detection

Suspicious complaints receive penalties to reduce manipulation.

### Greedy Approximation

Selects highly important complaints while reducing redundancy.

### Submodular Optimization Concept

Models Top-K selection as a diversity-aware optimization problem.

---

## Technology Stack

### Backend

* Python
* Flask
* SQLite

### Frontend

* HTML
* CSS
* JavaScript

### Mobile App

* Flutter
* Dart

---

## System Architecture

```text
Users
   │
   ▼
Web Frontend / Flutter App
   │
   ▼
Flask REST API
   │
 ┌──┼─────────────┐
 │  │             │
 ▼  ▼             ▼
Heap Ranking   Clustering   Spam Detection
 │
 ▼
SQLite Database
```

---

## API Endpoints

### Submit Complaint

POST

```http
/submit-complaint
```

### Get Complaints

GET

```http
/get-complaints
```

### Like Complaint

POST

```http
/like-complaint/<id>
```

---

## Project Structure

```text
backend/
frontend/
flutter_app/
```

---

## Future Improvements

* Machine Learning based spam detection
* NLP clustering
* User authentication
* Cloud deployment
* Push notifications
* Real-time WebSockets

---

## Author

Ahmer Abbasi

BS Computer Science

COMSATS University Islamabad, Wah Campus
