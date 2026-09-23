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

REPO_ROOT="${0:A:h:h}"                            # Absoluut pad naar de repo-root
source "$REPO_ROOT/lib/helpers.sh"


# -----------------------------------------------------------------------------
# Laad extensies uit .env (indien aanwezig), anders fallback naar hardcoded
# -----------------------------------------------------------------------------

# Probeer de waarden uit .env te lezen
_ENV_JAAR1=$(load_env_value "VSCODE_EXTENSIONS_JAAR1")
_ENV_JAAR2=$(load_env_value "VSCODE_EXTENSIONS_JAAR2")

# Fallback – hardcoded standaardlijsten (gebruikt als .env geen waarde heeft)
readonly FALLBACK_JAAR1=(
    "esbenp.prettier-vscode"                # Code formatter
    "ritwickdey.LiveServer"                 # Live-server voor HTML/CSS
    "bmewburn.vscode-intelephense-client"   # PHP-intelligentie
)

readonly FALLBACK_JAAR2=(
    "esbenp.prettier-vscode"                # Code formatter
    "dbaeumer.vscode-eslint"                # JavaScript-linting
    "dsznajder.es7-react-js-snippets"       # React-snippets
    "onecentlin.laravel-blade"              # Laravel Blade-syntax
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
# install_extensions <extensies-array>
#   Installeert één voor één de opgegeven extensies en toont per extensie
#   of de installatie is gelukt.
# -----------------------------------------------------------------------------
install_extensions() {
    local extensies=("$@")

    for extensie in "${extensies[@]}"; do
        print_info "Installeren: ${extensie} ..."
        if code --install-extension "$extensie" > /dev/null 2>&1; then
            print_success "${extensie}"
        else
            print_error "${extensie} – installatie mislukt"
        fi
    done
}


# -----------------------------------------------------------------------------
# Hoofdprogramma
# -----------------------------------------------------------------------------
print_header "VS Code Extensies Installeren"

# Controleer of de 'code' CLI beschikbaar is
if ! check_command_exists "code"; then
    print_error "Het commando 'code' is niet gevonden."
    print_info "Zorg dat VS Code is geïnstalleerd en het 'code'-commando"
    print_info "in je PATH staat. (In VS Code: Cmd+Shift+P → 'Shell Command: Install code command in PATH')"
    exit 1
fi

# Toon keuzemenu
echo "1) Leerjaar 1 (HTML/CSS, JS, PHP)"
echo "2) Leerjaar 2 (Node, React, Laravel)"
echo "3) Annuleren"
echo ""

read "jaar_keuze?> Voor welk leerjaar wil je extensies installeren? (1-3): "

case $jaar_keuze in
    1)
        echo ""
        print_info "Extensies voor Leerjaar 1 worden geïnstalleerd..."
        echo ""
        install_extensions "${EXTENSIES_JAAR1[@]}"
        echo ""
        print_success "Klaar met het installeren van de Leerjaar 1-extensies!"
        ;;
    2)
        echo ""
        print_info "Extensies voor Leerjaar 2 worden geïnstalleerd..."
        echo ""
        install_extensions "${EXTENSIES_JAAR2[@]}"
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