#!/usr/bin/env bash

set -e

_END="\033[0m"
_BOLD="\033[1m"
_GREEN="\033[32m"
_YELLOW="\033[33m"
_BLUE="\033[34m"
_RED="\033[31m"
_CYAN="\033[36m"

echo ""
echo -e "${_BLUE}${_BOLD}🔄 Migration WordPress → Bedrock${_END}"
echo ""

# Check if current directory is a WordPress installation
if [ ! -f "wp-config.php" ] && [ ! -d "wp-content" ]; then
    echo -e "${_RED}❌ Ce n'est pas un répertoire WordPress${_END}"
    echo -e "${_YELLOW}Ce script doit être exécuté depuis la racine d'une installation WordPress${_END}"
    exit 1
fi

echo -e "${_GREEN}✓ Installation WordPress détectée${_END}"

# Get current directory name for project name suggestion
CURRENT_DIR=$(basename "$PWD")
read -p "Nom du projet Bedrock [${CURRENT_DIR}-bedrock]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-${CURRENT_DIR}-bedrock}

# Detect theme
echo ""
echo -e "${_CYAN}Analyse de l'installation...${_END}"

ACTIVE_THEME=""
if [ -f "wp-content/themes" ]; then
    echo -e "${_YELLOW}Thèmes détectés:${_END}"
    ls wp-content/themes/ | head -5
fi

# Detect if Elementor or Divi is used
HAS_ELEMENTOR=false
HAS_DIVI=false

if [ -d "wp-content/plugins/elementor" ]; then
    HAS_ELEMENTOR=true
    echo -e "${_GREEN}✓ Elementor détecté${_END}"
fi

if [ -d "wp-content/themes/Divi" ]; then
    HAS_DIVI=true
    echo -e "${_GREEN}✓ Divi détecté${_END}"
fi

# Choose Bedrock theme configuration
echo ""
echo -e "${_CYAN}${_BOLD}🎨 Configuration Bedrock${_END}"
echo ""

if [ "$HAS_ELEMENTOR" = true ]; then
    echo -e "${_YELLOW}Elementor détecté - recommandation: configuration Elementor${_END}"
fi

if [ "$HAS_DIVI" = true ]; then
    echo -e "${_YELLOW}Divi détecté - recommandation: configuration Divi${_END}"
fi

echo ""
echo -e "  ${_GREEN}1)${_END} ${_BOLD}Elementor${_END} - Configuration Elementor"
echo -e "  ${_GREEN}2)${_END} ${_BOLD}Divi${_END} - Configuration Divi"
echo -e "  ${_GREEN}3)${_END} ${_BOLD}Blank${_END} - Configuration basique"
echo ""

DEFAULT_CHOICE=3
if [ "$HAS_ELEMENTOR" = true ]; then
    DEFAULT_CHOICE=1
elif [ "$HAS_DIVI" = true ]; then
    DEFAULT_CHOICE=2
fi

read -p "Votre choix [1-3] [$DEFAULT_CHOICE]: " THEME_CHOICE
THEME_CHOICE=${THEME_CHOICE:-$DEFAULT_CHOICE}

case "$THEME_CHOICE" in
    1)
        THEME_NAME="elementor"
        COMPOSER_FILE="themes-config/elementor/composer.json"
        ;;
    2)
        THEME_NAME="divi"
        COMPOSER_FILE="themes-config/divi/composer.json"
        ;;
    3)
        THEME_NAME="blank"
        COMPOSER_FILE="composer.json"
        ;;
    *)
        echo -e "${_RED}❌ Choix invalide${_END}"
        exit 1
        ;;
esac

# Parse wp-config.php for database credentials
echo ""
echo -e "${_YELLOW}📋 Lecture de wp-config.php...${_END}"

DB_NAME=$(grep "DB_NAME" wp-config.php | sed "s/.*['\"]DB_NAME['\"],\s*['\"]//;s/['\"].*//")
DB_USER=$(grep "DB_USER" wp-config.php | sed "s/.*['\"]DB_USER['\"],\s*['\"]//;s/['\"].*//")
DB_PASSWORD=$(grep "DB_PASSWORD" wp-config.php | sed "s/.*['\"]DB_PASSWORD['\"],\s*['\"]//;s/['\"].*//")
DB_HOST=$(grep "DB_HOST" wp-config.php | sed "s/.*['\"]DB_HOST['\"],\s*['\"]//;s/['\"].*//")
DB_PREFIX=$(grep "table_prefix" wp-config.php | sed "s/.*['\"]//;s/['\"].*//")

