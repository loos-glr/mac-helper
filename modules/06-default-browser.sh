#!/bin/zsh
# =============================================================================
# Module 6: Standaardbrowser instellen op Google Chrome
#
# Stelt Google Chrome in als de standaard webbrowser op macOS.
# Gebruikt 'duti' (via Homebrew) om URL-schemes (http, https) en
# HTML-bestanden te koppelen aan Chrome.
#
# Als duti nog niet is geïnstalleerd, biedt het script aan om dit
# automatisch via Homebrew te doen.
# =============================================================================

REPO_ROOT="${0:A:h:h}"
source "$REPO_ROOT/lib/helpers.sh"

CHROME_APP="/Applications/Google Chrome.app"
CHROME_BUNDLE_ID="com.google.Chrome"

print_header "Standaardbrowser – Google Chrome"


# -----------------------------------------------------------------------------
# Stap 1 – Controleer of Google Chrome is geïnstalleerd
# -----------------------------------------------------------------------------
print_info "Controleren of Google Chrome is geïnstalleerd..."

if [[ ! -d "$CHROME_APP" ]]; then
    print_error "Google Chrome niet gevonden in ${CHROME_APP}."
    echo ""
    print_info "Download Chrome via: https://www.google.com/chrome/"
    exit 1
fi

print_success "Google Chrome gevonden."
echo ""


# -----------------------------------------------------------------------------
# Stap 2 – Controleer of duti beschikbaar is
# -----------------------------------------------------------------------------
print_info "Controleren of 'duti' beschikbaar is..."

if check_command_exists "duti"; then
    print_success "'duti' is al beschikbaar."
else
    print_warning "'duti' is nog niet geïnstalleerd."
    print_info "duti is een kleine tool die bestandstype-koppelingen beheert op macOS."
    echo ""

    # Check of Homebrew beschikbaar is
    if ! check_command_exists "brew"; then
        print_error "Homebrew is niet geïnstalleerd."
        echo ""
        print_info "Installeer eerst Homebrew:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        print_info "Voer daarna deze module opnieuw uit."
        exit 1
    fi

    if confirm_yes_no "Wil je 'duti' nu installeren via Homebrew?"; then
        print_info "Bezig met installeren van duti..."
        brew install duti

        if ! check_command_exists "duti"; then
            print_error "Installatie van 'duti' is mislukt."
            print_info "Probeer het handmatig:  brew install duti"
            exit 1
        fi

        print_success "'duti' is succesvol geïnstalleerd."
    else
        print_info "Overgeslagen. Installeer duti handmatig met:  brew install duti"
        exit 0
    fi
fi

echo ""


# -----------------------------------------------------------------------------
# Stap 3 – Stel Chrome in als standaardbrowser via duti
# -----------------------------------------------------------------------------
print_info "Google Chrome instellen als standaardbrowser..."

fouten=0

# HTTP en HTTPS URL-schemes aan Chrome koppelen
duti -s "$CHROME_BUNDLE_ID" http all  2>/dev/null || ((fouten++))
duti -s "$CHROME_BUNDLE_ID" https all 2>/dev/null || ((fouten++))
duti -s "$CHROME_BUNDLE_ID" html all  2>/dev/null || ((fouten++))
duti -s "$CHROME_BUNDLE_ID" htm all   2>/dev/null || ((fouten++))
# public.html is de UTI voor HTML-bestanden op macOS
duti -s "$CHROME_BUNDLE_ID" public.html all 2>/dev/null || ((fouten++))

echo ""

if [[ $fouten -eq 0 ]]; then
    print_success "Google Chrome is ingesteld als standaardbrowser voor:"
    echo "           → http / https  (weblinks)"
    echo "           → .html / .htm  (HTML-bestanden)"
    echo ""
    print_info "Je kunt dit controleren via:"
    echo "         Systeeminstellingen → Bureaublad & Dock → Standaard webbrowser"
else
    print_warning "${fouten} koppeling(en) konden niet worden ingesteld."
    print_info "Dit kan komen door SIP-beperkingen (System Integrity Protection)."
    print_info "Stel Chrome handmatig in via Systeeminstellingen → Bureaublad & Dock."
    exit 1
fi