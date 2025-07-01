#!/usr/bin/env python3
import os
import random
import sys
import colorsys
import glob
from PIL import Image

# Configuration paths
SWAY_CONFIG_DIR = os.path.expanduser('~/.config/sway')
WALLS_DIR = os.path.join(SWAY_CONFIG_DIR, 'walls')
CONFIG_SNIPPET = os.path.join(SWAY_CONFIG_DIR, 'generated_colors.conf')
WAYBAR_CSS_VARS = os.path.expanduser('~/.config/waybar/colors.css')
WOFI_CSS = os.path.expanduser('~/.config/wofi/style.css')
WOFI_CONFIG = os.path.expanduser('~/.config/wofi/config')
DUNST_CONFIG = os.path.expanduser('~/.config/dunst/dunstrc')
CURRENT_WALLPAPER_FILE = os.path.join(WALLS_DIR, '.current')

def get_colors_from_image(image_path, num_colors=10):
    """Extract colors from an imag    # Write configuration files
    success = write_sway_config(color_scheme, wallpaper) and \
              write_waybar_css(color_scheme, wallpaper) and \
              write_wofi_css(color_scheme, wallpaper) and \
              write_wofi_config(wallpaper) and \
              write_kitty_colors(color_scheme, wallpaper) and \
              write_dunst_config(color_scheme, wallpaper)g color quantization."""
    try:
        # Open image and convert to RGB
        img = Image.open(image_path)
        
        # Resize image for faster processing
        img = img.resize((150, 150))
        
        # Convert to RGB if needed
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Use quantize to get the main colors
        quantized = img.quantize(colors=num_colors)
        palette = quantized.getpalette()
        color_counts = sorted(quantized.getcolors(), reverse=True)
        
        # Extract RGB values for the colors
        colors = []
        for count, i in color_counts:
            r, g, b = palette[i*3], palette[i*3+1], palette[i*3+2]
            # Skip near-black and near-white colors
            if sum([r, g, b]) > 30 and sum([r, g, b]) < 740:
                colors.append((r, g, b))
        
        # Return the dominant color or a default if no suitable colors found
        return colors[0] if colors else (100, 100, 120)
    except Exception as e:
        print(f"Error processing image {image_path}: {e}", file=sys.stderr)
        # Return a default blue color if there's an error
        return (70, 80, 100)

def adjust_color(rgb, lightness_factor=1.0, saturation_factor=1.0):
    """Adjust color lightness and saturation using HSL color space."""
    r, g, b = [x/255.0 for x in rgb]
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    
    # Adjust lightness and saturation
    l = max(0, min(1, l * lightness_factor))
    s = max(0, min(1, s * saturation_factor))
    
    # Convert back to RGB
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return tuple(int(x * 255) for x in (r, g, b))

def get_contrasting_text_color(rgb):
    """Determine if text should be light or dark based on background color."""
    r, g, b = rgb
    # Calculate perceived brightness (ITU-R BT.709)
    brightness = (0.2126 * r + 0.7152 * g + 0.0722 * b)
    
    if brightness > 128:
        return (25, 25, 30)  # Dark text for light backgrounds
    else:
        return (235, 235, 245)  # Light text for dark backgrounds

def rgb_to_hex(rgb):
    """Convert RGB tuple to hex color string."""
    return '#{:02x}{:02x}{:02x}'.format(rgb[0], rgb[1], rgb[2])

def create_color_scheme(base_color):
    """Create a harmonious color scheme from a base color."""
    # Background color (darker version of base)
    bg_color = adjust_color(base_color, lightness_factor=0.65, saturation_factor=0.85)
    
    # Darker version for borders and secondary elements
    dark_color = adjust_color(bg_color, lightness_factor=0.85, saturation_factor=1.0)
    
    # Accent color (more pastel version of base)
    accent_color = adjust_color(base_color, lightness_factor=1.25, saturation_factor=0.8)
    
    # Text color that contrasts with the background
    text_color = get_contrasting_text_color(bg_color)
    
    # Create a more subtle accent variation (even more pastel)
    subtle_accent = adjust_color(base_color, lightness_factor=1.05, saturation_factor=0.7)
    
    # Urgent/warning colors
    warning_color = (255, 85, 0)   # Orange
    critical_color = (255, 0, 0)   # Red
    
    return {
        'bg': rgb_to_hex(bg_color),
        'dark': rgb_to_hex(dark_color),
        'fg': rgb_to_hex(text_color),
        'accent': rgb_to_hex(accent_color),
        'subtle_accent': rgb_to_hex(subtle_accent),
        'warning': rgb_to_hex(warning_color),
        'critical': rgb_to_hex(critical_color)
    }

