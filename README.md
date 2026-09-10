# dotconfig

Quick shell scripts for bootstrapping personal dotfiles and dev environment settings.

## Quick start

```sh
cp .env.example .env
```

Edit .env file with your name and email

```
sh configure-git.sh
```

## Files

| File | Purpose |
|---|---|
| `.env.example` | Template for personal environment variables (NAME, EMAIL) |
| `.gitignore` | Excludes `.env` to keep secrets local |
| `configure-git.sh` | Sets global git `user.name` and `user.email` from `.env` |

## Requirements

- POSIX `sh`
- `git`