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
echo -e "${_BLUE}${_BOLD}🚀 Bedrock WordPress Starter Pack - Installation avec choix de thème${_END}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${_RED}❌ Docker is not running. Please start Docker first.${_END}"
    exit 1
fi

# Theme selection
echo -e "${_CYAN}${_BOLD}📦 Choisissez votre thème starter :${_END}"
echo ""
echo -e "  ${_GREEN}1)${_END} ${_BOLD}Elementor${_END} - Hello Elementor + Elementor plugin (gratuit)"
echo -e "  ${_GREEN}2)${_END} ${_BOLD}Divi${_END} - Divi theme (premium - installation manuelle)"
echo -e "  ${_GREEN}3)${_END} ${_BOLD}Blank${_END} - Installation basique sans thème"
echo ""
read -p "Votre choix [1-3]: " THEME_CHOICE

case "$THEME_CHOICE" in
    1)
        THEME_NAME="elementor"
        THEME_DISPLAY="Elementor (Hello Elementor + Elementor)"
        COMPOSER_FILE="themes-config/elementor/composer.json"
        ;;
    2)
        THEME_NAME="divi"
        THEME_DISPLAY="Divi"
        COMPOSER_FILE="themes-config/divi/composer.json"
        ;;
    3)
        THEME_NAME="blank"
        THEME_DISPLAY="Blank (Twenty Twenty-Four)"
        COMPOSER_FILE="composer.json"
        ;;
    *)
        echo -e "${_RED}❌ Choix invalide${_END}"
        exit 1
        ;;
esac

echo ""
echo -e "${_BLUE}✓ Thème sélectionné : ${_BOLD}${THEME_DISPLAY}${_END}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${_YELLOW}📝 Creating .env file...${_END}"
    cp .env.example .env
    
    # Generate WordPress salts
    echo -e "${_YELLOW}🔐 Generating WordPress salts...${_END}"
    SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    
    # Replace the salts in .env
    sed -i.bak '/AUTH_KEY=/d; /SECURE_AUTH_KEY=/d; /LOGGED_IN_KEY=/d; /NONCE_KEY=/d; /AUTH_SALT=/d; /SECURE_AUTH_SALT=/d; /LOGGED_IN_SALT=/d; /NONCE_SALT=/d' .env
    echo "$SALTS" | while IFS= read -r line; do
        key=$(echo "$line" | cut -d"'" -f2)
        value=$(echo "$line" | cut -d"'" -f4)
        echo "${key}='${value}'" >> .env
    done
    rm -f .env.bak
    
    echo -e "${_GREEN}✓ .env file created with WordPress salts${_END}"
else
    echo -e "${_YELLOW}⚠ .env file already exists, skipping...${_END}"
fi

# Get project name from .env
source .env
PROJECT_NAME=${PROJECT_NAME:-myproject}

# Check if Arxama stack is running
if ! docker network ls | grep -q "backend"; then
    echo -e "${_RED}❌ Arxama stack network 'backend' not found.${_END}"
    echo -e "${_YELLOW}Please start the Arxama stack first:${_END}"
    echo -e "  cd ../arxama-stack"
    echo -e "  make up"
    exit 1
fi

# Create necessary directories
echo -e "${_YELLOW}📁 Creating directories...${_END}"
mkdir -p web/app/uploads web/app/plugins web/app/mu-plugins vendor
touch web/app/uploads/.gitkeep web/app/plugins/.gitkeep

# Use the appropriate composer.json based on theme choice
if [ "$THEME_NAME" != "blank" ]; then
    echo -e "${_YELLOW}📦 Using ${THEME_DISPLAY} composer configuration...${_END}"
    cp "$COMPOSER_FILE" composer.json
fi

# Install Composer dependencies
echo -e "${_YELLOW}📦 Installing Composer dependencies...${_END}"
docker compose run --rm wordpress composer install --no-interaction

# Start containers
echo -e "${_YELLOW}🐳 Starting Docker containers...${_END}"
docker compose up -d

