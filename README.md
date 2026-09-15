# ⚽ Total Football Player Analyzer

> **A local Flutter learning project for analyzing and comparing players in Total Football VNG.**

## 📌 About This Project

**Total Football Player Analyzer** là một dự án cá nhân được xây dựng bằng **Flutter & Dart** với mục tiêu kết hợp giữa:

* 📚 Học và thực hành Flutter theo môn **PRM393 – Mobile Programming**
* ⚽ Xây dựng một ứng dụng thực tế phục vụ việc quản lý và phân tích cầu thủ trong **Total Football VNG**
* 🧠 Áp dụng kiến thức lập trình vào một project phát triển xuyên suốt trong quá trình học

Đây **không phải là ứng dụng chính thức của Total Football VNG**.

Project được phát triển chủ yếu dưới dạng **Local App**, phục vụ mục đích học tập, thử nghiệm và sử dụng cá nhân.

---

## 🎯 Project Goals

Mục tiêu chính của project là **học Flutter bằng cách xây dựng một ứng dụng hoàn chỉnh**, thay vì chỉ thực hiện các bài tập nhỏ độc lập.

Trong quá trình phát triển, project sẽ được mở rộng dần theo các nội dung được học trong PRM393:

```text
Dart
  ↓
Flutter Fundamentals
  ↓
UI & Navigation
  ↓
Forms & Validation
  ↓
REST API & JSON
  ↓
Local Storage / Database
  ↓
Authentication
  ↓
Testing
  ↓
Refactoring
  ↓
Build & Release
```

---

## ⚽ Main Idea

Ứng dụng hướng tới việc hỗ trợ người chơi lưu trữ và phân tích thông tin cầu thủ.

Các chức năng dự kiến:

### 👤 Player Management

* Thêm cầu thủ
* Chỉnh sửa cầu thủ
* Xóa cầu thủ
* Xem thông tin cầu thủ
* Tìm kiếm cầu thủ
* Lọc theo vị trí/chỉ số

### 📊 Player Statistics

Lưu trữ và hiển thị các chỉ số của cầu thủ, ví dụ:

* Overall
* Pace
* Shooting
* Passing
* Dribbling
* Defense
* Physical

### ⭐ Special Skills

Quản lý các **Skill đặc biệt** của từng cầu thủ.

Ứng dụng có thể sử dụng dữ liệu Skill để hỗ trợ việc phân tích và so sánh cầu thủ.

### ⚔️ Player Comparison

Cho phép lựa chọn nhiều cầu thủ để so sánh:

```text
Player A          Player B
──────────        ──────────
PAC     95        PAC     91
SHO     92        SHO     95
PAS     87        PAS     90
DRI     94        DRI     89
DEF     40        DEF     52
PHY     81        PHY     86
```

### 🎯 Player Analysis

Dựa trên các chỉ số và Skill, project hướng tới việc hỗ trợ phân tích:

* Điểm mạnh / điểm yếu
* So sánh giữa các cầu thủ
* Mức độ phù hợp với từng vai trò
* Xếp hạng theo tiêu chí do người dùng lựa chọn

> Các phương pháp tính điểm và đánh giá sẽ được phát triển dần trong quá trình học.

---

## 🏠 Local Development

Project hiện tại được phát triển theo hướng **Local-first**.

Điều này có nghĩa:

```text
Flutter App
     │
     ├── Local Data
     ├── Local Database
     └── Local Processing
             │
             ↓
       Samsung Note 9
```

Ứng dụng có thể được chạy và kiểm thử trực tiếp trên thiết bị Android cá nhân.

### Current Target Device

* **Samsung Galaxy Note 9**

Thiết bị được sử dụng như một thiết bị kiểm thử thực tế trong quá trình phát triển.

---

## 📚 Learning Project

Project này được phát triển **song song với quá trình học PRM393**.

Mỗi giai đoạn của project tương ứng với một nhóm kiến thức Flutter/Dart:

