# 📂 Correspondance WordPress → Bedrock

Guide de référence pour savoir où vont les fichiers lors de la migration.

## 🗂️ Structure des dossiers

### Vue d'ensemble

```
WordPress Classique              Bedrock
─────────────────────            ───────────────────────
/                                /
├── wp-admin/          ❌        (géré par Composer)
├── wp-includes/       ❌        (géré par Composer)
├── wp-content/        →         web/app/
│   ├── plugins/       →         web/app/plugins/
│   ├── themes/        →         web/app/themes/
│   ├── uploads/       →         web/app/uploads/
│   └── mu-plugins/    →         web/app/mu-plugins/
├── wp-config.php      →         .env + config/
├── .htaccess          →         web/.htaccess (Nginx n'en a pas besoin)
└── index.php          ❌        web/index.php (créé par Bedrock)
```

---

## 📁 Correspondance détaillée

### Core WordPress

| WordPress Classique | Bedrock | Action |
|---------------------|---------|--------|
| `wp-admin/` | `web/wp/wp-admin/` | ❌ Ne PAS copier (Composer) |
| `wp-includes/` | `web/wp/wp-includes/` | ❌ Ne PAS copier (Composer) |
| `wp-*.php` | `web/wp/wp-*.php` | ❌ Ne PAS copier (Composer) |
| `index.php` | `web/index.php` | ❌ Ne PAS copier (Bedrock le crée) |
| `xmlrpc.php` | `web/wp/xmlrpc.php` | ❌ Ne PAS copier (Composer) |

**Note** : Le core WordPress est géré par Composer dans `web/wp/`

---

### Contenu (wp-content)

| WordPress Classique | Bedrock | Action |
|---------------------|---------|--------|
| `wp-content/plugins/` | `web/app/plugins/` | ✅ COPIER |
| `wp-content/themes/` | `web/app/themes/` | ✅ COPIER |
| `wp-content/uploads/` | `web/app/uploads/` | ✅ COPIER |
| `wp-content/mu-plugins/` | `web/app/mu-plugins/` | ✅ COPIER (si existe) |
| `wp-content/languages/` | `web/app/languages/` | ✅ COPIER (si existe) |
| `wp-content/upgrade/` | ❌ | ❌ Ne PAS copier |
| `wp-content/cache/` | ❌ | ❌ Ne PAS copier |
| `wp-content/backup/` | ❌ | ❌ Ne PAS copier |

---

### Plugins spéciaux

Certains plugins peuvent être gérés par Composer :

| Plugin | Action |
|--------|--------|
| `wp-content/plugins/elementor/` | ❌ Si config Elementor (Composer) |
| `wp-content/plugins/akismet/` | ❌ Disponible via Composer |
| `wp-content/plugins/jetpack/` | ❌ Disponible via Composer |
| `wp-content/plugins/woocommerce/` | ❌ Disponible via Composer |
| Plugins custom/premium | ✅ Copier manuellement |

**Installer via Composer** :
```bash
composer require wpackagist-plugin/akismet
composer require wpackagist-plugin/jetpack
composer require wpackagist-plugin/woocommerce
```

---

### Thèmes spéciaux

| Thème | Action |
|-------|--------|
| `wp-content/themes/twentytwentyfour/` | ❌ Disponible via Composer |
| `wp-content/themes/Divi/` | ✅ Copier (thème premium) |
| Thèmes custom | ✅ Copier |
| `wp-content/themes/hello-elementor/` | ❌ Si config Elementor (Composer) |

---

### Configuration

| WordPress Classique | Bedrock | Contenu |
|---------------------|---------|---------|
| `wp-config.php` | `.env` | Variables d'environnement |
| | `config/application.php` | Config principale |
| | `config/environments/development.php` | Config dev |
| | `config/environments/production.php` | Config prod |

#### Conversion wp-config.php → .env

**wp-config.php** :
```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');
define('DB_PASSWORD', 'secret');
define('DB_HOST', 'localhost');
$table_prefix = 'wp_';

define('AUTH_KEY', 'votre-clé');
define('SECURE_AUTH_KEY', 'votre-clé');
// etc...

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
```

**.env** :
```bash
DB_NAME=wordpress
DB_USER=root
DB_PASSWORD=secret
DB_HOST=mariadb  # ou localhost
DB_PREFIX=wp_

AUTH_KEY='votre-clé'
SECURE_AUTH_KEY='votre-clé'
# etc...

WP_ENV=development
WP_DEBUG=true
WP_DEBUG_LOG=true
```

---

### Fichiers spéciaux

| WordPress Classique | Bedrock | Action |
|---------------------|---------|--------|
| `.htaccess` | `web/.htaccess` | ⚠️ Si Apache (Nginx non) |
| `robots.txt` | `web/robots.txt` | ✅ Copier si existe |
| `favicon.ico` | `web/app/themes/votre-theme/` | ✅ Via thème |
| `php.ini` | Dockerfile | ⚠️ Config PHP dans Docker |
| `.user.ini` | Dockerfile | ⚠️ Config PHP dans Docker |

