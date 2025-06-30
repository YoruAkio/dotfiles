#!/bin/bash

# ╭───────────────────────────────────────────────────╮
# │                                                   │
# │            YoruAkio's Dotfiles Setup              │
# │                                                   │
# ╰───────────────────────────────────────────────────╯

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    local text="$1"
    local color="${2:-$BLUE}"
    echo -e "\n${color}${BOLD}╭─────────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${color}${BOLD}│ $text${NC}"
    echo -e "${color}${BOLD}╰─────────────────────────────────────────────────────────────────────╯${NC}\n"
}

# Function to print status messages
print_status() {
    local text="$1"
    local status="$2"
    if [ "$status" == "success" ]; then
        echo -e "  ${BOLD}[${GREEN}✓${NC}${BOLD}]${NC} $text"
    elif [ "$status" == "warning" ]; then
        echo -e "  ${BOLD}[${YELLOW}!${NC}${BOLD}]${NC} $text"
    elif [ "$status" == "error" ]; then
        echo -e "  ${BOLD}[${RED}✗${NC}${BOLD}]${NC} $text"
    else
        echo -e "  ${BOLD}[${BLUE}i${NC}${BOLD}]${NC} $text"
    fi
}

# Function to print task status
print_task() {
    local text="$1"
    echo -e "  ${BOLD}[${CYAN}→${NC}${BOLD}]${NC} $text"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        if [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]] || [[ "$OS" == *"EndeavourOS"* ]]; then
            DISTRO="arch"
        elif [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]] || [[ "$OS" == *"Pop!_OS"* ]] || [[ "$OS" == *"Linux Mint"* ]]; then
            DISTRO="debian"
        elif [[ "$OS" == *"Fedora"* ]]; then
            DISTRO="fedora"
        elif [[ "$OS" == *"openSUSE"* ]]; then
            DISTRO="opensuse"
        else
            DISTRO="unknown"
        fi
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
    elif [ -f /etc/opensuse-release ]; then
        DISTRO="opensuse"
    else
        DISTRO="unknown"
    fi
    
    echo $DISTRO
}

# Function to install base dependencies based on the distribution
install_base_dependencies() {
    local distro=$1
    
    print_task "Installing base dependencies for $distro..."
    
    case $distro in
        arch)
            if ! command_exists yay; then
                print_status "yay not found, installing..." "info"
                sudo pacman -S --noconfirm --needed git base-devel
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                (cd /tmp/yay && makepkg -si --noconfirm)
                rm -rf /tmp/yay
                print_status "yay installed successfully" "success"
            else
                print_status "yay is already installed" "success"
            fi
            sudo pacman -S --noconfirm --needed git curl wget ;;
        debian)
            sudo apt update
            sudo apt install -y git curl wget ;;
        fedora)
            sudo dnf install -y git curl wget ;;
        opensuse)
            sudo zypper install -n git curl wget ;;
        *)
            print_status "Unknown distribution. Installing base dependencies with apt..." "warning"
            sudo apt update
            sudo apt install -y git curl wget ;;
    esac
    
    if [ $? -eq 0 ]; then
        print_status "Base dependencies installed successfully" "success"
    else
        print_status "Failed to install base dependencies" "error"
        exit 1
    fi
}

