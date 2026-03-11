#!/bin/sh
set -e

REPO="gastigonzalez1999/vacuum"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  darwin) OS="macos" ;;
  linux) OS="linux" ;;
  *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

case "$ARCH" in
  x86_64) ARCH="x86_64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Linux only has x86_64 builds
if [ "$OS" = "linux" ]; then
  ARCH="x86_64"
fi

ASSET="vacuum-${OS}-${ARCH}.tar.gz"
URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"

echo "Downloading vacuum for ${OS}-${ARCH}..."
curl -fsSL "$URL" -o /tmp/vacuum.tar.gz
tar -xzf /tmp/vacuum.tar.gz -C /tmp
rm /tmp/vacuum.tar.gz

# Try to install to /usr/local/bin, fall back to ~/.local/bin
INSTALL_DIR=""

if [ -w "/usr/local/bin" ]; then
  INSTALL_DIR="/usr/local/bin"
  mv /tmp/vacuum "$INSTALL_DIR/vacuum"
elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  # sudo available without password
  INSTALL_DIR="/usr/local/bin"
  sudo mv /tmp/vacuum "$INSTALL_DIR/vacuum"
  sudo chmod +x "$INSTALL_DIR/vacuum"
else
  # Fall back to user directory
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"
  mv /tmp/vacuum "$INSTALL_DIR/vacuum"
  chmod +x "$INSTALL_DIR/vacuum"
fi

echo "Installed to ${INSTALL_DIR}/vacuum"

# Check if install dir is in PATH
add_to_path() {
  SHELL_NAME=$(basename "$SHELL")
  case "$SHELL_NAME" in
    zsh)
      PROFILE="$HOME/.zshrc"
      ;;
    bash)
      if [ -f "$HOME/.bashrc" ]; then
        PROFILE="$HOME/.bashrc"
      else
        PROFILE="$HOME/.bash_profile"
      fi
      ;;
    fish)
      PROFILE="$HOME/.config/fish/config.fish"
      mkdir -p "$(dirname "$PROFILE")"
      ;;
    *)
      PROFILE="$HOME/.profile"
      ;;
  esac
  
  if [ -f "$PROFILE" ] || [ "$SHELL_NAME" = "fish" ]; then
    if ! grep -q "$INSTALL_DIR" "$PROFILE" 2>/dev/null; then
      echo "" >> "$PROFILE"
      echo "# Added by vacuum installer" >> "$PROFILE"
      if [ "$SHELL_NAME" = "fish" ]; then
        echo "set -gx PATH \"$INSTALL_DIR\" \$PATH" >> "$PROFILE"
      else
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$PROFILE"
      fi
      echo "Added $INSTALL_DIR to PATH in $PROFILE"
    fi
  fi
}

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
  echo ""
  add_to_path
  echo ""
  echo "Restart your terminal or run:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "✓ vacuum installed successfully!"
echo ""
echo "Run 'vacuum --help' to get started."
