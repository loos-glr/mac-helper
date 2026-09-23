#!/bin/zsh
# =============================================================================
# Module 5: Terminal Aliassen
#
# Voegt handige snelkoppelingen (aliassen) toe aan ~/.zshrc.
# Dubbele aliassen worden automatisch overgeslagen, zodat je dit script
# veilig meerdere keren kunt uitvoeren.
#
# Na afloop wordt ~/.zshrc opnieuw ingelezen zodat de aliassen direct
# beschikbaar zijn in de huidige terminalsessie.
# =============================================================================

source "${0:A:h:h}/lib/helpers.sh"


# -----------------------------------------------------------------------------
# Configuratie – voeg hier je eigen aliassen toe
# -----------------------------------------------------------------------------

# Git-aliassen
readonly GIT_ALIASES=(
    'alias gs="git status"'
    'alias ga="git add ."'
    'alias gc="git commit -m"'
    'alias gp="git push"'
)

# Navigatie-aliassen
readonly NAV_ALIASES=(
    'alias ..="cd .."'
    'alias desk="cd ~/Desktop"'
    'alias ll="ls -lah"'
    'alias c="code ."'
)

# Bepaal waar de aliassen naartoe geschreven worden
# Probeer eerst ~/.zshrc, anders een alternatief bestand op het bureaublad
if [[ -f "$HOME/.zshrc" && -w "$HOME/.zshrc" ]] || [[ ! -f "$HOME/.zshrc" && -w "$HOME" ]]; then
    ZSHRC_FILE="$HOME/.zshrc"
    USE_ALT_FILE=0
elif [[ -d "$HOME/Desktop" && -w "$HOME/Desktop" ]]; then
    ZSHRC_FILE="$HOME/Desktop/mijn-aliases.sh"
    USE_ALT_FILE=1
    echo ""
    print_warning "~/.zshrc is niet schrijfbaar (netwerk-homedir of beperkt account?)."
    print_info "Aliassen worden opgeslagen in: ${ZSHRC_FILE}"
    print_info "Start elke nieuwe terminal met dit commando om je aliassen te laden:"
    echo ""
    echo "  source ${ZSHRC_FILE}"
    echo ""
else
    print_error "Kan geen schrijfbare locatie vinden voor aliassen."
    print_info "Aliassen die je kunt toevoegen zodra je ~/.zshrc kunt bewerken:"
    echo ""
    for alias_regel in "${GIT_ALIASES[@]}" "${NAV_ALIASES[@]}"; do
        echo "  ${alias_regel}"
    done
    exit 1
fi

# -----------------------------------------------------------------------------
# add_alias <alias_regel>
#   Voegt een alias toe aan ~/.zshrc, maar alleen als deze nog niet
#   voorkomt (voorkomt duplicaten).
# -----------------------------------------------------------------------------
add_alias() {
    local alias_regel="$1"

    if ! grep -Fxq "$alias_regel" "$ZSHRC_FILE"; then
        echo "$alias_regel" >> "$ZSHRC_FILE"
        print_success "Toegevoegd: ${alias_regel}"
    else
        print_info "Bestaat al: ${alias_regel} (overgeslagen)"
    fi
}


# -----------------------------------------------------------------------------
# Hoofdprogramma
# -----------------------------------------------------------------------------
print_header "Terminal Aliassen Instellen"

# Zorg dat het doelbestand bestaat
if [[ ! -f "$ZSHRC_FILE" ]]; then
    print_info "${ZSHRC_FILE} bestond nog niet – wordt aangemaakt."
    touch "$ZSHRC_FILE" || {
        print_error "Kon ${ZSHRC_FILE} niet aanmaken."
        exit 1
    }
fi

print_info "Aliassen toevoegen aan ${ZSHRC_FILE}..."

# Verwerk Git-aliassen
echo ""
echo "${BLAUW}Git-aliassen:${GEEN_KLEUR}"
for alias_regel in "${GIT_ALIASES[@]}"; do
    add_alias "$alias_regel"
done

# Verwerk navigatie-aliassen
echo ""
echo "${BLAUW}Navigatie-aliassen:${GEEN_KLEUR}"
for alias_regel in "${NAV_ALIASES[@]}"; do
    add_alias "$alias_regel"
done

# Laad het bestand opnieuw in voor de huidige sessie
echo ""
print_info "Aliassen opnieuw inlezen..."
if source "$ZSHRC_FILE" 2>/dev/null; then
    print_success "Aliassen zijn nu beschikbaar in deze sessie."
else
    if [[ $USE_ALT_FILE -eq 1 ]]; then
        print_warning "Kon het bestand niet opnieuw inlezen."
        print_info "Start een nieuwe terminal en voer uit:  source ${ZSHRC_FILE}"
    else
        print_warning "Kon ~/.zshrc niet opnieuw inlezen. Sluit je terminal en open een nieuwe"
        print_warning "om de aliassen te gebruiken."
    fi
fi

echo ""
echo "Probeer bijvoorbeeld:"
echo "  ${GROEN}gs${GEEN_KLEUR}   in plaats van ${GROEN}git status${GEEN_KLEUR}"
echo "  ${GROEN}desk${GEEN_KLEUR}  in plaats van ${GROEN}cd ~/Desktop${GEEN_KLEUR}"
echo "  ${GROEN}c .${GEEN_KLEUR}  in plaats van ${GROEN}code .${GEEN_KLEUR}"