echo -e "${_GREEN}✓ Configuration base de données récupérée${_END}"

# Get current site URL
echo ""
read -p "URL actuelle du site (ex: https://ancien-site.com): " CURRENT_URL
read -p "Nouvelle URL locale (ex: ${PROJECT_NAME}.arxama.local): " NEW_URL
NEW_URL=${NEW_URL:-${PROJECT_NAME}.arxama.local}

# Confirmation
echo ""
echo -e "${_BLUE}${_BOLD}📋 Récapitulatif de la migration${_END}"
echo -e "  Projet Bedrock:  ${_YELLOW}${PROJECT_NAME}${_END}"
echo -e "  Configuration:   ${_YELLOW}${THEME_NAME}${_END}"
echo -e "  Base de données: ${_YELLOW}${DB_NAME}${_END}"
echo -e "  Ancienne URL:    ${_YELLOW}${CURRENT_URL}${_END}"
echo -e "  Nouvelle URL:    ${_YELLOW}https://${NEW_URL}${_END}"
echo ""
read -p "Continuer? (y/n) [y]: " CONFIRM
CONFIRM=${CONFIRM:-y}

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${_RED}Migration annulée${_END}"
    exit 0
fi

# Create Bedrock project directory
echo ""
echo -e "${_YELLOW}📁 Création du projet Bedrock...${_END}"
BEDROCK_DIR="../${PROJECT_NAME}"

if [ -d "$BEDROCK_DIR" ]; then
    echo -e "${_RED}❌ Le répertoire ${BEDROCK_DIR} existe déjà${_END}"
    exit 1
fi

# Get the bedrock starter pack directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
STARTER_PACK_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Copy Bedrock starter pack
echo -e "${_YELLOW}📦 Copie du starter pack Bedrock...${_END}"
cp -r "$STARTER_PACK_DIR" "$BEDROCK_DIR"
cd "$BEDROCK_DIR"

# Clean up
rm -rf .git .github/workflows node_modules vendor web/wp

# Select theme configuration
if [ "$THEME_NAME" != "blank" ]; then
    echo -e "${_YELLOW}🎨 Configuration du thème ${THEME_NAME}...${_END}"
    cp "$COMPOSER_FILE" composer.json
fi

# Create .env file
echo -e "${_YELLOW}📝 Création du fichier .env...${_END}"

cat > .env << EOF
# Project
PROJECT_NAME=${PROJECT_NAME}

# Database
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_HOST=${DB_HOST}
DB_PREFIX=${DB_PREFIX}

# URLs
WP_HOME=https://${NEW_URL}
WP_SITEURL=\${WP_HOME}/wp

# Environment
WP_ENV=development
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=false

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Mail
MAIL_HOST=mailhog
MAIL_PORT=1025

# PHP
PHP_VERSION=8.2
PHP_MEMORY_LIMIT=256M
PHP_UPLOAD_MAX_FILESIZE=64M
PHP_POST_MAX_SIZE=64M

# Docker
WORDPRESS_PORT=8000
EOF

# Extract and add WordPress salts from old wp-config.php
echo -e "${_YELLOW}🔐 Extraction des salts WordPress...${_END}"
cd "$OLDPWD"

grep "AUTH_KEY\|SECURE_AUTH_KEY\|LOGGED_IN_KEY\|NONCE_KEY\|AUTH_SALT\|SECURE_AUTH_SALT\|LOGGED_IN_SALT\|NONCE_SALT" wp-config.php | \
    sed "s/define(['\"]//g;s/['\"],\s*/=/;s/['\"]);//" >> "$BEDROCK_DIR/.env"

cd "$BEDROCK_DIR"

# Create necessary directories
echo -e "${_YELLOW}📁 Création de la structure Bedrock...${_END}"
mkdir -p web/app/{mu-plugins,plugins,themes,uploads}
mkdir -p dumps

# Copy WordPress content
echo -e "${_YELLOW}📦 Migration des fichiers WordPress...${_END}"

