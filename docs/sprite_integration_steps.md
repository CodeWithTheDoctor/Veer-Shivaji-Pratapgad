# Sprite Integration Guide for Godot

## 🎮 Testing Your Shivaji Sprite in Game

### Step 1: Place Your Sprite File

1. Save your exported `shivaji_walk.png` to:

   ```
   veer-shivaji/assets/art/characters/shivaji/shivaji_walk.png
   ```

### Step 2: Create SpriteFrames Resource

1. **Open Godot** and load your veer-shivaji project
2. **In FileSystem dock**, navigate to `assets/art/characters/shivaji/`
3. **Right-click** in the folder → **New Resource**
4. **Search for** "SpriteFrames" → **Create**
5. **Name it** `shivaji_animations.tres`

### Step 3: Set Up Animation Frames

1. **Double-click** `shivaji_animations.tres` to open SpriteFrames editor
2. **Create animations**:
   - **Rename "default"** to **"idle"**
   - **Add new animation** called **"walk"**
   - **Add new animation** called **"jump"** (for later)

3. **For the "walk" animation**:
   - **Click "Add frames from sprite sheet"**
   - **Select** your `shivaji_walk.png`
   - **Set horizontal/vertical frames** (e.g., 4 horizontal, 1 vertical)
   - **Select all 4 frames**
   - **Set FPS to 8**

4. **For the "idle" animation**:
   - **Use frame 1** from your walk cycle (or create separate idle sprite)
   - **Set FPS to 4**

### Step 4: Assign to Player Character

1. **Open** `scenes/shared/characters/Player.tscn`
2. **Select** the **AnimatedSprite2D** node
3. **In Inspector**, find **"Sprite Frames"** property
4. **Click** the dropdown → **Load** → Select `shivaji_animations.tres`
5. **Save the scene**

### Step 5: Test in Game

1. **Run** your project (F5)
2. **Select** your main scene
3. **Move around** using WASD or arrow keys
4. **Watch Shivaji animate** as he walks!

## 🐛 Troubleshooting

### If sprite doesn't appear

- Check file path is correct
- Ensure PNG has transparent background
- Verify SpriteFrames resource is properly assigned

### If animation doesn't play

- Check animation names match in Player.gd
- Verify FPS is set (try 8 FPS for walk)
- Ensure all frames are added to animation

### If sprite is wrong size

- In AnimatedSprite2D node, adjust **Scale** property
- Or re-export from Piskel at different size

## 🎯 Next Steps After Testing

Once Shivaji's walk animation works:

1. **Create idle animation** (subtle breathing movement)
2. **Create jump animation** (3 frames: up, peak, down)
3. **Generate NPC sprites** using same process
4. **Create environment tiles** for backgrounds

## 📝 Animation Names in Code

Your Player.gd script looks for these animations:

- **"idle"** - When standing still
- **"walk"** - When moving horizontally  
- **"jump"** - When jumping up
- **"fall"** - When falling down (optional)

Make sure your SpriteFrames animations match these names!
