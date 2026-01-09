# three_forge

A high-performance, modular 3D game engine for Flutter built on the foundations of web-standard graphics and physics. This engine bridges the gap between Flutter’s UI capabilities and advanced 3D game development by integrating the industry-standard Three.js ecosystem with native performance via ANGLE.

## 🚀 Core Tech Stack
 - Graphics Engine: three_js – A comprehensive Dart port of Three.js for scene management, lighting, and materials.
 - Rendering Layer: flutter_angle – Provides high-performance OpenGL ES hardware acceleration via Google's ANGLE layer.
 - Physics Engine: cannon_physics – A lightweight, fast 3D rigid-body physics engine.
 - AI & Steering: yuka – A robust library for developing autonomous agent behaviors and game AI.

## ✨ Key Features
 - Unified Game Loop: A centralized ticker system that synchronizes physics updates, AI decision-making, and frame rendering.
 - Hardware Accelerated: Bypasses standard Flutter painting for direct GPU-accelerated rendering.
 - Autonomous Agents: Out-of-the-box support for pathfinding, steering behaviors, and state machines via Yuka.
 - Realistic Physics: Support for spheres, boxes, planes, and complex convex polyhedrons with customizable friction and restitution.
 - Cross-Platform: Designed to run seamlessly across Android, iOS, and Web.

## 🚦 Getting Started
Prerequisite: Install Flutter
 - Before using this engine, you must have the Flutter SDK installed on your machine.
 - Download: Follow the Official Flutter Installation Guide for your specific operating system (Windows, macOS, or Linux).
 - Verify: Ensure your environment is ready by running:
```bash
flutter doctor
```

## 🛠 Installation
To install please download from github then run the following.
 - `flutter create ./` this will create all the missing files
 - `flutter clean`
 - `flutter pub get`
 - `flutter run -d x` where x is either linux, mac, or windows

## 🏗 Architecture
 - The Scene (Three.js): Manages the visual hierarchy, including cameras, meshes, and lights.
 - The World (Cannon): A parallel mathematical simulation that calculates collisions and forces, then syncs coordinates back to the Three.js meshes.
 - The Brain (Yuka): Manages the logic of "Actors," determining how they move and react to the player within the scene.
 - The Bridge (Flutter Angle): The underlying context that allows the 3D buffer to be displayed within a Flutter Texture widget.

## 📄 License
Distributed under the MIT License. See LICENSE for more information.

## 🛠 Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/three_forge/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/three_forge/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/three_forge/pulls) directly.