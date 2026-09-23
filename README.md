# GLR Creative Software Developer – iMac Setup
# ==============================================

Welkom bij de **GLR Dev Setup**! Omdat de iMacs op school na het
uitloggen worden gereset, ben je vaak veel tijd kwijt aan het opnieuw
instellen van je werkomgeving. Met deze scripts automatiseer je dat.

> **Doelgroep:** MBO 4 studenten Creative Software Developer.
> De code is bedoeld als leermateriaal – lees het, snap het, breid het uit!

---

## 📂 Projectstructuur

```
dotconfig/
├── setup.sh                     # Hoofdmenu – startpunt van de tool
├── lib/
│   └── helpers.sh               # Gedeelde hulpfuncties (kleuren, validatie, etc.)
├── modules/                     # Elke module doet één taak
│   ├── 01-git-config.sh         # Git user.name / user.email instellen
│   ├── 02-vscode-extensions.sh  # VS Code extensies per leerjaar installeren
│   ├── 03-ssh-keygen.sh         # Tijdelijke SSH-sleutel voor GitHub
│   ├── 04-scaffolding.sh        # Snel een HTML- of PHP-project opzetten
│   ├── 05-aliases.sh            # Handige terminal-snelkoppelingen (aliassen)
│   └── 06-default-browser.sh    # Standaardbrowser instellen op Google Chrome
├── templates/                   # Fysieke bestanden voor project-scaffolding
│   ├── html-basis/              # Template: HTML + CSS + JS
│   └── php-basis/               # Template: PHP met includes-structuur
├── .env.example                 # Voorbeeldconfiguratie (kopieer naar .env)
└── README.md                    # Je leest het nu :)
```

### Waarom deze structuur?
- **`lib/helpers.sh`** laat zien hoe je code *herbruikbaar* maakt (DRY-principe).
- **`templates/`** bevat fysieke bestanden in plaats van 'ingebakken' code in
  het script. Zo kun je templates aanpassen zónder het script te wijzigen.
- **`modules/`** zijn *onafhankelijke* scripts die elk één taak uitvoeren
  (Single Responsibility). Je kunt ze los aanroepen of via het menu.

---

## 🚀 Hoe gebruik je dit?

1. **Open je terminal** (Zsh).
2. **Navigeer** naar de map waar je dit project hebt opgeslagen (bijv. je
   OneDrive of externe HDD).
3. **Voer het hoofdscript uit:**
   ```bash
   zsh setup.sh
   ```
4. **Volg de stappen** in het interactieve keuzemenu.

### Optioneel: `.env` aanmaken
Kopieer `.env.example` naar `.env` en vul je naam, e-mail en eventueel je
eigen VS Code-extensies in:
```bash
cp .env.example .env
```
De Git-configuratiemodule (optie 1) en de VS Code-extensiemodule (optie 2)
lezen dit bestand automatisch en gebruiken de waarden als standaardantwoord.
Zo hoef je niet elke keer opnieuw te typen.

#### `.env`-variabelen

| Variabele | Gebruikt door | Beschrijving |
|---|---|---|
| `NAME` | `01-git-config.sh` | Je volledige naam (Git `user.name`) |
| `EMAIL` | `01-git-config.sh` | Je (school) e-mailadres (Git `user.email`) |
| `VSCODE_EXTENSIONS_JAAR1` | `02-vscode-extensions.sh` | Komma-gescheiden lijst met extensie-ID's voor Leerjaar 1 |
| `VSCODE_EXTENSIONS_JAAR2` | `02-vscode-extensions.sh` | Komma-gescheiden lijst met extensie-ID's voor Leerjaar 2 |

> **Tip:** Als je `VSCODE_EXTENSIONS_JAAR1` of `VSCODE_EXTENSIONS_JAAR2` leeg laat
> (of het `.env`-bestand niet aanmaakt), gebruikt het script automatisch de
> hardcoded standaardlijsten.

---

## 🎓 Wat leer je hiervan?

| Concept | Waar te vinden |
|---|---|
| **Shell scripting** (`zsh`) | `setup.sh`, alle `modules/*.sh` |
| **DRY (Don't Repeat Yourself)** | `lib/helpers.sh` – gedeelde functies |
| **Modulaire opbouw** | `modules/` – elk script heeft één taak |
| **Foutafhandeling** | `set -euo pipefail`, `exit`-codes, validatie |
| **Template-based scaffolding** | `templates/` + `cp -R` in `04-scaffolding.sh` |
| **Configuratiebestanden** | `.env` (optionele voorgedefinieerde waarden) |
| **Flow-control** | `while`-loop, `case`-statement in `setup.sh` |

### Zelf uitbreiden?
1. **Nieuwe template toevoegen:** maak een map aan in `templates/` (bijv.
   `react-basis/`) en voeg een nieuwe case toe in `04-scaffolding.sh`.
2. **Nieuwe extensies:** voeg het extensie-ID toe aan de array in
   `02-vscode-extensions.sh`.
3. **Nieuwe module:** maak een `07-xxx.sh` in `modules/` en voeg een
   menu-optie toe in `setup.sh`.

---

## 📋 Vereisten

- **macOS** (de scripts gebruiken `pbcopy`, `ssh-keygen`, etc.)
- **Zsh** (standaard shell op macOS)
- **Git** (wordt meegeleverd met Xcode Command Line Tools)
- **VS Code** (voor de extensie-installatie, optioneel)
- **Homebrew + `duti`** (alleen voor optie 6 – de module installeert dit
  automatisch als het ontbreekt)

---

## 📝 Licentie

Dit project is bedoeld als lesmateriaal voor het Grafisch Lyceum Rotterdam.
Voel je vrij om het te gebruiken, aan te passen en te delen met medestudenten.