#!/bin/zsh

# Module 4: Project Scaffolding
# Genereert snel een standaard mappenstructuur.

echo "--- Project Scaffolding ---"
read "projectnaam?> Wat is de naam van je project? (gebruik-geen-spaties): "

TARGET_DIR="$HOME/Desktop/$projectnaam"
mkdir -p "$TARGET_DIR"

echo "\nWelk type project wil je aanmaken?"
echo "1) Basis (HTML, CSS, JS)"
echo "2) PHP (Basis mappen)"
echo "3) Annuleren"
echo ""

read "type_keuze?> Typ het nummer van je keuze (1-3): "

case $type_keuze in
    1)
        mkdir -p "$TARGET_DIR/css" "$TARGET_DIR/js" "$TARGET_DIR/assets/img"
        
        cat <<EOF > "$TARGET_DIR/index.html"
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$projectnaam</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>Welkom bij $projectnaam</h1>
    <script src="js/script.js"></script>
</body>
</html>
EOF
        touch "$TARGET_DIR/css/style.css"
        touch "$TARGET_DIR/js/script.js"
        
        echo "\nBasis project succesvol aangemaakt in: $TARGET_DIR"
        ;;
    2)
        mkdir -p "$TARGET_DIR/public/css" "$TARGET_DIR/public/js" "$TARGET_DIR/includes"
        
        cat <<EOF > "$TARGET_DIR/public/index.php"
<?php
// Start van je PHP project
require_once '../includes/functions.php';
?>
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <title>$projectnaam - PHP</title>
</head>
<body>
    <h1>PHP Project is live!</h1>
</body>
</html>
EOF
        touch "$TARGET_DIR/includes/functions.php"
        
        echo "\nPHP project succesvol aangemaakt in: $TARGET_DIR"
        ;;
    3)
        echo "Geannuleerd. Er zijn geen bestanden aangemaakt."
        ;;
    *) 
        echo "Ongeldige keuze. Proces afgebroken."
        ;;
esac