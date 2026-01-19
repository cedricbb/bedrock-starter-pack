# 🚀 Déploiement SSH

Ce guide explique comment configurer le déploiement automatique via SSH/rsync.

## 🎯 Vue d'ensemble

Le workflow SSH utilise **rsync** pour synchroniser les fichiers avec votre serveur de production via SSH.

### Avantages
- ✅ Rapide et efficace (synchronisation incrémentielle)
- ✅ Sécurisé (SSH)
- ✅ Contrôle total sur le serveur
- ✅ Support des commandes post-déploiement

### Prérequis
- Accès SSH à votre serveur
- Rsync installé sur le serveur
- Clé SSH privée

## ⚙️ Configuration

### 1. Générer une clé SSH

Sur votre machine locale :

```bash
ssh-keygen -t ed25519 -C "github-actions@yourproject.com" -f ~/.ssh/deploy_key
```

Cela crée deux fichiers :
- `deploy_key` (clé privée) - à ajouter dans GitHub Secrets
- `deploy_key.pub` (clé publique) - à ajouter sur le serveur

### 2. Ajouter la clé publique sur le serveur

```bash
# Sur le serveur
cat deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 3. Configurer les GitHub Secrets

Aller dans : `Settings > Secrets and variables > Actions > New repository secret`

Ajouter les secrets suivants :

| Secret | Description | Exemple |
|--------|-------------|---------|
| `SSH_HOST` | Hostname du serveur | `example.com` ou `192.168.1.100` |
| `SSH_USER` | Utilisateur SSH | `deploy` ou `www-data` |
| `SSH_PRIVATE_KEY` | Contenu de la clé privée | Contenu du fichier `deploy_key` |
| `SSH_PATH` | Chemin de déploiement | `/var/www/html/mon-site` |

**SSH_PRIVATE_KEY** :
```bash
# Copier le contenu de la clé privée
cat ~/.ssh/deploy_key | pbcopy  # macOS
cat ~/.ssh/deploy_key | xclip    # Linux
```

### 4. Structure sur le serveur

Le serveur doit avoir cette structure :

```
/var/www/html/mon-site/
├── web/
│   ├── app/
│   │   ├── plugins/
│   │   ├── themes/
│   │   └── uploads/       # Préservé lors du deploy
│   └── wp/
├── vendor/
├── .env                    # Fichier de config (préservé)
└── ...
```

## 🔧 Configuration du serveur

### Prérequis serveur

```bash
# Installer rsync
sudo apt-get update
sudo apt-get install rsync

# Créer l'utilisateur de déploiement (optionnel)
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG www-data deploy

# Créer le répertoire de déploiement
sudo mkdir -p /var/www/html/mon-site
sudo chown deploy:www-data /var/www/html/mon-site
sudo chmod 775 /var/www/html/mon-site
```

### Configuration Nginx sur le serveur

```nginx
server {
    listen 80;
    server_name example.com;
    
    root /var/www/html/mon-site/web;
    index index.php index.html;
    
    # Inclure le reste de la config Bedrock
    include /var/www/html/mon-site/docker/nginx/default.conf;
}
```

### Configuration PHP-FPM

```bash
# S'assurer que PHP-FPM tourne
sudo systemctl status php8.2-fpm

# Configuration PHP-FPM pour Bedrock
sudo nano /etc/php/8.2/fpm/pool.d/www.conf
```

Vérifier :
```ini
user = www-data
group = www-data
listen = /run/php/php8.2-fpm.sock
```

## 🚀 Utilisation

### Déploiement automatique

Le déploiement se déclenche automatiquement lors d'un push sur `main` :

```bash
git add .
git commit -m "Deploy: nouvelle fonctionnalité"
git push origin main
```

### Déploiement manuel

Via l'interface GitHub :
1. Aller dans `Actions > Deploy to Production (SSH)`
2. Cliquer sur `Run workflow`
3. Sélectionner l'environnement (production/staging)
4. Cliquer sur `Run workflow`

### Via GitHub CLI

```bash
gh workflow run deploy-ssh.yml -f environment=production
```

## 🔄 Workflow détaillé

Le workflow exécute les étapes suivantes :

1. **Checkout** - Récupère le code
2. **Setup PHP** - Configure PHP 8.2
3. **Install Composer** - Installe les dépendances (sans dev)
4. **Setup Node** - Configure Node.js
5. **Build assets** - Compile les assets front-end
6. **Deploy via rsync** - Synchronise avec le serveur
7. **Post-deploy commands** - Exécute les commandes sur le serveur

### Fichiers exclus du déploiement

Le workflow exclut automatiquement :
- `.git/`
- `.github/`
- `node_modules/`
- `.env` et `.env.*`
- `dumps/`
- `web/app/uploads/` (uploads préservés)
- `*.log`

## 🎛️ Commandes post-déploiement

Les commandes suivantes sont exécutées automatiquement sur le serveur :

```bash
# Migrations de base de données (si configuré)
# wp db migrate --allow-root

