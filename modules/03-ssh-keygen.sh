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

# Bepaal het e-mailadres: eerst .env, daarna bestaande Git-configuratie
DEFAULT_EMAIL=$(resolve_default "EMAIL" "user.email")

if [[ -n "$DEFAULT_EMAIL" ]]; then
    email="$DEFAULT_EMAIL"
    print_info "E-mailadres al bekend – invoer overgeslagen: ${email}"
    echo ""
else
    read "email?> Voer je GitHub e-mailadres in: "
fi

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
# Stap 3 – Start de SSH-agent en voeg de sleutel toe (optioneel)
# ------------------------------------------------------------------
print_info "SSH-agent starten en sleutel toevoegen..."

agent_ok=0
if agent_output=$(ssh-agent -s 2>/dev/null); then
    eval "$agent_output" > /dev/null 2>&1

    if ssh-add "$SSH_KEY_PATH" 2>/dev/null; then
        print_success "SSH-sleutel toegevoegd aan de agent."
        agent_ok=1
    fi
fi

if [[ $agent_ok -eq 0 ]]; then
    print_warning "SSH-agent kon niet gestart worden (sandbox-/MDM-beperking?)."
    echo ""
    print_info "Je kunt de sleutel handmatig gebruiken door deze regel toe"
    print_info "te voegen aan ~/.ssh/config (maak het bestand aan als het niet bestaat):"
    echo ""
    echo "  Host github.com"
    echo "      HostName github.com"
    echo "      IdentityFile ${SSH_KEY_PATH}"
    echo "      User git"
    echo ""
fi


# ------------------------------------------------------------------
# Stap 4 – Toon de public key
#         (probeert pbcopy, anders tonen we de tekst direct)
# ------------------------------------------------------------------
print_info "Public key beschikbaar maken..."

if pbcopy < "$SSH_KEY_PATH.pub" 2>/dev/null; then
    print_success "Public key staat op je klembord (Cmd+V om te plakken)!"
else
    print_info "Klembord niet beschikbaar (sandbox-beperking?)."
    print_info "Hier is je public key – selecteer en kopieer handmatig (Cmd+C):"
    echo ""
    echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
    cat "$SSH_KEY_PATH.pub"
    echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
    echo ""
fi

echo ""
echo "Ga nu naar:  ${BLAUW}https://github.com/settings/keys${GEEN_KLEUR}"
echo "Klik op 'New SSH Key' en plak (Cmd+V) de sleutel."
echo ""
print_warning "Deze sleutel wordt automatisch verwijderd zodra je uitlogt van deze iMac."
