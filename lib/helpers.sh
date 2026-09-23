#!/bin/zsh
# =============================================================================
# helpers.sh – Gedeelde hulpfuncties voor GLR Dev Setup
# =============================================================================
# Dit bestand wordt door alle modules én setup.sh ingeladen via 'source'.
# Het bevat kleurdefinities, uitvoerfuncties en veelgebruikte controles.
#
# LET OP: Deze library doet alleen definities. Er worden hier geen commando's
#          uitgevoerd die de omgeving wijzigen.
# =============================================================================

# -----------------------------------------------------------------------------
# ANSI-kleuren – gebruikt voor gekleurde uitvoer in de terminal.
# -----------------------------------------------------------------------------
readonly GROEN='\033[0;32m'
readonly BLAUW='\033[0;34m'
readonly ROOD='\033[0;31m'
readonly GEEL='\033[0;33m'
readonly GEEN_KLEUR='\033[0m'          # Reset alle opmaak (No Color)


# -----------------------------------------------------------------------------
# print_success <bericht>
#   Toont een groen "✓" met het opgegeven bericht.
# -----------------------------------------------------------------------------
print_success() {
    echo "${GROEN}✓ ${*}${GEEN_KLEUR}"
}


# -----------------------------------------------------------------------------
# print_error <bericht>
#   Toont een rood "✗" met het opgegeven bericht. Gebruik deze functie
#   wanneer een handeling is mislukt.
# -----------------------------------------------------------------------------
print_error() {
    echo "${ROOD}✗ ${*}${GEEN_KLEUR}" >&2
}


# -----------------------------------------------------------------------------
# print_info <bericht>
#   Toont een blauw "→" met het opgegeven bericht. Geschikt voor
#   voortgangsmeldingen of neutrale informatie.
# -----------------------------------------------------------------------------
print_info() {
    echo "${BLAUW}→ ${*}${GEEN_KLEUR}"
}


# -----------------------------------------------------------------------------
# print_warning <bericht>
#   Toont een geel "⚠" met het opgegeven bericht. Gebruik dit voor
#   situaties die aandacht nodig hebben maar niet fataal zijn.
# -----------------------------------------------------------------------------
print_warning() {
    echo "${GEEL}⚠ ${*}${GEEN_KLEUR}" >&2
}


# -----------------------------------------------------------------------------
# print_header <titel>
#   Toont een gestileerde sectiekop in het blauw.
# -----------------------------------------------------------------------------
print_header() {
    echo ""
    echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
    echo "${BLAUW}  ${*}${GEEN_KLEUR}"
    echo "${BLAUW}────────────────────────────────────────────${GEEN_KLEUR}"
    echo ""
}


# -----------------------------------------------------------------------------
# check_command_exists <commando>
#   Controleert of een CLI-commando beschikbaar is op het systeem.
#   Retourneert 0 (true) als het commando bestaat, anders 1 (false).
#
#   Gebruik:
#     if check_command_exists "code"; then
#         code --install-extension ...
#     else
#         print_error "VS Code CLI niet gevonden"
#         return 1
#     fi
# -----------------------------------------------------------------------------
check_command_exists() {
    command -v "$1" > /dev/null 2>&1
}


# -----------------------------------------------------------------------------
# validate_non_empty <waarde> <veldnaam>
#   Controleert of een variabele niet leeg is. Als deze wel leeg is,
#   toont de functie een foutmelding en stopt het script (exit 1).
#
#   Gebruik:
#     validate_non_empty "$projectnaam" "projectnaam"
# -----------------------------------------------------------------------------
validate_non_empty() {
    if [[ -z "$1" ]]; then
        print_error "${2:-De waarde} mag niet leeg zijn."
        exit 1
    fi
}


# -----------------------------------------------------------------------------
# check_dir_exists <pad>
#   Controleert of een map al bestaat. Geeft 0 (true) terug als dat zo is.
#
#   Gebruik:
#     if check_dir_exists "$HOME/Desktop/mijn-project"; then
#         print_warning "Map bestaat al: $HOME/Desktop/mijn-project"
#     fi
# -----------------------------------------------------------------------------
check_dir_exists() {
    [[ -d "$1" ]]
}


# -----------------------------------------------------------------------------
# confirm_yes_no <vraag>
#   Stelt een ja/nee-vraag aan de gebruiker en retourneert 0 voor "ja"
#   en 1 voor "nee". De invoer is hoofdletterongevoelig.
#
#   Gebruik:
#     if confirm_yes_no "Wil je doorgaan?"; then
#         echo "Doorgaan..."
#     fi
# -----------------------------------------------------------------------------
confirm_yes_no() {
    local antwoord
    read "antwoord?> ${*} (j/n): "
    case "${(L)antwoord}" in
        j|ja|y|yes) return 0 ;;
        *)          return 1 ;;
    esac
}


# -----------------------------------------------------------------------------
# get_repo_root
#   Bepaalt de absolute hoofdmap van deze repository (waar setup.sh staat).
#   Werkt ook als het script vanuit een submap wordt aangeroepen.
# -----------------------------------------------------------------------------
get_repo_root() {
    echo "${0:A:h:h}"
}


# -----------------------------------------------------------------------------
# get_env_file
#   Retourneert het pad naar het .env-bestand in de repository-root,
#   of een lege string als het bestand niet bestaat.
# -----------------------------------------------------------------------------
get_env_file() {
    local root
    root=$(get_repo_root)
    if [[ -f "$root/.env" ]]; then
        echo "$root/.env"
    fi
}


# -----------------------------------------------------------------------------
# load_env_value <variabelenaam>
#   Leest een enkele waarde uit het .env-bestand (indien aanwezig) en
#   retourneert deze. Retourneert een lege string als het bestand niet
#   bestaat of de variabele niet gevonden is.
#
#   Gebruik:
#     naam=$(load_env_value "NAME")
#     if [[ -n "$naam" ]]; then ... fi
# -----------------------------------------------------------------------------
load_env_value() {
    local var_naam="$1"
    local env_file
    env_file=$(get_env_file)

    if [[ -z "$env_file" ]]; then
        return
    fi

    grep -E "^${var_naam}=" "$env_file" 2>/dev/null \
        | head -1 \
        | sed 's/^[^=]*=["'"'"']*//;s/["'"'"']*$//'
}


# -----------------------------------------------------------------------------
# resolve_default <env_variabele> <git-sleutel>
#   Bepaalt een standaardwaarde: eerst uit .env, daarna uit de globale
#   Git-configuratie. Retourneert een lege string als beide niet bestaan.
#
#   Gebruik:
#     email=$(resolve_default "EMAIL" "user.email")
# -----------------------------------------------------------------------------
resolve_default() {
    local waarde
    waarde=$(load_env_value "$1" 2>/dev/null || true)
    if [[ -z "$waarde" ]]; then
        waarde=$(git config --global "$2" 2>/dev/null || true)
    fi
    echo "$waarde"
}