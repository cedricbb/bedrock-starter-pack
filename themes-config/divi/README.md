# 🎨 Configuration Divi

Ce guide détaille l'utilisation du starter pack avec **Divi**.

## 📦 Ce qui est requis

- **Divi Theme** (Premium - Elegant Themes) - Installation manuelle
- Licence Elegant Themes active
- Tous les plugins WordPress de base

## 🚀 Installation

### Option 1 : Installation automatique avec Divi

```bash
./scripts/install-with-theme.sh
# Choisir option 2 (Divi)
# Puis suivre les instructions pour installer Divi manuellement
```

### Option 2 : Installation manuelle complète

```bash
# 1. Copier le composer.json Divi
cp themes-config/divi/composer.json composer.json

# 2. Installer les dépendances WordPress
make composer cmd="install"

# 3. Démarrer les containers
make up

# 4. Télécharger Divi depuis Elegant Themes
# https://www.elegantthemes.com/members-area/

# 5. Installer Divi
make wp cmd="theme install /path/to/Divi.zip --activate"
```

### Installation via l'interface WordPress

1. Accéder à https://myproject.arxama.local/wp/wp-admin
2. Aller dans Apparence > Thèmes > Ajouter
3. Uploader le fichier Divi.zip
4. Activer Divi

## 🔑 Activation de la licence Divi

```bash
# Via WP-CLI
make wp cmd="divi-license-activate YOUR_API_KEY YOUR_USERNAME"

# Ou via l'interface WordPress
# Aller dans Divi > Theme Options > Updates
# Entrer votre API Key et Username
```

## 🎯 Plugins recommandés pour Divi

### Essentiels Divi
```bash
# Divi Builder (inclus dans le thème)
# Bloom - Email Opt-In Plugin (Elegant Themes)
# Monarch - Social Sharing Plugin (Elegant Themes)
```

### Extensions Divi tierces
```bash
# Divi Extended
make composer cmd="require wpackagist-plugin/divi-extended"

# Divi Toolbox
make composer cmd="require wpackagist-plugin/divi-toolbox"

# Divi Bars (bandeaux de notification)
# Installation manuelle depuis le site officiel
```

### Performance
```bash
# WP Rocket (premium - fortement recommandé avec Divi)
# LiteSpeed Cache (alternative gratuite)
make composer cmd="require wpackagist-plugin/litespeed-cache"
make wp cmd="plugin activate litespeed-cache"

# Divi Rocket (optimisation spécifique Divi)
# Installation via le site officiel
```

### SEO
```bash
# Rank Math SEO
make composer cmd="require wpackagist-plugin/seo-by-rank-math"
make wp cmd="plugin activate seo-by-rank-math"

# Yoast SEO (alternative)
make composer cmd="require wpackagist-plugin/wordpress-seo"
make wp cmd="plugin activate wordpress-seo"
```

### Formulaires
```bash
# Contact Form 7
make composer cmd="require wpackagist-plugin/contact-form-7"
make wp cmd="plugin activate contact-form-7"

# Gravity Forms (premium - recommandé)
# Installation manuelle
```

## ⚙️ Configuration recommandée

### 1. Paramètres Divi

Après installation, configurer dans WP Admin :

**Divi > Theme Options > General**
- Activer Divi Builder
- Configurer les couleurs du site
- Définir les polices par défaut

**Divi > Theme Options > Builder**
- Advanced > Static CSS File Generation : Enabled
- Advanced > Dynamic Module Framework : Enabled (Divi 4.0+)

**Divi > Theme Options > Performance**
- Enable Dynamic CSS : On
- Enable Dynamic JS Libraries : On

### 2. Configuration PHP pour Divi

Divi nécessite plus de ressources que d'autres thèmes. Le Dockerfile inclut déjà :

```ini
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 300
```

Pour les gros projets Divi, augmenter dans le `Dockerfile` :

```dockerfile
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'upload_max_filesize = 128M'; \
    echo 'post_max_size = 128M'; \
    echo 'max_execution_time = 600'; \
} > /usr/local/etc/php/conf.d/divi.ini
```

Puis reconstruire :
```bash
docker compose down
docker compose up -d --build
```

### 3. Configuration Nginx pour Divi

