```text
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
```

# QALIFE V 0.3.0

[Qalife](https://github.com/Felipe-Druk/qalife.git) is a unified Command Line Interface (CLI) application and security-focused 
maintenance suite designed for Debian-based Linux distributions (Ubuntu, Kubuntu).

Version 0.3.0 introduces a dynamic configuration engine, allowing users to create, 
modify, and execute custom command routines on the fly using a robust JSON state manager.

---

## NEW IN v0.3.0
* Dynamic Routines: Users can now group multiple scripts into custom routines.
* Configuration Manager: The new `qalife config` command allows for CRUD operations on command groups and state variables via a secure `config.json` file.
* Smart Autocompletion: The shell dynamically reads your custom routines and suggests them when pressing Tab.
* Smart Pruning: `devclean` now supports configurable retention for Docker images to protect recent local builds.
* `jq` Integration: Uses industry-standard JSON parsing to ensure state integrity.

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
`qalife [flags] <command> [arguments]`

### Available Flags:
  -v, --verbose    Outputs raw dependency and system logs instead of the UI spinner.
  -h, --help       Displays the manual or context-specific help for a command.

### Configuration & Routines (NEW):
* config           Manages dynamic routines and settings. Syntax: `qalife config <group/key> <action> [item/value]`
                   Example (Group): `qalife config my-routine add sysupdate`
                   Example (Value): `qalife config docker-prune-days set 1`

### Core Commands:
* sysupdate        Safely updates apt package lists and runs dist-upgrade.
* clean            Removes orphaned packages, clears apt cache, and rotates logs.
* codeupdate       Updates Visual Studio Code and its Microsoft GPG repositories.
* devclean         Purges dev caches (Python, Node.js, Go, Rust, C++, Docker) to free up space. Note: Docker retention is configurable via `config`.
* audit            Scans for exposed ports, UFW status, and SSH root login misconfigurations.

### Lifecycle Commands:
* up / update      Pulls the latest changes from the repository and safely reinstalls the CLI.
* uninstall        Completely removes Qalife from the system and cleans terminal rc files.

### Lifecycle Commands:
* up / update      Pulls the latest changes from the repository and safely reinstalls the CLI.
* uninstall        Completely removes Qalife from the system and cleans terminal rc files.

Example Usage:
```bash
qalife config full-maintenance remove devclean
qalife config docker-prune-days set 1
qalife config security-scan add audit
qalife security-scan
qalife up
```

---

## ARCHITECTURE & SECURITY

Qalife follows the principle of least privilege:
- Core loaders, configurations (`config.json`), and UI elements are stored in `~/.qalife/core`.
- Executable shell scripts are dynamically resolved from `~/.qalife/scripts`.
- Global flags seamlessly pass through the `sudo` barrier without polluting user env variables.
- Repository origin path is securely cached to allow seamless global updates.
- Strict header and linting rules guarantee code robustness.

---

## LICENSE

This project is licensed under the MIT License - see the LICENSE file for details.