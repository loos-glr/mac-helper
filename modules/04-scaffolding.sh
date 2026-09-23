#!/bin/zsh
# =============================================================================
# Module 4: Project Scaffolding
#
# Genereert een standaard mappenstructuur voor een HTML/CSS/JS- of
# PHP-project. In plaats van bestandsinhoud 'in te bakken' in het script,
# kopiëren we fysieke template-mappen uit de 'templates/' directory.
#
# Studenten kunnen de templates eenvoudig aanpassen door de bestanden in
# die mappen te wijzigen – geen scriptkennis nodig.
# =============================================================================

source "${0:A:h:h}/lib/helpers.sh"

REPO_ROOT=$(get_repo_root)               # Hoofdmap van deze repository
TEMPLATES_DIR="$REPO_ROOT/templates"      # Map met alle template-projecten


# -----------------------------------------------------------------------------
# Hoofdprogramma
# -----------------------------------------------------------------------------
print_header "Project Scaffolding"


# ------------------------------------------------------------------
# Stap 1 – Vraag de projectnaam en valideer deze
# ------------------------------------------------------------------
read "projectnaam?> Wat is de naam van je project? (gebruik een kebab-case naam zoals 'mijn-app'): "

# Valideer: projectnaam mag niet leeg zijn
validate_non_empty "$projectnaam" "Projectnaam"

# Valideer: projectnaam mag geen spaties of rare tekens bevatten
if [[ ! "$projectnaam" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    print_error "Projectnaam mag alleen letters, cijfers, streepjes (-) en underscores (_) bevatten."
    print_info "Bijvoorbeeld: 'mijn-eerste-project' of 'opdracht_1'"
    exit 1
fi

# Bepaal de doelmap – probeer eerst Desktop, anders huidige map of /tmp
if [[ -d "$HOME/Desktop" && -w "$HOME/Desktop" ]]; then
    DOEL_DIR="$HOME/Desktop/$projectnaam"
else
    print_warning "Desktop niet beschikbaar of niet schrijfbaar."
    if [[ -w "$PWD" ]]; then
        DOEL_DIR="$PWD/$projectnaam"
        print_info "Project wordt aangemaakt in huidige map: ${DOEL_DIR}"
    else
        DOEL_DIR="/tmp/$projectnaam"
        print_warning "Project wordt aangemaakt in /tmp (tijdelijk!): ${DOEL_DIR}"
        print_warning "LET OP: /tmp wordt gewist bij herstart van de computer."
    fi
    echo ""
fi


# ------------------------------------------------------------------
# Stap 2 – Controleer of de doelmap al bestaat
# ------------------------------------------------------------------
if check_dir_exists "$DOEL_DIR"; then
    print_warning "De map '${DOEL_DIR}' bestaat al!"
    if ! confirm_yes_no "Wil je doorgaan? Bestaande bestanden kunnen overschreven worden."; then
        print_info "Scaffolding geannuleerd."
        exit 0
    fi
fi


# ------------------------------------------------------------------
# Stap 3 – Vraag het projecttype
# ------------------------------------------------------------------
echo "Welk type project wil je aanmaken?"
echo "1) Basis (HTML, CSS, JS)"
echo "2) PHP (met includes-structuur)"
echo "3) Annuleren"
echo ""

read "type_keuze?> Typ het nummer van je keuze (1-3): "


# ------------------------------------------------------------------
# Stap 4 – Kopieer het juiste template
# ------------------------------------------------------------------
case $type_keuze in
    1)
        print_info "HTML/CSS/JS-template kopiëren naar ${DOEL_DIR} ..."

        if [[ ! -d "$TEMPLATES_DIR/html-basis" ]]; then
            print_error "Template 'html-basis' niet gevonden in ${TEMPLATES_DIR}"
            exit 1
        fi

        # Kopieer de volledige template-map naar de doelmap
        cp -R "$TEMPLATES_DIR/html-basis/" "$DOEL_DIR"

        print_success "Basis HTML/CSS/JS-project aangemaakt in: ${DOEL_DIR}"
        echo ""
        echo "Structuur:"
        find "$DOEL_DIR" -not -path '*/.gitkeep' | sed "s|$DOEL_DIR|  .|" | sort
        ;;

    2)
        print_info "PHP-template kopiëren naar ${DOEL_DIR} ..."

        if [[ ! -d "$TEMPLATES_DIR/php-basis" ]]; then
            print_error "Template 'php-basis' niet gevonden in ${TEMPLATES_DIR}"
            exit 1
        fi

        # Kopieer de volledige template-map naar de doelmap
        cp -R "$TEMPLATES_DIR/php-basis/" "$DOEL_DIR"

        print_success "PHP-project aangemaakt in: ${DOEL_DIR}"
        echo ""
        echo "Structuur:"
        find "$DOEL_DIR" -not -path '*/.gitkeep' | sed "s|$DOEL_DIR|  .|" | sort
        ;;

    3)
        print_info "Scaffolding geannuleerd. Er zijn geen bestanden aangemaakt."
        ;;

    *)
        print_error "Ongeldige keuze (${type_keuze}). Scaffolding afgebroken."
        exit 1
        ;;
esac

echo ""
print_info "Tip: open je project met 'code ${DOEL_DIR}'"
