#!/bin/zsh

# Module 3: Tijdelijke SSH Key
# Genereert een tijdelijke SSH key voor een veilige connectie met GitHub.

echo "--- Tijdelijke SSH Key Genereren ---"
read "email?> Voer je GitHub e-mailadres in: "

# Genereer sleutel zonder prompt voor wachtwoord
ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519_glr_tmp -N ""

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_glr_tmp

pbcopy < ~/.ssh/id_ed25519_glr_tmp.pub

echo "\nSucces! Je nieuwe public key is naar je klembord (clipboard) gekopieerd."
echo "Ga nu naar https://github.com/settings/keys, klik op 'New SSH Key' en doe CMD+V (Plakken)."
echo "Deze key wordt automatisch veilig verwijderd als je uitlogt van deze iMac."