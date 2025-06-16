# Veer Shivaji: Sprite Creation Guide

## 🎨 AI Image Generation Setup

### Character Specifications (from plan.md)

- **Resolution**: 32x64 pixels for characters
- **Style**: High-resolution pixel art with historical accuracy
- **Required Characters**: Shivaji, Advisor, Spy, Netaji Palkar, Afzal Khan

### AI Prompt Templates

#### **Shivaji Base Sprite**

```
Character sprite, Chhatrapati Shivaji Maharaj, 17th century Maratha king, 
side-view pixel art style, 32x64 pixels, standing pose, 
traditional saffron/orange royal turban, white kurta, 
orange waistcoat, sword at waist, black mustache, 
determined expression, historically accurate, 
clean pixel art style, no background, transparent PNG
```

#### **NPC Sprites**

**Advisor (Wise counselor):**

```
Elderly Indian advisor sprite, 17th century Maratha court, 
side-view pixel art, 32x64 pixels, white beard, 
simple white dhoti and shawl, holding palm leaf manuscript, 
wise gentle expression, traditional Indian scholarly dress
```

**Spy (Disguised merchant):**

```
Indian spy character sprite, 17th century merchant disguise, 
side-view pixel art, 32x64 pixels, simple brown clothing, 
carrying small bundle, hood covering head partially, 
alert cautious expression, common person appearance
```

**Netaji Palkar (Military commander):**

```
Maratha military commander sprite, 17th century warrior, 
side-view pixel art, 32x64 pixels, light armor over clothing, 
sword and shield, military turban, strong confident pose, 
traditional Maratha military uniform, commander bearing
```

## 🔧 Piskel Animation Workflow

### Setting Up Your Project

1. **Open Piskel** (<https://www.piskelapp.com/>)
2. **Create New Sprite**: 32x64 pixels
3. **Set Frame Rate**: 8 FPS for walking, 4 FPS for idle
4. **Name Project**: "Shivaji_Character_Sprites"

### Animation Requirements (per character)

#### **Essential Animations:**

- **Idle**: 4 frames (breathing, slight movement)
- **Walk**: 4 frames (walking cycle)
- **Jump**: 3 frames (up, peak, down)

#### **Optional Animations:**

- **Attack**: 3 frames (wind-up, strike, recovery)
- **Interact**: 2 frames (reach, action)

### Step-by-Step Walking Animation

#### **Frame 1: Contact**

- One foot on ground, other lifting
- Body slightly forward
- Arms in walking position

#### **Frame 2: Recoil**

- Lifting foot highest
- Body upright
- Opposite arm forward

#### **Frame 3: Passing**

- Feet passing each other
- Body weight shifting
- Arms swinging

#### **Frame 4: High Point**

- Other foot highest
- Body leaning into step
- Arms in opposite position

### Piskel Tools Guide

#### **Essential Tools:**

- **Pen Tool**: For pixel-perfect drawing
- **Paint Bucket**: For filling areas
- **Move Tool**: For positioning
- **Duplicate Frame**: For creating similar frames
- **Onion Skin**: To see previous frames (helps with smooth animation)

#### **Animation Workflow:**

1. **Import AI base sprite** as Frame 1
2. **Duplicate frame** for each animation frame
3. **Enable Onion Skin** to see previous frame
4. **Modify each frame** gradually for smooth motion
5. **Preview animation** using play button
6. **Export as sprite sheet** when complete

## 📁 File Organization

### Export Settings in Piskel

- **Format**: PNG Sprite Sheet
- **Layout**: Horizontal strip
- **Scale**: 1x (keep original 32x64 size)
- **Naming**: `character_animation.png`

### Recommended File Structure

```
veer-shivaji/assets/art/characters/
├── shivaji/
│   ├── shivaji_idle.png
│   ├── shivaji_walk.png
│   ├── shivaji_jump.png
│   └── shivaji_all_animations.png
├── advisor/
│   ├── advisor_idle.png
│   └── advisor_walk.png
├── spy/
│   ├── spy_idle.png
│   └── spy_walk.png
└── netaji_palkar/
    ├── netaji_idle.png
    └── netaji_walk.png
```

## 🎯 Priority Order

### Week 1: Core Characters

1. **Shivaji**: idle + walk animations
2. **Advisor**: idle animation (stationary NPC)
3. **Spy**: idle animation (stationary NPC)

### Week 2: Enhanced Animations

4. **Shivaji**: jump animation
5. **Netaji Palkar**: idle + walk
6. **Additional poses** as needed

## 🔍 Quality Checklist

### Before Finalizing Each Sprite

- [ ] Correct size (32x64 pixels)
- [ ] Consistent style across all frames
- [ ] Smooth animation (no jarring movements)
- [ ] Historical accuracy in clothing/appearance
- [ ] Clean pixel art (no blurry edges)
- [ ] Transparent background
- [ ] Proper naming convention

## 💡 Pro Tips

### AI Generation Tips

- **Generate multiple variations** and pick the best
- **Use "pixel art" specifically** in prompts
- **Add "no background"** to get transparent images
- **Specify "side-view"** for consistent perspective
- **Include "32x64 pixels"** for proper sizing

### Piskel Animation Tips

- **Use onion skinning** to see previous frames
- **Keep movements small** between frames
- **Test animation frequently** using preview
- **Save project files** (.piskel format) for future edits
- **Export both individual frames AND sprite sheets**

## 🚀 Getting Started Today

### Immediate Action Steps

1. **Generate Shivaji base sprite** using AI tool
2. **Open Piskel** and create new 32x64 project
3. **Import AI sprite** as first frame
4. **Create 4-frame walking animation**
5. **Export as sprite sheet**
6. **Test in Godot** by replacing placeholder sprite

### Next Session Goals

- Complete Shivaji idle and walk animations
- Generate and animate Advisor sprite
- Test all sprites in the game
- Begin environment tiles if time permits