def write_sway_config(scheme, wallpaper):
    """Write Sway color configuration."""
    try:
        with open(CONFIG_SNIPPET, 'w') as f:
            f.write(f'''# Auto-generated colors from wallpaper: {os.path.basename(wallpaper)}

# Client colors derived from wallpaper
client.focused          {scheme['accent']} {scheme['dark']} {scheme['fg']} {scheme['accent']} {scheme['dark']}
client.unfocused        {scheme['dark']} {scheme['bg']} {scheme['subtle_accent']} {scheme['dark']} {scheme['bg']}
client.urgent           {scheme['warning']} {scheme['dark']} {scheme['fg']} {scheme['warning']} {scheme['dark']}
client.placeholder      {scheme['dark']} {scheme['bg']} {scheme['subtle_accent']} {scheme['dark']} {scheme['bg']}

# Bar-related colors for the main config
set $statusline {scheme['fg']}
set $background {scheme['bg']}
set $separator {scheme['accent']}
set $focused_workspace_border {scheme['accent']}
set $focused_workspace_bg {scheme['dark']}
set $focused_workspace_text {scheme['fg']}
set $active_workspace_border {scheme['dark']}
set $active_workspace_bg {scheme['dark']}
set $active_workspace_text {scheme['subtle_accent']}
set $inactive_workspace_border {scheme['bg']}
set $inactive_workspace_bg {scheme['bg']}
set $inactive_workspace_text {scheme['subtle_accent']}
set $urgent_workspace_border {scheme['warning']}
set $urgent_workspace_bg {scheme['dark']}
set $urgent_workspace_text {scheme['fg']}
''')
    except Exception as e:
        print(f"Error writing Sway config: {e}", file=sys.stderr)
        return False
    return True

def write_waybar_css(scheme, wallpaper):
    """Write Waybar CSS variables."""
    try:
        with open(WAYBAR_CSS_VARS, 'w') as f:
            f.write(f'''/* Auto-generated colors from wallpaper: {os.path.basename(wallpaper)} */
@define-color bg {scheme['bg']};
@define-color dark {scheme['dark']};
@define-color fg {scheme['fg']};
@define-color accent {scheme['accent']};
@define-color subtle {scheme['subtle_accent']};
@define-color warning {scheme['warning']};
@define-color critical {scheme['critical']};
''')
    except Exception as e:
        print(f"Error writing Waybar CSS: {e}", file=sys.stderr)
        return False
    return True

def write_wofi_css(scheme, wallpaper):
    """Write wofi style configuration."""
    try:
        # Create the directory if needed
        os.makedirs(os.path.dirname(WOFI_CSS), exist_ok=True)
            
        with open(WOFI_CSS, 'w') as f:
            f.write(f'''/* Auto-generated wofi style from wallpaper: {os.path.basename(wallpaper)} */

window {{
    font-family: "JetBrains Mono", monospace;
    font-size: 13px;
    background-color: rgba({int(scheme['dark'][1:3], 16)}, {int(scheme['dark'][3:5], 16)}, {int(scheme['dark'][5:7], 16)}, 0.85);
    color: {scheme['fg']};
    border: 2px solid {scheme['accent']};
    border-radius: 15px;
    margin: 5px;
}}

#input {{
    margin: 5px;
    background-color: rgba({int(scheme['bg'][1:3], 16)}, {int(scheme['bg'][3:5], 16)}, {int(scheme['bg'][5:7], 16)}, 0.7);
    color: {scheme['fg']};
    border: 1px solid {scheme['subtle_accent']};
    border-radius: 8px;
    padding: 8px;
}}

#outer-box {{
    margin: 5px;
    padding: 15px;
}}

#inner-box {{
    margin: 5px;
    padding: 5px;
    background-color: transparent;
}}

#scroll {{
    margin: 0px;
    padding: 5px;
}}

#img {{
    margin-right: 10px;
}}

#text {{
    margin: 5px;
    padding: 5px;
}}

#entry {{
    padding: 10px;
    margin: 3px 0px;
    border-radius: 10px;
}}

#entry:selected {{
    background-color: rgba({int(scheme['accent'][1:3], 16)}, {int(scheme['accent'][3:5], 16)}, {int(scheme['accent'][5:7], 16)}, 0.7);
    color: {scheme['fg']};
    border-radius: 10px;
}}

#text:selected {{
    color: {scheme['fg']};
    font-weight: bold;
}}

/* For icon-focused view */
.entry {{
    padding: 8px;
}}

/* Improve icon display */
#icon {{
    min-width: 48px;
    min-height: 48px;
    margin: 5px;
}}
''')
        print(f"Generated wofi style at {WOFI_CSS}", file=sys.stderr)
        return True
    except Exception as e:
        print(f"Error writing wofi style: {e}", file=sys.stderr)
        return False

