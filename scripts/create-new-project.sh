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
echo -e "${_BLUE}${_BOLD}🚀 Bedrock Starter Pack - Créateur de Nouveau Projet${_END}"
echo ""

# Check dependencies
command -v git >/dev/null 2>&1 || { echo -e "${_RED}❌ git n'est pas installé${_END}"; exit 1; }
command -v gh >/dev/null 2>&1 || { echo -e "${_RED}❌ GitHub CLI (gh) n'est pas installé${_END}"; exit 1; }

# Check if gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo -e "${_RED}❌ GitHub CLI n'est pas authentifié${_END}"
    echo -e "${_YELLOW}Exécutez: gh auth login${_END}"
    exit 1
fi

# Get project information
echo -e "${_CYAN}${_BOLD}📋 Informations du projet${_END}"
echo ""

read -p "Nom du projet (ex: mon-site-web): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${_RED}❌ Le nom du projet est requis${_END}"
    exit 1
fi

read -p "Description du projet: " PROJECT_DESCRIPTION
read -p "Organisation/Username GitHub: " GITHUB_ORG

if [ -z "$GITHUB_ORG" ]; then
    GITHUB_ORG=$(gh api user -q .login)
    echo -e "${_YELLOW}→ Utilisation de l'utilisateur par défaut: ${GITHUB_ORG}${_END}"
fi

read -p "Repo privé? (y/n) [y]: " IS_PRIVATE
IS_PRIVATE=${IS_PRIVATE:-y}

# Theme selection
echo ""
echo -e "${_CYAN}${_BOLD}🎨 Choix du thème starter${_END}"
echo ""
echo -e "  ${_GREEN}1)${_END} ${_BOLD}Elementor${_END} - Hello Elementor + Elementor plugin (gratuit)"
echo -e "  ${_GREEN}2)${_END} ${_BOLD}Divi${_END} - Divi theme (premium - installation manuelle)"
echo -e "  ${_GREEN}3)${_END} ${_BOLD}Blank${_END} - Installation basique sans thème"
echo ""
read -p "Votre choix [1-3]: " THEME_CHOICE

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

# Deployment type
echo ""
echo -e "${_CYAN}${_BOLD}🚀 Type de déploiement${_END}"
echo ""
echo -e "  ${_GREEN}1)${_END} ${_BOLD}SSH${_END} - Déploiement via SSH/rsync"
echo -e "  ${_GREEN}2)${_END} ${_BOLD}FTP${_END} - Déploiement via FTP"
echo -e "  ${_GREEN}3)${_END} ${_BOLD}Docker${_END} - Déploiement Docker (Registry + SSH)"
echo -e "  ${_GREEN}4)${_END} ${_BOLD}Aucun${_END} - Pas de déploiement automatique"
echo ""
read -p "Votre choix [1-4]: " DEPLOY_CHOICE

case "$DEPLOY_CHOICE" in
    1) DEPLOY_TYPE="ssh" ;;
    2) DEPLOY_TYPE="ftp" ;;
    3) DEPLOY_TYPE="docker" ;;
    4) DEPLOY_TYPE="none" ;;
    *)
        echo -e "${_RED}❌ Choix invalide${_END}"
        exit 1
        ;;
esac

# Confirmation
echo ""
echo -e "${_BLUE}${_BOLD}📋 Récapitulatif${_END}"
echo -e "  Projet:        ${_YELLOW}${PROJECT_NAME}${_END}"
echo -e "  GitHub:        ${_YELLOW}${GITHUB_ORG}/${PROJECT_NAME}${_END}"
echo -e "  Privé:         ${_YELLOW}${IS_PRIVATE}${_END}"
echo -e "  Thème:         ${_YELLOW}${THEME_NAME}${_END}"
echo -e "  Déploiement:   ${_YELLOW}${DEPLOY_TYPE}${_END}"
echo ""
read -p "Continuer? (y/n) [y]: " CONFIRM
CONFIRM=${CONFIRM:-y}

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${_RED}Annulé${_END}"
    exit 0
fi

# Create project directory
echo ""
echo -e "${_YELLOW}📁 Création du répertoire projet...${_END}"
PROJECT_DIR="../${PROJECT_NAME}"

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${_RED}❌ Le répertoire ${PROJECT_DIR} existe déjà${_END}"
    exit 1
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Copy starter pack files
echo -e "${_YELLOW}📦 Copie des fichiers du starter pack...${_END}"
rsync -av --exclude='.git' \
    --exclude='node_modules' \
    --exclude='vendor' \
    --exclude='web/wp' \
    --exclude='web/app/uploads/*' \
    --exclude='web/app/plugins/*' \
    ../"$(basename "$(dirname "$0")")"/. .

# Select theme configuration
if [ "$THEME_NAME" != "blank" ]; then
    echo -e "${_YELLOW}🎨 Configuration du thème ${THEME_NAME}...${_END}"
    cp "$COMPOSER_FILE" composer.json
fi

# Create .env file
echo -e "${_YELLOW}📝 Création du fichier .env...${_END}"
cp .env.example .env

# Update .env with project name
sed -i.bak "s/PROJECT_NAME=myproject/PROJECT_NAME=${PROJECT_NAME}/" .env
sed -i.bak "s/myproject.arxama.local/${PROJECT_NAME}.arxama.local/" .env
rm -f .env.bak

