# fish-awsp

AWS profile switcher for **Fish shell** with:

- fzf interactive selector
- preview pane
- colorized output
- AWS account alias support
- shell completion
- Fisher plugin support

Quickly switch AWS profiles from the terminal.

---

## Install

Install using **Fisher**

```bash
fisher install https://github.com/kobusan/fish-awsp
```

If you don't have Fisher:

```bash
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher
```

---

## Usage

Interactive switch

```bash
awsp
```

List profiles

```bash
awsp list
```

Show current profile

```bash
awsp current
```

Direct switch

```bash
awsp dev
```

Clear profile

```bash
awsp clear
```

Completion

```bash
awsp <TAB>
```

---

## Requirements

- Fish shell
- AWS CLI
- fzf

Install on macOS:

```bash
brew install awscli fzf
```

---

## Features

### Interactive selector

Use `fzf` to fuzzy-search AWS profiles.

### Preview pane

Shows selected profile details:

- account alias
- region
- role ARN
- source profile
- SSO session
- SSO start URL

### Colorized output

`awsp list` highlights the active profile.

### Account alias caching

AWS account alias lookups are cached to avoid repeated API calls.

### Shell completion

Profile names and commands are available via tab completion.

---

## Repository structure

    fish-awsp
    ├── functions
    │   ├── awsp.fish
    │   └── awsp_preview.fish
    ├── completions
    │   └── awsp.fish
    ├── README.md
    └── LICENSE

---

## License

MIT