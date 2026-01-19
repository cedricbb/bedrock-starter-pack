# 🔄 Migration WordPress → Bedrock

Guide complet pour migrer vos sites WordPress existants vers Bedrock.

## ⚠️ Important : Ce n'est PAS un simple copier-coller

La migration nécessite plusieurs étapes car Bedrock a une **structure différente** :

### Structure WordPress classique
```
wordpress/
├── wp-admin/
├── wp-content/
│   ├── plugins/
│   ├── themes/
│   └── uploads/
├── wp-includes/
└── wp-config.php
```

### Structure Bedrock
```
bedrock/
├── web/
│   ├── app/           ← wp-content renommé
│   │   ├── plugins/
│   │   ├── themes/
│   │   └── uploads/
│   └── wp/            ← WordPress core (géré par Composer)
├── vendor/            ← Dépendances Composer
├── config/            ← Configuration (au lieu de wp-config.php)
└── .env               ← Variables d'environnement
```

---

## 🚀 Migration automatique (Recommandée)

### Script de migration

Nous avons créé un **script automatique** qui fait tout pour vous :

```bash
cd votre-wordpress-actuel
/chemin/vers/bedrock-starter-pack/scripts/migration/migrate-to-bedrock.sh
```

**Ce que fait le script** :
1. ✅ Détecte votre installation WordPress
2. ✅ Analyse les plugins (Elementor, Divi, etc.)
3. ✅ Extrait la configuration de `wp-config.php`
4. ✅ Crée la structure Bedrock
5. ✅ Migre tous les fichiers au bon endroit
6. ✅ Copie les salts WordPress
7. ✅ Exporte la base de données
8. ✅ Crée le fichier `.env`
9. ✅ Génère un fichier `MIGRATION-NOTES.md` avec les prochaines étapes
10. ✅ (Optionnel) Crée le repo GitHub

### Exemple d'utilisation

```bash
# 1. Aller dans votre WordPress existant
cd /var/www/html/mon-vieux-site

# 2. Lancer la migration
/chemin/vers/bedrock-starter-pack/scripts/migration/migrate-to-bedrock.sh

# Le script vous pose des questions :
# Nom du projet: mon-site-bedrock
# Configuration: 1 (Elementor détecté)
# Ancienne URL: https://ancien-site.com
# Nouvelle URL: mon-site.arxama.local

# 3. Le script fait tout automatiquement !
```

---

## 📋 Migration manuelle (Étape par étape)

Si vous préférez migrer manuellement ou comprendre le processus :

### 1. Créer le projet Bedrock

```bash
cd bedrock-starter-pack
./scripts/create-new-project.sh
# Ou copier le starter pack manuellement
```

### 2. Copier les fichiers

**Plugins** :
```bash
# WordPress classique
cp -r wp-content/plugins/* ../mon-bedrock/web/app/plugins/

# Sauf ceux gérés par Composer (Elementor, etc.)
```

**Thèmes** :
```bash
cp -r wp-content/themes/* ../mon-bedrock/web/app/themes/
```

**Uploads** :
```bash
cp -r wp-content/uploads/* ../mon-bedrock/web/app/uploads/
```

**MU-Plugins** (si existants) :
```bash
cp -r wp-content/mu-plugins/* ../mon-bedrock/web/app/mu-plugins/
```

### 3. Convertir wp-config.php en .env

**Ancien (wp-config.php)** :
```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');
define('DB_PASSWORD', 'password');
define('DB_HOST', 'localhost');
$table_prefix = 'wp_';
```

**Nouveau (.env)** :
```bash
DB_NAME=wordpress
DB_USER=root
DB_PASSWORD=password
DB_HOST=mariadb  # ou localhost selon votre setup
DB_PREFIX=wp_
```

**Copier les salts** :
```bash
# Copier les lignes AUTH_KEY, SECURE_AUTH_KEY, etc. de wp-config.php
# Les ajouter dans .env avec le format:
AUTH_KEY='votre-clé-ici'
SECURE_AUTH_KEY='votre-clé-ici'
# etc.
```

### 4. Configurer les URLs

Dans `.env` :
```bash
WP_HOME=https://nouveau-site.arxama.local
WP_SITEURL=${WP_HOME}/wp
```

### 5. Exporter/Importer la base de données

**Export** :
```bash
# Depuis l'ancien site
mysqldump -u root -p wordpress > migration.sql
# OU avec WP-CLI
wp db export migration.sql
```

**Import** :
```bash
# Dans le projet Bedrock
make db-import file=migration.sql
```

### 6. Mettre à jour les URLs dans la DB

```bash
make wp cmd="search-replace 'https://ancien-site.com' 'https://nouveau-site.arxama.local' --all-tables"
```

