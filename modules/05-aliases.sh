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
    return 1
fi

# -----------------------------------------------------------------------------
# add_alias <alias_regel>
#   Voegt een alias toe aan ~/.zshrc, maar alleen als deze nog niet
#   voorkomt (voorkomt duplicaten).
#   Retourneert 0 als de alias is toegevoegd, 1 als deze al bestond.
# -----------------------------------------------------------------------------
add_alias() {
    local alias_regel="$1"

    if ! grep -Fxq "$alias_regel" "$ZSHRC_FILE"; then
        echo "$alias_regel" >>"$ZSHRC_FILE"

        # Verifieer dat de alias daadwerkelijk is weggeschreven
        if grep -Fxq "$alias_regel" "$ZSHRC_FILE"; then
            print_success "Toegevoegd: ${alias_regel}"
            return 0
        else
            print_error "Kon niet wegschrijven: ${alias_regel}"
            return 2
        fi
    else
        print_info "Bestaat al: ${alias_regel} (overgeslagen)"
        return 1
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
        return 1
    }
fi

print_info "Aliassen toevoegen aan ${ZSHRC_FILE}..."

# Tellers voor het overzicht
toegevoegd=0
overgeslagen=0
mislukt=0

# -----------------------------------------------------------------------------
# Verwerk Git-aliassen
# -----------------------------------------------------------------------------
echo ""
echo "${BLAUW}Git-aliassen:${GEEN_KLEUR}"
for alias_regel in "${GIT_ALIASES[@]}"; do
    add_alias "$alias_regel"
    case $? in
    0) ((toegevoegd++)) ;;
    1) ((overgeslagen++)) ;;
    *) ((mislukt++)) ;;
    esac
done

# -----------------------------------------------------------------------------
# Verwerk navigatie-aliassen
# -----------------------------------------------------------------------------
echo ""
echo "${BLAUW}Navigatie-aliassen:${GEEN_KLEUR}"
for alias_regel in "${NAV_ALIASES[@]}"; do
    add_alias "$alias_regel"
    case $? in
    0) ((toegevoegd++)) ;;
    1) ((overgeslagen++)) ;;
    *) ((mislukt++)) ;;
    esac
done

# -----------------------------------------------------------------------------
# Controleer of alle aliassen in het bestand staan (write-verificatie)
# -----------------------------------------------------------------------------
echo ""
print_info "Aliassen verifiëren in ${ZSHRC_FILE}..."
write_ok=0
write_fail=0
for alias_regel in "${GIT_ALIASES[@]}" "${NAV_ALIASES[@]}"; do
    if grep -Fxq "$alias_regel" "$ZSHRC_FILE"; then
        ((write_ok++))
    else
        ((write_fail++))
        print_error "Ontbreekt in bestand: ${alias_regel}"
    fi
done
echo ""

# -----------------------------------------------------------------------------
# Bron het bestand en test of elke alias ook echt werkt
# -----------------------------------------------------------------------------
print_info "Aliassen inlezen en testen..."

if source "$ZSHRC_FILE" 2>/dev/null; then
    werkend=0
    niet_werkend=0

    # Verzamel alle alias-namen uit de configuratie
    alias_namen=()
    for alias_regel in "${GIT_ALIASES[@]}" "${NAV_ALIASES[@]}"; do
        # Extract de alias-naam uit 'alias naam="..."'
        naam="${alias_regel#alias }"
        naam="${naam%%=*}"
        alias_namen+=("$naam")
    done

    echo ""
    echo "${BLAUW}Verificatie per alias:${GEEN_KLEUR}"
    for alias_naam in "${alias_namen[@]}"; do
        if alias "$alias_naam" &>/dev/null; then
            print_success "${alias_naam} werkt"
            ((werkend++))
        else
            print_error "${alias_naam} NIET beschikbaar"
            ((niet_werkend++))
        fi
    done

    echo ""
    if [[ $niet_werkend -eq 0 ]]; then
        print_success "Alle ${werkend} aliassen geverifieerd en actief."
    else
        print_warning "${werkend}/${#alias_namen[@]} aliassen werken, ${niet_werkend} niet beschikbaar."
    fi
else
    niet_werkend=${#GIT_ALIASES[@]}
    ((niet_werkend += ${#NAV_ALIASES[@]}))
    werkend=0

    if [[ $USE_ALT_FILE -eq 1 ]]; then
        print_warning "Kon ${ZSHRC_FILE} niet inlezen."
        print_info "Start een nieuwe terminal en voer uit:  source ${ZSHRC_FILE}"
    else
        print_warning "Kon ~/.zshrc niet inlezen."
    fi
fi

# -----------------------------------------------------------------------------
# Samenvatting en instructies
# -----------------------------------------------------------------------------
echo ""
echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
echo "${BLAUW}  Samenvatting${GEEN_KLEUR}"
echo ""
echo "  Toegevoegd:   ${GROEN}${toegevoegd}${GEEN_KLEUR}"
echo "  Overgeslagen: ${BLAUW}${overgeslagen}${GEEN_KLEUR}"
if [[ $mislukt -gt 0 ]]; then
    echo "  Mislukt:      ${ROOD}${mislukt}${GEEN_KLEUR}"
fi
echo "  In bestand:   ${GROEN}${write_ok}${GEEN_KLEUR}/${#GIT_ALIASES[@]} + ${#NAV_ALIASES[@]}"
echo "  Werkend:      ${GROEN}${werkend}${GEEN_KLEUR}/${#GIT_ALIASES[@]} + ${#NAV_ALIASES[@]}"
echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"

echo ""
print_info "Hoe nu verder?"
if [[ $USE_ALT_FILE -eq 1 ]]; then
    echo "  Open een nieuwe terminal en type:"
    echo ""
    echo "    ${GROEN}source ${ZSHRC_FILE}${GEEN_KLEUR}"
else
    echo "  De aliassen staan in ~/.zshrc en worden automatisch"
    echo "  geladen als je een nieuw terminalvenster opent."
    echo ""
    echo "  Voor deze sessie: type   ${GROEN}source ~/.zshrc${GEEN_KLEUR}"
fi

echo ""
echo "Probeer bijvoorbeeld:"
echo "  ${GROEN}gs${GEEN_KLEUR}   in plaats van ${GROEN}git status${GEEN_KLEUR}"
echo "  ${GROEN}desk${GEEN_KLEUR}  in plaats van ${GROEN}cd ~/Desktop${GEEN_KLEUR}"
echo "  ${GROEN}c .${GEEN_KLEUR}  in plaats van ${GROEN}code .${GEEN_KLEUR}"
