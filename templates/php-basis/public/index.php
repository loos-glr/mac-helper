<?php
/**
 * index.php – Hoofdbestand voor PROJECT_NAAM
 *
 * Dit bestand staat in de map 'public/' zodat het bereikbaar is
 * voor de bezoeker. Bedrijfslogica hoort thuis in de map 'includes/'.
 */

require_once dirname(__DIR__) . '/includes/functions.php';

// Optioneel: begin hier met je eigen PHP-code.
// $pagina_titel = 'PROJECT_NAAM';

?>
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Vervang PROJECT_NAAM hieronder met de naam van je project -->
    <title>PROJECT_NAAM – PHP</title>

    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>PHP Project is live!</h1>
    <p>Dit is de startpagina van <strong>PROJECT_NAAM</strong>.
       De PHP-logica staat in <code>includes/functions.php</code>.</p>

    <script src="js/script.js"></script>
</body>
</html>