# Function to install required packages based on the distribution
install_required_packages() {
    local distro=$1
    
    print_task "Installing required packages for $distro..."
    
    case $distro in
        arch)
            sudo pacman -S --noconfirm --needed sway waybar kitty wofi python python-pillow \
                wf-recorder slurp grim brightnessctl jq swaybg \
                ttf-font-awesome ttf-jetbrains-mono pavucontrol
            if command_exists yay; then
                yay -S --noconfirm grimblast-git ttf-space-mono-nerd wofi-emoji
            else
                print_status "yay not found, skipping AUR packages" "warning"
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y sway waybar kitty wofi python3 python3-pil \
                brightnessctl jq swaybg fonts-font-awesome \
                fonts-jetbrains-mono pavucontrol grim slurp wf-recorder
            
            print_status "Building grimblast from source..." "info"
            if [ ! -d "/tmp/grimblast" ]; then
                git clone https://github.com/hyprwm/grimblast.git /tmp/grimblast
                (cd /tmp/grimblast && sudo make install)
                rm -rf /tmp/grimblast
            fi
            print_status "grimblast installed" "success"
            
            # Install wofi-emoji for Debian/Ubuntu
            print_status "Installing wofi-emoji..." "info"
            if [ ! -d "/tmp/wofi-emoji" ]; then
                git clone https://github.com/Zeioth/wofi-emoji.git /tmp/wofi-emoji
                (cd /tmp/wofi-emoji && sudo make install)
                rm -rf /tmp/wofi-emoji
            fi
            print_status "wofi-emoji installed" "success"
            ;;
        fedora)
            sudo dnf install -y sway waybar kitty wofi python3 python3-pillow \
                wf-recorder slurp grim brightnessctl jq \
                fontawesome-fonts jetbrains-mono-fonts pavucontrol
            
            print_status "Building grimblast from source..." "info"
            if [ ! -d "/tmp/grimblast" ]; then
                git clone https://github.com/hyprwm/grimblast.git /tmp/grimblast
                (cd /tmp/grimblast && sudo make install)
                rm -rf /tmp/grimblast
            fi
            print_status "grimblast installed" "success"
            
            # Install wofi-emoji for Fedora
            print_status "Installing wofi-emoji..." "info"
            if [ ! -d "/tmp/wofi-emoji" ]; then
                git clone https://github.com/Zeioth/wofi-emoji.git /tmp/wofi-emoji
                (cd /tmp/wofi-emoji && sudo make install)
                rm -rf /tmp/wofi-emoji
            fi
            print_status "wofi-emoji installed" "success"
            ;;
        opensuse)
            sudo zypper install -n sway waybar kitty wofi python3 python3-Pillow \
                wf-recorder slurp grim brightnessctl jq fontawesome-fonts pavucontrol
            
            print_status "Building grimblast from source..." "info"
            if [ ! -d "/tmp/grimblast" ]; then
                git clone https://github.com/hyprwm/grimblast.git /tmp/grimblast
                (cd /tmp/grimblast && sudo make install)
                rm -rf /tmp/grimblast
            fi
            print_status "grimblast installed" "success"
            
            # Install wofi-emoji for openSUSE
            print_status "Installing wofi-emoji..." "info"
            if [ ! -d "/tmp/wofi-emoji" ]; then
                git clone https://github.com/Zeioth/wofi-emoji.git /tmp/wofi-emoji
                (cd /tmp/wofi-emoji && sudo make install)
                rm -rf /tmp/wofi-emoji
            fi
            print_status "wofi-emoji installed" "success"
            ;;
        *)
            print_status "Unknown distribution. Please install required packages manually." "error"
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        print_status "Required packages installed successfully" "success"
    else
        print_status "Failed to install some packages" "warning"
    fi
}

# Function to backup existing configs (backup in dotfiles root, not polluted path)
backup_configs() {
    local dotfiles_path=$1
    local backup_dir="$dotfiles_path/backup/$(date +%Y%m%d_%H%M%S)"

    print_task "Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir"

    for config_dir in sway waybar kitty wofi; do
        local src="$HOME/.config/$config_dir"
        if [ -e "$src" ]; then
            print_task "Backing up $src to $backup_dir/$config_dir ..."
            cp -aL "$src" "$backup_dir/"
            print_status "Backup of $config_dir created at $backup_dir/$config_dir" "success"
            print_task "Removing original $src ..."
            rm -rf "$src"
            print_status "Removed original $src" "success"
        else
            print_status "No existing $src found, skipping backup" "info"
        fi
    done
    print_status "All backups created successfully at $backup_dir" "success"
    echo "$backup_dir"
}

# Function to set up symlinks (always use correct ln -s syntax)
setup_symlinks() {
    local dotfiles_path=$1
    print_task "Setting up symlinks..."
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.config/sway/walls"
    mkdir -p "$HOME/Videos/Screenrecorder"
    for config_dir in sway waybar kitty wofi; do
        if [ -L "$HOME/.config/$config_dir" ] || [ -d "$HOME/.config/$config_dir" ]; then
            print_task "Removing existing $config_dir from ~/.config ..."
            rm -rf "$HOME/.config/$config_dir"
        fi
        print_task "Creating symlink for $config_dir ..."
        ln -s "$dotfiles_path/$config_dir" "$HOME/.config/$config_dir"
        print_status "Symlink created: $HOME/.config/$config_dir -> $dotfiles_path/$config_dir" "success"
    done
    print_status "All symlinks created successfully" "success"
}

