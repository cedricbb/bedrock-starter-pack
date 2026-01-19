#!make
-include .env
export

_END=\033[0m
_BOLD=\033[1m
_GREEN=\033[32m
_YELLOW=\033[33m
_BLUE=\033[34m
_RED=\033[31m

.DEFAULT_GOAL := help

help: ## Show this help
	@echo ""
	@echo "${_BLUE}${_BOLD}Bedrock WordPress Starter Pack${_END}"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${_GREEN}%-20s${_END} %s\n", $$1, $$2}'
	@echo ""

init: ## Initialize the project (first time setup)
	@echo "${_BLUE}Initializing project...${_END}"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "${_GREEN}✓ Created .env file${_END}"; \
	else \
		echo "${_YELLOW}⚠ .env file already exists${_END}"; \
	fi
	@if [ ! -d web ]; then \
		mkdir -p web/app/uploads web/app/plugins; \
		touch web/app/uploads/.gitkeep web/app/plugins/.gitkeep; \
		echo "${_GREEN}✓ Created web directory structure${_END}"; \
	fi
	@echo "${_YELLOW}→ Installing Composer dependencies...${_END}"
	@docker compose run --rm wordpress composer install
	@echo "${_GREEN}✓ Project initialized!${_END}"
	@echo ""
	@echo "${_BLUE}Next steps:${_END}"
	@echo "1. Update your .env file with your configuration"
	@echo "2. Add ${_YELLOW}${PROJECT_NAME}.arxama.local${_END} to your /etc/hosts:"
	@echo "   ${_YELLOW}127.0.0.1 ${PROJECT_NAME}.arxama.local${_END}"
	@echo "3. Run ${_GREEN}make up${_END} to start the containers"
	@echo "4. Visit ${_YELLOW}https://${PROJECT_NAME}.arxama.local${_END}"
	@echo ""

up: ## Start containers
	@docker compose up -d
	@echo "${_GREEN}✓ Containers started${_END}"
	@echo "Visit: ${_YELLOW}https://${PROJECT_NAME}.arxama.local${_END}"

down: ## Stop containers
	@docker compose down
	@echo "${_GREEN}✓ Containers stopped${_END}"

restart: down up ## Restart containers

logs: ## Show logs
	@docker compose logs -f

logs-wordpress: ## Show WordPress logs
	@docker compose logs -f wordpress

logs-nginx: ## Show Nginx logs
	@docker compose logs -f nginx

ps: ## Show containers status
	@docker compose ps

shell: ## Access WordPress container shell
	@docker compose exec wordpress sh

shell-root: ## Access WordPress container shell as root
	@docker compose exec -u root wordpress sh

composer: ## Run composer command (usage: make composer cmd="install")
	@docker compose exec wordpress composer $(cmd)

wp: ## Run WP-CLI command (usage: make wp cmd="plugin list")
	@docker compose exec wordpress wp $(cmd) --allow-root

npm: ## Run npm command (usage: make npm cmd="install")
	@docker compose exec node npm $(cmd)

db-export: ## Export database
	@docker compose exec -T mariadb mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > dumps/$(PROJECT_NAME)-$$(date +%Y%m%d-%H%M%S).sql
	@echo "${_GREEN}✓ Database exported to dumps/${_END}"

db-import: ## Import database (usage: make db-import file=dump.sql)
	@docker compose exec -T mariadb mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < $(file)
	@echo "${_GREEN}✓ Database imported${_END}"

clean: ## Remove containers, volumes, and generated files
	@echo "${_RED}Warning: This will remove all containers, volumes, and generated files${_END}"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		rm -rf vendor web/wp web/app/uploads/* web/app/plugins/* node_modules; \
		echo "${_GREEN}✓ Cleaned${_END}"; \
	fi

update: ## Update WordPress and plugins
	@docker compose exec wordpress composer update
	@echo "${_GREEN}✓ Updated${_END}"

.PHONY: help init up down restart logs logs-wordpress logs-nginx ps shell shell-root composer wp npm db-export db-import clean update
