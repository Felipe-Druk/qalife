```text
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
```

# QALIFE V 0.2.1

Qalife is a unified Command Line Interface (CLI) application and security-focused 
maintenance suite designed for Debian-based Linux distributions (Ubuntu, Kubuntu).

Version 0.2.1 is a Quality of Life (QoL) and Developer Experience (DX) update, 
introducing full lifecycle management commands, UI consistency, and strict code 
linting pipelines.

---

## NEW IN v0.2.1
* Lifecycle Management: Seamlessly update (`qalife up`) or remove (`qalife uninstall`) the suite from anywhere in your system.
* Unified UI/UX: Installation and update processes now utilize the core animated logger for a consistent, professional feel.
* Developer Experience (DX): Integrated strict ShellCheck linting via pre-commit hooks to guarantee code robustness (development branch only).
* Smart Routing: Global flags like `-h` now parse correctly regardless of their position in the argument string.

---

## INSTALLATION

1. Clone the repository to your home directory:
   ```bash
   git clone https://github.com/Felipe-Druk/qalife.git
   ```

2. Navigate to the project directory:
   ```bash
   cd qalife
   ```

3. Grant execution permissions and run the safe installer:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

4. Load the new configuration (or restart your terminal):
   ```bash
   source ~/.zshrc  # For Zsh users
   source ~/.bashrc # For Bash users
   ```

---

## USAGE & SYNTAX

Qalife follows standard CLI syntax:
`qalife [flags] <command>`

### Available Flags:
  -v, --verbose    Outputs raw dependency and system logs instead of the UI spinner.
  -h, --help       Displays the manual or context-specific help for a command.

### Core Commands:
* sysupdate        Safely updates apt package lists and runs dist-upgrade.
* clean            Removes orphaned packages, clears apt cache, and rotates logs.
* codeupdate       Updates Visual Studio Code and its Microsoft GPG repositories.
* devclean         Purges dev caches (Python, Node.js, Go, Rust, C++, Docker) to free up space.
* audit            Scans for exposed ports, UFW status, and SSH root login misconfigurations.
* full-maintenance Runs sysupdate, codeupdate, clean, and devclean in sequence.

### Lifecycle Commands:
* up / update      Pulls the latest changes from the repository and safely reinstalls the CLI.
* uninstall        Completely removes Qalife from the system and cleans terminal rc files.

Example Usage:
```bash
qalife devclean
qalife -v audit
qalife sysupdate --help
qalife up
```

---

## ARCHITECTURE & SECURITY

Qalife follows the principle of least privilege:
- Core loaders and UI elements are stored in `~/.qalife/core`.
- Executable shell scripts are dynamically resolved from `~/.qalife/scripts`.
- Global flags seamlessly pass through the `sudo` barrier without polluting user env variables.
- Repository origin path is securely cached to allow seamless global updates.
- Strict header and linting rules guarantee code robustness.

---

## LICENSE

This project is licensed under the MIT License - see the LICENSE file for details.