#!/bin/zsh
# =============================================================================
# Module 6: Standaardbrowser instellen op Google Chrome
#
# Stelt Google Chrome in als de standaard webbrowser op macOS.
# Gebruikt uitsluitend macOS-native commando's (osascript) – géén Homebrew,
# géén duti, géén sudo. Werkt ook op accounts met beperkte rechten.
#
# Als de automatische instelling faalt (bijv. door MDM/SIP-beperkingen),
# toont het script duidelijke handmatige instructies.
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
# Stap 2 – Probeer Chrome automatisch in te stellen via osascript
#
# osascript is de macOS-native manier om AppleScript/JavaScript voor
# automatisering uit te voeren. Het vereist géén extra installatie.
# Op MDM-beheerde Macs kan System Events echter geblokkeerd zijn,
# vandaar de fallback naar handmatige instructies.
# -----------------------------------------------------------------------------
print_info "Google Chrome instellen als standaardbrowser (automatisch)..."

automatisch_gelukt=0

# Methode 1: osascript via System Events (werkt op de meeste Macs)
if check_command_exists "osascript"; then
    if osascript -e "
        tell application \"System Events\"
            set default web browser to \"Google Chrome.app\"
        end tell" 2>/dev/null; then
        automatisch_gelukt=1
        print_success "Google Chrome is ingesteld als standaard webbrowser."
    fi
fi

# Methode 2: alternatieve osascript-syntax (sommige macOS-versies)
if [[ $automatisch_gelukt -eq 0 ]] && check_command_exists "osascript"; then
    if osascript -e "tell application \"Google Chrome\" to activate" \
                  -e "tell application \"System Events\" to tell process \"Google Chrome\" to set frontmost to true" 2>/dev/null; then
        # Deze methode opent Chrome en brengt het naar voorgrond;
        # Chrome vraagt dan zelf of het de standaardbrowser wil worden
        print_info "Google Chrome is geopend – bevestig de vraag of Chrome"
        print_info "de standaardbrowser mag worden (indien deze verschijnt)."
        automatisch_gelukt=1
    fi
fi

echo ""


# -----------------------------------------------------------------------------
# Stap 3 – Toon handmatige instructies als automatisering faalt
# -----------------------------------------------------------------------------
if [[ $automatisch_gelukt -eq 1 ]]; then
    print_info "Ter controle: ga naar Systeeminstellingen → Bureaublad & Dock"
    echo "           en kijk bij 'Standaard webbrowser' of Chrome geselecteerd is."
    echo ""
else
    print_warning "Automatische instelling niet mogelijk (MDM/SIP-beperking?)."
    echo ""
    echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
    echo "${BLAUW}  HANDMATIGE INSTELLING (minder dan 1 minuut)${GEEN_KLEUR}"
    echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
    echo ""
    echo "  ${GROEN}1.${GEEN_KLEUR} Open ${BLAUW}Systeeminstellingen${GEEN_KLEUR} (Apple-menu  → Systeeminstellingen)"
    echo "  ${GROEN}2.${GEEN_KLEUR} Ga naar ${BLAUW}Bureaublad & Dock${GEEN_KLEUR}"
    echo "  ${GROEN}3.${GEEN_KLEUR} Scroll omlaag naar het dropdown-menu ${BLAUW}Standaard webbrowser${GEEN_KLEUR}"
    echo "  ${GROEN}4.${GEEN_KLEUR} Selecteer ${BLAUW}Google Chrome${GEEN_KLEUR}"
    echo ""
    echo "  💡 ${GEEL}Tip:${GEEN_KLEUR} Als het dropdown-menu grijs is (uitgegrijsd),"
    echo "     dan beheert de school deze instelling centraal."
    echo "     Vraag je docent of systeembeheerder om hulp."
    echo ""
fi
