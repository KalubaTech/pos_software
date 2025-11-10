# Printing Dialog - Visual Preview

## 🎨 Dialog Appearance

```
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║     ╔════════════════════════════════════════╗          ║
║     ║  ░░░░░░░░░░░ BACKGROUND PATTERN ░░░░░░║          ║
║     ║  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░║          ║
║     ║                                        ║          ║
║     ║            ┌─────────────┐             ║          ║
║     ║            │             │             ║          ║
║     ║            │   ╔═════╗   │             ║          ║
║     ║            │   ║ 🖨️  ║   │  ← Printer Icon       ║
║     ║            │   ╚═════╝   │     (Animated)        ║
║     ║            │             │                        ║
║     ║            └─────────────┘                        ║
║     ║                                                   ║
║     ║         ═══════════════════════                   ║
║     ║         PRINTING RECEIPT                          ║
║     ║         ═══════════════════════                   ║
║     ║                                                   ║
║     ║         ╔═══════════════════╗                     ║
║     ║         ║ Receipt #RCP-1234 ║  ← Receipt Badge   ║
║     ║         ╚═══════════════════╝                     ║
║     ║                                                   ║
║     ║   Please wait while we print                      ║
║     ║        your receipt...                            ║
║     ║                                                   ║
║     ║              ┌───────┐                            ║
║     ║              │   ◉   │  ← Progress Indicator     ║
║     ║              │ ┌───┐ │     (Spinning)            ║
║     ║              │ │ ● │ │                            ║
║     ║              │ └───┘ │                            ║
║     ║              └───────┘                            ║
║     ║                                                   ║
║     ║         ● Processing...  ← Status (Pulsing)      ║
║     ║                                                   ║
║     ║  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░          ║
║     ╚════════════════════════════════════════╝          ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

## 🌈 Color Specifications

### Gradient Background
```
┌─────────────────────────┐
│ #667eea (Top Left)      │
│          ↘              │
│            Purple       │
│              Gradient   │
│                ↘        │
│         #764ba2         │
│         (Bottom Right)  │
└─────────────────────────┘
```

### Element Colors
- **Printer Icon**: `#FFFFFF` (White)
- **Title Text**: `#FFFFFF` (White)
- **Receipt Badge Background**: `rgba(255, 255, 255, 0.2)`
- **Receipt Badge Border**: `rgba(255, 255, 255, 0.3)`
- **Message Text**: `rgba(255, 255, 255, 0.9)`
- **Progress Background**: `rgba(255, 255, 255, 0.1)`
- **Progress Indicator**: `#FFFFFF` (White)
- **Status Dot**: `#FFFFFF` with glow
- **Background Pattern**: `rgba(255, 255, 255, 0.05)`

## 📐 Dimensions

### Dialog Container
```
Width: 400px (max)
Height: Auto (min content)
Padding: 32px
Border Radius: 20px
Elevation: 8
```

### Printer Icon Container
```
Size: 96px × 96px (container)
Icon Size: 56px
Background: Circle
Border: 2px white (30% opacity)
```

### Progress Indicator
```
Size: 60px × 60px
Stroke Width: 3px
Center Dot: 8px diameter
```

### Receipt Badge
```
Padding: 8px × 16px
Border Radius: 20px (pill shape)
Font Size: 14px
Border: 1px
```

## 🎭 Animation Timeline

```
0ms     ┌─────────────────────────────────────┐
        │ Dialog appears with fade            │
        │ Backdrop darkens                    │
100ms   │                                     │
        ├─────────────────────────────────────┤
        │ Icon begins scale animation         │
200ms   │                                     │
        ├─────────────────────────────────────┤
300ms   │                                     │
        │ Icon at 50% scale                   │
400ms   │                                     │
        ├─────────────────────────────────────┤
500ms   │                                     │
        │ Icon at 80% scale                   │
600ms   ├─────────────────────────────────────┤
        │ Icon reaches 100% scale ✓           │
        │ Progress indicator begins fade      │
700ms   │                                     │
        ├─────────────────────────────────────┤
800ms   │ Progress indicator fully visible ✓  │
        ├─────────────────────────────────────┤
        │ Pulsing dot animation starts        │
        │ (Continuous 1200ms cycles)          │
        └─────────────────────────────────────┘

Continuous animations:
• Progress indicator: Spinning (infinite)
• Status dot: Pulsing (1200ms cycles)
```