La configuration Nginx est déjà optimisée. Pour Divi spécifiquement :

```nginx
# Ajouter dans docker/nginx/default.conf

# Cache pour les fichiers Divi
location ~* /et-cache/ {
    expires 30d;
    add_header Cache-Control "public, immutable";
    access_log off;
}

# Cache pour les modules Divi
location ~* \.et_pb_temp {
    expires 1h;
    add_header Cache-Control "public";
}
```

## 🎨 Structure recommandée des thèmes

### Thème enfant Divi

```bash
mkdir -p web/app/themes/divi-child
cd web/app/themes/divi-child
```

**style.css**
```css
/*
Theme Name: Divi Child
Template: Divi
Description: Custom child theme for Divi
Version: 1.0.0
*/

/* Vos styles personnalisés ici */
```

**functions.php**
```php
<?php
/**
 * Divi Child Theme Functions
 */

// Charger les styles parent et enfant
add_action('wp_enqueue_scripts', function() {
    wp_enqueue_style('parent-style', 
        get_template_directory_uri() . '/style.css'
    );
    
    wp_enqueue_style('child-style',
        get_stylesheet_directory_uri() . '/style.css',
        array('parent-style'),
        wp_get_theme()->get('Version')
    );
});

// Ajouter vos hooks Divi personnalisés ici
```

**Activer le thème enfant**
```bash
make wp cmd="theme activate divi-child"
```

## 🚀 Optimisations de performance

### 1. Activer les CSS statiques de Divi

Dans **Divi > Theme Options > Builder > Advanced** :
- Static CSS File Generation : **ON**
- Combine & Minify CSS Files : **ON** (si pas de plugin de cache)

### 2. Redis Object Cache

```bash
make composer cmd="require wpackagist-plugin/redis-cache"
make wp cmd="plugin activate redis-cache"
make wp cmd="redis enable"
```

### 3. WP Rocket + Divi

Configuration optimale WP Rocket pour Divi :

**Cache**
- ✅ Enable Caching for Mobile Devices
- ✅ Enable Caching for Logged-in Users (pour les développeurs)

**File Optimization**
- ✅ Minify CSS files
- ✅ Combine CSS files (désactiver si problèmes de style)
- ✅ Optimize CSS delivery
- ⚠️ Minify JavaScript (tester, peut casser certains modules Divi)
- ❌ Combine JavaScript (peut casser Divi)

**Media**
- ✅ Enable for images
- ✅ Enable for iframes and videos
- Replace YouTube iframe with preview image : **ON**

**Exclusions à ajouter** :
```
/et-cache/
/et_pb_
/_et_dynamic_
.et-animated
```

### 4. LiteSpeed Cache (alternative gratuite)

Si vous utilisez LiteSpeed Cache au lieu de WP Rocket :

```bash
# Configuration spécifique Divi
make wp cmd="option update litespeed.conf.css-minify 1"
make wp cmd="option update litespeed.conf.css-combine 0"  # OFF pour Divi
make wp cmd="option update litespeed.conf.js-minify 0"    # OFF pour Divi
```

## 📊 Workflow de développement

### Développer localement avec Divi

```bash
# Démarrer le projet
make up

# Activer le Divi Visual Builder
# Accéder à une page et cliquer "Enable Visual Builder"

# Voir les logs en cas de problème
make logs-wordpress

# Shell pour debugging
make shell
```

### Exporter/Importer des Layouts Divi

```bash
# Export depuis l'interface Divi
# Divi > Divi Library > Export/Import

# Via WP-CLI (si vous avez Divi API)
make wp cmd="divi-export-layouts --file=layouts.json"
make wp cmd="divi-import-layouts --file=layouts.json"
```

### Déployer en production

```bash
# 1. Export de la bibliothèque Divi
# Via Divi > Divi Library > Export

# 2. Export de la DB
make db-export

# 3. Synchroniser les uploads
rsync -avz web/app/uploads/ user@production:/path/to/uploads/

# 4. Synchroniser le cache Divi
rsync -avz web/app/et-cache/ user@production:/path/to/et-cache/

# 5. Sur production
make db-import file=backup.sql
make wp cmd="search-replace 'https://myproject.arxama.local' 'https://myproject.com'"
make wp cmd="divi clear"  # Nettoyer le cache Divi
```

