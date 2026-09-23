<?php
/**
 * functions.php – Verzamelbestand voor hulpfuncties van PROJECT_NAAM
 *
 * Definieer hier functies die je op meerdere pagina's nodig hebt.
 * Denk aan:
 *   - Databaseverbindingen
 *   - Validatie-functies
 *   - Hulpfuncties voor het renderen van HTML
 */

/**
 * Voorbeeld: een functie die begroet.
 *
 * @param string $naam De naam van de persoon die je wilt begroeten.
 * @return string Een HTML-vriendelijke begroeting.
 */
function begroet(string $naam): string
{
    return "<p>Hallo {$naam}, veel succes met je PHP-project!</p>";
}