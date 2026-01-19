# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.2.0] - 2026-01-19

### Ajouté
- 🚀 **CI/CD complet avec GitHub Actions**
  - Workflow de tests automatiques (CI)
  - Workflow de déploiement SSH
  - Workflow de déploiement FTP
  - Workflow de déploiement Docker
- 🤖 **Script de création de projet automatisé** (`create-new-project.sh`)
  - Création automatique du repo GitHub via GitHub CLI
  - Configuration du thème au choix (Elementor/Divi/Blank)
  - Sélection du type de déploiement (SSH/FTP/Docker)
  - Génération automatique des salts WordPress
  - Push initial automatique
- 📚 **Documentation CI/CD complète**
  - Guide général CI/CD (docs/deployment/README.md)
  - Guide déploiement SSH (docs/deployment/DEPLOY-SSH.md)
  - Guide déploiement FTP (docs/deployment/DEPLOY-FTP.md)
  - Guide déploiement Docker (docs/deployment/DEPLOY-DOCKER.md)
  - Quick Start CI/CD (docs/deployment/QUICKSTART.md)
- 🐳 **Dockerfile Nginx** pour déploiement Docker
- 🔒 **Scan de sécurité** avec Trivy dans le workflow CI
- 🧪 **Tests automatiques** (PHP syntax, CodeSniffer, JavaScript build, Docker build)
- 🌍 **Support multi-environnements** (production, staging avec GitHub Environments)
- 🔔 **Support notifications** (templates Slack, Discord)
- ⚙️ **Workflows optimisés** avec cache Composer et NPM

### Amélioré
- 📝 Workflows GitHub Actions avec cache pour performance
- 🔐 Gestion sécurisée des secrets GitHub par environnement
- 📦 Build assets automatique avant chaque déploiement
- 🎯 Exclusion intelligente des fichiers au déploiement
- 🔄 Commandes post-déploiement personnalisables
- 📊 Monitoring intégré via GitHub Actions

## [1.1.0] - 2026-01-19

### Ajouté
- 🎨 **Support pour plusieurs thèmes starter**
  - Configuration Elementor (Hello Elementor + Elementor plugin)
  - Configuration Divi (thème premium avec installation guidée)
  - Configuration Blank (base minimale pour thèmes custom)
- 📚 Script d'installation interactif avec choix de thème (`install-with-theme.sh`)
- 📖 Documentation complète pour chaque thème :
  - `themes-config/elementor/README.md` - Guide Elementor complet
  - `themes-config/divi/README.md` - Guide Divi complet  
  - `themes-config/blank/README.md` - Guide développement custom
- 📋 `THEMES.md` - Guide de sélection et comparaison des thèmes
- ⚙️ Configuration Composer spécifique pour chaque thème
- 🚀 Post-installation automatique selon le thème choisi

### Amélioré
- 📝 README.md mis à jour avec section thèmes starter
- 🎯 Expérience d'installation plus guidée et flexible

## [1.0.0] - 2026-01-19

### Ajouté
- Configuration Bedrock initiale avec WordPress 6.7
- Intégration complète avec Arxama Stack Dev
- Support Docker avec PHP 8.2 FPM et Nginx
- Configuration Traefik pour HTTPS automatique
- Script d'installation automatique
- Support Redis pour le cache objet
- Configuration MailHog pour la capture d'emails
- Makefile avec commandes automatisées
- Support WP-CLI
- Configuration Vite pour les assets front-end
- Documentation complète (README, QUICKSTART)
- Configuration PHP CodeSniffer (PSR-12)
- Variables d'environnement (.env.example)
- Gestion des dépendances via Composer
- Support multi-environnements (development, staging, production)

### Configuration par défaut
- PHP 8.2 avec extensions optimisées
- Nginx avec configuration Bedrock
- MariaDB depuis Arxama Stack
- Redis depuis Arxama Stack
- MailHog depuis Arxama Stack

## [Unreleased]

### Prévu
- Support pour plusieurs thèmes starter
- Intégration CI/CD
- Scripts de déploiement automatisés
- Support Docker multi-stage builds
- Optimisations de performance additionnelles
- Support Cloudflare pour production
- Intégration monitoring (Sentry)