# Vider le cache WordPress
wp cache flush --allow-root

# Mettre à jour les permissions
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```

### Personnaliser les commandes post-déploiement

Éditer `.github/workflows/deploy-ssh.yml` :

```yaml
script: |
  cd ${{ secrets.SSH_PATH }}
  
  # Vos commandes personnalisées ici
  wp cache flush --allow-root
  wp rewrite flush --allow-root
  
  # Redémarrer PHP-FPM
  sudo systemctl reload php8.2-fpm
  
  echo "✅ Deployment completed!"
```

## 🔐 Sécurité

### Bonnes pratiques

1. **Utilisateur dédié** : Créer un utilisateur `deploy` séparé
2. **Permissions restreintes** : N'autoriser que les commandes nécessaires
3. **Rotation des clés** : Changer les clés SSH régulièrement
4. **Logs** : Surveiller les logs de déploiement
5. **Firewall** : Limiter l'accès SSH aux IPs de GitHub Actions

### Restreindre l'utilisateur deploy

Créer `/home/deploy/.ssh/authorized_keys` :

```bash
command="/usr/local/bin/deploy-commands.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 AAAA...
```

Script `/usr/local/bin/deploy-commands.sh` :

```bash
#!/bin/bash
case "$SSH_ORIGINAL_COMMAND" in
    "rsync --server"*)
        $SSH_ORIGINAL_COMMAND
        ;;
    *)
        echo "Command not allowed"
        exit 1
        ;;
esac
```

## 🌍 Environnements multiples

### Configurer staging et production

**GitHub Environments** :
1. Aller dans `Settings > Environments`
2. Créer `production` et `staging`
3. Configurer les secrets pour chaque environnement

**Variables spécifiques** :

| Environment | SSH_HOST | SSH_PATH |
|-------------|----------|----------|
| production | `prod.example.com` | `/var/www/html/site` |
| staging | `staging.example.com` | `/var/www/html/staging` |

### Déployer sur staging

```bash
git push origin develop  # Si configuré
# OU
gh workflow run deploy-ssh.yml -f environment=staging
```

## 🐛 Troubleshooting

### Erreur : Permission denied (publickey)

**Cause** : La clé SSH n'est pas configurée correctement

**Solution** :
```bash
# Vérifier la clé sur le serveur
cat ~/.ssh/authorized_keys

# Vérifier les permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Tester la connexion
ssh -i deploy_key deploy@server
```

### Erreur : rsync: command not found

**Cause** : rsync n'est pas installé sur le serveur

**Solution** :
```bash
sudo apt-get update
sudo apt-get install rsync
```

### Erreur : WP-CLI not found

**Cause** : WP-CLI n'est pas installé

**Solution** :
```bash
# Installer WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Vérifier
wp --info --allow-root
```

### Le site ne se met pas à jour

**Vérifications** :
```bash
# Sur le serveur, vérifier les permissions
ls -la /var/www/html/mon-site

# Vérifier les logs Nginx
sudo tail -f /var/log/nginx/error.log

# Vérifier les logs PHP
sudo tail -f /var/log/php8.2-fpm.log

# Vérifier le .env
cat /var/www/html/mon-site/.env
```

## 📊 Monitoring

### Surveiller les déploiements

GitHub Actions fournit :
- Logs détaillés de chaque étape
- Temps d'exécution
- Statut (succès/échec)
- Historique complet

### Notifications

Ajouter des notifications Slack/Discord :

```yaml
- name: 🔔 Notify Slack
  if: success()
  uses: slackapi/slack-github-action@v1.24.0
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "✅ Deployment successful!",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Deployment to production completed\nCommit: ${{ github.sha }}"
            }
          }
        ]
      }
```

## 🎯 Optimisations

### Cache Composer

Le workflow utilise déjà le cache pour Composer :
```yaml
- uses: actions/cache@v3
  with:
    path: ${{ steps.composer-cache.outputs.dir }}
    key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
```

### Déploiement parallèle

Pour déployer sur plusieurs serveurs :

```yaml
deploy:
  strategy:
    matrix:
      server: [server1, server2, server3]
  steps:
    - name: Deploy to ${{ matrix.server }}
      # ...
```

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Rsync Documentation](https://rsync.samba.org/)
- [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
- [Bedrock Deployment](https://roots.io/bedrock/docs/deployment/)

---

**Bon déploiement ! 🚀**
