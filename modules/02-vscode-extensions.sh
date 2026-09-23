#!/bin/zsh
# =============================================================================
# Module 2: VS Code Extensies
#
# Installeert extensies voor Leerjaar 1 of Leerjaar 2 via de VS Code CLI.
# Controleert eerst of de 'code'-opdracht beschikbaar is voordat er
# iets geïnstalleerd wordt.
#
# De lijsten met extensie-ID's worden eerst uit het .env-bestand gelezen
# (als komma-gescheiden strings). Als het .env-bestand niet bestaat of de
# variabelen leeg zijn, wordt teruggevallen op de hardcoded standaardlijsten.
# =============================================================================

REPO_ROOT="${0:A:h:h}" # Absoluut pad naar de repo-root
source "$REPO_ROOT/lib/helpers.sh"

# -----------------------------------------------------------------------------
# Laad extensies uit .env (indien aanwezig), anders fallback naar hardcoded
# -----------------------------------------------------------------------------

# Probeer de waarden uit .env te lezen
_ENV_JAAR1=$(load_env_value "VSCODE_EXTENSIONS_JAAR1")
_ENV_JAAR2=$(load_env_value "VSCODE_EXTENSIONS_JAAR2")

# Fallback – hardcoded standaardlijsten (gebruikt als .env geen waarde heeft)
readonly FALLBACK_JAAR1=(
    "esbenp.prettier-vscode"              # Code formatter
    "ritwickdey.LiveServer"               # Live-server voor HTML/CSS
    "bmewburn.vscode-intelephense-client" # PHP-intelligentie
)

readonly FALLBACK_JAAR2=(
    "esbenp.prettier-vscode"          # Code formatter
    "dbaeumer.vscode-eslint"          # JavaScript-linting
    "dsznajder.es7-react-js-snippets" # React-snippets
    "onecentlin.laravel-blade"        # Laravel Blade-syntax
)

# Bepaal de definitieve lijsten: .env-waarde splitsen op komma, anders fallback
if [[ -n "$_ENV_JAAR1" ]]; then
    EXTENSIES_JAAR1=("${(@s:,:)_ENV_JAAR1}")
    print_info "Extensies Jaar 1 geladen uit .env"
else
    EXTENSIES_JAAR1=("${FALLBACK_JAAR1[@]}")
    print_info "Extensies Jaar 1: standaardlijst gebruikt"
fi

if [[ -n "$_ENV_JAAR2" ]]; then
    EXTENSIES_JAAR2=("${(@s:,:)_ENV_JAAR2}")
    print_info "Extensies Jaar 2 geladen uit .env"
else
    EXTENSIES_JAAR2=("${FALLBACK_JAAR2[@]}")
    print_info "Extensies Jaar 2: standaardlijst gebruikt"
fi

# -----------------------------------------------------------------------------
# find_vscode_cli
#   Zoekt de VS Code CLI ('code') op meerdere bekende locaties.
#   Retourneert het pad als de CLI gevonden wordt, anders een lege string.
# -----------------------------------------------------------------------------
find_vscode_cli() {
    # Standaard: check PATH
    if command -v code >/dev/null 2>&1; then
        echo "code"
        return 0
    fi

    # Locatie binnen het .app-bundle (zelf geïnstalleerd of beheerd)
    local alt_path="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    if [[ -x "$alt_path" ]]; then
        echo "$alt_path"
        return 0
    fi

    return 1
}

# -----------------------------------------------------------------------------
# install_extensions <vs-code-cmd> <extensies-array>
#   Installeert één voor één de opgegeven extensies en toont per extensie
#   of de installatie is gelukt.
# -----------------------------------------------------------------------------
install_extensions() {
    local vs_code_cmd="$1"
    shift
    local extensies=("$@")

    for extensie in "${extensies[@]}"; do
        print_info "Installeren: ${extensie} ..."
        if "$vs_code_cmd" --install-extension "$extensie" >/dev/null 2>&1; then
            print_success "${extensie}"
        else
            print_error "${extensie} – installatie mislukt"
        fi
    done
}