## 📱 Responsive Behavior

### Mobile (< 600px)
```
┌──────────────┐
│   Padding    │
│    Reduces   │
│      to      │
│     24px     │
│              │
│   Dialog     │
│   Adapts to  │
│   Screen     │
│    Width     │
└──────────────┘
```

### Tablet/Desktop (≥ 600px)
```
┌──────────────────────┐
│   Max Width 400px    │
│   Full Padding 32px  │
│                      │
│    Dialog Centered   │
│    in Viewport       │
└──────────────────────┘
```

## 🎬 State Transitions

### Test Print Mode
```
┌─────────────────────────┐
│      TEST PRINT         │ ← Title (no badge)
│                         │
│  Sending test print     │ ← Message
│  to printer...          │
└─────────────────────────┘
```

### Receipt Print Mode
```
┌─────────────────────────┐
│   PRINTING RECEIPT      │ ← Title
│  ┌──────────────────┐   │
│  │ Receipt #RCP-123 │   │ ← Badge appears
│  └──────────────────┘   │
│  Please wait while we   │ ← Message
│  print your receipt...  │
└─────────────────────────┘
```

## 🎯 Visual Hierarchy

### Level 1 (Highest Priority)
```
  ╔═══════╗
  ║ Icon  ║  ← First thing user sees
  ╚═══════╝
```

### Level 2 (Secondary)
```
═════════════════
    TITLE
═════════════════
```

### Level 3 (Tertiary)
```
┌─────────────┐
│ Receipt #   │  ← Context information
└─────────────┘
```

### Level 4 (Supporting)
```
Message text describing action
```

### Level 5 (Feedback)
```
  ⟳ Progress
  ● Status
```

## ✨ Special Effects

### Glow Effect
```
     ╔═══════╗
   ┌─║─────║─┐  ← Purple glow
  ┌──║────║──┐
 └───╚═══╝───┘   extends 10px
      Box          with blur 20px
```

### Pattern Effect
```
━━━━━━━━━━━━━━━━  ← Horizontal lines (white 5%)
  ╱  ╱  ╱  ╱     ← Diagonal lines (white 3%)
━━━━━━━━━━━━━━━━
  ╱  ╱  ╱  ╱
━━━━━━━━━━━━━━━━
```

### Pulsing Effect
```
Frame 1:  ●     (50% opacity)
Frame 2:   ●    (65% opacity)
Frame 3:    ●   (80% opacity)
Frame 4:     ●  (100% opacity)
Frame 5:    ●   (80% opacity)
Frame 6:   ●    (65% opacity)
Frame 7:  ●     (50% opacity)
[Repeat every 1200ms]
```

## 🎨 Design Principles Applied

### 1. Visual Feedback
- Immediate animation on appearance
- Continuous progress indication
- Pulsing status shows activity

### 2. Clarity
- Large, bold title
- Clear message text
- Receipt number prominently displayed

### 3. Polish
- Smooth animations
- Professional gradient
- Attention to detail

### 4. Focus
- Non-dismissible prevents distraction
- Dark backdrop isolates dialog
- Single action (wait for completion)

### 5. Consistency
- Follows Material Design
- Matches app theme
- Reusable pattern

## 🔧 Technical Details

### Performance Optimizations
```
✓ CustomPainter (shouldRepaint: false)
✓ Minimal widget rebuilds
✓ Efficient animations
✓ Static background pattern
✓ Lightweight gradient
```

### Memory Efficiency
```
✓ Single animation controller (pulsing dot)
✓ No image assets required
✓ Vector-based graphics
✓ Reusable components
```

---

**Visual Design**: ✅ Complete
**Animation**: ✅ Smooth
**Performance**: ✅ Optimized
**User Experience**: ✅ Professional