# Generate WordPress salts
echo -e "${_YELLOW}🔐 Génération des salts WordPress...${_END}"
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sed -i.bak '/AUTH_KEY=/d; /SECURE_AUTH_KEY=/d; /LOGGED_IN_KEY=/d; /NONCE_KEY=/d; /AUTH_SALT=/d; /SECURE_AUTH_SALT=/d; /LOGGED_IN_SALT=/d; /NONCE_SALT=/d' .env
echo "$SALTS" | while IFS= read -r line; do
    key=$(echo "$line" | cut -d"'" -f2)
    value=$(echo "$line" | cut -d"'" -f4)
    echo "${key}='${value}'" >> .env
done
rm -f .env.bak

# Select GitHub Actions workflow
if [ "$DEPLOY_TYPE" != "none" ]; then
    echo -e "${_YELLOW}🔧 Configuration du workflow GitHub Actions...${_END}"
    
    # Copy the appropriate workflow
    if [ -f ".github/workflows/deploy-${DEPLOY_TYPE}.yml" ]; then
        cp ".github/workflows/deploy-${DEPLOY_TYPE}.yml" .github/workflows/deploy.yml
        rm .github/workflows/deploy-*.yml
    fi
fi

# Initialize git repository
echo -e "${_YELLOW}📚 Initialisation du dépôt Git...${_END}"
git init
git add .
git commit -m "Initial commit from Bedrock Starter Pack

Project: ${PROJECT_NAME}
Theme: ${THEME_NAME}
Deploy: ${DEPLOY_TYPE}"

# Create GitHub repository
echo -e "${_YELLOW}🐙 Création du dépôt GitHub...${_END}"

VISIBILITY_FLAG="--public"
if [[ "$IS_PRIVATE" =~ ^[Yy]$ ]]; then
    VISIBILITY_FLAG="--private"
fi

gh repo create "${GITHUB_ORG}/${PROJECT_NAME}" \
    ${VISIBILITY_FLAG} \
    --source=. \
    --description="${PROJECT_DESCRIPTION}" \
    --remote=origin \
    --push

echo ""
echo -e "${_GREEN}${_BOLD}✅ Projet créé avec succès!${_END}"
echo ""
echo -e "${_BLUE}📍 Votre projet:${_END}"
echo -e "   Local:  ${_YELLOW}${PROJECT_DIR}${_END}"
echo -e "   GitHub: ${_YELLOW}https://github.com/${GITHUB_ORG}/${PROJECT_NAME}${_END}"
echo ""

if [ "$DEPLOY_TYPE" != "none" ]; then
    echo -e "${_CYAN}${_BOLD}⚙️  Configuration du déploiement requise${_END}"
    echo ""
    echo -e "Ajoutez les secrets GitHub suivants dans:"
    echo -e "${_YELLOW}https://github.com/${GITHUB_ORG}/${PROJECT_NAME}/settings/secrets/actions${_END}"
    echo ""
    
    case "$DEPLOY_TYPE" in
        ssh)
            echo -e "Secrets requis:"
            echo -e "  ${_GREEN}SSH_HOST${_END}         - Hostname du serveur"
            echo -e "  ${_GREEN}SSH_USER${_END}         - Utilisateur SSH"
            echo -e "  ${_GREEN}SSH_PRIVATE_KEY${_END}  - Clé privée SSH"
            echo -e "  ${_GREEN}SSH_PATH${_END}         - Chemin de déploiement"
            ;;
        ftp)
            echo -e "Secrets requis:"
            echo -e "  ${_GREEN}FTP_HOST${_END}         - Hostname FTP"
            echo -e "  ${_GREEN}FTP_USER${_END}         - Utilisateur FTP"
            echo -e "  ${_GREEN}FTP_PASSWORD${_END}     - Mot de passe FTP"
            echo -e "  ${_GREEN}FTP_PATH${_END}         - Chemin de déploiement"
            ;;
        docker)
            echo -e "Secrets requis:"
            echo -e "  ${_GREEN}DOCKER_REGISTRY${_END}  - URL du registry Docker"
            echo -e "  ${_GREEN}DOCKER_USERNAME${_END}  - Utilisateur Docker"
            echo -e "  ${_GREEN}DOCKER_PASSWORD${_END}  - Mot de passe Docker"
            echo -e "  ${_GREEN}SSH_HOST${_END}         - Hostname du serveur"
            echo -e "  ${_GREEN}SSH_USER${_END}         - Utilisateur SSH"
            echo -e "  ${_GREEN}SSH_PRIVATE_KEY${_END}  - Clé privée SSH"
            ;;
    esac
    
    echo ""
    echo -e "Documentation: ${_YELLOW}docs/deployment/DEPLOY-${DEPLOY_TYPE^^}.md${_END}"
fi

echo ""
echo -e "${_BLUE}📚 Prochaines étapes:${_END}"
echo -e "  1. ${_GREEN}cd ${PROJECT_DIR}${_END}"

if [ "$DEPLOY_TYPE" != "none" ]; then
    echo -e "  2. Configurer les secrets GitHub pour le déploiement"
    echo -e "  3. ${_GREEN}git push origin main${_END} (déclenchera le premier déploiement)"
else
    echo -e "  2. ${_GREEN}./scripts/install.sh${_END} (pour tester localement)"
fi

echo ""
