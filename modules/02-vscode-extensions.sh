#!/bin/zsh
# =============================================================================
# Module 2: VS Code Extensies
#
# Installeert extensies voor Leerjaar 1 of Leerjaar 2 via de VS Code CLI.
# Controleert eerst of de 'code'-opdracht beschikbaar is voordat er
# iets geïnstalleerd wordt.
# =============================================================================

source "${0:A:h:h}/lib/helpers.sh"


# -----------------------------------------------------------------------------
# Lijsten met extensie-ID's – makkelijk uit te breiden door studenten
# -----------------------------------------------------------------------------

# Leerjaar 1: HTML/CSS, JavaScript, PHP
readonly EXTENSIES_JAAR1=(
    "esbenp.prettier-vscode"                # Code formatter
    "ritwickdey.LiveServer"                 # Live-server voor HTML/CSS
    "bmewburn.vscode-intelephense-client"   # PHP-intelligentie
)

# Leerjaar 2: Node.js, React, Laravel
readonly EXTENSIES_JAAR2=(
    "esbenp.prettier-vscode"                # Code formatter
    "dbaeumer.vscode-eslint"                # JavaScript-linting
    "dsznajder.es7-react-js-snippets"       # React-snippets
    "onecentlin.laravel-blade"              # Laravel Blade-syntax
)


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