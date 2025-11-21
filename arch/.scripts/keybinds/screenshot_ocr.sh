#!/bin/bash

# Exit on any error
set -e

# Define temporary files
IMG_FILE="/tmp/scr.jpg"
TXT_FILE="/tmp/scr.txt"
CLEAN_TXT_FILE="/tmp/scr_clean.txt"

# Check for required tools
if ! command -v spectacle >/dev/null 2>&1; then
    echo "Error: spectacle is not installed. Install it with: sudo pacman -S spectacle"
    exit 1
fi
if ! command -v tesseract >/dev/null 2>&1; then
    echo "Error: tesseract-ocr is not installed. Install it with: sudo pacman -S tesseract-ocr tesseract-data-eng"
    exit 1
fi
if ! command -v wl-copy >/dev/null 2>&1; then
    echo "Error: wl-clipboard is not installed. Install it with: sudo pacman -S wl-clipboard"
    exit 1
fi
if ! command -v magick >/dev/null 2>&1; then
    echo "Error: imagemagick is not installed or outdated. Install it with: sudo pacman -S imagemagick"
    exit 1
fi
if ! command -v strings >/dev/null 2>&1; then
    echo "Error: coreutils (strings) is not installed. Install it with: sudo pacman -S coreutils"
    exit 1
fi

# Clear existing screenshot and text files to avoid conflicts
rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE" >/dev/null 2>&1

# Capture screenshot with spectacle
echo "Capturing screenshot with spectacle..."
spectacle -r -b -n -o "$IMG_FILE" || { echo "Error: Failed to capture screenshot with spectacle. Try resetting config: rm ~/.config/spectaclerc"; exit 1; }

# Check if screenshot file was created
if [ ! -f "$IMG_FILE" ]; then
    echo "Error: Screenshot file $IMG_FILE not created"
    exit 1
fi

# Verify image is valid
if ! magick identify "$IMG_FILE" >/dev/null 2>&1; then
    echo "Error: Screenshot file $IMG_FILE is invalid or corrupted"
    rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"
    exit 1
fi

# Preprocess image to improve OCR accuracy
echo "Preprocessing image..."
magick "$IMG_FILE" -threshold 50% -monochrome -sharpen 0x1 "$IMG_FILE" || { echo "Error: Image preprocessing failed"; rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"; exit 1; }

# Perform OCR with Tesseract
echo "Running Tesseract OCR..."
tesseract "$IMG_FILE" "${TXT_FILE%.txt}" -l eng --psm 6 --oem 3 || { echo "Error: Tesseract OCR failed"; rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"; exit 1; }

# Check if OCR output file exists
if [ ! -f "$TXT_FILE" ]; then
    echo "Error: OCR output file $TXT_FILE not created"
    rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"
    exit 1
fi

# Debug: Display raw OCR output
echo "Raw OCR output ($TXT_FILE):"
if ! cat "$TXT_FILE"; then
    echo "Warning: Failed to display raw OCR output"
    rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"
    exit 1
fi

# Clean OCR output to remove non-text data
echo "Cleaning OCR output..."
if ! cat "$TXT_FILE" | strings | grep -vE '^[[:space:]]*$' > "$CLEAN_TXT_FILE"; then
    echo "Warning: Failed to clean OCR output, checking raw output..."
    cat "$TXT_FILE"
    rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"
    exit 1
fi

# Check if cleaned text file is empty
if [ ! -s "$CLEAN_TXT_FILE" ]; then
    echo "Error: Cleaned OCR output is empty"
    cat "$TXT_FILE"  # Show raw output for debugging
    rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"
    exit 1
fi

# Display cleaned text for debugging
echo "OCR output (cleaned, $CLEAN_TXT_FILE):"
cat "$CLEAN_TXT_FILE"

# Copy cleaned text to clipboard
echo "Copying text to clipboard..."
cat "$CLEAN_TXT_FILE" | wl-copy --type text/plain || { echo "Error: Failed to copy text to clipboard"; rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"; exit 1; }

# Verify clipboard content
echo "Clipboard content (verify with 'wl-paste'):"
wl-paste

# Clean up temporary files
rm -f "$IMG_FILE" "$TXT_FILE" "$CLEAN_TXT_FILE"
