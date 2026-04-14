```text
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
```

# QALIFE V 0.1.0

Qalife is a collection of high-performance, lightweight, and security-focused 
bash scripts designed to automate system maintenance and auditing on Debian-based 
Linux distributions (Ubuntu, Kubuntu, Debian, etc.).

This project aims to provide a "Quality of Life" improvement for Linux users 
while maintaining strict security standards and minimal system overhead.

---

## MAIN FEATURES

* System Optimization: Safe removal of orphaned packages and log rotation.
* App Management: Standardized Visual Studio Code updates.
* Security Auditing: Fast detection of exposed ports and vulnerable configurations.
* Developer Cleanup: Deep purging of Python, Node.js, Go, and Docker caches.
* Security First: Restricted file permissions and privilege validation.
* Automation: Single-command full system maintenance.

---

## INSTALLATION

To install Qalife on your local machine, follow these steps:

1. Clone the repository to your home directory:
   ```bash
   git clone [https://github.com/your-username/qalife.git](https://github.com/your-username/qalife.git)
   ```

2. Navigate to the project directory:
   ```bash
   cd qalife
   ```

3. Grant execution permissions to the installer:
   ```bash
   chmod +x install.sh
   ```

4. Run the installer:
   ```bash
   ./install.sh
   ```

5. Load the new configuration:
   To use the commands immediately without restarting your terminal, run:
   ```bash
   source ~/.zshrc  # For Zsh users
   source ~/.bashrc # For Bash users
   ```

---

## USAGE

Once installed, Qalife dynamically loads its commands. You can run:

* qalife-clean: Cleans system cache, logs, and orphaned dependencies.
* qalife-update-code: Updates Visual Studio Code to the latest stable version.
* qalife-sysupdate: Performs a full system update and repository refresh.
* qalife-audit: Scans the system for common security misconfigurations and open ports.
* qalife-devclean: Safely purges dev caches (pip, __pycache__, npm, docker) and reports freed space.
* qalife-full-maintenance: Executes sysupdate, codeupdate, clean, and devclean in sequence.

---

## SECURITY ARCHITECTURE

Qalife follows the principle of least privilege:
- Core files are stored in ~/.qalife/core with 600 permissions.
- Executable scripts are stored in ~/.qalife/scripts with 700 permissions.
- All system-level scripts require root privileges (sudo) to perform changes safely.

---

## LICENSE

This project is licensed under the MIT License - see the LICENSE file for details.