### 7. Installer Composer

```bash
composer install
```

### 8. Lancer le projet

```bash
make up
```

---

## 🎯 Cas d'usage spécifiques

### Migration avec Elementor

**Si Elementor est installé** :

1. Utiliser la configuration Elementor :
   ```bash
   cp themes-config/elementor/composer.json composer.json
   ```

2. Composer installe automatiquement Elementor

3. Ne PAS copier le dossier `wp-content/plugins/elementor`

4. Après import DB :
   ```bash
   make wp cmd="plugin activate elementor"
   make wp cmd="elementor flush-css"
   ```

---

### Migration avec Divi

**Si Divi est installé** :

1. Utiliser la configuration Divi :
   ```bash
   cp themes-config/divi/composer.json composer.json
   ```

2. **Important** : Divi doit être installé manuellement (thème premium)
   ```bash
   # Copier le thème Divi
   cp -r /ancien/wp-content/themes/Divi web/app/themes/
   
   # OU l'installer via WP-CLI
   make wp cmd="theme install /chemin/vers/Divi.zip --activate"
   ```

3. Réactiver la licence Divi après migration

---

### Migration avec plugins custom

**Plugins non disponibles sur WordPress.org** :

```bash
# Copier les plugins custom
cp -r wp-content/plugins/mon-plugin-custom web/app/plugins/

# Ou les ajouter au composer.json
{
  "repositories": [
    {
      "type": "path",
      "url": "web/app/plugins/mon-plugin-custom"
    }
  ],
  "require": {
    "custom/mon-plugin-custom": "*"
  }
}
```

---

### Migration avec multisite

**WordPress Multisite** nécessite une configuration spéciale :

1. Dans `config/application.php`, ajouter :
   ```php
   Config::define('WP_ALLOW_MULTISITE', true);
   Config::define('MULTISITE', true);
   Config::define('SUBDOMAIN_INSTALL', false); // ou true selon votre config
   Config::define('DOMAIN_CURRENT_SITE', 'monsite.com');
   Config::define('PATH_CURRENT_SITE', '/');
   Config::define('SITE_ID_CURRENT_SITE', 1);
   Config::define('BLOG_ID_CURRENT_SITE', 1);
   ```

2. Migrer TOUS les uploads de tous les sous-sites

---

### Migration depuis un hébergement mutualisé

**Si vous n'avez pas accès SSH** :

1. **Via FTP** :
   - Télécharger tout `wp-content/` en local
   - Utiliser phpMyAdmin pour exporter la DB
   
2. **Utiliser le script de migration en local** :
   ```bash
   # Reconstituer la structure WordPress localement
   mkdir mon-ancien-site
   cd mon-ancien-site
   # Copier wp-content téléchargé
   # Créer un wp-config.php minimal
   
   # Lancer la migration
   /chemin/vers/migrate-to-bedrock.sh
   ```

---

## ✅ Checklist post-migration

Après la migration, vérifier :

### Accès et affichage
- [ ] Site accessible sur la nouvelle URL
- [ ] Login admin fonctionne (`/wp/wp-admin`)
- [ ] Thème affiché correctement
- [ ] Pages s'affichent correctement

### Contenu
- [ ] Articles visibles
- [ ] Pages visibles
- [ ] Images des uploads visibles
- [ ] Menu(s) fonctionnel(s)
- [ ] Sidebar/Widgets affichés

### Plugins
```bash
# Lister les plugins
make wp cmd="plugin list"

# Activer tous les plugins
make wp cmd="plugin activate --all"

# Ou activer individuellement
make wp cmd="plugin activate nom-du-plugin"
```

### Permaliens
```bash
make wp cmd="rewrite flush"
```

### Cache
```bash
make wp cmd="cache flush"

# Si vous avez Redis
make wp cmd="redis enable"
```

