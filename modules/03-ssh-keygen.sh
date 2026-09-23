#!/bin/zsh
# =============================================================================
# Module 3: Tijdelijke SSH Key
#
# Genereert een Ed25519 SSH-sleutel die veilig is voor een tijdelijke
# schoolsessie. De sleutel wordt toegevoegd aan de SSH-agent en de
# public key wordt naar het klembord gekopieerd.
# =============================================================================

# Schakel strikte foutafhandeling in: bij de eerste fout stopt het script
set -euo pipefail

source "${0:A:h:h}/lib/helpers.sh"


# -----------------------------------------------------------------------------
# Configuratie – pas deze waarden aan als je een ander pad wilt
# -----------------------------------------------------------------------------
readonly SSH_KEY_PATH="$HOME/.ssh/id_ed25519_glr_tmp"
readonly SSH_KEY_COMMENT="glr-dev-setup-tijdelijk"


# -----------------------------------------------------------------------------
# Hoofdprogramma
# -----------------------------------------------------------------------------
print_header "Tijdelijke SSH Key Genereren"

read "email?> Voer je GitHub e-mailadres in: "
validate_non_empty "$email" "E-mailadres"


# ------------------------------------------------------------------
# Stap 1 – Controleer of er al een sleutel met deze naam bestaat
# ------------------------------------------------------------------
if [[ -f "$SSH_KEY_PATH" ]]; then
    print_warning "Er bestaat al een sleutel op: ${SSH_KEY_PATH}"
    if confirm_yes_no "Wil je deze overschrijven?"; then
        rm -f "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
        print_info "Oude sleutel verwijderd."
    else
        print_info "Bestaande sleutel blijft behouden. Script stopt."
        exit 0
    fi
fi


# ------------------------------------------------------------------
# Stap 2 – Genereer een nieuwe Ed25519-sleutel (zonder wachtwoordzin)
# ------------------------------------------------------------------
print_info "Nieuwe SSH-sleutel genereren (ed25519)..."

if ssh-keygen -t ed25519 -C "$SSH_KEY_COMMENT ($email)" \
    -f "$SSH_KEY_PATH" -N ""; then
    print_success "SSH-sleutel aangemaakt: ${SSH_KEY_PATH}"
else
    print_error "SSH-sleutel kon niet worden gegenereerd."
    exit 1
fi


# ------------------------------------------------------------------
# Stap 3 – Start de SSH-agent en voeg de sleutel toe
# ------------------------------------------------------------------
print_info "SSH-agent starten en sleutel toevoegen..."

eval "$(ssh-agent -s)" > /dev/null 2>&1

if ssh-add "$SSH_KEY_PATH" 2>/dev/null; then
    print_success "SSH-sleutel toegevoegd aan de agent."
else
    print_error "Kon de SSH-sleutel niet toevoegen aan de agent."
    exit 1
fi


# ------------------------------------------------------------------
# Stap 4 – Kopieer de public key naar het klembord (macOS)
# ------------------------------------------------------------------
print_info "Public key naar klembord kopiëren..."

if pbcopy < "$SSH_KEY_PATH.pub"; then
    print_success "Public key staat op je klembord!"
else
    print_error "Kon de public key niet naar het klembord kopiëren."
    print_info "Je kunt hem handmatig openen met: cat ${SSH_KEY_PATH}.pub"
    exit 1
fi

echo ""
echo "Ga nu naar:  ${BLAUW}https://github.com/settings/keys${GEEN_KLEUR}"
echo "Klik op 'New SSH Key' en plak (Cmd+V) de sleutel."
echo ""
print_warning "Deze sleutel wordt automatisch verwijderd zodra je uitlogt van deze iMac."