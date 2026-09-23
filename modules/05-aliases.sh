#!/bin/zsh
# =============================================================================
# Module 5: Terminal Aliassen
#
# Voegt handige snelkoppelingen (aliassen) toe aan ~/.glr_aliases
# en injecteert een 'source'-regel in ~/.zshenv, ~/.zshrc en ~/.zprofile
# zodat aliassen gegarandeerd worden geladen – ongeacht hoe Zsh wordt
# gestart (login/non-login/interactief).
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

# =============================================================================
# Bepaal de dedicated aliases file en init-bestanden om te hooken
# =============================================================================

readonly ALIAS_FILE="$HOME/.glr_aliases"

# Zsh init-bestanden waarin we 'source $ALIAS_FILE' injecteren
# .zshenv  = ALTIJD geladen (login/non-login/interactief/scripts) – safety net
# .zshrc   = interactieve shells (waar aliassen nuttig zijn)
# .zprofile = login shells (Terminal.app opent standaard login shells)
readonly INIT_FILES=(
    "$HOME/.zshenv"
    "$HOME/.zshrc"
    "$HOME/.zprofile"
)

SOURCE_LINE="source ${ALIAS_FILE}"

# -----------------------------------------------------------------------------
# Controleer of we naar de home-directory kunnen schrijven
# Als ALLE init-bestanden read-only zijn, vallen we terug naar Desktop
# -----------------------------------------------------------------------------
home_writable=0
for init_file in "${INIT_FILES[@]}"; do
    if [[ -f "$init_file" && -w "$init_file" ]] || [[ ! -f "$init_file" && -w "$HOME" ]]; then
        home_writable=1
        break
    fi
done

if [[ $home_writable -eq 1 ]]; then
    USE_ALT_FILE=0
elif [[ -d "$HOME/Desktop" && -w "$HOME/Desktop" ]]; then
    USE_ALT_FILE=1
    echo ""
    print_warning "Home-directory is niet schrijfbaar (netwerk-account?)."
    print_info "Aliassen worden opgeslagen op je bureaublad."
    print_info "Je moet ze handmatig laden – zie de instructies onderaan."
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
# Detecteer aliassen die de gebruiker al heeft (in alle init-bestanden)
# zodat we geen bestaande aliassen overschrijven (bijv. 'll' voor eza)
# -----------------------------------------------------------------------------
existing_names=()
for init_file in "${INIT_FILES[@]}"; do
    if [[ -f "$init_file" && -r "$init_file" ]]; then
        while IFS= read -r line; do
            # Extract alias-naam uit 'alias naam=...' of 'alias naam="..."'
            if [[ "$line" =~ ^[[:space:]]*alias[[:space:]]+([^=]+)= ]]; then
                existing_names+=("${match[1]}")
            fi
        done <"$init_file"
    fi
done

