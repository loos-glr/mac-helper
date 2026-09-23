#!/bin/zsh

# Hoofdscript GLR Dev Setup
# We gebruiken een expliciete while-loop voor voorspelbare gedragingen.

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
    clear
    echo "${BLUE}==========================================${NC}"
    echo "${BLUE}    GLR CREATIVE SOFTWARE DEVELOPER       ${NC}"
    echo "${BLUE}    iMac Workspace Setup Script           ${NC}"
    echo "${BLUE}==========================================${NC}"
    echo "1) Git naam en e-mail instellen"
    echo "2) VS Code extensies installeren (Leerjaar 1 & 2)"
    echo "3) Tijdelijke SSH Key genereren (voor GitHub)"
    echo "4) Project scaffolding (Mappenstructuur genereren)"
    echo "5) Handige Terminal Aliassen instellen"
    echo "6) Alles in één keer uitvoeren (optie 1, 2, 3 en 5)"
    echo "7) Afsluiten"
    echo ""
    
    read "keuze?> Kies een optie (1-7): "
    
    echo ""
    
    case $keuze in
        1) 
            zsh modules/01-git-config.sh 
            ;;
        2) 
            zsh modules/02-vscode-extensions.sh 
            ;;
        3) 
            zsh modules/03-ssh-keygen.sh 
            ;;
        4) 
            zsh modules/04-scaffolding.sh 
            ;;
        5) 
            zsh modules/05-aliases.sh 
            ;;
        6)
            zsh modules/01-git-config.sh
            zsh modules/02-vscode-extensions.sh
            zsh modules/03-ssh-keygen.sh
            zsh modules/05-aliases.sh
            echo "${GREEN}Setup compleet! Project scaffolding moet je per project los aanroepen.${NC}"
            ;;
        7)
            echo "Tot ziens!"
            break
            ;;
        *) 
            echo "Ongeldige optie: $keuze. Probeer het opnieuw."
            ;;
    esac
    
    echo ""
    read "pauze?> Druk op Enter om terug te gaan naar het hoofdmenu..."
done