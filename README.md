# vacuum

Disk cleanup CLI for developers. Finds and removes build artifacts, caches, and other space hogs.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/gastigonzalez1999/vacuum/main/install.sh | sh
```

<details>
<summary>Other install methods</summary>

**With Cargo:**
```bash
cargo install --git https://github.com/gastigonzalez1999/vacuum
```

**Manual download:**
- [macOS Apple Silicon](https://github.com/gastigonzalez1999/vacuum/releases/latest/download/vacuum-macos-arm64.tar.gz)
- [macOS Intel](https://github.com/gastigonzalez1999/vacuum/releases/latest/download/vacuum-macos-x86_64.tar.gz)
- [Linux x86_64](https://github.com/gastigonzalez1999/vacuum/releases/latest/download/vacuum-linux-x86_64.tar.gz)
- [Windows x86_64](https://github.com/gastigonzalez1999/vacuum/releases/latest/download/vacuum-windows-x86_64.zip)

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/gastigonzalez1999/vacuum/main/install.ps1 | iex
```

</details>

## Commands

```bash
vacuum scan              # Find cleanable files (dry-run)
vacuum clean             # Select categories, then delete (with confirmation)
vacuum clean -y          # Delete without confirmation
vacuum analyze           # Detailed breakdown by category
vacuum space             # Total / free disk space (default: home fs)
vacuum space --path /tmp # For a specific path's filesystem
vacuum space --json      # Machine-readable output
vacuum tui               # Interactive TUI to visualize cleanable disk usage
vacuum config            # Show current settings
```

## Categories

```bash
--cache       # App/system caches (~/.cache, ~/Library/Caches)
--trash       # Trash bin
--temp        # Temp files older than 1 day
--downloads   # Old files in ~/Downloads
--build       # Build artifacts from inactive projects (node_modules, target/, etc.)
--large       # Files over 100MB
--duplicates  # Duplicate files (by hash)
--old         # Files not accessed in 30+ days
--all, -a     # All categories (default if none specified)
```

## Options

```bash
--min-age <DAYS>      # Age threshold for old files (default: 30)
--min-size <SIZE>     # Size threshold for large files (default: 100MB)
--project-age <DAYS>  # Projects inactive for this long are cleanable (default: 14)
--path <PATH>         # Scan path (default: home directory)
--exclude <PATTERN>   # Exclude matching paths (repeatable)
--json                # Output as JSON
```

## Examples

```bash
# Quick cache cleanup
vacuum clean --cache --trash -y

# Find build artifacts from old projects
vacuum scan --build --project-age 30

# Large files over 500MB
vacuum scan --large --min-size 500MB

# Everything as JSON
vacuum scan --json
```

## TUI Mode

Run `vacuum tui` for an interactive terminal visualization of cleanable disk space by category.
Use `up/down` (or `j/k`) to move between categories and `q` to exit.

## Config File

Optional: `~/.config/vacuum/config.toml`

```toml
min_age_days = 30
min_large_size_mb = 100
project_recent_days = 14
download_age_days = 30
excluded_paths = ["important-project/node_modules"]
custom_paths = [
  { path = "~/Library/Application Support/Cursor Nightly", category = "cache", description = "Cursor Nightly app data" },
  { path = "~/Library/Caches/co.anysphere.cursor.nightly", category = "cache", description = "Cursor Nightly cache" },
  { path = "~/Library/Caches/co.anysphere.cursor.nightly.ShipIt", category = "cache", description = "Cursor Nightly updater cache" },
  { path = "~/dev/everysphere/anyrun/target", category = "build", description = "Anyrun build artifacts" }
]
```

### Custom Clean Paths

Use `custom_paths` to include specific directories or files that vacuum doesn't
discover automatically. Each entry supports:

- `path`: Absolute or `~/`-relative path.
- `category`: One of `cache`, `build`, `trash`, `temp`, `downloads`, `large`, `duplicates`, `old`.
- `description`: Optional text shown in reports.
- `min_size_mb`: Optional size threshold (defaults to 1MB).

## How Build Detection Works

Build artifacts (`node_modules`, `target/`, `.gradle`, etc.) are only flagged if the parent project hasn't been modified within `--project-age` days. This protects active projects.