### Formulaires
- [ ] Tester l'envoi d'un formulaire
- [ ] Vérifier dans MailHog (https://mailhog.arxama.local)

### Performance
- [ ] Installer un plugin de cache si nécessaire
- [ ] Activer Redis Object Cache
- [ ] Optimiser les images

---

## 🐛 Problèmes courants

### Site blanc / erreur 500

**Cause** : Permissions ou erreur PHP

**Solution** :
```bash
# Voir les logs
make logs-wordpress

# Corriger les permissions
make shell-root
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

---

### Images ne s'affichent pas

**Cause** : Uploads non copiés ou URLs incorrectes

**Solution** :
```bash
# Vérifier que les uploads sont présents
ls -la web/app/uploads/

# Mettre à jour les URLs des médias
make wp cmd="search-replace 'https://ancien-site.com' 'https://nouveau-site.arxama.local' --all-tables"
```

---

### Plugins ne fonctionnent pas

**Cause** : Plugins non activés

**Solution** :
```bash
# Lister les plugins
make wp cmd="plugin list"

# Activer tous
make wp cmd="plugin activate --all"

# Désactiver un plugin problématique
make wp cmd="plugin deactivate nom-plugin"
```

---

### Elementor ne charge pas

**Cause** : Cache Elementor ou données CSS

**Solution** :
```bash
make wp cmd="elementor flush-css"
make wp cmd="elementor regenerate-css"

# Nettoyer le cache
rm -rf web/app/uploads/elementor/css/*
```

---

### Divi Builder ne fonctionne pas

**Cause** : Options Divi ou cache

**Solution** :
```bash
# Nettoyer le cache Divi
rm -rf web/app/et-cache/*

# Régénérer les static CSS
make wp cmd="divi clear"

# Vérifier les permissions
chown -R www-data:www-data web/app/et-cache
```

---

### Base de données ne s'importe pas

**Cause** : Erreur de syntaxe SQL ou charset

**Solution** :
```bash
# Vérifier l'encodage
file dumps/migration.sql

# Importer avec verbose
docker exec -i mariadb mysql -uroot -proot wordpress < dumps/migration.sql

# Si erreur de charset
iconv -f ISO-8859-1 -t UTF-8 dumps/migration.sql > dumps/migration-utf8.sql
make db-import file=dumps/migration-utf8.sql
```

---

### Permaliens cassés (404)

**Cause** : Structure de permaliens non mise à jour

**Solution** :
```bash
make wp cmd="rewrite flush"

# Vérifier la configuration Nginx
make logs-nginx
```

---

## 📊 Comparaison : Avant / Après

| Aspect | WordPress classique | Bedrock |
|--------|---------------------|---------|
| **Structure** | Plate | Organisée (12-factor) |
| **Core WP** | Mélangé | Séparé dans `web/wp/` |
| **Config** | `wp-config.php` | `.env` (sécurisé) |
| **Dépendances** | Manuel | Composer |
| **Plugins** | Via admin | Composer + admin |
| **Environnements** | Difficile | Facile (dev/staging/prod) |
| **Git** | Tout commiter | Ignore core + vendor |
| **Sécurité** | Fichiers exposés | Structure protégée |
| **Déploiement** | FTP manual | CI/CD automatisé |

---

## 🎓 Pourquoi migrer vers Bedrock ?

### Avantages

1. **Sécurité** ✅
   - Config sensible dans `.env` (hors Git)
   - WordPress core dans sous-dossier
   - Meilleure séparation des responsabilités

2. **Développement moderne** ✅
   - Composer pour les dépendances
   - Structure 12-factor app
   - Environnements multiples faciles

3. **CI/CD** ✅
   - Déploiement automatisé
   - Tests automatiques
   - Git workflow propre

4. **Maintenance** ✅
   - Updates via Composer
   - Dépendances versionnées
   - Rollback facile

### Inconvénients

1. **Courbe d'apprentissage** ⚠️
   - Structure différente
   - Composer à apprendre
   - Workflow Git

2. **Migration initiale** ⚠️
   - Temps de setup
   - Vérifications nécessaires
   - Formation équipe

3. **Plugins premium** ⚠️
   - Installation manuelle souvent nécessaire
   - Licences à gérer

---

## 💡 Best Practices

### Après migration

1. **Activer Redis** pour les performances
   ```bash
   make composer cmd="require wpackagist-plugin/redis-cache"
   make wp cmd="plugin activate redis-cache"
   make wp cmd="redis enable"
   ```

2. **Configurer un plugin de cache**
   ```bash
   make composer cmd="require wpackagist-plugin/litespeed-cache"
   make wp cmd="plugin activate litespeed-cache"
   ```

3. **Mettre en place le CI/CD**
   - Créer le repo GitHub
   - Configurer les workflows
   - Setup déploiement automatique

4. **Documenter**
   - Créer un README spécifique au projet
   - Lister les plugins custom
   - Noter les configurations spéciales

5. **Tester en profondeur**
   - Tous les formulaires
   - Tous les liens
   - Toutes les fonctionnalités custom

---

## 📚 Ressources

- [Bedrock Documentation](https://roots.io/bedrock/docs/)
- [Composer for WordPress](https://composer.rarst.net/)
- [WordPress VIP Go](https://wpvip.com/documentation/vip-go/)
- [12-Factor App](https://12factor.net/)

---

## 🆘 Support

Si vous rencontrez des problèmes :

1. Consulter `MIGRATION-NOTES.md` généré par le script
2. Vérifier les logs : `make logs`
3. Consulter cette documentation
4. Ouvrir une issue sur GitHub

---

**La migration est un investissement qui en vaut la peine ! 🚀**