# Verwijder duplicaten uit de lijst
if ((${#existing_names[@]})); then
    existing_names=("${(@u)existing_names}")
fi

# -----------------------------------------------------------------------------
# alias_al_bestaat <naam>
#   Controleert of een alias-naam al bestaat in de init-bestanden
# -----------------------------------------------------------------------------
alias_al_bestaat() {
    local naam="$1"
    for bestaand in "${existing_names[@]}"; do
        if [[ "$bestaand" == "$naam" ]]; then
            return 0
        fi
    done
    return 1
}

# -----------------------------------------------------------------------------
# add_alias_to_file <alias_regel> <doelbestand>
#   Voegt een alias toe aan het opgegeven bestand (idempotent)
#   Retourneert 0 = toegevoegd, 1 = bestond al, 2 = fout
# -----------------------------------------------------------------------------
add_alias_to_file() {
    local alias_regel="$1"
    local doelbestand="$2"

    if grep -Fxq "$alias_regel" "$doelbestand"; then
        return 1
    fi

    echo "$alias_regel" >>"$doelbestand"

    if grep -Fxq "$alias_regel" "$doelbestand"; then
        return 0
    else
        return 2
    fi
}

# -----------------------------------------------------------------------------
# inject_source_line <doelbestand>
#   Zorgt dat 'source ~/.glr_aliases' in het init-bestand staat
#   Retourneert 0 = geïnjecteerd, 1 = bestond al, 2 = fout
# -----------------------------------------------------------------------------
inject_source_line() {
    local doelbestand="$1"

    # Maak bestand aan als het niet bestaat
    if [[ ! -f "$doelbestand" ]]; then
        touch "$doelbestand" 2>/dev/null || return 2
    fi

    if grep -Fxq "$SOURCE_LINE" "$doelbestand"; then
        return 1
    fi

    echo "" >>"$doelbestand"
    echo "# GLR Dev Setup – laad terminal aliassen" >>"$doelbestand"
    echo "$SOURCE_LINE" >>"$doelbestand"

    if grep -Fxq "$SOURCE_LINE" "$doelbestand"; then
        return 0
    else
        return 2
    fi
}

# -----------------------------------------------------------------------------
# Hoofdprogramma
# -----------------------------------------------------------------------------
print_header "Terminal Aliassen Instellen"

# Tellers voor het overzicht
toegevoegd=0
overgeslagen=0
mislukt=0
conflicten=0
geinjecteerd=0
inject_bestond=0
inject_mislukt=0

# Bepaal het bestand waar de aliassen naartoe geschreven worden
if [[ $USE_ALT_FILE -eq 1 ]]; then
    TARGET_FILE="$HOME/Desktop/mijn-aliases.sh"
else
    TARGET_FILE="$ALIAS_FILE"
fi

# Zorg dat het doelbestand bestaat
if [[ ! -f "$TARGET_FILE" ]]; then
    print_info "${TARGET_FILE} bestond nog niet – wordt aangemaakt."
    touch "$TARGET_FILE" || {
        print_error "Kon ${TARGET_FILE} niet aanmaken."
        return 1
    }
fi

print_info "Aliassen toevoegen aan ${TARGET_FILE}..."

# -----------------------------------------------------------------------------
# Verwerk Git-aliassen
# -----------------------------------------------------------------------------
echo ""
echo "${BLAUW}Git-aliassen:${GEEN_KLEUR}"
for alias_regel in "${GIT_ALIASES[@]}"; do
    add_alias_to_file "$alias_regel" "$TARGET_FILE"
    case $? in
    0)
        print_success "Toegevoegd: ${alias_regel}"
        ((toegevoegd++))
        ;;
    1)
        print_info "Bestaat al: ${alias_regel}"
        ((overgeslagen++))
        ;;
    *)
        print_error "Fout: ${alias_regel}"
        ((mislukt++))
        ;;
    esac
done

# -----------------------------------------------------------------------------
# Verwerk navigatie-aliassen
# -----------------------------------------------------------------------------
echo ""
echo "${BLAUW}Navigatie-aliassen:${GEEN_KLEUR}"
for alias_regel in "${NAV_ALIASES[@]}"; do
    add_alias_to_file "$alias_regel" "$TARGET_FILE"
    case $? in
    0)
        print_success "Toegevoegd: ${alias_regel}"
        ((toegevoegd++))
        ;;
    1)
        print_info "Bestaat al: ${alias_regel}"
        ((overgeslagen++))
        ;;
    *)
        print_error "Fout: ${alias_regel}"
        ((mislukt++))
        ;;
    esac
done

# -----------------------------------------------------------------------------
# Injecteer 'source ~/.glr_aliases' in init-bestanden (alleen home-dir modus)
# -----------------------------------------------------------------------------
if [[ $USE_ALT_FILE -eq 0 ]]; then
    echo ""
    echo "${BLAUW}Shell-integratie:${GEEN_KLEUR}"
    for init_file in "${INIT_FILES[@]}"; do
        bestandsnaam=$(basename "$init_file")
        inject_source_line "$init_file"
        case $? in
        0)
            print_success "source-regel toegevoegd aan ~/${bestandsnaam}"
            ((geinjecteerd++))
            ;;
        1)
            print_info "source-regel bestond al in ~/${bestandsnaam}"
            ((inject_bestond++))
            ;;
        *)
            print_warning "Kon source-regel niet toevoegen aan ~/${bestandsnaam}"
            ((inject_mislukt++))
            ;;
        esac
    done
fi

# -----------------------------------------------------------------------------
# Waarschuw voor alias-naam conflicten met bestaande aliassen in init-bestanden
# (onze aliassen staan in .glr_aliases; als de gebruiker dezelfde naam elders
#  heeft, krijgt die voorrang omdat .zshrc na .glr_aliases wordt ingelezen)
# -----------------------------------------------------------------------------
conflicten=0
conflict_namen=()
for alias_regel in "${GIT_ALIASES[@]}" "${NAV_ALIASES[@]}"; do
    naam="${alias_regel#alias }"
    naam="${naam%%=*}"
    if alias_al_bestaat "$naam"; then
        conflict_namen+=("$naam")
        ((conflicten++))
    fi
done

if [[ $conflicten -gt 0 ]]; then
    echo ""
    print_warning "Let op: ${conflicten} alias-naam/namen bestaan al in je shell-config:"
    echo "         ${(j:, :)conflict_namen}"
    print_info "Jouw bestaande aliassen krijgen voorrang (worden later geladen)."
