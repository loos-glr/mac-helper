#!/bin/zsh

# Module 2: VS Code Extensies
# Installeert de belangrijkste extensies via de VS Code CLI.

echo "--- VS Code Extensies Installeren ---"
echo "1) Leerjaar 1 (HTML/CSS, JS, PHP)"
echo "2) Leerjaar 2 (Node, React, Laravel)"
echo "3) Annuleren"
echo ""

read "jaar_keuze?> Voor welk leerjaar wil je extensies installeren? (1-3): "

case $jaar_keuze in
    1)
        echo "\nExtensies voor Leerjaar 1 worden geïnstalleerd..."
        code --install-extension esbenp.prettier-vscode
        code --install-extension ritwickdey.LiveServer
        code --install-extension bmewburn.vscode-intelephense-client
        echo "Klaar met het installeren van de extensies!"
        ;;
    2)
        echo "\nExtensies voor Leerjaar 2 worden geïnstalleerd..."
        code --install-extension esbenp.prettier-vscode
        code --install-extension dbaeumer.vscode-eslint
        code --install-extension dsznajder.es7-react-js-snippets
        code --install-extension onecentlin.laravel-blade
        echo "Klaar met het installeren van de extensies!"
        ;;
    3)
        echo "Installatie geannuleerd."
        ;;
    *) 
        echo "Ongeldige keuze. Installatie afgebroken."
        ;;
esac