# -----------------------------------------------------------------------------
# write_extensions_to_file <leerjaar-label> <extensies-array>
#   Schrijft de extensielijst naar een tekstbestand op het bureaublad,
#   inclusief Marketplace-links voor handmatige installatie.
#   Wordt gebruikt als fallback wanneer de VS Code CLI niet beschikbaar is.
# -----------------------------------------------------------------------------
write_extensions_to_file() {
    local leerjaar="$1"
    shift
    local extensies=("$@")
    local output_file="$HOME/Desktop/vscode-extensies-${leerjaar// /-}.txt"

    {
        echo "=========================================="
        echo " VS Code Extensies voor ${leerjaar}"
        echo " Aangemaakt op: $(date '+%Y-%m-%d %H:%M')"
        echo "=========================================="
        echo ""
        echo "Om deze extensies te installeren:"
        echo "  1. Open VS Code"
        echo "  2. Ga naar de Extensions sidebar (Cmd+Shift+X)"
        echo "  3. Plak het ID in de zoekbalk en druk Enter"
        echo "  4. Klik op 'Install'"
        echo ""
        echo "------------------------------------------"
        for ext in "${extensies[@]}"; do
            echo ""
            echo "  📦 ${ext}"
            echo "     Marketplace: https://marketplace.visualstudio.com/items?itemName=${ext}"
        done
        echo ""
        echo "=========================================="
    } >"$output_file"

    print_success "Extensielijst opgeslagen op je bureaublad:"
    echo "           vscode-extensies-${leerjaar// /-}.txt"
}

# -----------------------------------------------------------------------------
# Hoofdprogramma
# -----------------------------------------------------------------------------
print_header "VS Code Extensies Installeren"

# Controleer of de 'code' CLI beschikbaar is
VSC_CLI=$(find_vscode_cli)

if [[ -z "$VSC_CLI" ]]; then
    echo ""
    print_warning "Het commando 'code' is niet gevonden op deze computer."
    print_info "Mogelijke oorzaken:"
    echo "           → VS Code is niet geïnstalleerd"
    echo "           → De 'code' shell-command is niet in PATH"
    echo "           → VS Code wordt beheerd via MDM (andere locatie)"
    echo ""
    print_info "Je kunt extensies handmatig installeren – het script schrijft"
    print_info "de lijst met extensies naar een bestand op je bureaublad."
    echo ""

    # Toon keuzemenu voor bestand-export
    echo "1) Leerjaar 1 – extensielijst opslaan (HTML/CSS, JS, PHP)"
    echo "2) Leerjaar 2 – extensielijst opslaan (Node, React, Laravel)"
    echo "3) Annuleren"
    echo ""

    read "jaar_keuze? Voor welk leerjaar wil je de extensielijst opslaan? (1-3): "

    case $jaar_keuze in
    1)
        echo ""
        write_extensions_to_file "Leerjaar 1" "${EXTENSIES_JAAR1[@]}"
        echo ""
        print_info "Tip: open VS Code en installeer de extensies één voor één."
        print_info "     Of vraag je docent of VS Code met de CLI geïnstalleerd kan worden."
        ;;
    2)
        echo ""
        write_extensions_to_file "Leerjaar 2" "${EXTENSIES_JAAR2[@]}"
        echo ""
        print_info "Tip: open VS Code en installeer de extensies één voor één."
        print_info "     Of vraag je docent of VS Code met de CLI geïnstalleerd kan worden."
        ;;
    3)
        print_info "Geannuleerd."
        ;;
    *)
        print_error "Ongeldige keuze (${jaar_keuze}). Afgebroken."
        ;;
    esac

    exit 0
fi

# VS Code CLI is beschikbaar – toon keuzemenu voor directe installatie
echo "1) Leerjaar 1 (HTML/CSS, JS, PHP)"
echo "2) Leerjaar 2 (Node, React, Laravel)"
echo "3) Annuleren"
echo ""

read "jaar_keuze? Voor welk leerjaar wil je extensies installeren? (1-3): "

case $jaar_keuze in
1)
    echo ""
    print_info "Extensies voor Leerjaar 1 worden geïnstalleerd..."
    echo ""
    install_extensions "$VSC_CLI" "${EXTENSIES_JAAR1[@]}"
    echo ""
    print_success "Klaar met het installeren van de Leerjaar 1-extensies!"
    ;;
2)
    echo ""
    print_info "Extensies voor Leerjaar 2 worden geïnstalleerd..."
    echo ""
    install_extensions "$VSC_CLI" "${EXTENSIES_JAAR2[@]}"
    echo ""
    print_success "Klaar met het installeren van de Leerjaar 2-extensies!"
    ;;
3)
    print_info "Installatie geannuleerd."
    ;;
*)
    print_error "Ongeldige keuze (${jaar_keuze}). Installatie afgebroken."
    ;;
esac
