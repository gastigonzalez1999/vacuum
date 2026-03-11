# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-10

### Added

- Commands: `scan`, `clean`, `analyze`, `space`, `tui`, `config`
- Categories: cache, trash, temp, downloads, build artifacts, large files, duplicates, old files
- Scan result cache: reuse scan within 5 minutes when running `vacuum clean` after `vacuum scan`
- Custom clean paths in config (`~/.config/vacuum/config.toml`)
- Interactive category selection in `vacuum clean` (Space=toggle, Enter=confirm; all pre-selected by default)
- TUI mode: `vacuum tui` for interactive disk usage visualization
- **Windows support**: cache, trash (Recycle Bin), temp scanners; known caches (npm, Chrome, VS Code, Docker, JetBrains, etc.); PowerShell installer
- TUI fallback to JSON when stdout is not a TTY (e.g. piped)

### Fixed

- Category selection: pressing Enter without toggling no longer exits with "No categories selected"
- TUI terminal teardown: raw mode and alternate screen restored on panic or early exit
