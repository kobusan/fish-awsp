# awsp-fish

AWS profile switcher for **Fish shell** with:

- fzf interactive UI
- preview pane
- color output
- AWS account alias support

Quickly switch AWS profiles from the terminal.

---

# Install

Install using **Fisher**


fisher install <your-username>/awsp-fish


Install fisher if needed:


curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish
 | source
fisher install jorgebucaran/fisher


---

# Usage

Interactive switch


awsp


List profiles


awsp list


Show current profile


awsp current


Direct switch


awsp dev


Clear profile


awsp clear


---

# Requirements

- fish shell
- AWS CLI
- fzf

Install:


brew install awscli fzf


---

# Features

### Interactive selector


awsp


Fuzzy search AWS profiles.

---

### Preview pane

Shows:

- account alias
- region
- role
- SSO session

---

### Colorized output


awsp list


Highlights the active profile.

---

# Structure


awsp-fish
├ functions
│ ├ awsp.fish
│ └ awsp_preview.fish
├ README.md
└ LICENSE


---

# License

MIT