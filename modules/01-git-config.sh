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
# Stap 1 – Bepaal naam en e-mail (.env → Git-configuratie)
# -----------------------------------------------------------------------------
print_header "Git Configuratie"

DEFAULT_NAME=$(resolve_default "NAME"  "user.name")
DEFAULT_EMAIL=$(resolve_default "EMAIL" "user.email")


# -----------------------------------------------------------------------------
# Stap 2 – Gebruik bekende waarden of vraag de gebruiker om invoer
# -----------------------------------------------------------------------------
if [[ -n "$DEFAULT_NAME" && -n "$DEFAULT_EMAIL" ]]; then
    naam="$DEFAULT_NAME"
    email="$DEFAULT_EMAIL"

    print_info "Naam en e-mail al bekend – invoer overgeslagen."
    echo "         Naam:  ${naam}"
    echo "         Email: ${email}"
    echo ""
    print_info "Later aanpassen? Bewerk .env of gebruik:"
    echo "         git config --global user.name \"Voornaam Achternaam\""
    echo "         git config --global user.email \"email@voorbeeld.nl\""
else
    read "naam?> Voer je volledige naam in (bijv. Voornaam Achternaam): "
    read "email>? Voer je (school) e-mailadres in:                    "
fi

# Gebruik de standaardwaarden als fallback wanneer de gebruiker niets invult
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