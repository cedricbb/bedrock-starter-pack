# 🚀 CI/CD - Déploiement Automatisé

Guide complet pour le déploiement automatique avec GitHub Actions.

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Types de déploiement](#types-de-déploiement)
- [Configuration initiale](#configuration-initiale)
- [Création automatique de projet](#création-automatique-de-projet)
- [Workflows disponibles](#workflows-disponibles)
- [Environnements](#environnements)
- [Troubleshooting](#troubleshooting)

## 🎯 Vue d'ensemble

Le Bedrock Starter Pack inclut un système complet de CI/CD avec GitHub Actions pour automatiser :

- ✅ **Tests** - Code quality, sécurité, build
- ✅ **Déploiement** - SSH, FTP, ou Docker
- ✅ **Environments** - Production et Staging
- ✅ **Notifications** - Succès/échec des déploiements

## 🔧 Types de déploiement

### 1. SSH/Rsync (Recommandé)

**Pour qui** : Serveurs VPS, dédiés avec accès SSH

**Avantages** :
- Rapide (synchronisation incrémentielle)
- Sécurisé
- Contrôle total
- Commandes post-déploiement

**Documentation** : [DEPLOY-SSH.md](DEPLOY-SSH.md)

---

### 2. FTP

**Pour qui** : Hébergements mutualisés sans SSH

**Avantages** :
- Compatible avec tous les hébergeurs
- Simple à configurer
- Aucun accès serveur requis

**Inconvénients** :
- Plus lent
- Moins sécurisé
- Pas de commandes post-déploiement

**Documentation** : [DEPLOY-FTP.md](DEPLOY-FTP.md)

---

### 3. Docker

**Pour qui** : Infrastructure containerisée

**Avantages** :
- Environnement reproductible
- Isolation complète
- Scaling facile
- CI/CD moderne

**Documentation** : [DEPLOY-DOCKER.md](DEPLOY-DOCKER.md)

---

## ⚡ Configuration initiale

### Prérequis

1. **GitHub CLI** installé et authentifié :
   ```bash
   # Installer GitHub CLI
   brew install gh  # macOS
   # ou https://cli.github.com/
   
   # Authentifier
   gh auth login
   ```

2. **Git** configuré :
   ```bash
   git config --global user.name "Votre Nom"
   git config --global user.email "votre@email.com"
   ```

## 🆕 Création automatique de projet

### Script `create-new-project.sh`

Le starter pack inclut un script qui automatise **tout le processus** :

```bash
cd bedrock-starter-pack
./scripts/create-new-project.sh
```

**Ce que fait le script** :

1. ✅ Demande les informations du projet
2. ✅ Choisit le thème (Elementor, Divi, Blank)
3. ✅ Choisit le type de déploiement (SSH, FTP, Docker)
4. ✅ Crée le répertoire projet
5. ✅ Copie tous les fichiers du starter pack
6. ✅ Configure le `.env` automatiquement
7. ✅ Génère les WordPress salts
8. ✅ Sélectionne le bon workflow GitHub Actions
9. ✅ Initialise Git
10. ✅ Crée le repo GitHub
11. ✅ Push le code initial

**Exemple d'utilisation** :

```bash
$ ./scripts/create-new-project.sh

🚀 Bedrock Starter Pack - Créateur de Nouveau Projet

📋 Informations du projet

Nom du projet: site-client-abc
Description du projet: Site vitrine pour Client ABC
Organisation/Username GitHub: mon-agence
Repo privé? (y/n) [y]: y

🎨 Choix du thème starter
  1) Elementor
  2) Divi  
  3) Blank

Votre choix [1-3]: 1

🚀 Type de déploiement
  1) SSH
  2) FTP
  3) Docker
  4) Aucun

Votre choix [1-4]: 1

📋 Récapitulatif
  Projet:        site-client-abc
  GitHub:        mon-agence/site-client-abc
  Privé:         y
  Thème:         elementor
  Déploiement:   ssh

Continuer? (y/n) [y]: y

[... création automatique ...]

✅ Projet créé avec succès!

📍 Votre projet:
   Local:  ../site-client-abc
   GitHub: https://github.com/mon-agence/site-client-abc
```

### Après la création

Le script vous indique les **prochaines étapes** :

```bash
⚙️  Configuration du déploiement requise

Ajoutez les secrets GitHub suivants dans:
https://github.com/mon-agence/site-client-abc/settings/secrets/actions

Secrets requis:
  SSH_HOST         - Hostname du serveur
  SSH_USER         - Utilisateur SSH
  SSH_PRIVATE_KEY  - Clé privée SSH
  SSH_PATH         - Chemin de déploiement

📚 Prochaines étapes:
  1. cd ../site-client-abc
  2. Configurer les secrets GitHub
  3. git push origin main (déclenchera le premier déploiement)
```

## 📦 Workflows disponibles

### CI - Tests & Quality (`.github/workflows/ci.yml`)

**Déclenché sur** : Push et Pull Request

**Étapes** :
- ✅ Tests PHP (syntax, CodeSniffer)
- ✅ Tests JavaScript (build)
- ✅ Build Docker (sur PR)
- ✅ Scan de sécurité (Trivy)

**Branches** : `main`, `develop`, `feature/*`

---

### Deploy SSH (`.github/workflows/deploy-ssh.yml`)

**Déclenché sur** : Push sur `main` ou manuellement

**Étapes** :
1. Checkout code
2. Install Composer dependencies (--no-dev)
3. Build assets (npm)
4. Deploy via rsync
5. Commandes post-déploiement

---

### Deploy FTP (`.github/workflows/deploy-ftp.yml`)

**Déclenché sur** : Push sur `main` ou manuellement

**Étapes** :
1. Checkout code
2. Install Composer dependencies
3. Build assets
4. Clean dev files
5. Upload via FTP

---

### Deploy Docker (`.github/workflows/deploy-docker.yml`)

**Déclenché sur** : Push sur `main` ou manuellement

**Étapes** :
1. Build images (WordPress + Nginx)
2. Push to registry (GitHub Container Registry)
3. Deploy on server (docker compose)

---

## 🌍 Environnements

### Configuration des environnements GitHub

1. Aller dans `Settings > Environments`
2. Créer `production` et `staging`
3. Configurer les secrets pour chaque environnement

### Variables par environnement

| Variable | Production | Staging |
|----------|-----------|---------|
| `SSH_HOST` | `prod.example.com` | `staging.example.com` |
| `SSH_PATH` | `/var/www/html/site` | `/var/www/html/staging` |
| `WP_ENV` | `production` | `staging` |

### Déploiement manuel vers staging

```bash
# Via GitHub CLI
gh workflow run deploy-ssh.yml -f environment=staging

# Via l'interface GitHub
Actions > Deploy > Run workflow > staging
```

## 🔐 Secrets GitHub

### Où les configurer

`Settings > Secrets and variables > Actions > New repository secret`

### Secrets communs

| Secret | Description |
|--------|-------------|
| `SSH_HOST` | Hostname du serveur |
| `SSH_USER` | Utilisateur SSH |
| `SSH_PRIVATE_KEY` | Clé privée SSH (format PEM) |
| `SSH_PATH` | Chemin absolu sur le serveur |

### Secrets FTP

| Secret | Description |
|--------|-------------|
| `FTP_HOST` | Hostname FTP |
| `FTP_USER` | Utilisateur FTP |
| `FTP_PASSWORD` | Mot de passe FTP |
| `FTP_PATH` | Chemin relatif |

### Secrets Docker

| Secret | Description |
|--------|-------------|
| `DOCKER_REGISTRY` | URL du registry (ghcr.io) |
| `DOCKER_USERNAME` | Utilisateur Docker |
| `DOCKER_PASSWORD` | Token d'accès |
| `SSH_HOST` | Serveur Docker |
| `SSH_USER` | Utilisateur SSH |
| `SSH_PRIVATE_KEY` | Clé SSH |

## 📊 Monitoring

### Dashboard GitHub Actions

Aller dans l'onglet **Actions** de votre repo pour :
- Voir l'historique des déploiements
- Consulter les logs détaillés
- Relancer des workflows
- Vérifier le statut

### Badge de statut

Ajouter dans votre `README.md` :

```markdown
![CI](https://github.com/username/repo/workflows/CI/badge.svg)
![Deploy](https://github.com/username/repo/workflows/Deploy/badge.svg)
```

## 🔔 Notifications

### Slack

Ajouter dans vos workflows :

```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "✅ Deployment successful to production"
      }
```

### Discord

```yaml
- name: Notify Discord
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    status: ${{ job.status }}
    title: "Deployment"
```

### Email

GitHub envoie automatiquement des emails sur les échecs de workflow.

## 🐛 Troubleshooting

### Le workflow ne se déclenche pas

**Causes possibles** :
- Branch incorrecte (doit être `main`)
- Workflow désactivé
- Fichier YAML invalide

**Solution** :
```bash
# Vérifier la syntaxe YAML
yamllint .github/workflows/deploy.yml

# Vérifier dans Actions > Workflows
# Activer le workflow si désactivé
```

### Erreur de build

**Voir les logs** :
1. Aller dans Actions
2. Cliquer sur le run échoué
3. Consulter les logs de l'étape qui a échoué

### Les secrets ne fonctionnent pas

**Vérifications** :
- Secrets bien configurés dans Settings > Secrets
- Noms exacts (sensibles à la casse)
- Environnement correct (production/staging)

### Permissions GitHub Actions

Si erreur de permissions :

1. Aller dans `Settings > Actions > General`
2. Scroll vers `Workflow permissions`
3. Sélectionner `Read and write permissions`
4. Cocher `Allow GitHub Actions to create and approve pull requests`

## 📚 Ressources

### Documentation

- [SSH Deployment](DEPLOY-SSH.md)
- [FTP Deployment](DEPLOY-FTP.md)
- [Docker Deployment](DEPLOY-DOCKER.md)

### Liens utiles

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub CLI](https://cli.github.com/)
- [Bedrock Deployment](https://roots.io/bedrock/docs/deployment/)

## 🎯 Best Practices

### 1. Utilisez des environnements

Toujours avoir au minimum `staging` et `production`.

### 2. Tests avant déploiement

Ne déployez pas si les tests échouent :

```yaml
deploy:
  needs: [tests]  # Attend que les tests passent
```

### 3. Rollback strategy

Gardez une sauvegarde avant chaque déploiement :

```bash
# Sur le serveur
cp -r /var/www/html/site /var/www/html/site.backup.$(date +%Y%m%d)
```

### 4. Monitoring

Surveillez les logs et configurez des alertes.

### 5. Documentation

Documentez votre processus de déploiement spécifique.

## 🔮 Prochaines fonctionnalités

- [ ] Support Kubernetes
- [ ] Déploiement blue-green
- [ ] Rollback automatique
- [ ] Tests end-to-end
- [ ] Performance monitoring

---

**Automatisez vos déploiements ! 🚀**
