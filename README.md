# Eco Stock Tracker 🌿📈

A Flutter mobile app that allows users to track their stock portfolios while monitoring the environmental impact of their investments. It integrates real-time financial tracking with sustainability metrics, helping users build a greener portfolio.

---

## ✨ Features

- **Real-Time Financial Data**: Live stock prices and daily change percentages fetched via Alpha Vantage API.
- **Sustainability Metrics**: View ESG (Environmental, Social, and Governance) scores, A/B/C/D Eco-Tags, and Carbon Emissions data for every holding.
- **Portfolio Green Score**: A weighted sustainability score based on the value of your investments, visualized in an interactive dashboard gauge.
- **Historical CO₂ Footprint**: Interactive 5-year line charts built with `fl_chart` to track corporate emissions trends.
- **Eco-Friendly Alternative Suggestions**: Smart sector-mapping logic that detects high-emission stocks (e.g., Oil/Gas) and suggests greener alternatives within the same sector.
- **Local Persistence**: Securely stores your portfolio holdings locally using SQLite.
- **Sleek UI**: Fully responsive, dynamic dark-mode user interface powered by Riverpod 3.0 state management.

---

## 🛠️ Architecture & Tech Stack

This project is built strictly following Clean Architecture principles to ensure scalability, testability, and separation of concerns.

- **Frontend Framework**: Flutter (v3.10+)
- **State Management**: flutter_riverpod (v3.3+)
- **Local Database**: sqflite & path_provider
- **Networking**: dio (v5.9+)
- **Charts**: fl_chart (v1.2.0)

---

## 🚀 Setup Instructions

### 1. Prerequisites
Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- An IDE such as Android Studio, VS Code, or Cursor.

### 2. Getting Started
Clone or download the repository, then navigate to the project root directory in your terminal:

```bash
cd /Users/admin/Documents/appprojects/eco_stock_tracker
```

Fetch the required Flutter dependencies:
```bash
flutter pub get
```

### 3. API Key Configuration
The app uses the **Alpha Vantage API** for real-time stock data. 
Ensure the API key is configured correctly in `lib/data/datasources/remote/alpha_vantage_api.dart`:

```dart
// The key is already populated in the project:
final String _apiKey = 'UW68ZMJAEQ4TFJZ9'; 
```
*(Note: Alpha Vantage imposes a rate limit of 5 requests per minute on their free tier. The app safely catches rate limits and falls back to mock financial data automatically).*

### 4. Running the App
To compile and run the application on your connected device or emulator, execute:

```bash
flutter run
```

---

## 🏗️ Project Structure

```
lib/
├── data/
│   ├── datasources/
│   │   ├── local/        # SQLite Database initialization and queries
│   │   └── remote/       # Alpha Vantage & Mocked ESG APIs
│   └── repositories/     # Concrete implementations of Domain rep interfaces
├── domain/
│   ├── entities/         # Core business models (StockHolding, ESGData, etc.)
│   ├── repositories/     # Interfaces defining data ops (StockRepository...)
│   └── usecases/         # Business logic rules (GetPortfolioDataUseCase)
└── presentation/
    ├── providers/        # Riverpod setup (Notifier tracking global state)
    └── screens/          # UI layer (Dashboard, Search, Detail)
```
