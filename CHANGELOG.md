# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

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