---

### Fichiers à NE PAS copier

| Fichier/Dossier | Raison |
|-----------------|--------|
| `wp-content/cache/` | Cache temporaire |
| `wp-content/upgrade/` | Fichiers d'upgrade WP |
| `wp-content/backup*/` | Backups |
| `.DS_Store` | Fichiers macOS |
| `thumbs.db` | Fichiers Windows |
| `error_log` | Logs |
| `debug.log` | Logs |

---

## 🗄️ Base de données

### Aucun changement de structure

La structure de la base de données **reste identique** :

| Table | WordPress | Bedrock |
|-------|-----------|---------|
| `wp_posts` | ✅ | ✅ Identique |
| `wp_postmeta` | ✅ | ✅ Identique |
| `wp_users` | ✅ | ✅ Identique |
| `wp_options` | ✅ | ✅ Identique |
| etc. | ✅ | ✅ Identique |

**Mais** : Les URLs doivent être mises à jour avec search-replace.

---

## 🔧 Fichiers de configuration spéciaux

### Redis

**WordPress Classique** :
```php
// Dans wp-config.php
define('WP_REDIS_HOST', 'localhost');
define('WP_REDIS_PORT', 6379);
```

**Bedrock** :
```bash
# Dans .env
REDIS_HOST=redis
REDIS_PORT=6379
```

```php
// Dans config/application.php
Config::define('WP_REDIS_HOST', env('REDIS_HOST'));
Config::define('WP_REDIS_PORT', env('REDIS_PORT'));
```

---

### Multisite

**WordPress Classique** :
```php
// Dans wp-config.php
define('WP_ALLOW_MULTISITE', true);
define('MULTISITE', true);
define('SUBDOMAIN_INSTALL', false);
define('DOMAIN_CURRENT_SITE', 'example.com');
```

**Bedrock** :
```bash
# Dans .env
MULTISITE=true
SUBDOMAIN_INSTALL=false
DOMAIN_CURRENT_SITE=example.com
```

```php
// Dans config/application.php
Config::define('WP_ALLOW_MULTISITE', true);
Config::define('MULTISITE', env('MULTISITE'));
Config::define('SUBDOMAIN_INSTALL', env('SUBDOMAIN_INSTALL'));
Config::define('DOMAIN_CURRENT_SITE', env('DOMAIN_CURRENT_SITE'));
```

---

## 📊 Tailles approximatives

Estimation des tailles de fichiers à migrer :

| Élément | Taille typique |
|---------|----------------|
| Plugins | 50-500 MB |
| Thèmes | 10-100 MB |
| Uploads | 100 MB - 10 GB+ |
| Base de données | 10-500 MB |
| **Total** | **200 MB - 20 GB+** |

**Temps de copie** (dépend de la vitesse disque) :
- Local → Local : Quelques secondes à minutes
- FTP download : Minutes à heures
- SSH rsync : Rapide (quelques minutes)

---

## 🎯 Vérifications post-migration

### Structure des dossiers

Vérifier que la structure est correcte :

```bash
cd votre-projet-bedrock

# Vérifier la structure
tree -L 3 -I 'node_modules|vendor'

# Devrait ressembler à :
# .
# ├── composer.json
# ├── config/
# │   ├── application.php
# │   └── environments/
# ├── web/
# │   ├── app/
# │   │   ├── plugins/
# │   │   ├── themes/
# │   │   └── uploads/
# │   ├── index.php
# │   └── wp-config.php
# └── .env
```

### Permissions

```bash
# Vérifier les permissions
ls -la web/app/uploads/
# Devrait être accessible en écriture

# Si besoin
chown -R www-data:www-data web/app/uploads
chmod -R 755 web/app/uploads
```

### Fichiers critiques

```bash
# Vérifier que ces fichiers existent
test -f .env && echo "✓ .env" || echo "✗ .env manquant"
test -f composer.json && echo "✓ composer.json" || echo "✗ composer.json manquant"
test -f web/index.php && echo "✓ web/index.php" || echo "✗ web/index.php manquant"
test -d web/app/plugins && echo "✓ web/app/plugins" || echo "✗ web/app/plugins manquant"
test -d web/app/themes && echo "✓ web/app/themes" || echo "✗ web/app/themes manquant"
test -d web/app/uploads && echo "✓ web/app/uploads" || echo "✗ web/app/uploads manquant"
```

---

## 📚 Références rapides

### Commandes utiles

```bash
# Voir où sont les fichiers
find . -name "wp-config.php"  # Devrait être dans web/
find . -name "uploads" -type d  # Devrait être dans web/app/

# Compter les plugins
ls web/app/plugins/ | wc -l

# Compter les thèmes  
ls web/app/themes/ | wc -l

# Taille des uploads
du -sh web/app/uploads/
```

---

**Utilisez cette référence pendant la migration pour ne rien oublier ! ✅**
