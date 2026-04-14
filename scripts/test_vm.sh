#!/bin/zsh

# --- CONFIGURATION ---
VM_NAME="macos-test-sandbox"
# Pull vanilla Sequoia (macOS 15) image
IMAGE_SOURCE="ghcr.io/cirruslabs/macos-sequoia-vanilla:latest"

# --- 1. PULL IMAGE ---
if ! tart list | grep -q "$IMAGE_SOURCE"; then
  echo "Action: Pulling fresh macOS image (this takes time)..."
  tart pull "$IMAGE_SOURCE"
fi

# --- 2. CLONE FOR DISPOSABILITY ---
# Clone the base image and delete it later
echo "Action: Creating a disposable clone: $VM_NAME"
tart delete "$VM_NAME" 2>/dev/null
tart clone "$IMAGE_SOURCE" "$VM_NAME"

# --- 3. RUN THE VM ---
echo "Action: Booting VM..."
echo "TIP: Once inside, go to /Volumes/My Shared Files/dotfiles and run your sync.sh"
tart run "$VM_NAME" --vnc --dir="dotfiles:$HOME/dotfiles"
tart delete macos-test-sandbox
