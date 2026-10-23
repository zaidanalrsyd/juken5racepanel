# 🏍️ Juken Racing Dashboard — Race Panel

Aplikasi Android berbasis Flutter untuk monitoring parameter mesin secara real-time melalui ECU Juken 5+.

Juken Racing Dashboard merupakan project pengembangan race panel digital yang dirancang untuk menampilkan informasi kondisi mesin sepeda motor dalam antarmuka dashboard yang informatif, responsif, dan mudah dibaca.

Project ini berfokus pada integrasi pembacaan data ECU, visualisasi parameter mesin, serta pengembangan antarmuka monitoring yang dapat digunakan sebagai alternatif panel instrumen digital.

---

## 📌 Project Overview

| Informasi | Detail |
|---|---|
| Project Name | Juken Racing Dashboard |
| Project Type | Android Race Panel / ECU Monitoring |
| Platform | Android |
| Framework | Flutter |
| Programming Language | Dart |
| Development Environment | Visual Studio Code |
| ECU Target | BRT Juken 5+ |
| Communication | Bluetooth / Wi-Fi (integration in progress) |
| Application Mode | Read-only monitoring |

## 🎯 Project Objectives

Tujuan utama pengembangan aplikasi ini adalah:

- Mengembangkan dashboard digital untuk monitoring ECU Juken 5+.
- Menampilkan parameter mesin dalam bentuk visualisasi yang mudah dibaca.
- Mengembangkan sistem komunikasi antara aplikasi Android dan ECU.
- Membuat antarmuka yang responsif untuk penggunaan dalam orientasi portrait maupun landscape.
- Menyediakan sistem monitoring yang tidak mengubah konfigurasi atau mapping ECU.

## ⚙️ Main Features

### 1. Engine Overview

Dashboard utama dirancang untuk menampilkan informasi mesin secara visual.

| Parameter | Description |
|---|---|
| RPM | Engine speed dalam revolutions per minute |
| TPS | Throttle Position Sensor |
| EOT | Engine Oil Temperature / parameter temperatur sesuai definisi ECU |
| AFR | Air-Fuel Ratio |
| Battery Voltage | Tegangan aki kendaraan |

Fitur visualisasi dashboard meliputi:

- Large RPM display.
- RPM bar indicator.
- Engine parameter cards.
- Dynamic gauge visualization.
- ECU connection status.
- Responsive dashboard layout.

### 2. Engine Data Monitoring

Halaman Engine Data dirancang untuk menampilkan parameter mesin dalam format yang lebih terperinci.

Parameter yang ditampilkan:

- Engine RPM
- Throttle Position (TPS)
- Engine Temperature (EOT)
- Air-Fuel Ratio (AFR)
- Battery Voltage

### 3. ECU Connectivity

Aplikasi dikembangkan dengan fokus pada integrasi komunikasi antara Android dan ECU Juken 5+.

Fitur konektivitas yang menjadi bagian dari pengembangan:

- Device discovery.
- ECU connection status.
- Connection initialization.
- ECU data reception.
- Live parameter updates.
- Connection error handling.

**Catatan:** Komunikasi ECU dan validasi format data masih menjadi bagian dari proses pengembangan. Keberhasilan koneksi perangkat belum tentu berarti seluruh parameter ECU telah berhasil dibaca dan ditampilkan dengan benar.

### 4. Dashboard Interface

Antarmuka aplikasi dirancang dengan mempertimbangkan penggunaan pada kendaraan.

Fitur UI:

- Dark mode interface.
- Dashboard visualization.
- Responsive layout.
- Portrait and landscape support.
- Engine overview screen.
- Engine data screen.

---

## 🏗️ System Architecture

Arsitektur aplikasi dirancang dengan memisahkan proses komunikasi ECU, pemrosesan data, dan visualisasi dashboard.

```text
          BRT Juken 5+ ECU
                 |
                 |
       Communication Interface
        Bluetooth / Wi-Fi
                 |
                 |
          Android Application
                 |
                 v
       ECU Communication Layer
                 |
                 v
        Data Parsing Layer
                 |
                 v
       Engine Data Model
                 |
                 v
        Dashboard UI Layer
                 |
        +--------+--------+
        |        |        |
       RPM      TPS      EOT
        |        |        |
        +--------+--------+
                 |
                AFR
```

