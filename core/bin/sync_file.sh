#!/bin/bash

# Check for even number of arguments
if [ $(( $# % 2 )) -ne 0 ]; then
  echo "Error: You must supply source and destination pairs."
  echo "Usage: $0 source1 dest1 [source2 dest2 ...]"
  exit 1
fi

# Loop over pairs of arguments
while [ $# -gt 0 ]; do
  SOURCE_FILE="$1"
  DEST_FILE="$2"

  # Shift to next pair
  shift 2

  # Check if source file exists
  if [ ! -f "$SOURCE_FILE" ]; then
    echo "Source file '$SOURCE_FILE' does not exist. Skipping..."
    continue
  fi

  # Create destination directory if it doesn't exist
  DEST_DIR=$(dirname "$DEST_FILE")
  mkdir -p "$DEST_DIR"

  # If destination file doesn't exist, copy it
  if [ ! -f "$DEST_FILE" ]; then
    echo "Destination file '$DEST_FILE' does not exist. Copying..."
    cp "$SOURCE_FILE" "$DEST_FILE"
  else
    # Compare files
    if cmp -s "$SOURCE_FILE" "$DEST_FILE"; then
      echo "Files '$SOURCE_FILE' and '$DEST_FILE' are identical. Skipping..."
    else
      echo "Files '$SOURCE_FILE' and '$DEST_FILE' differ. Copying..."
      cp "$SOURCE_FILE" "$DEST_FILE"
    fi
  fi
done