def write_wofi_config(wallpaper):
    """Write wofi configuration file."""
    try:
        # Create the directory if needed
        os.makedirs(os.path.dirname(WOFI_CONFIG), exist_ok=True)
            
        with open(WOFI_CONFIG, 'w') as f:
            f.write(f'''# Auto-generated wofi configuration from wallpaper: {os.path.basename(wallpaper)}

# Position and size
width=650
height=450
location=center
orientation=vertical
halign=fill
valign=center

# Appearance
show=drun
prompt=
normal_window=false
layer=overlay
term=kitty
allow_images=true
image_size=48
insensitive=true

# Behavior
allow_markup=true
no_actions=true
filter_rate=100
key_expand=Tab
sort_order=alphabetical
''')
    except Exception as e:
        print(f"Error writing wofi config: {e}", file=sys.stderr)
        return False
    return True

def write_dunst_config(scheme, wallpaper):
    """Write dunst notification color configuration."""
    try:
        import re
        
        # Clean up any existing backup files
        backup_pattern = f"{DUNST_CONFIG}.backup*"
        import glob
        for backup_file in glob.glob(backup_pattern):
            try:
                os.remove(backup_file)
                print(f"Removed old backup: {backup_file}", file=sys.stderr)
            except:
                pass
        
        # Read the existing dunst config to preserve non-color settings
        existing_config = ""
        if os.path.exists(DUNST_CONFIG):
            with open(DUNST_CONFIG, 'r') as f:
                content = f.read()
                # Remove all old header comments (lines starting with # Auto-generated)
                lines = content.split('\n')
                filtered_lines = []
                skip_header = True
                for line in lines:
                    if line.startswith('# Auto-generated') or line.startswith('# Generated on'):
                        continue
                    elif line.strip() == '' and skip_header:
                        continue
                    else:
                        skip_header = False
                        filtered_lines.append(line)
                existing_config = '\n'.join(filtered_lines)
        
        # Create base config if it doesn't exist or is empty
        if not existing_config.strip():
            existing_config = """[global]
    # Display
    monitor = 0
    follow = mouse

    width = 200
    height = (50, 50)
    origin = top-right
    offset = 10

    indicate_hidden = yes
    shrink = no
    transparency = 80
    separator_height = 2
    padding = 10
    horizontal_padding = 12
    frame_width = 2
    frame_color = "#88c0d0"
    separator_color = frame
    sort = yes
    idle_threshold = 120
    gap_size = 10

    # Text
    font = SpaceMono Nerd Font Mono 12
    line_height = 0
    markup = full
    format = "<b>%s</b>\\n%b"
    alignment = left
    show_age_threshold = 60
    word_wrap = yes
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes

    # Icons
    icon_position = left
    max_icon_size = 32
    icon_path = /usr/share/icons/gnome/16x16/status/:/usr/share/icons/gnome/16x16/devices/

    # History
    sticky_history = yes
    history_length = 20

    # Misc/Advanced
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/firefox -new-tab
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 8

    # Mouse
    mouse_left_click = close_current
    mouse_middle_click = do_action
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false"""

        # Update the frame_color in [global] section with generated colors
        existing_config = re.sub(
            r'(\s*frame_color\s*=\s*)["\']?[^#\n]*#[a-fA-F0-9]{6}["\']?',
            f'\\1{scheme["accent"]}',
            existing_config
        )
        
        # Create better, more readable colors for different urgency levels
        def adjust_dunst_color(base_rgb, lightness_factor=1.0, saturation_factor=1.0):
            """Adjust colors specifically for dunst readability"""
            r, g, b = [int(base_rgb[i:i+2], 16) for i in (1, 3, 5)]
            r, g, b = [x/255.0 for x in (r, g, b)]
            h, l, s = colorsys.rgb_to_hls(r, g, b)
            
            l = max(0, min(1, l * lightness_factor))
            s = max(0, min(1, s * saturation_factor))
            
            r, g, b = colorsys.hls_to_rgb(h, l, s)
            return '#{:02x}{:02x}{:02x}'.format(int(r*255), int(g*255), int(b*255))
        
        # Create more subtle and readable color variations
        # Low urgency - very subtle, low contrast
        low_bg = adjust_dunst_color(scheme['bg'], lightness_factor=0.9, saturation_factor=0.6)
        low_fg = scheme['fg']  # Keep text readable
        
        # Normal urgency - moderate visibility  
        normal_bg = adjust_dunst_color(scheme['dark'], lightness_factor=1.1, saturation_factor=0.8)
        normal_fg = scheme['fg']
        normal_frame = adjust_dunst_color(scheme['accent'], lightness_factor=0.9, saturation_factor=0.9)
        
        # Critical urgency - high visibility but not harsh
        critical_bg = adjust_dunst_color(scheme['warning'], lightness_factor=0.7, saturation_factor=0.8)
        critical_fg = scheme['fg']
        critical_frame = adjust_dunst_color(scheme['critical'], lightness_factor=0.8, saturation_factor=0.9)
        
        # Remove existing urgency sections
        existing_config = re.sub(r'\[urgency_low\][^[]*(?=\[|\Z)', '', existing_config, flags=re.DOTALL)
        existing_config = re.sub(r'\[urgency_normal\][^[]*(?=\[|\Z)', '', existing_config, flags=re.DOTALL)
        existing_config = re.sub(r'\[urgency_critical\][^[]*(?=\[|\Z)', '', existing_config, flags=re.DOTALL)
        
        # Add new urgency sections at the end
        urgency_sections = f"""

[urgency_low]
    background = "{low_bg}"
    foreground = "{low_fg}"
    timeout = 10

[urgency_normal]
    background = "{normal_bg}"
    foreground = "{normal_fg}"
    frame_color = "{normal_frame}"
    timeout = 10

[urgency_critical]
    background = "{critical_bg}"
    foreground = "{critical_fg}"
    frame_color = "{critical_frame}"
    timeout = 0
"""
        
        # Add header comment (single, clean header)
        header_comment = f"# Auto-generated dunst colors from wallpaper: {os.path.basename(wallpaper)}\n\n"
        
        # Write the updated config
        os.makedirs(os.path.dirname(DUNST_CONFIG), exist_ok=True)
        with open(DUNST_CONFIG, 'w') as f:
            f.write(header_comment + existing_config.rstrip() + urgency_sections)
        
        print(f"Generated dunst config at {DUNST_CONFIG}", file=sys.stderr)
        return True
    except Exception as e:
        print(f"Error writing dunst config: {e}", file=sys.stderr)
        return False

