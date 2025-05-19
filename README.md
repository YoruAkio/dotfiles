# 🌈 YoruAkio's Sway Dotfiles

A modern and minimalist Sway desktop environment with dynamic theming based on wallpapers.

## ✨ Features

- 🎨 **Dynamic color theming**: Automatically generates color schemes from wallpapers
- 🖼️ **Wallpaper management**: Tools to select, randomize, and download wallpapers
- 🧹 **Clean, minimalist design**: Simple but functional interface
- 🎬 **Screen recording utilities**: Record full screen or selected areas with or without audio
- 🔄 **Integrated configuration**: Cohesive theme across Sway, Waybar, Kitty terminal, and Wofi

## 🚀 Installation

### 1️⃣ Clone the repository

```bash
git clone https://github.com/YoruAkio/dotfiles.git
cd dotfiles
```

### 2️⃣ Install required packages

> 📝 **Note**: This configuration has been primarily tested on Arch Linux based distributions.

#### 🐧 Arch Linux / Manjaro

```bash
# Install main packages
sudo pacman -S sway waybar kitty wofi python python-pillow wf-recorder slurp grim \
               brightnessctl jq swaybg ttf-font-awesome ttf-jetbrains-mono pavucontrol

# Install AUR packages
yay -S grimblast-git ttf-spacemono-nerd
# OR using paru
paru -S grimblast-git ttf-spacemono-nerd
```

#### 🐧 Debian / Ubuntu

```bash
# Install main packages
sudo apt update
sudo apt install -y sway waybar kitty wofi python3 python3-pil brightnessctl \
                    jq swaybg fonts-font-awesome fonts-jetbrains-mono pavucontrol \
                    grim slurp wf-recorder

# You may need to manually install some packages not available in repositories
# For grimblast, you can build from source:
git clone https://github.com/hyprwm/grimblast.git
cd grimblast
sudo make install
```

#### 🐧 Fedora

```bash
# Install main packages  
sudo dnf install -y sway waybar kitty wofi python3 python3-pillow wf-recorder \
                   slurp grim brightnessctl jq fontawesome-fonts \
                   jetbrains-mono-fonts pavucontrol

# For grimblast, you can build from source:
git clone https://github.com/hyprwm/grimblast.git
cd grimblast
sudo make install
```

#### 🐧 openSUSE

```bash
# Install main packages
sudo zypper install sway waybar kitty wofi python3 python3-Pillow wf-recorder \
                   slurp grim brightnessctl jq fontawesome-fonts pavucontrol

# For grimblast, you can build from source:
git clone https://github.com/hyprwm/grimblast.git
cd grimblast
sudo make install
```

### 3️⃣ Copy configuration files

```bash
mkdir -p ~/.config
cp -r dotfiles/sway ~/.config/
cp -r dotfiles/waybar ~/.config/
cp -r dotfiles/kitty ~/.config/
cp -r dotfiles/wofi ~/.config/
```

### 4️⃣ Create directories for wallpapers and recordings

```bash
mkdir -p ~/.config/sway/walls
mkdir -p ~/Videos/Screenrecorder
```

### 5️⃣ Download some initial wallpapers

```bash
chmod +x ~/.config/sway/scripts/download_wallpapers.sh
~/.config/sway/scripts/download_wallpapers.sh
```

### 6️⃣ Make all scripts executable

```bash
find ~/.config/sway/scripts -type f -name "*.sh" -exec chmod +x {} \;
find ~/.config/sway/scripts -type f -name "*.py" -exec chmod +x {} \;
```

## 🎮 Usage

### ⌨️ Basic Keybindings

- **Super + Return**: Launch terminal (kitty)
- **Super + q**: Kill focused window
- **Super + r**: Launch application launcher (wofi)
- **Super + Shift + r**: Reload configuration
- **Super + Shift + q**: Exit Sway
- **Super + [1-0]**: Switch to workspace 1-10
- **Super + Shift + [1-0]**: Move window to workspace 1-0
- **Super + f**: Toggle fullscreen
- **Super + Shift + Space**: Toggle floating
- **Super + h/j/k/l**: Move focus (vim-style)
- **Print**: Take screenshot of entire screen
- **Super + Shift + s**: Take screenshot of selected area
- **Super + Ctrl + r**: Launch screen recording tool

### 🖼️ Wallpaper Management

- **Super + Alt + w**: Set random wallpaper
- **Super + Shift + w**: Manually select a wallpaper

### 🎬 Screen Recording

1. Press **Super + Ctrl + r** to open recording options
2. Choose between:
   - Record Fullscreen (with or without audio)
   - Record Selected Area (with or without audio)
3. To stop recording, press **Super + Ctrl + r** again and select "Stop"

### 🎨 Adding Custom Wallpapers

Place your wallpaper images (JPG, PNG) in `~/.config/sway/walls/`

## 🧩 Components

### 🪟 Sway
The core window manager with tiling capabilities and keyboard-centric design.

### 📊 Waybar
A highly customizable status bar displaying:
- Workspaces
- Window title
- Volume level
- Network status
- CPU and memory usage
- Battery status
- Clock
- System tray

### 🐱 Kitty
A fast terminal emulator with GPU acceleration and custom color themes synced to the wallpaper.

### 🔍 Wofi
A simple application launcher with a clean interface that matches the overall theme.

### 🎨 Dynamic Color Generation
- `get_wallpaper_color.py` extracts colors from wallpapers and generates consistent themes
- Colors are applied to Sway, Waybar, Kitty terminal, and Wofi

## ⚠️ Troubleshooting

### 🎨 No Wallpaper Colors
If wallpaper colors aren't applying:
```bash
# Check if the Python script is executable
chmod +x ~/.config/sway/scripts/get_wallpaper_color.py

# Check if Python PIL is installed
pip install pillow  # or pip3 install pillow
```

### 🎬 Screen Recording Issues
If screen recording doesn't work:
```bash
# Check if wf-recorder is installed
# For Arch:
sudo pacman -S wf-recorder

# For Debian/Ubuntu:
sudo apt install wf-recorder

# Check if the scripts are executable  
chmod +x ~/.config/sway/scripts/record_runner.sh
chmod +x ~/.config/sway/scripts/record/*.sh
```

## 📝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an Issue on GitHub.

## 🔗 Links

- [GitHub Repository](https://github.com/YoruAkio/dotfiles)

---

Created with ❤️ by [YoruAkio](https://github.com/YoruAkio)