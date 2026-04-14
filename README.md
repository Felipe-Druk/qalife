```text
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
```

# QALIFE V 0.2.0

Qalife is a unified Command Line Interface (CLI) application and security-focused 
maintenance suite designed for Debian-based Linux distributions (Ubuntu, Kubuntu).

Version 0.2.0 transforms Qalife into a robust native CLI tool, featuring a dynamic 
loader, shell autocomplete, and an interactive UI with standard and verbose modes.

---

## NEW IN v0.2.0
* Unified CLI: All tools are now executed through the base `qalife` command.
* Dynamic Autocompletion: Pressing Tab natively suggests available commands in Bash and Zsh.
* Verbose Mode (-v): Bypass the UI spinners to get raw, deep-level system output for debugging.
* Contextual Help (-h): Read specific documentation per command (e.g., `qalife devclean -h`).

---

## INSTALLATION

1. Clone the repository to your home directory:
   ```bash
   git clone [https://github.com/Felipe-Druk/qalife.git](https://github.com/Felipe-Druk/qalife.git)
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

Example Usage:
```bash
qalife devclean
qalife -v audit
qalife sysupdate --help
```

---

## ARCHITECTURE & SECURITY

Qalife follows the principle of least privilege:
- Core loaders and UI elements are stored in `~/.qalife/core`.
- Executable shell scripts are dynamically resolved from `~/.qalife/scripts`.
- Global flags seamlessly pass through the `sudo` barrier without polluting user env variables.
- Strict header and linting rules guarantee code robustness.

---

## LICENSE

This project is licensed under the MIT License - see the LICENSE file for details.