| Learning Stage    | Project Application     |
| ----------------- | ----------------------- |
| Dart Fundamentals | Player Model            |
| OOP               | Models & Business Logic |
| Flutter UI        | Player Screens          |
| Navigation        | Player Detail / Edit    |
| Forms             | Add & Edit Player       |
| REST API          | Player Data             |
| JSON              | Data Parsing            |
| Local Storage     | Player Database         |
| Authentication    | User Session            |
| Testing           | Unit & Widget Tests     |
| Refactoring       | Project Architecture    |
| Build & Release   | Android APK             |

Mục tiêu không phải chỉ để hoàn thành một ứng dụng, mà là **sử dụng chính ứng dụng này làm môi trường thực hành Flutter**.

---

## 🛠️ Tech Stack

Current / Planned:

* **Flutter**
* **Dart**
* **Android**
* Local Storage / Database
* REST API
* JSON
* Unit Testing
* Widget Testing

Các công nghệ sẽ được bổ sung dần khi chúng xuất hiện trong quá trình học.

---

## 🗺️ Development Roadmap

### Week 1 — Flutter & Dart Fundamentals

* [ ] Create Flutter project
* [ ] Flutter project structure
* [ ] Dart fundamentals
* [ ] `Player` model
* [ ] Basic Player List
* [ ] Run on Samsung Note 9

### Week 2 — OOP & Async

* [ ] Improve Player Model
* [ ] Repository Pattern
* [ ] `Future`
* [ ] `async/await`

### Week 3 — UI & Navigation

* [ ] Player List
* [ ] Player Detail
* [ ] Navigation
* [ ] Passing arguments

### Week 4 — Forms & Responsive UI

* [ ] Add Player
* [ ] Edit Player
* [ ] Validation
* [ ] Responsive layout

### Week 5 — REST API & JSON

* [ ] HTTP requests
* [ ] JSON parsing
* [ ] Loading state
* [ ] Error handling
* [ ] Retry

### Week 6 — Local Storage / Database

* [ ] Persistent player data
* [ ] CRUD
* [ ] Favorites
* [ ] Import / Export

### Week 7 — Authentication

* [ ] Login
* [ ] Session
* [ ] Protected screens
* [ ] Logout

### Week 8 — Testing

* [ ] Unit tests
* [ ] Widget tests
* [ ] Debugging

### Week 9 — Refactoring & Polish

* [ ] Refactor architecture
* [ ] Fix bugs
* [ ] Improve UI/UX
* [ ] User testing

### Week 10 — Build & Release

* [ ] Build APK
* [ ] Final testing on Android device
* [ ] Documentation
* [ ] Project presentation

---

## 📱 Development Workflow

The project follows a simple development cycle:

```text
Learn
  ↓
Implement
  ↓
Run Locally
  ↓
Test on Samsung Note 9
  ↓
Debug
  ↓
Commit
  ↓
Reflect / Refactor
  ↓
Learn Next Topic
```

Mỗi tính năng mới được xây dựng nhằm phục vụ đồng thời **hai mục tiêu**:

1. Hiểu kiến thức Flutter/Dart đang học.
2. Đưa kiến thức đó vào một ứng dụng thực tế.

---

## ⚠️ Disclaimer

This project is an **unofficial personal learning project**.

It is not affiliated with, endorsed by, or officially connected to **Total Football VNG** or its developers/publishers.

All game-related names, player information, images, trademarks, and other intellectual property belong to their respective owners.

The project is intended for **educational and personal use**.

---

## 🚧 Project Status

> **Early Development — Week 1**

The application is currently in the initial development stage.

Features, architecture, data sources and analysis methods may change as the developer progresses through the Flutter learning roadmap.

---

## 👨‍💻 Purpose

This repository serves as both:

* 📚 A **Flutter learning journal**
* 🛠️ A **personal software project**
* ⚽ A **Total Football player analysis tool**

The final goal is not simply to have a working app, but to understand **how and why each part of the application works**.