# Function to make scripts executable (check if scripts exist first)
make_scripts_executable() {
    local dotfiles_path=$1
    print_task "Making scripts executable..."
    if [ -d "$dotfiles_path/sway/scripts" ]; then
        find "$dotfiles_path/sway/scripts" -type f -name "*.sh" -exec chmod +x {} \;
        find "$dotfiles_path/sway/scripts" -type f -name "*.py" -exec chmod +x {} \;
        chmod +x "$dotfiles_path/sway/scripts/download_wallpapers.sh" 2>/dev/null
        print_status "All scripts are now executable" "success"
    else
        print_status "No scripts directory found to make executable" "warning"
    fi
}

# Function to download initial wallpapers (check if script exists first)
download_wallpapers() {
    local dotfiles_path=$1
    print_task "Downloading initial wallpapers..."
    local walls_dir="$HOME/.config/sway/walls"
    mkdir -p "$walls_dir"

    # Check if there are any image files in the wallpaper directory
    local image_count=$(find "$walls_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | wc -l)

    if [ "$image_count" -eq 0 ]; then
        print_task "No wallpapers found in $walls_dir. Downloading from GitHub..."
        # List of wallpapers in the GitHub repo (update this list if you add/remove wallpapers)
        local github_base="https://raw.githubusercontent.com/YoruAkio/dotfiles/main/sway/walls"
        local wallpapers=(
            "aaaa.jpg"
            "bocch.jpg"
            "bocch1.png"
            "floresta.jpg"
            "Gura-1.jpg"
            "Gura-3.png"
            "menhera.jpg"
            "PlaneWall.png"
            "princess.jpg"
            "rezeNull.png"
            "ruiva.png"
            "wallhaven-9d9med.png"
            "wallpaper4.png"
        )
        for wp in "${wallpapers[@]}"; do
            local url="$github_base/$wp"
            local target="$walls_dir/$wp"
            print_task "Downloading $wp ..."
            if command -v curl >/dev/null 2>&1; then
                curl -fsSL "$url" -o "$target"
            elif command -v wget >/dev/null 2>&1; then
                wget -q "$url" -O "$target"
            else
                print_status "Neither curl nor wget is installed. Cannot download wallpapers." "error"
                break
            fi
        done
        print_status "Wallpapers downloaded from GitHub." "success"
    fi
}

# Function to display post-installation instructions
show_post_install_instructions() {
    print_header "🎉 Installation Complete! 🎉" $GREEN
    cat << EOF

Next Steps:

1. Log out and select Sway at the login screen
2. Key Combinations:

  • Super + Return: Launch terminal
  • Super + r: Application launcher
  • Super + q: Close window
  • Super + Alt + w: Random wallpaper
  • Super + Shift + w: Select wallpaper
  • Super + Ctrl + r: Screen recording options
  • Print: Take screenshot

Documentation:

For full documentation and more information, please visit:
https://github.com/YoruAkio/dotfiles

Note: If you encounter any issues, please check the README or open an issue on GitHub.

EOF
}

# Main script execution
print_header "🌈 YoruAkio's Dotfiles Setup" $MAGENTA

# Step 1: Detect the Linux distribution
print_header "Step 1: Detecting System" $CYAN
print_task "Detecting Linux distribution..."
DISTRO=$(detect_distro)
print_status "Detected distribution: ${BOLD}$DISTRO${NC}" "success"

# Step 2: Install base dependencies
print_header "Step 2: Installing Base Dependencies" $CYAN
install_base_dependencies $DISTRO

# Step 3: Install required packages
print_header "Step 3: Installing Required Packages" $CYAN
install_required_packages $DISTRO

# Step 4: Set dotfiles path to current script directory
print_header "Step 4: Setting Up Dotfiles" $CYAN
DOTFILES_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "$DOTFILES_PATH" ]; then
    print_status "Failed to determine dotfiles path. Exiting." "error"
    exit 1
fi
print_status "Dotfiles path: $DOTFILES_PATH" "success"

# Step 5: Backup existing configs
print_header "Step 5: Backing Up Existing Configs" $CYAN
BACKUP_PATH=$(backup_configs "$DOTFILES_PATH")

# Step 6: Set up symlinks
print_header "Step 6: Creating Symlinks" $CYAN
setup_symlinks "$DOTFILES_PATH"

# Step 7: Make scripts executable
print_header "Step 7: Setting Permissions" $CYAN
make_scripts_executable "$DOTFILES_PATH"

# Step 8: Download initial wallpapers
print_header "Step 8: Downloading Wallpapers" $CYAN
download_wallpapers "$DOTFILES_PATH"

# Show post-installation instructions
show_post_install_instructions

exit 0