#!/bin/zsh
# =============================================================================
# setup.sh – Hoofdmenu GLR Dev Setup
#
# Dit is het centrale script waarmee MBO 4 Creative Software Developer
# studenten hun iMac-werkomgeving snel kunnen instellen. Het toont een
# interactief keuzemenu en roept de juiste module-scripts aan.
#
# De modules staan in de map 'modules/' en zijn onafhankelijk van elkaar
# aan te roepen. Gedeelde functies (kleuren, validatie) staan in 'lib/'.
#
# Gebruik:  zsh setup.sh
# =============================================================================

# Laad de gedeelde helpers (kleurdefinities, validatie-functies)
SCRIPT_DIR="${0:A:h}"                         # Map waarin setup.sh zelf staat
source "$SCRIPT_DIR/lib/helpers.sh"


# -----------------------------------------------------------------------------
# check_omgeving
#   Voert een snelle gezondheidscheck uit en waarschuwt de gebruiker
#   als bepaalde tools of directories niet beschikbaar zijn.
# -----------------------------------------------------------------------------
check_omgeving() {
    local waarschuwingen=0

    if ! check_command_exists "code"; then
        print_warning "VS Code CLI niet in PATH – extensies worden naar bestand geschreven."
        ((waarschuwingen++))
    fi

    if [[ ! -d "$HOME/Desktop" || ! -w "$HOME/Desktop" ]]; then
        print_warning "Desktop niet schrijfbaar – projecten/aliassen worden elders opgeslagen."
        ((waarschuwingen++))
    fi

    if [[ -f "$HOME/.gitconfig" && ! -w "$HOME/.gitconfig" ]]; then
        print_warning "~/.gitconfig is read-only – Git-configuratie alleen per project mogelijk."
        ((waarschuwingen++))
    fi

    if [[ $waarschuwingen -gt 0 ]]; then
        echo ""
        print_info "Je werkt in een beperkte omgeving. De scripts zijn hierop aangepast"
        print_info "en bieden fallback-opties waar nodig."
        echo ""
    fi

    return $waarschuwingen
}


# -----------------------------------------------------------------------------
# run_module <module-pad>
#   Roept een module-script aan binnen dezelfde Zsh-sessie.
#   Toont de exitcode als deze niet 0 is, zodat de gebruiker weet
#   dat er iets misging.
# -----------------------------------------------------------------------------
run_module() {
    local module_pad="$SCRIPT_DIR/modules/$1"

    if [[ ! -f "$module_pad" ]]; then
        print_error "Module niet gevonden: ${module_pad}"
        return 1
    fi

    zsh "$module_pad"
    local exitcode=$?

    if [[ $exitcode -ne 0 ]]; then
        echo ""
        print_warning "Module eindigde met exitcode ${exitcode}."
        print_warning "Controleer de uitvoer hierboven voor foutmeldingen."
    fi

    return $exitcode
}


# -----------------------------------------------------------------------------
# toon_menu
#   Tekent het hoofdmenu op het scherm.
# -----------------------------------------------------------------------------
toon_menu() {
    clear
    echo "${BLAUW}==========================================${GEEN_KLEUR}"
    echo "${BLAUW}    GLR CREATIVE SOFTWARE DEVELOPER       ${GEEN_KLEUR}"
    echo "${BLAUW}    iMac Workspace Setup Script           ${GEEN_KLEUR}"
    echo "${BLAUW}==========================================${GEEN_KLEUR}"
    echo "1) Git naam en e-mail instellen"
    echo "2) VS Code extensies installeren (Leerjaar 1 & 2)"
    echo "3) Tijdelijke SSH Key genereren (voor GitHub)"
    echo "4) Project scaffolding (Mappenstructuur genereren)"
    echo "5) Handige Terminal Aliassen instellen"
    echo "6) Standaardbrowser instellen op Google Chrome"
    echo "7) Alles in één keer uitvoeren (opties 1, 2, 3, 5 en 6)"
    echo "8) Afsluiten"
    echo ""
}


# -----------------------------------------------------------------------------
# Hoofdloop – blijft tonen tot de gebruiker kiest voor afsluiten (optie 8)
#
# Voer eerst een omgevingscheck uit zodat de gebruiker weet of er
# beperkingen zijn voordat hij/zij modules gaat uitvoeren.
# -----------------------------------------------------------------------------
check_omgeving
echo ""
read "pauze?> Druk op Enter om door te gaan naar het menu..."

while true; do
    toon_menu

    read "keuze?> Kies een optie (1-8): "
    echo ""

    case $keuze in
        1)
            run_module "01-git-config.sh"
            ;;
        2)
            run_module "02-vscode-extensions.sh"
            ;;
        3)
            run_module "03-ssh-keygen.sh"
            ;;
        4)
            run_module "04-scaffolding.sh"
            ;;
        5)
            run_module "05-aliases.sh"
            ;;
        6)
            run_module "06-default-browser.sh"
            ;;
        7)
            print_info "Alles-in-één modus gestart..."
            echo ""
            run_module "01-git-config.sh"
            run_module "02-vscode-extensions.sh"
            run_module "03-ssh-keygen.sh"
            run_module "05-aliases.sh"
            run_module "06-default-browser.sh"
            echo ""
            print_success "Setup voltooid!"
            print_info "Project scaffolding (optie 4) moet je per project apart aanroepen."
            ;;
        8)
            echo "Tot ziens! 👋"
            break
            ;;
        *)
            print_error "Ongeldige optie: ${keuze}. Kies een nummer van 1 tot en met 8."
            ;;
    esac

    echo ""
    read "pauze?> Druk op Enter om terug te gaan naar het hoofdmenu..."
done
