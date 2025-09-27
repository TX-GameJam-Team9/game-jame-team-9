# README.md
# Weekend Game Jam Project 🎮

## 1. Setup
### godot steps
- Install [Godot 4.x](https://godotengine.org/).
- run the executable
- In Godot’s Project Manager, click **Import**, point to this repo folder.

### git steps
- Install [Git](https://git-scm.com/) if not already.
- Install Git LFS (needed for images/audio):
``` bash
git lfs install
```

-- clone the repo:
``` bash
git clone https://github.com/TX-GameJam-Team9/game-jame-team-9.git
cd game-jam-team-9
git lfs pull
```

## Run the project
Run the project (F5).

## Structure
- `scenes/` → game objects (Player, Enemy, etc.)
- `scripts/` → code for objects
- `assets/` → sprites, sounds, fonts
- `ui/` → menus, HUD

### Dev structure and workflow
-- always branch off main while working:
```bash 
git checkout main
git pull
git checkout -b feat/<feature>
git push -u origin feat/<feature>
```

---keep commits small dont commit a whole file commit early and often (ie after a function is done)
--after branch is made:
```bash
git checkout -b feat/<feature>
git add .
git commit -m "<message>"
git push
```


## Team Notes; TLDR
- Keep code modular.
- Commit early and often.
- Use branches for features.
