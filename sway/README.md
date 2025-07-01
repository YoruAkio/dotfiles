# Sway Configuration - Object-Oriented Architecture

## Overview

This Sway configuration has been redesigned using Object-Oriented Programming principles to create a more maintainable, scalable, and organized window manager setup.

## Design Patterns Used

### 1. **Factory Pattern**

- **Application Registry**: Centralized application definitions
- **System Tool Registry**: Unified system command definitions
- **UI Launcher Management**: Consistent menu system

### 2. **Singleton Pattern**

- **Auto-start Applications**: Ensures single instances of services
- **Scratchpad Manager**: Single scratchpad instance management

### 3. **Strategy Pattern**

- **Input Handler Classes**: Different input device configurations
- **Navigation Strategies**: Multiple navigation methods (vim-keys, arrows)

### 4. **Command Pattern**

- **Script Registry**: Centralized script execution
- **Navigation Controller**: Unified window/focus commands
- **Keybinding Modules**: Organized command mapping

### 5. **Observer Pattern**

- **System Controller**: Wallpaper and configuration management
- **Idle Management**: System state monitoring

### 6. **State Pattern**

- **Layout Manager**: Different window layout states
- **Window Resize Controller**: Mode-based resizing

### 7. **Mode Pattern**

- **Power Management Mode**: System power operations
- **Media Control Mode**: Audio/video controls
- **Screenshot Mode**: Various capture options

### 8. **Decorator Pattern**

- **Floating Window Rules**: Enhanced window behaviors
- **Theme System**: Visual decoration management

### 9. **Composition Pattern**

- **Modular Configuration**: Separate config files for different concerns
- **Include System**: Hierarchical configuration loading

### 10. **Association Pattern**

- **Workspace Assignments**: Application-workspace relationships

## File Structure

```
sway/
├── config                      # Main configuration (Base Class)
├── config.d/                   # Modular configuration modules
│   ├── variables.conf          # All variables and constants
│   ├── keybindings.conf        # All keyboard shortcuts
│   ├── autostart.conf          # Startup applications and services
│   ├── window_rules.conf       # Window-specific behaviors
│   ├── appearance.conf         # Theme, gaps, borders, and bar
│   ├── input.conf              # Mouse, keyboard, touchpad settings
│   └── resize_mode.conf        # Window resizing functionality
├── generated_colors.conf       # Dynamic color scheme
└── scripts/                    # External command implementations
```

## Key Features

### Modular Design

- **Separation of Concerns**: Each config file handles specific functionality
- **Easy Maintenance**: Changes isolated to relevant modules
- **Extensibility**: New features can be added without touching core config

### Consistent Naming

- **Variable Naming**: Clear, descriptive variable names with prefixes
- **Logical Grouping**: Related configurations grouped together
- **Interface Definitions**: Clear boundaries between different systems

### Enhanced Functionality

- **Custom Modes**: Power, Media, Screenshot, and Launcher modes
- **Advanced Navigation**: Workspace cycling and container management
- **Theme System**: Consistent visual design across all elements
- **Smart Window Rules**: Application-specific behaviors

### Error Prevention

- **Variable Abstraction**: Centralized definitions prevent typos
- **Consistent Patterns**: Repeatable structures reduce errors
- **Clear Documentation**: Every section clearly documented

## Usage

### Basic Operations

- `$mod + Return`: Terminal
- `$mod + q`: Kill window
- `$mod + r`: Application launcher
- `$mod + e`: File manager

### Advanced Modes

- `$mod + Shift + p`: Power management mode
- `$mod + Alt + l`: Application launcher mode
- `$mod + Alt + m`: Media control mode
- `$mod + Alt + s`: Screenshot mode

### Window Management

- `$mod + [hjkl]` or `$mod + [Arrow Keys]`: Focus movement
- `$mod + Shift + [hjkl]`: Move windows
- `$mod + Alt + r`: Resize mode

### Workspace Management

- `$mod + [1-0]`: Switch to workspace
- `$mod + Shift + [1-0]`: Move container to workspace
- `$mod + Tab`: Next workspace
- `$mod + Shift + Tab`: Previous workspace

## Benefits of This Approach

1. **Maintainability**: Easy to modify and extend
2. **Readability**: Clear structure and documentation
3. **Reusability**: Patterns can be reused for new features
4. **Scalability**: Easy to add new functionality
5. **Consistency**: Uniform approach across all configurations
6. **Debugging**: Easier to isolate and fix issues

## Customization

To customize this configuration:

1. **Variables & Constants**: Edit `config.d/variables.conf`
2. **Keybindings**: Edit `config.d/keybindings.conf`
3. **Autostart Applications**: Edit `config.d/autostart.conf`
4. **Window Rules**: Edit `config.d/window_rules.conf`
5. **Appearance & Theme**: Edit `config.d/appearance.conf`
6. **Input Devices**: Edit `config.d/input.conf`
7. **Resize Mode**: Edit `config.d/resize_mode.conf`

Each module is focused on a specific aspect of the configuration, making it easy to find and modify exactly what you need.

## Installation

1. Backup your existing config
2. Copy this configuration to `~/.config/sway/`
3. Ensure scripts are executable
4. Reload Sway configuration

This architecture makes the Sway configuration more professional, maintainable, and easier to understand while providing enhanced functionality.