## 🐛 Troubleshooting Divi

### Visual Builder ne charge pas

```bash
# Vérifier les logs
make logs-wordpress

# Augmenter la mémoire PHP
# Éditer Dockerfile : memory_limit = 512M

# Nettoyer le cache
make wp cmd="cache flush"
make wp cmd="divi clear"

# Vérifier les permissions
make shell-root
chown -R www-data:www-data /var/www/html/web/app/et-cache
```

### Erreur "Update Failed" lors de la sauvegarde

```bash
# Augmenter max_input_vars dans Dockerfile
RUN echo 'max_input_vars = 3000' > /usr/local/etc/php/conf.d/divi.ini

# Reconstruire
docker compose down
docker compose up -d --build
```

### Mise à jour Divi bloquée

```bash
# Vérifier la licence
make wp cmd="divi-license-check"

# Réactiver si nécessaire
make wp cmd="divi-license-activate YOUR_API_KEY YOUR_USERNAME"

# Forcer la vérification des mises à jour
make wp cmd="transient delete update_themes"
make wp cmd="theme update divi"
```

### CSS dynamique ne se génère pas

```bash
# Vérifier les permissions sur et-cache
make shell-root
chown -R www-data:www-data /var/www/html/web/app/et-cache
chmod -R 755 /var/www/html/web/app/et-cache

# Régénérer le CSS
make wp cmd="divi clear"
```

## 📚 Ressources

- [Documentation Divi](https://www.elegantthemes.com/documentation/divi/)
- [Divi Marketplace](https://www.elegantthemes.com/marketplace/)
- [Divi Community](https://www.facebook.com/groups/DiviThemeUsers/)
- [Divi Layout Library](https://www.elegantthemes.com/layouts/)

## 🎓 Best Practices Divi

### 1. Utiliser la bibliothèque Divi

Créez des layouts, sections et modules réutilisables dans **Divi > Divi Library**.

### 2. Global Colors et Fonts

Définissez vos couleurs et polices globales dans :
**Divi > Theme Customizer > General Settings**

### 3. Modules réutilisables

Pour les éléments répétés (headers, footers, CTA), créez des :
- Global Modules (changements appliqués partout)
- Regular Modules (templates réutilisables)

### 4. Responsive Design

Toujours tester en :
- Desktop (par défaut)
- Tablet (768px)
- Mobile (480px)

Utilisez les options responsive de chaque module.

### 5. Performance

- ✅ Activer Static CSS Generation
- ✅ Utiliser Dynamic CSS
- ✅ Charger les Google Fonts localement (OMGF plugin)
- ✅ Optimiser les images avant upload
- ✅ Limiter le nombre de modules par page

## 💡 Tips & Tricks Divi

1. **Keyboard Shortcuts**
   - `Cmd/Ctrl + S` : Sauvegarder
   - `Cmd/Ctrl + Z` : Annuler
   - `Cmd/Ctrl + Shift + Z` : Refaire
   - `Cmd/Ctrl + C` : Copier un module

2. **Wireframe View** : Toggle pour voir la structure sans design

3. **Extend Styles** : Copier les styles d'un module vers d'autres

4. **Find & Replace** : Chercher et remplacer du contenu sur tout le site

5. **Revision History** : Revenir à des versions précédentes des pages

## 🔐 Sécurité

```bash
# Cacher la version de Divi
add_filter('et_get_theme_version', function() {
    return '';
});

# Désactiver Divi Builder pour certains rôles
add_filter('et_pb_is_allowed', function($allowed) {
    if (!current_user_can('administrator')) {
        return false;
    }
    return $allowed;
});
```

## 📈 Optimisation SEO avec Divi

```bash
# Installer Rank Math
make composer cmd="require wpackagist-plugin/seo-by-rank-math"
make wp cmd="plugin activate seo-by-rank-math"
```

Configuration Rank Math pour Divi :
- Schema Markup : Configurer les types de contenu
- Breadcrumbs : Activer et styliser avec Divi
- Local SEO : Pour les sites locaux

---

**Bon développement avec Divi ! 🎨**