### Architecture Components

| Component | Responsibility |
|---|---|
| Communication Layer | Mengelola komunikasi dengan perangkat ECU |
| Data Parsing Layer | Memproses data mentah yang diterima |
| Engine Data Model | Menyimpan parameter mesin |
| Dashboard UI | Menampilkan informasi mesin |
| Connection Manager | Mengelola status koneksi dan error |

Arsitektur ini dirancang agar proses pembacaan data ECU dapat dikembangkan secara terpisah dari tampilan dashboard.

---

## 🛠️ Technology Stack

| Technology | Usage |
|---|---|
| Flutter | Cross-platform application framework |
| Dart | Application programming language |
| Visual Studio Code | Development environment |
| Android SDK | Android application development |
| Bluetooth / Wi-Fi | Communication interface under development |
| Git & GitHub | Version control and project repository |

---

## 📂 Project Structure

Struktur folder yang direncanakan untuk pengembangan aplikasi:

```text
lib/
├── main.dart
│
├── app/
│   └── app.dart
│
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── dashboard/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   │
│   ├── engine_data/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── connectivity/
│       ├── services/
│       ├── models/
│       └── providers/
│
└── shared/
    └── widgets/
```

Struktur di atas merupakan gambaran arsitektur pengembangan. Struktur aktual dapat disesuaikan dengan implementasi project.

---

## 🚀 Getting Started

### Prerequisites

Pastikan perangkat pengembangan telah memiliki:

- Flutter SDK
- Dart SDK
- Visual Studio Code
- Flutter Extension for VS Code
- Android SDK
- Android device atau emulator

### 1. Clone Repository

```bash
git clone https://github.com/USERNAME/REPOSITORY.git
```

Masuk ke direktori project:

```bash
cd REPOSITORY
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Check Flutter Environment

```bash
flutter doctor
```

Pastikan konfigurasi Flutter dan Android SDK telah tersedia.

### 4. Run Application

Hubungkan perangkat Android melalui USB debugging atau gunakan emulator.

Kemudian jalankan:

```bash
flutter devices
```

Jalankan aplikasi:

```bash
flutter run
```

---

## 🔒 Safety & Scope

Project ini dikembangkan sebagai aplikasi monitoring ECU.

Batasan pengembangan:

- Aplikasi berfokus pada pembacaan data ECU.
- Tidak melakukan perubahan mapping ECU.
- Tidak mengirimkan perintah tuning atau konfigurasi mesin.
- Tidak menggantikan perangkat tuning resmi.
- Validitas data bergantung pada protokol komunikasi ECU yang digunakan.

Aplikasi ini merupakan project pengembangan independen dan bukan aplikasi resmi dari BRT.

---

## 📈 Development Roadmap

- [x] Flutter application initialization
- [x] Dashboard UI development
- [x] Engine overview interface
- [x] Engine data interface
- [x] Responsive dashboard layout
- [ ] ECU communication integration
- [ ] ECU data protocol validation
- [ ] RPM data parsing
- [ ] TPS data parsing
- [ ] EOT data parsing
- [ ] AFR data parsing
- [ ] Battery voltage monitoring
- [ ] Live dashboard data integration
- [ ] Connection stability testing
- [ ] Real-world testing

Roadmap ini akan diperbarui seiring dengan perkembangan integrasi ECU.

---

## ⚠️ Disclaimer

Juken Racing Dashboard is an independent development project intended for educational, research, and vehicle monitoring purposes.

This application is not an official BRT product and is not affiliated with BRT.

The application is designed for read-only ECU monitoring. Actual data accuracy and communication reliability depend on the ECU interface, communication protocol, and implementation.

Always verify engine parameters using appropriate diagnostic equipment before making mechanical or tuning decisions.

---

## 👨‍💻 Developer

Developed as an independent automotive technology project.

**Juken Racing Dashboard — Digital Race Panel for ECU Monitoring**
<img width="738" height="1600" alt="image" src="https://github.com/user-attachments/assets/676f6fac-38d6-46bd-976d-b2f0d43649f0" />