fi

# -----------------------------------------------------------------------------
# Write-verificatie: controleer of elke alias in het doelbestand staat
# -----------------------------------------------------------------------------
echo ""
print_info "Aliassen verifiëren in ${TARGET_FILE}..."
write_ok=0
write_fail=0
for alias_regel in "${GIT_ALIASES[@]}" "${NAV_ALIASES[@]}"; do
    if grep -Fxq "$alias_regel" "$TARGET_FILE"; then
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

if source "$TARGET_FILE" 2>/dev/null; then
    werkend=0
    niet_werkend=0

    alias_namen=()
    for alias_regel in "${GIT_ALIASES[@]}" "${NAV_ALIASES[@]}"; do
        naam="${alias_regel#alias }"
        naam="${naam%%=*}"
        if grep -Fxq "$alias_regel" "$TARGET_FILE"; then
            alias_namen+=("$naam")
        fi
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
        print_warning "${werkend}/${#alias_namen[@]} werken, ${niet_werkend} niet beschikbaar."
    fi
else
    niet_werkend=$((${#GIT_ALIASES[@]} + ${#NAV_ALIASES[@]}))
    werkend=0
    print_warning "Kon ${TARGET_FILE} niet inlezen."
fi

# -----------------------------------------------------------------------------
# Samenvatting en instructies
# -----------------------------------------------------------------------------
echo ""
echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
echo "${BLAUW}  Samenvatting${GEEN_KLEUR}"
echo ""
echo "  Bestand:         ${TARGET_FILE}"
echo "  Toegevoegd:      ${GROEN}${toegevoegd}${GEEN_KLEUR}"
echo "  Overgeslagen:    ${BLAUW}${overgeslagen}${GEEN_KLEUR}"
if [[ $mislukt -gt 0 ]]; then
    echo "  Mislukt:         ${ROOD}${mislukt}${GEEN_KLEUR}"
fi
if [[ $conflicten -gt 0 ]]; then
    echo "  Conflict (eigen alias): ${GEEL}${conflicten}${GEEN_KLEUR}"
fi
echo "  In bestand:      ${GROEN}${write_ok}${GEEN_KLEUR}/$((${#GIT_ALIASES[@]} + ${#NAV_ALIASES[@]}))"
echo "  Werkend nu:      ${GROEN}${werkend}${GEEN_KLEUR}/$((${#GIT_ALIASES[@]} + ${#NAV_ALIASES[@]}))"
if [[ $USE_ALT_FILE -eq 0 ]]; then
    echo "  Shell-integratie:${GROEN}${geinjecteerd}${GEEN_KLEUR} toegevoegd, ${BLAUW}${inject_bestond}${GEEN_KLEUR} bestond al"
    if [[ $inject_mislukt -gt 0 ]]; then
        echo "                   ${ROOD}${inject_mislukt}${GEEN_KLEUR} mislukt"
    fi
fi
echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"

echo ""
print_info "Hoe nu verder?"
if [[ $USE_ALT_FILE -eq 1 ]]; then
    echo "  Je home-directory is niet schrijfbaar (netwerk-account?)."
    echo "  Laad de aliassen in elke nieuwe terminal met:"
    echo ""
    echo "    ${GROEN}source ~/Desktop/mijn-aliases.sh${GEEN_KLEUR}"
    echo ""
    echo "  📌 Tip: als je ~/.zshrc wél kunt bewerken, voeg dan deze"
    echo "  regel toe zodat de aliassen automatisch laden:"
    echo ""
    echo "    echo 'source ~/Desktop/mijn-aliases.sh' >> ~/.zshrc"
else
    total_integratie=$((geinjecteerd + inject_bestond))
    echo "  ✅ Aliassen opgeslagen in ${ALIAS_FILE}"
    echo "  ✅ ${total_integratie} shell-bestand(en) sourcen dit automatisch"
    echo ""
    echo "  Ze worden geladen bij elke nieuwe terminal die je opent."
    echo ""
    echo "  Voor deze sessie: type   ${GROEN}source ${ALIAS_FILE}${GEEN_KLEUR}"
fi

echo ""
echo "Probeer bijvoorbeeld:"
echo "  ${GROEN}gs${GEEN_KLEUR}   in plaats van ${GROEN}git status${GEEN_KLEUR}"
echo "  ${GROEN}desk${GEEN_KLEUR}  in plaats van ${GROEN}cd ~/Desktop${GEEN_KLEUR}"
echo "  ${GROEN}c .${GEEN_KLEUR}  in plaats van ${GROEN}code .${GEEN_KLEUR}"
