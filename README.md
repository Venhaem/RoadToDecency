# Road to Decency

Welcome to **Road to Decency**, a playful take on weight loss and fitness goals built in Godot 4! Guide your pixel-art runner along a winding path from 120 kg down to 80 kg, track your steps, and build daily streaks—all while the game world smoothly transitions between day and night.

---

## 🌟 Features

- **Weight & Distance Tracking**: Log your current weight and kilometers walked each day.
- **Progress Path**: Your pixel hero advances along a zig‑zag path as you shed kilos.
- **Daily Streaks**: Keep a true daily-log streak—miss a day and it resets, hit it two days in a row and watch your streak climb.
- **Day/Night Cycle**: Background and character tint fade smoothly based on your local time.
- **Footstep Audio**: Hear satisfying looped footsteps whenever your runner dashes forward.
- **Persistent Save**: All metrics save to `user://save.cfg` so your progress survives restarts.

---

## 🔧 Requirements

- [Godot Engine 4.x](https://godotengine.org/download)
- Your favorite desktop platform (Windows only for now...)

---

## 🚀 Installation & Running

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/fitness-quest-tracker.git
   cd fitness-quest-tracker
   ```
2. **Open in Godot**
   - Launch Godot 4, click **Import**, and select the project folder.
3. **Run the game**
   - Press **Play** (F5) in the editor.

---

## 🎮 How to Play

1. **Log your data**: Enter your current weight and kilometers walked in the input fields at the bottom.
2. **Tap **Log****: Your runner will play a running animation and footstep audio as they move along the path.
3. **Watch your progress**: The progress bar and path position update with smooth tweens.
4. **Build streaks**: Log once each day to grow your streak—don’t let it drop!
5. **Enjoy the cycle**: The scene will gently fade between day and night based on your system clock.

---

## 📂 Save File Location

- **Windows**: `%APPDATA%\Godot\app_userdata\Tracker NEW\save.cfg`

To reset your progress manually, delete the `save.cfg` file or use the in‐game reset button (if added).

---

## 🤝 Contributing

Feel free to submit bug reports or feature requests via GitHub issues. Pull requests are welcome—just fork, tweak, and send a PR!

---

## 📄 License

This project is open‐source under the **MIT License**.

---

Happy running, and may your streak stay strong! 🏃‍♂️💨

