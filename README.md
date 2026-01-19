# 🚀 Bedrock WordPress Starter Pack

Un starter pack WordPress moderne basé sur [Roots Bedrock](https://roots.io/bedrock/), optimisé pour l'intégration avec **Arxama Stack Dev**.

## ✨ Caractéristiques

- 🎯 **Bedrock** - Structure WordPress moderne avec Composer
- 🐳 **Docker** - Environnement de développement complet
- 🔒 **HTTPS** - Intégration native avec Traefik (Arxama Stack)
- 📦 **Composer** - Gestion des dépendances PHP
- 🎨 **Vite** - Build tool moderne pour les assets
- 🗄️ **MariaDB** - Base de données (via Arxama Stack)
- 🚀 **Redis** - Cache objet (via Arxama Stack)
- 📧 **Mailhog** - Capture des emails (via Arxama Stack)
- 🔧 **WP-CLI** - Interface en ligne de commande WordPress

## 📋 Prérequis

1. **Arxama Stack Dev** doit être installé et lancé
   ```bash
   cd ../stack-dev-arxama
   make up
   ```

2. **Docker** et **Docker Compose** installés
3. **Make** installé (optionnel, mais recommandé)

## ⚡ Installation rapide

### Option 1: Installation automatique (recommandée)

```bash
# Cloner le projet
git clone <repo-url> my-wordpress-project
cd my-wordpress-project

# Lancer l'installation automatique
./scripts/install.sh
```

Le script va :
- ✅ Créer le fichier `.env` avec les salts WordPress
- ✅ Installer les dépendances Composer
- ✅ Démarrer les containers Docker
- ✅ Installer WordPress
- ✅ Ajouter l'entrée dans `/etc/hosts`

### Option 2: Installation manuelle

```bash
# 1. Créer le fichier .env
cp .env.example .env

# 2. Modifier PROJECT_NAME dans .env
nano .env  # Changer PROJECT_NAME=myproject

# 3. Générer les salts WordPress
# Aller sur https://roots.io/salts.html et copier dans .env

# 4. Ajouter au /etc/hosts
echo "127.0.0.1 myproject.arxama.local" | sudo tee -a /etc/hosts

# 5. Initialiser le projet
make init

# 6. Démarrer les containers
make up

# 7. Installer WordPress
docker compose exec wordpress wp core install \
  --url="https://myproject.arxama.local" \
  --title="My Project" \
  --admin_user="admin" \
  --admin_password="admin" \
  --admin_email="admin@myproject.local" \
  --allow-root
```

## 🎯 Accès

Après l'installation, votre site est accessible à :

- **Site web**: https://myproject.arxama.local
- **Admin**: https://myproject.arxama.local/wp/wp-admin
  - Username: `admin`
  - Password: `admin`

### Services Arxama Stack disponibles

- **Traefik Dashboard**: https://traefik.arxama.local
- **PhpMyAdmin**: https://phpmyadmin.arxama.local
- **Mailhog**: https://mailhog.arxama.local
- **PgAdmin**: https://pgadmin.arxama.local

## 🛠️ Commandes disponibles

### Gestion des containers

```bash
make up          # Démarrer les containers
make down        # Arrêter les containers
make restart     # Redémarrer les containers
make ps          # Voir l'état des containers
make logs        # Voir tous les logs
make logs-wordpress  # Logs WordPress uniquement
make logs-nginx      # Logs Nginx uniquement
```

### Accès aux containers

```bash
make shell       # Shell dans le container WordPress (user www-data)
make shell-root  # Shell dans le container WordPress (user root)
```

### Composer

```bash
make composer cmd="install"              # Installer les dépendances
make composer cmd="require vendor/package"  # Ajouter un package
make composer cmd="update"               # Mettre à jour les packages
```

### WP-CLI

```bash
make wp cmd="plugin list"                    # Lister les plugins
make wp cmd="plugin install akismet"         # Installer un plugin
make wp cmd="theme list"                     # Lister les thèmes
make wp cmd="user create john john@example.com"  # Créer un utilisateur
make wp cmd="db export dumps/backup.sql"     # Export DB via WP-CLI
```

### NPM (pour les assets front-end)

```bash
make npm cmd="install"   # Installer les dépendances Node
make npm cmd="run dev"   # Démarrer le serveur de développement
make npm cmd="run build" # Build de production
```

### Base de données

```bash
make db-export                    # Exporter la DB
make db-import file=dump.sql      # Importer une DB
```

### Nettoyage

```bash
make clean   # Supprimer containers, volumes et fichiers générés
```

## 📁 Structure du projet

```
.
├── config/                  # Configuration Bedrock
│   ├── application.php      # Config principale
│   └── environments/        # Config par environnement
│       ├── development.php
│       └── production.php
├── web/                     # Document root (exposé publiquement)
│   ├── app/                 # Contenu WordPress
│   │   ├── mu-plugins/      # Must-use plugins
│   │   ├── plugins/         # Plugins
│   │   ├── themes/          # Thèmes
│   │   └── uploads/         # Fichiers uploadés
│   ├── wp/                  # Core WordPress (géré par Composer)
│   └── index.php            # Point d'entrée WordPress
├── docker/                  # Configuration Docker
│   └── nginx/               # Config Nginx
├── scripts/                 # Scripts utiles
│   └── install.sh           # Script d'installation
├── .env.example             # Template de configuration
├── composer.json            # Dépendances PHP
├── docker-compose.yml       # Configuration Docker
├── Dockerfile               # Image PHP personnalisée
└── Makefile                 # Commandes automatisées
```

## 🔧 Configuration

### Variables d'environnement (.env)

Les principales variables à configurer :

```bash
# Nom du projet (utilisé pour le domaine et les containers)
PROJECT_NAME=myproject

# Base de données (utilise MariaDB de la stack Arxama)
DB_NAME=wordpress
DB_USER=root
DB_PASSWORD=root
DB_HOST=mariadb

# URLs
WP_HOME=https://myproject.arxama.local
WP_SITEURL=${WP_HOME}/wp

# Environnement
WP_ENV=development  # ou 'staging' ou 'production'
WP_DEBUG=true

# Redis (via stack Arxama)
REDIS_HOST=redis
REDIS_PORT=6379
```

### Changer le nom du projet

1. Modifier `PROJECT_NAME` dans `.env`
2. Mettre à jour `/etc/hosts` avec le nouveau domaine
3. Redémarrer : `make restart`

## 🔌 Installer des plugins et thèmes

### Via Composer (recommandé)

```bash
# Installer un plugin depuis WordPress.org
make composer cmd="require wpackagist-plugin/akismet"

# Installer un thème
make composer cmd="require wpackagist-theme/twentytwentythree"

# Installer un plugin premium (via URL privée)
# Ajouter le repository dans composer.json puis :
make composer cmd="require vendor/plugin-name"
```

### Via WP-CLI

```bash
# Installer et activer un plugin
make wp cmd="plugin install akismet --activate"

# Installer un thème
make wp cmd="theme install twentytwentythree"
```

### Via l'admin WordPress

En développement, vous pouvez aussi installer des plugins via l'interface d'administration WordPress (non recommandé pour la production).

## 🚀 Déploiement

Pour préparer le projet pour la production :

1. Modifier `.env` : `WP_ENV=production`
2. Désactiver le debug : `WP_DEBUG=false`
3. Générer de nouvelles salts : https://roots.io/salts.html
4. Build des assets : `make npm cmd="run build"`
5. Optimiser Composer : `make composer cmd="install --no-dev --optimize-autoloader"`

## 🐛 Debugging

### Voir les logs

```bash
# Tous les logs
make logs

# Logs WordPress/PHP
make logs-wordpress

# Logs Nginx
make logs-nginx

# Suivre les logs en temps réel
docker compose logs -f
```

### Erreurs courantes

**"Network backend not found"**
- La stack Arxama n'est pas lancée
- Solution : `cd ../arxama-stack && make up`

**"Address already in use"**
- Un autre service utilise le port
- Solution : Changer `WORDPRESS_PORT` dans `.env`

**"Error establishing database connection"**
- La base de données n'est pas prête
- Solution : Attendre quelques secondes et recharger

**Page blanche après installation**
- Vérifier les logs : `make logs-wordpress`
- Vérifier les permissions : `make shell-root` puis `chown -R www-data:www-data /var/www/html`

## 📚 Ressources

- [Documentation Bedrock](https://roots.io/bedrock/)
- [Documentation WordPress](https://developer.wordpress.org/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [Documentation Docker](https://docs.docker.com/)
- [Documentation Traefik](https://doc.traefik.io/traefik/)

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 📄 Licence

MIT License - voir le fichier LICENSE pour plus de détails.
