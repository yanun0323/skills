# Skills

Personal agent skills.

## Install or update

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/yanun0323/skills/master/install.sh | sh
```

The installer updates skills from this repository in `~/.agents/skills`. Skills from other sources are left unchanged.

### Options

Install from a specific branch or tag:

```bash
curl -fsSL https://raw.githubusercontent.com/yanun0323/skills/master/install.sh | SKILLS_REF=v1.0.0 sh
```

Use a different destination:

```bash
curl -fsSL https://raw.githubusercontent.com/yanun0323/skills/master/install.sh | SKILLS_DIR="$HOME/.claude/skills" sh
```