# Copy plugins (except those that will be managed by Composer)
echo -e "${_CYAN}  → Copie des plugins...${_END}"
if [ -d "$OLDPWD/wp-content/plugins" ]; then
    # Skip Elementor if it's in the Composer config
    if [ "$THEME_NAME" = "elementor" ]; then
        rsync -av --exclude='elementor' --exclude='hello-elementor' "$OLDPWD/wp-content/plugins/" web/app/plugins/
    else
        cp -r "$OLDPWD/wp-content/plugins/"* web/app/plugins/ 2>/dev/null || true
    fi
    echo -e "${_GREEN}  ✓ Plugins copiés${_END}"
fi

# Copy themes (except Divi if using Divi config)
echo -e "${_CYAN}  → Copie des thèmes...${_END}"
if [ -d "$OLDPWD/wp-content/themes" ]; then
    if [ "$THEME_NAME" = "divi" ]; then
        rsync -av --exclude='Divi' "$OLDPWD/wp-content/themes/" web/app/themes/
    else
        cp -r "$OLDPWD/wp-content/themes/"* web/app/themes/ 2>/dev/null || true
    fi
    echo -e "${_GREEN}  ✓ Thèmes copiés${_END}"
fi

# Copy uploads
echo -e "${_CYAN}  → Copie des uploads...${_END}"
if [ -d "$OLDPWD/wp-content/uploads" ]; then
    cp -r "$OLDPWD/wp-content/uploads/"* web/app/uploads/ 2>/dev/null || true
    echo -e "${_GREEN}  ✓ Uploads copiés${_END}"
fi

# Copy mu-plugins if they exist
if [ -d "$OLDPWD/wp-content/mu-plugins" ]; then
    echo -e "${_CYAN}  → Copie des mu-plugins...${_END}"
    cp -r "$OLDPWD/wp-content/mu-plugins/"* web/app/mu-plugins/ 2>/dev/null || true
    echo -e "${_GREEN}  ✓ MU-plugins copiés${_END}"
fi

# Export database
echo ""
echo -e "${_YELLOW}💾 Export de la base de données...${_END}"
cd "$OLDPWD"

if command -v wp &> /dev/null; then
    wp db export "$BEDROCK_DIR/dumps/migration-$(date +%Y%m%d-%H%M%S).sql" --allow-root 2>/dev/null || \
        mysqldump -u"${DB_USER}" -p"${DB_PASSWORD}" -h"${DB_HOST}" "${DB_NAME}" > "$BEDROCK_DIR/dumps/migration-$(date +%Y%m%d-%H%M%S).sql"
else
    mysqldump -u"${DB_USER}" -p"${DB_PASSWORD}" -h"${DB_HOST}" "${DB_NAME}" > "$BEDROCK_DIR/dumps/migration-$(date +%Y%m%d-%H%M%S).sql" 2>/dev/null || true
fi

if [ -f "$BEDROCK_DIR/dumps/migration-"*.sql ]; then
    echo -e "${_GREEN}✓ Base de données exportée${_END}"
else
    echo -e "${_YELLOW}⚠ Export de la base de données échoué - à faire manuellement${_END}"
fi

cd "$BEDROCK_DIR"

# Create migration notes
cat > MIGRATION-NOTES.md << EOF
# Notes de Migration

## Migration effectuée le $(date)

### Ancien site
- URL: ${CURRENT_URL}
- Base de données: ${DB_NAME}
- Préfixe: ${DB_PREFIX}

### Nouveau site Bedrock
- URL: https://${NEW_URL}
- Configuration: ${THEME_NAME}
- Structure: Bedrock

## Prochaines étapes

### 1. Installer les dépendances Composer

