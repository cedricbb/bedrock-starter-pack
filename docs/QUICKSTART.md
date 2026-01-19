# ⚡ Quick Start CI/CD

Guide ultra-rapide pour déployer automatiquement avec GitHub Actions.

## 🚀 En 5 minutes

### 1. Installer GitHub CLI

```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authentifier
gh auth login
```

### 2. Créer un nouveau projet

```bash
cd bedrock-starter-pack
./scripts/create-new-project.sh
```

Répondre aux questions :
- Nom du projet
- Thème (Elementor/Divi/Blank)
- Type de déploiement (SSH/FTP/Docker/Aucun)

### 3. Configurer les secrets

Aller dans : `https://github.com/VOTRE-ORG/VOTRE-PROJET/settings/secrets/actions`

**Pour SSH** :
```
SSH_HOST = votre-serveur.com
SSH_USER = deploy
SSH_PRIVATE_KEY = [contenu de votre clé privée]
SSH_PATH = /var/www/html/mon-site
```

### 4. Déployer

```bash
cd ../votre-projet
git push origin main
```

✅ Le déploiement se lance automatiquement !

## 📊 Vérifier le déploiement

1. Aller sur GitHub → Actions
2. Voir le workflow en cours
3. Consulter les logs

## 🔧 Configuration SSH rapide

### Générer la clé

```bash
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key
```

### Ajouter sur le serveur

```bash
# Copier la clé publique
cat ~/.ssh/deploy_key.pub

# Sur le serveur
echo "LA_CLE_PUBLIQUE" >> ~/.ssh/authorized_keys
```

### Ajouter dans GitHub

```bash
# Copier la clé privée
cat ~/.ssh/deploy_key
```

Coller dans `Settings > Secrets > SSH_PRIVATE_KEY`

## 🎯 Types de déploiement

### SSH (Recommandé)
- ✅ Rapide
- ✅ Sécurisé
- ✅ Commandes post-déploiement

### FTP
- ✅ Hébergement mutualisé
- ✅ Simple
- ⚠️ Plus lent

### Docker
- ✅ Infrastructure moderne
- ✅ Reproductible
- ⚠️ Setup plus complexe

## 🐛 Problèmes courants

### Le workflow ne se déclenche pas
→ Vérifier que vous avez push sur `main`

### Permission denied SSH
→ Vérifier la clé privée dans les secrets

### Composer install fails
→ Vérifier composer.json et composer.lock

## 📚 Documentation complète

- [README CI/CD](docs/deployment/README.md)
- [Déploiement SSH](docs/deployment/DEPLOY-SSH.md)
- [Déploiement FTP](docs/deployment/DEPLOY-FTP.md)
- [Déploiement Docker](docs/deployment/DEPLOY-DOCKER.md)

---

**C'est tout ! Votre site se déploie automatiquement à chaque push ! 🚀**
