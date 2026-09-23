#!/bin/zsh

# Module 5: Terminal Aliassen
# Voegt handige snelkoppelingen toe aan je terminal profiel.

echo "--- Terminal Aliassen Instellen ---"

ZSHRC_FILE="$HOME/.zshrc"

if [ ! -f "$ZSHRC_FILE" ]; then
    touch "$ZSHRC_FILE"
fi

add_alias() {
    local alias_cmd=$1
    if ! grep -q "$alias_cmd" "$ZSHRC_FILE"; then
        echo "$alias_cmd" >> "$ZSHRC_FILE"
    fi
}

echo "Aliassen toevoegen aan .zshrc..."

add_alias 'alias gs="git status"'
add_alias 'alias ga="git add ."'
add_alias 'alias gc="git commit -m"'
add_alias 'alias gp="git push"'

add_alias 'alias ..="cd .."'
add_alias 'alias desk="cd ~/Desktop"'
add_alias 'alias ll="ls -lah"'
add_alias 'alias c="code ."'

echo "Aliassen zijn toegevoegd!"
source "$ZSHRC_FILE" 2>/dev/null || true

echo "Klaar! Typ in het vervolg bijvoorbeeld 'gs' in plaats van 'git status'."