\`\`\`bash
composer install
\`\`\`

### 2. Lancer la stack Arxama (si pas déjà fait)

\`\`\`bash
cd ../arxama-stack
make up
\`\`\`

### 3. Ajouter au /etc/hosts

\`\`\`bash
echo "127.0.0.1 ${NEW_URL}" | sudo tee -a /etc/hosts
\`\`\`

### 4. Lancer le projet

\`\`\`bash
make up
\`\`\`

### 5. Importer la base de données

\`\`\`bash
make db-import file=dumps/migration-*.sql
\`\`\`

### 6. Mettre à jour les URLs dans la base de données

\`\`\`bash
make wp cmd="search-replace '${CURRENT_URL}' 'https://${NEW_URL}' --all-tables"
\`\`\`

### 7. Vérifier les permaliens

\`\`\`bash
make wp cmd="rewrite flush"
\`\`\`

### 8. Vérifier les plugins

Certains plugins ont peut-être besoin d'être réactivés:

\`\`\`bash
make wp cmd="plugin list"
make wp cmd="plugin activate --all"
\`\`\`

## Fichiers migrés

- ✅ Plugins → web/app/plugins/
- ✅ Thèmes → web/app/themes/
- ✅ Uploads → web/app/uploads/
- ✅ MU-Plugins → web/app/mu-plugins/
- ✅ Base de données → dumps/

## Plugins à installer via Composer (recommandé)

Pour les plugins du WordPress.org, utilisez Composer:

\`\`\`bash
# Exemple
make composer cmd="require wpackagist-plugin/nom-du-plugin"
\`\`\`

## Vérifications post-migration

- [ ] Site accessible sur https://${NEW_URL}
- [ ] Connexion admin fonctionne
- [ ] Thème actif et affiché correctement
- [ ] Plugins actifs
- [ ] Uploads accessibles
- [ ] Permaliens fonctionnent
- [ ] Formulaires fonctionnent
- [ ] Emails de test (via MailHog)

## Problèmes courants

### Site ne s'affiche pas
\`\`\`bash
make logs-wordpress
make logs-nginx
\`\`\`

### Permissions
\`\`\`bash
make shell-root
chown -R www-data:www-data /var/www/html
\`\`\`

### Cache
\`\`\`bash
make wp cmd="cache flush"
\`\`\`
EOF

echo ""
echo -e "${_GREEN}${_BOLD}✅ Migration terminée!${_END}"
echo ""
echo -e "${_BLUE}📍 Votre projet Bedrock:${_END}"
echo -e "   ${_YELLOW}${BEDROCK_DIR}${_END}"
echo ""
echo -e "${_CYAN}📖 Consultez MIGRATION-NOTES.md pour les prochaines étapes${_END}"
echo ""
echo -e "${_BLUE}🚀 Pour lancer le projet:${_END}"
echo -e "   ${_GREEN}cd ${BEDROCK_DIR}${_END}"
echo -e "   ${_GREEN}composer install${_END}"
echo -e "   ${_GREEN}make up${_END}"
echo -e "   ${_GREEN}make db-import file=dumps/migration-*.sql${_END}"
echo -e "   ${_GREEN}make wp cmd=\"search-replace '${CURRENT_URL}' 'https://${NEW_URL}' --all-tables\"${_END}"
echo ""

# Offer to create GitHub repo
echo -e "${_CYAN}Voulez-vous créer un repo GitHub pour ce projet? (y/n) [n]:${_END}"
read -p "" CREATE_REPO
CREATE_REPO=${CREATE_REPO:-n}

if [[ "$CREATE_REPO" =~ ^[Yy]$ ]]; then
    if command -v gh &> /dev/null; then
        echo -e "${_YELLOW}Création du repo GitHub...${_END}"
        
        read -p "Organisation/Username GitHub: " GITHUB_ORG
        if [ -z "$GITHUB_ORG" ]; then
            GITHUB_ORG=$(gh api user -q .login)
        fi
        
        read -p "Repo privé? (y/n) [y]: " IS_PRIVATE
        IS_PRIVATE=${IS_PRIVATE:-y}
        
        VISIBILITY_FLAG="--public"
        if [[ "$IS_PRIVATE" =~ ^[Yy]$ ]]; then
            VISIBILITY_FLAG="--private"
        fi
        
        git init
        git add .
        git commit -m "Initial commit - Migration from WordPress to Bedrock

Migrated from: ${CURRENT_URL}
Theme config: ${THEME_NAME}
Migration date: $(date)"
        
        gh repo create "${GITHUB_ORG}/${PROJECT_NAME}" \
            ${VISIBILITY_FLAG} \
            --source=. \
            --description="Bedrock project migrated from WordPress" \
            --remote=origin \
            --push
        
        echo -e "${_GREEN}✓ Repo GitHub créé: https://github.com/${GITHUB_ORG}/${PROJECT_NAME}${_END}"
    else
        echo -e "${_YELLOW}GitHub CLI non installé - création manuelle nécessaire${_END}"
    fi
fi

echo ""
echo -e "${_GREEN}🎉 Migration WordPress → Bedrock terminée avec succès!${_END}"
echo ""
