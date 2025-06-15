# Veer Shivaji: Pratapgad Campaign

A 2D historical adventure game telling the story of Chhatrapati Shivaji's encounter with Afzal Khan at Pratapgad. Built with Godot 4.x.

## 🎮 Current Status: Core Systems Implemented

### ✅ What's Complete

- **Core Architecture**: All autoload systems (GameManager, SaveSystem, InputManager, AudioManager, DialogueManager)
- **Player System**: Movement, interaction, and animation framework
- **Dialogue System**: Complete with UI and JSON data support
- **Project Structure**: Full folder hierarchy as per design document
- **Testing Framework**: System validation and testing scripts

### 🧪 Testing the Game

1. **Open in Godot 4.x**:
   - Launch Godot Editor
   - Open the `veer-shivaji` project folder
   - Open `scenes/Main.tscn`

2. **Run the Project**:
   - Press F5 or click the Play button
   - Select `Main.tscn` as the main scene when prompted
   - Watch the console output for system test results

3. **Test Controls**:
   - **WASD/Arrow Keys**: Move Shivaji around
   - **E or Space**: Interact (currently shows in console)
   - **T**: Test dialogue system (press while holding Space)

4. **Expected Results**:
   - All system tests should show ✅ (green checkmarks)
   - Player should move smoothly with WASD/Arrow keys
   - Dialogue system should work when pressing T

## 📁 Project Structure

```
veer-shivaji/
├── autoload/           # Core game systems (GameManager, SaveSystem, etc.)
├── scenes/
│   ├── Main.tscn      # Current test scene
│   ├── main_menu/     # Ready for main menu
│   ├── levels/        # Ready for game levels
│   ├── cutscenes/     # Ready for story cutscenes
│   └── ui/            # UI components (DialogueUI implemented)
├── scripts/
│   ├── characters/    # Player.gd
│   ├── systems/       # MainScene.gd, SystemTester.gd
│   └── ui/            # DialogueUI.gd
├── characters/
│   └── Shivaji.tscn   # Player character with full functionality
├── assets/            # Ready for art, audio, fonts
└── data/              # Ready for dialogue, level data, educational content
```

## 🎯 Next Development Steps

1. **Create Main Menu System**
   - Title screen with play/continue/settings options
   - Integration with save system

2. **Implement First Level** (Level01_ShadowOfAfzal)
   - Story introduction cutscene
   - Basic exploration and NPC interaction
   - Educational card reward system

3. **Add Art Assets**
   - Character sprites and animations
   - Environment tilesets
   - UI elements

4. **Expand Dialogue System**
   - Voice acting integration
   - Rich text formatting
   - Character portraits

## 🔧 Development Notes

- All core systems are functional and tested
- Input system supports both keyboard and touch (touch controls ready for iPad)
- Audio system is implemented but needs audio assets
- Save/load functionality is complete and working
- Educational card system is ready for content

## 📚 Design Document

Refer to `docs/plan.md` for the complete game design document with detailed specifications for all systems and levels.

## 🚀 For Developers

To continue development:

1. Read `docs/status.md` for current progress
2. Use `docs/continue-prompt.md` for AI-assisted development
3. Follow the technical architecture in `docs/plan.md`
4. Test new features using the SystemTester framework

---

**Historical Note**: This game respectfully portrays the historic encounter between Chhatrapati Shivaji Maharaj and Afzal Khan at Pratapgad fort in 1659, emphasizing the strategic brilliance and cultural values of the Maratha empire.
