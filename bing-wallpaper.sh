#!/usr/bin/env bash
set -euo pipefail

SCRIPT=$(basename "$0")
VERSION="1.0.0"

# Defaults
PICTURE_DIR="${HOME}/Pictures/bing-wallpapers"
RESOLUTION="UHD"
BOOST=1
PROTO="https"
QUIET=false
FORCE=false
SET_WALLPAPER=false
FILENAME=""

SUPPORTED_RESOLUTIONS=("UHD" "1920x1200" "1920x1080" "800x480" "400x240")

log() {
    [[ "$QUIET" == true ]] || echo -e "$1"
}

die() {
    echo "$1" >&2
    exit 1
}

usage() {
cat <<EOF
Usage:
  $SCRIPT [options]

Options:
  -f, --force              Overwrite existing files
  -s, --ssl                Use HTTPS (default)
  -b, --boost <n>          Download last n images (default: 1)
  -q, --quiet              Silent mode
  -n, --filename <name>    Custom filename
  -p, --picturedir <dir>   Download directory (default: $PICTURE_DIR)
  -r, --resolution <res>   Image resolution
  -w, --set-wallpaper      Set as wallpaper (macOS only)
  -h, --help               Show help
  --version                Show version
EOF
}

# ------------------------
# Argument Parsing
# ------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--resolution)
            [[ -n "${2:-}" ]] || die "Missing value for --resolution"
            RESOLUTION="$2"
            shift
            ;;
        -p|--picturedir)
            [[ -n "${2:-}" ]] || die "Missing value for --picturedir"
            PICTURE_DIR="$2"
            shift
            ;;
        -n|--filename)
            [[ -n "${2:-}" ]] || die "Missing value for --filename"
            FILENAME="$2"
            shift
            ;;
        -b|--boost)
            [[ "${2:-}" =~ ^[0-9]+$ ]] || die "--boost must be a number"
            BOOST="$2"
            shift
            ;;
        -f|--force) FORCE=true ;;
        -s|--ssl) PROTO="https" ;;
        -q|--quiet) QUIET=true ;;
        -w|--set-wallpaper) SET_WALLPAPER=true ;;
        -h|--help) usage; exit 0 ;;
        --version) echo "$VERSION"; exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
    shift
done

# ------------------------
# Validate Resolution
# ------------------------

if [[ ! " ${SUPPORTED_RESOLUTIONS[*]} " =~ " ${RESOLUTION} " ]]; then
    die "Unsupported resolution: $RESOLUTION"
fi

# ------------------------
# Setup
# ------------------------

mkdir -p "$PICTURE_DIR"

API_URL="${PROTO}://www.bing.com/HPImageArchive.aspx?format=js&n=${BOOST}"

log "Fetching metadata..."

response=$(curl -fsSL "$API_URL") || die "Failed to fetch data"

# Extract URL
urls=()
while IFS= read -r line; do
    urls+=("$line")
done < <(
    echo "$response" |
    grep -o '"url":"[^"]*"' |
    sed 's/"url":"\(.*\)"/\1/' |
    sed "s/[0-9]\{3,4\}x[0-9]\{3,4\}/${RESOLUTION}/" |
    sed "s|^|${PROTO}://www.bing.com|"
)

[[ ${#urls[@]} -gt 0 ]] || die "No images found"

# ------------------------
# Download Images
# ------------------------

for url in "${urls[@]}"; do
    if [[ -z "$FILENAME" ]]; then
        id_part=$(echo "$url" | sed -n 's/.*id=\([^&]*\).*/\1/p')
        # remove prefix + resolution suffix
        clean_name=$(echo "$id_part" | sed -E 's/^OHR\.//; s/_UHD.*//')
        
        filename="$(date +%Y-%m-%d)_${clean_name}_${id_part##*.}.jpg"
    else
        filename="$FILENAME"
        if [[ "$filename" != *.* ]]; then
            filename="${filename}.jpg"
        fi
    fi

    filepath="${PICTURE_DIR}/${filename}"

    if [[ -f "$filepath" && "$FORCE" == false ]]; then
    log "Skipping: $filename"
    LAST_FILE="$filepath"
    continue
    fi
    
    log "Downloading: $filename"
    curl -fsSL -o "$filepath" "$url" || die "Download failed"
    
    LAST_FILE="$filepath"
done


if [[ "$SET_WALLPAPER" == true ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Setting wallpaper..."
        osascript <<EOF
tell application "System Events"
    set picture of every desktop to POSIX file "$LAST_FILE"
end tell
EOF
    else
        log "Wallpaper setting only supported on macOS"
    fi
fi

log "Completed!"