# Wait for services to be ready
echo -e "${_YELLOW}⏳ Waiting for services to be ready...${_END}"
sleep 5

# Check if WordPress is installed
WP_INSTALLED=$(docker compose exec -T wordpress wp core is-installed --allow-root 2>/dev/null && echo "yes" || echo "no")

if [ "$WP_INSTALLED" = "no" ]; then
    echo -e "${_YELLOW}🔧 Installing WordPress...${_END}"
    
    # Install WordPress
    docker compose exec -T wordpress wp core install \
        --url="https://${PROJECT_NAME}.arxama.local" \
        --title="${PROJECT_NAME}" \
        --admin_user="admin" \
        --admin_password="admin" \
        --admin_email="admin@${PROJECT_NAME}.local" \
        --skip-email \
        --allow-root
    
    echo -e "${_GREEN}✓ WordPress installed successfully${_END}"
    
    # Theme-specific post-installation
    case "$THEME_NAME" in
        elementor)
            echo -e "${_YELLOW}🎨 Configuring Elementor...${_END}"
            docker compose exec -T wordpress wp theme activate hello-elementor --allow-root
            docker compose exec -T wordpress wp plugin activate elementor --allow-root
            echo -e "${_GREEN}✓ Elementor activated and configured${_END}"
            ;;
        divi)
            echo -e "${_YELLOW}🎨 Divi theme requires manual installation${_END}"
            echo -e "${_CYAN}Please follow these steps:${_END}"
            echo -e "  1. Download Divi theme from your Elegant Themes account"
            echo -e "  2. Place the zip file in web/app/themes/"
            echo -e "  3. Run: make wp cmd=\"theme install web/app/themes/Divi.zip\""
            echo -e "  4. Run: make wp cmd=\"theme activate Divi\""
            ;;
        blank)
            echo -e "${_YELLOW}🎨 Activating Twenty Twenty-Four theme...${_END}"
            docker compose exec -T wordpress wp theme activate twentytwentyfour --allow-root
            ;;
    esac
else
    echo -e "${_YELLOW}⚠ WordPress is already installed, skipping...${_END}"
fi

# Update /etc/hosts if not already added
if ! grep -q "${PROJECT_NAME}.arxama.local" /etc/hosts 2>/dev/null; then
    echo -e "${_YELLOW}🧭 Adding entry to /etc/hosts...${_END}"
    echo "127.0.0.1 ${PROJECT_NAME}.arxama.local" | sudo tee -a /etc/hosts > /dev/null
    echo -e "${_GREEN}✓ Entry added to /etc/hosts${_END}"
else
    echo -e "${_YELLOW}⚠ Entry already exists in /etc/hosts${_END}"
fi

echo ""
echo -e "${_GREEN}${_BOLD}✅ Installation complete!${_END}"
echo ""
echo -e "${_BLUE}📍 Your WordPress site with ${_BOLD}${THEME_DISPLAY}${_END}${_BLUE} is ready:${_END}"
echo -e "   URL:      ${_YELLOW}https://${PROJECT_NAME}.arxama.local${_END}"
echo -e "   Username: ${_YELLOW}admin${_END}"
echo -e "   Password: ${_YELLOW}admin${_END}"
echo ""

if [ "$THEME_NAME" = "divi" ]; then
    echo -e "${_CYAN}${_BOLD}⚠️  Divi Installation Required:${_END}"
    echo -e "   Divi is a premium theme. Please install it manually:"
    echo -e "   1. Download from Elegant Themes"
    echo -e "   2. Upload via WordPress admin or WP-CLI"
    echo ""
fi

echo -e "${_BLUE}📚 Useful commands:${_END}"
echo -e "   ${_GREEN}make up${_END}      - Start containers"
echo -e "   ${_GREEN}make down${_END}    - Stop containers"
echo -e "   ${_GREEN}make logs${_END}    - View logs"
echo -e "   ${_GREEN}make shell${_END}   - Access WordPress container"
echo -e "   ${_GREEN}make help${_END}    - Show all commands"
echo ""
