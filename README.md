# 🚀 Wallora  

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" />
  <img src="https://img.shields.io/badge/Platform-iOS-black?logo=apple" />
  <img src="https://img.shields.io/github/license/your-username/wallora" />
</p>

## 🎮 Play Wallora on itch.io

[![Play Wallora](https://img.itch.zone/aW1nLzEwMDAwMDAucG5n/original/example.png)](https://hexaghost-09.itch.io/wallora)

<p align="center">
  A modern Flutter application built with clean UI and scalable architecture.
</p>

---

## ✨ Features

- 📱 Cross-platform (Android & iOS)
- ⚡ Fast performance with Flutter
- 🎨 Modern UI design
- 🔥 Scalable project structure

---


## 📂 Project Structure

```

lib/
├── main.dart
├── screens/
├── widgets/
├── models/
└── services/

````

---

## 🛠 Getting Started

### 1️⃣ Clone the repository

```bash
git clone https://github.com/your-username/wallora.git
cd wallora
````

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Run the app

```bash
flutter run
```

---

## 📚 Resources

* 📘 [Flutter Documentation](https://docs.flutter.dev/)
* 🧪 [Flutter Codelab](https://docs.flutter.dev/get-started/codelab)
* 🍳 [Flutter Cookbook](https://docs.flutter.dev/cookbook)

---

## 📦 Build Release

```bash
flutter build apk
flutter build ios
```

---


## ☁️ OTA Updates with Shorebird

Wallora now includes a GitHub Actions workflow for Shorebird so you can ship **real OTA patches** (Flutter code/assets) without waiting for Play Store / App Store review.

### 1) Add required GitHub secret

In your repository settings, add:

- `SHOREBIRD_TOKEN`: token from `shorebird login:ci`

### 2) Run OTA workflow

Use **Actions → Shorebird OTA → Run workflow** and choose:

- `command`: `release` (first Shorebird build) or `patch` (OTA fix)
- `platform`: `android` or `ios`
- `release_version`: required only for `release` (example: `1.2.0+45`)

### 3) Typical flow

1. Publish your first Shorebird-enabled release with `command=release`.
2. Merge a hotfix to `main`.
3. Trigger `command=patch` for the same platform.
4. Existing users receive the patch on next app start (no store re-review for Dart/UI fixes).

> Note: Native Android/iOS code changes still require a store release.

---

## 🤝 Contributing

Pull requests are welcome.
For major changes, please open an issue first to discuss what you would like to change.

---

## 📜 License

This project is licensed under the MIT License.

```

If you want GitHub stats widgets added (like contribution graph, stars, forks), tell me your GitHub username and I’ll generate it ready-to-paste.
```