def write_kitty_colors(scheme, wallpaper):
    """Write kitty color configuration matching the example aesthetic with darker pastel backgrounds."""
    try:
        kitty_config = os.path.expanduser('~/.config/kitty/colors.conf')
        os.makedirs(os.path.dirname(kitty_config), exist_ok=True)

        def rgb_to_hex(rgb):
            return '#{:02x}{:02x}{:02x}'.format(*rgb)

        def pastelize(rgb, l_factor=1.25, s_factor=0.4):
            """Create soft pastel colors similar to the example"""
            r, g, b = [x/255.0 for x in rgb]
            h, l, s = colorsys.rgb_to_hls(r, g, b)
            l = min(0.9, l * l_factor)  # Cap at 0.9 to avoid pure white
            s = max(0.05, s * s_factor)  # Lower saturation for pastel look
            r, g, b = colorsys.hls_to_rgb(h, l, s)
            return tuple(int(x * 255) for x in (r, g, b))

        def make_dark_bg(rgb, darkness=0.7, pastel_factor=0.5):
            """Create a darker, slightly pastel background similar to #1a2423"""
            r, g, b = [x/255.0 for x in rgb]
            h, l, s = colorsys.rgb_to_hls(r, g, b)
            # Darken
            l = max(0.05, min(0.2, l * darkness))
            # Reduce saturation slightly for pastel effect
            s = max(0.05, s * pastel_factor)
            r, g, b = colorsys.hls_to_rgb(h, l, s)
            return tuple(int(x * 255) for x in (r, g, b))

        def brightness(rgb):
            return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]
            
        def is_dark(rgb, threshold=128):
            return brightness(rgb) < threshold
            
        def desaturate(rgb, factor=0.7):
            """Reduce saturation of a color"""
            r, g, b = [x/255.0 for x in rgb]
            h, l, s = colorsys.rgb_to_hls(r, g, b)
            s = max(0.0, s * factor)
            r, g, b = colorsys.hls_to_rgb(h, l, s)
            return tuple(int(x * 255) for x in (r, g, b))

        # Extract a palette of 10 colors from the wallpaper
        palette = []
        try:
            img = Image.open(wallpaper).convert('RGB').resize((100, 100))
            quantized = img.quantize(colors=10)
            palette_raw = quantized.getpalette()
            color_counts = sorted(quantized.getcolors(), reverse=True)
            for count, idx in color_counts:
                rgb = tuple(palette_raw[idx*3:idx*3+3])
                if rgb not in palette:
                    palette.append(rgb)
                if len(palette) >= 10:
                    break
        except Exception as e:
            palette = [(33, 26, 24), (237, 224, 220), (255, 180, 169), (155, 68, 39), (215, 198, 141), (124, 45, 18), (255, 219, 207), (255, 181, 156), (237, 224, 220)]

        palette = sorted(palette, key=brightness)

        # Background: Make it darker and slightly pastel like example #1a2423
        bg = make_dark_bg(palette[1], darkness=0.65, pastel_factor=0.5)
        
        # Determine if background is dark or light
        bg_is_dark = is_dark(bg)
        
        # Foreground: For dark backgrounds, use pure white as in the example
        if bg_is_dark:
            fg = (255, 255, 255)  # Pure white like in the example
        else:
            # For light backgrounds, use dark desaturated color
            fg = desaturate(palette[0], 0.8)
            # Ensure it's dark enough
            if brightness(fg) > 60:
                fg = (30, 30, 30)
        
        cursor = fg
        
        # Create harmonious pastel colors similar to example
        color_slots = []
        
        # Use the middle to lighter colors from the palette
        for c in palette[2:]:
            if len(color_slots) < 6:
                color_slots.append(c)
        
        # If still not enough colors, add more from the palette
        while len(color_slots) < 6:
            if len(color_slots) % 2 == 0:
                # Add a pastel version of the darkest color
                dark_pastel = pastelize(palette[0], l_factor=1.6, s_factor=0.4)
                color_slots.append(dark_pastel)
            else:
                # Add a desaturated version of a middle color
                mid_index = len(palette) // 2
                desat_mid = desaturate(palette[mid_index], 0.7)
                color_slots.append(desat_mid)
        
        # Pastelize all color slots to match example
        pastel_slots = []
        for c in color_slots:
            # Create warm, muted pastels like in the example
            p = pastelize(c, l_factor=1.3, s_factor=0.35)
            # Ensure colors are visible against background
            if abs(brightness(p) - brightness(bg)) < 80:
                if bg_is_dark:
                    # Lighten color if background is dark
                    r, g, b = [x/255.0 for x in p]
                    h, l, s = colorsys.rgb_to_hls(r, g, b)
                    l = min(0.9, l * 1.4)
                    r, g, b = colorsys.hls_to_rgb(h, l, s)
                    p = tuple(int(x * 255) for x in (r, g, b))
                else:
                    # Darken color if background is light
                    r, g, b = [x/255.0 for x in p]
                    h, l, s = colorsys.rgb_to_hls(r, g, b)
                    l = max(0.2, l * 0.7)
                    r, g, b = colorsys.hls_to_rgb(h, l, s)
                    p = tuple(int(x * 255) for x in (r, g, b))
            pastel_slots.append(p)
            
        # Create bright variants similar to example
        bright_slots = []
        for c in pastel_slots:
            if bg_is_dark:
                # For dark backgrounds, create lighter colors 
                r, g, b = [x/255.0 for x in c]
                h, l, s = colorsys.rgb_to_hls(r, g, b)
                l = min(0.95, l * 1.15)  # Lighter but not pure white
                s = max(0.05, s * 0.9)   # Slightly less saturated
                r, g, b = colorsys.hls_to_rgb(h, l, s)
                b = tuple(int(x * 255) for x in (r, g, b))
            else:
                # For light backgrounds, create more saturated colors
                r, g, b = [x/255.0 for x in c]
                h, l, s = colorsys.rgb_to_hls(r, g, b)
                l = max(0.25, l * 0.9)  # Slightly darker
                s = min(0.8, s * 1.2)   # More saturated
                r, g, b = colorsys.hls_to_rgb(h, l, s)
                b = tuple(int(x * 255) for x in (r, g, b))
                
            bright_slots.append(b)

        with open(kitty_config, 'w') as f:
            f.write(f"""# Auto-generated kitty colors from wallpaper: {os.path.basename(wallpaper)}
# Background brightness: {'dark' if bg_is_dark else 'light'}

foreground   {rgb_to_hex(fg)}
background   {rgb_to_hex(bg)}
cursor       {rgb_to_hex(cursor)}

color0 {rgb_to_hex(bg)}
color8 {rgb_to_hex(make_dark_bg(bg, darkness=1.1, pastel_factor=0.9) if bg_is_dark else desaturate(bg, 0.9))}

color1 {rgb_to_hex(pastel_slots[0])}
color9 {rgb_to_hex(bright_slots[0])}

color2 {rgb_to_hex(pastel_slots[1])}
color10 {rgb_to_hex(bright_slots[1])}

color3 {rgb_to_hex(pastel_slots[2])}
color11 {rgb_to_hex(bright_slots[2])}

color4 {rgb_to_hex(pastel_slots[3])}
color12 {rgb_to_hex(bright_slots[3])}

color5 {rgb_to_hex(pastel_slots[4])}
color13 {rgb_to_hex(bright_slots[4])}

color6 {rgb_to_hex(pastel_slots[5])}
color14 {rgb_to_hex(bright_slots[5])}

color7 {rgb_to_hex(fg)}
color15 {rgb_to_hex(fg)}
""")
        print(f"Generated kitty colors at {kitty_config}", file=sys.stderr)
        return True
    except Exception as e:
        print(f"Error writing kitty colors: {e}", file=sys.stderr)
        return False

