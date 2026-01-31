# Star Collector (Working Title)

A minimal logic/puzzle game where you need to find and collect hidden stars using a limited number of bombs.

## Game Rules

- Each cell is represented as a box that can be in one of three states:
  - Closed (hidden)
  - Opened (revealed, empty)
  - Destroyed by explosion

### At the start of each round:
- Stars are randomly placed on the field (number varies by difficulty)
- Stars **cannot** be placed in neighboring cells (including diagonally)
  → minimum distance between any two stars = 2 cells (Chebyshev distance ≥ 2)
- Rocks are also randomly placed on the field (number varies by difficulty)
- All stars and rocks are hidden under closed boxes

### Player actions:
- **Left click** on a closed cell → place a **bomb**
- Maximum number of bombs varies by difficulty level
- You **cannot** place a bomb on an already opened cell
- 1 second after placing, each bomb explodes and **destroys** boxes in a **3×3 area** centered on itself (1 cell in each direction)
- If a star was inside any destroyed box → the star is **collected**

### Goal:
- Collect **all stars** using no more than the maximum number of bombs (varies by difficulty)

### Game over conditions:
- All stars collected → **Victory!**
- All bombs used and at least one star remains → **Game Over**

### Interface elements:
- Button **"New Game"** – starts a new round with a fresh field and new star/rock positions
- Display of remaining bombs
- Display of collected stars

## Difficulty Modes

The game features three difficulty levels, each with different field sizes and configurations:

| Mode | Field Size | Stars | Bombs | Rocks |
|------|------------|-------|-------|-------|
| **Easy** | 9×9 (81 cells) | 6 | 9 | 10 |
| **Medium** | 12×12 (144 cells) | 10 | 15 | 18 |
| **Hard** | 15×15 (225 cells) | 12 | 22 | 28 |

## Technical Notes

- Stars must always be placed with at least one cell separation in all 8 directions
- Explosion reveals/destroys exactly 9 cells (unless at edge of the board)
- Already opened (safe) cells are immune to new bomb placement

## Possible future improvements

- Sound effects (bomb tick, explosion, star collected)
- Animation of explosion
- Score = number of stars collected with fewest bombs used

Enjoy the hunt! 🧨⭐