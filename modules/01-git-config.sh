#!/bin/zsh

# Module 1: Git Configuratie
# Stelt de globale user.name en user.email in voor de huidige sessie.

echo "--- Git Configuratie ---"

read "name?> Voer je volledige naam in (bijv. Voornaam Achternaam): "
read "email?> Voer je (school) e-mailadres in: "

git config --global user.name "$name"
git config --global user.email "$email"
git config --global init.defaultBranch main

echo "\nSucces! Git is geconfigureerd met:"
git config --global -l | grep user