def main():
    # Check if a specific wallpaper was provided
    if len(sys.argv) > 1 and os.path.isfile(sys.argv[1]):
        wallpaper = sys.argv[1]
        print(f"Using specified wallpaper: {wallpaper}", file=sys.stderr)
    else:
        # Check if there's a saved wallpaper and we're using --reload-only
        if '--reload-only' in sys.argv and os.path.exists(CURRENT_WALLPAPER_FILE):
            with open(CURRENT_WALLPAPER_FILE, 'r') as f:
                saved_wallpaper = f.read().strip()
                if os.path.exists(saved_wallpaper):
                    print(f"Using saved wallpaper: {saved_wallpaper}", file=sys.stderr)
                    print(saved_wallpaper)
                    sys.exit(0)
                else:
                    print(f"Saved wallpaper not found: {saved_wallpaper}", file=sys.stderr)
        
        # Ensure wallpaper directory exists
        if not os.path.exists(WALLS_DIR):
            try:
                os.makedirs(WALLS_DIR, exist_ok=True)
                print(f"Created wallpaper directory: {WALLS_DIR}", file=sys.stderr)
            except Exception as e:
                print(f"Error creating wallpaper directory: {e}", file=sys.stderr)
                sys.exit(1)
        
        # Get all .png, .jpg, and .jpeg files
        files = []
        for f in os.listdir(WALLS_DIR):
            if f.lower().endswith(('.png', '.jpg', '.jpeg')) and not f.startswith('.'):
                files.append(os.path.join(WALLS_DIR, f))
        
        # Pick a random wallpaper if files were found
        if files:
            wallpaper = random.choice(files)
            print(f"Selected random wallpaper: {wallpaper}", file=sys.stderr)
        else:
            print(f"Error: No wallpaper files found in {WALLS_DIR}", file=sys.stderr)
            sys.exit(1)
    
    # Get colors from the wallpaper
    base_color = get_colors_from_image(wallpaper)
    color_scheme = create_color_scheme(base_color)
    
    # Write configuration files
    success = write_sway_config(color_scheme, wallpaper) and \
              write_waybar_css(color_scheme, wallpaper) and \
              write_wofi_css(color_scheme, wallpaper) and \
              write_wofi_config(wallpaper) and \
              write_dunst_config(color_scheme, wallpaper) and \
              write_kitty_colors(color_scheme, wallpaper)
    
    # Save the wallpaper path to the current wallpaper file
    try:
        with open(CURRENT_WALLPAPER_FILE, 'w') as f:
            f.write(wallpaper)
    except Exception as e:
        print(f"Error saving current wallpaper path: {e}", file=sys.stderr)
        
    if success:
        # Print the wallpaper path as the only stdout output
        # (this is captured by the shell script)
        print(wallpaper)
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()