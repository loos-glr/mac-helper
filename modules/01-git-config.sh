#!/bin/zsh
# =============================================================================
# Module 1: Git Configuratie
#
# Stelt de globale user.name, user.email en default branch in voor Git.
# Als er een .env-bestand in de repo-root staat met NAME/EMAIL, worden die
# waarden als standaardvoorkeur getoond.
# =============================================================================

# Laad gedeelde helpers in (kleuren, validatie, etc.)
REPO_ROOT="${0:A:h:h}"                            # Absoluut pad naar de repo-root
source "$REPO_ROOT/lib/helpers.sh"


# -----------------------------------------------------------------------------
# Stap 1 – Probeer bestaande waarden uit .env te lezen (optioneel)
# -----------------------------------------------------------------------------
print_header "Git Configuratie"

DEFAULT_NAME=$(load_env_value "NAME")
DEFAULT_EMAIL=$(load_env_value "EMAIL")

if [[ -n "$DEFAULT_NAME" && -n "$DEFAULT_EMAIL" ]]; then
    print_info "Standaardwaarden gevonden in .env:"
    echo "         Naam:  ${DEFAULT_NAME}"
    echo "         Email: ${DEFAULT_EMAIL}"
    echo ""
fi


# -----------------------------------------------------------------------------
# Stap 2 – Vraag naam en e-mail aan de gebruiker
# -----------------------------------------------------------------------------
read "naam?> Voer je volledige naam in (bijv. Voornaam Achternaam): "
read "email>? Voer je (school) e-mailadres in:                    "

# Gebruik de .env-waarden als fallback wanneer de gebruiker niets invult
naam="${naam:-$DEFAULT_NAME}"
email="${email:-$DEFAULT_EMAIL}"

# Valideer dat beide velden zijn ingevuld
validate_non_empty "$naam"  "Naam"
validate_non_empty "$email" "E-mailadres"


# -----------------------------------------------------------------------------
# Stap 3 – Pas de globale Git-configuratie toe
# -----------------------------------------------------------------------------
print_info "Git-configuratie toepassen..."

if git config --global user.name "$naam" \
    && git config --global user.email "$email" \
    && git config --global init.defaultBranch main; then

    print_success "Git is geconfigureerd met:"
    echo ""
    git config --global -l | grep user
    echo ""
else
    print_error "Kon Git-configuratie niet wegschrijven. Controleer je rechten."
    exit 1
fi