# 🎨 Configuration Elementor

Ce guide détaille l'utilisation du starter pack avec **Elementor**.

## 📦 Ce qui est installé

- **Hello Elementor** - Thème officiel optimisé pour Elementor
- **Elementor** (version gratuite) - Page builder
- Tous les plugins WordPress de base

## 🚀 Installation

### Option 1 : Installation automatique avec Elementor

```bash
./scripts/install-with-theme.sh
# Choisir option 1 (Elementor)
```

### Option 2 : Installation manuelle

```bash
# Copier le composer.json Elementor
cp themes-config/elementor/composer.json composer.json

# Installer les dépendances
make composer cmd="install"

# Activer le thème
make wp cmd="theme activate hello-elementor"

# Activer Elementor
make wp cmd="plugin activate elementor"
```

## 🎯 Plugins recommandés pour Elementor

### Essentiels
```bash
# Elementor Pro (nécessite licence)
# À installer manuellement depuis votre compte Elementor

# Essential Addons for Elementor
make composer cmd="require wpackagist-plugin/essential-addons-for-elementor-lite"
make wp cmd="plugin activate essential-addons-for-elementor-lite"

# Header Footer for Elementor
make composer cmd="require wpackagist-plugin/header-footer-elementor"
make wp cmd="plugin activate header-footer-elementor"
```

### Performance
```bash
# WP Rocket (premium - installation manuelle)
# LiteSpeed Cache (gratuit)
make composer cmd="require wpackagist-plugin/litespeed-cache"
make wp cmd="plugin activate litespeed-cache"

# Asset CleanUp
make composer cmd="require wpackagist-plugin/wp-asset-clean-up"
make wp cmd="plugin activate wp-asset-clean-up"
```

### SEO
```bash
# Rank Math SEO
make composer cmd="require wpackagist-plugin/seo-by-rank-math"
make wp cmd="plugin activate seo-by-rank-math"
```

### Formulaires
```bash
# Contact Form 7
make composer cmd="require wpackagist-plugin/contact-form-7"
make wp cmd="plugin activate contact-form-7"

# WPForms Lite
make composer cmd="require wpackagist-plugin/wpforms-lite"
make wp cmd="plugin activate wpforms-lite"
```

## ⚙️ Configuration recommandée

### 1. Paramètres Elementor

Après installation, configurer dans WP Admin :

**Elementor > Paramètres > Général**
- Désactiver les couleurs et polices par défaut
- Activer le mode maintenance si besoin

**Elementor > Paramètres > Avancé**
- CSS Print Method : Internal Embedding
- Optimiser le chargement des Google Fonts

### 2. Configuration PHP pour Elementor

Le Dockerfile inclut déjà des valeurs optimisées :
```ini
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 300
```

Pour augmenter si nécessaire, éditer `Dockerfile` :
```dockerfile
RUN { \
    echo 'memory_limit = 512M'; \
    echo 'upload_max_filesize = 128M'; \
    echo 'post_max_size = 128M'; \
} > /usr/local/etc/php/conf.d/elementor.ini
```

Puis reconstruire :
```bash
docker compose down
docker compose up -d --build
```

### 3. Configuration Nginx pour Elementor

La configuration Nginx est déjà optimisée dans `docker/nginx/default.conf`.

Pour améliorer les performances, ajouter le cache Nginx :
```nginx
# Ajouter dans default.conf
location ~* \.(css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 🎨 Structure recommandée des thèmes

Pour créer un thème enfant optimisé pour Elementor :

```bash
mkdir -p web/app/themes/my-elementor-theme
cd web/app/themes/my-elementor-theme
```

**style.css**
```css
/*
Theme Name: My Elementor Theme
Template: hello-elementor
Description: Custom theme for Elementor
Version: 1.0.0
*/
```

**functions.php**
```php
<?php
add_action('wp_enqueue_scripts', function() {
    wp_enqueue_style('parent-style', 
        get_template_directory_uri() . '/style.css'
    );
});

// Personnalisations Elementor
add_action('elementor/theme/register_locations', function($manager) {
    $manager->register_all_core_location();
});
```

## 🚀 Optimisations de performance

### 1. Redis Object Cache

Le projet inclut déjà Redis. Pour l'utiliser avec Elementor :

```bash
make composer cmd="require wpackagist-plugin/redis-cache"
make wp cmd="plugin activate redis-cache"
make wp cmd="redis enable"
```

### 2. Lazy loading

Elementor Pro inclut le lazy loading natif. Pour la version gratuite :

```bash
make composer cmd="require wpackagist-plugin/a3-lazy-load"
make wp cmd="plugin activate a3-lazy-load"
```

### 3. Minification CSS/JS

Avec WP Rocket (premium) ou LiteSpeed Cache (gratuit) - déjà installé.

## 📊 Workflow de développement

### Développer localement

```bash
# Démarrer le projet
make up

# Voir les logs
make logs

# Accéder au container
make shell

# Importer un design Elementor
# Aller dans WP Admin > Elementor > Tools > Import
```

### Déployer en production

```bash
# 1. Export du contenu
make wp cmd="export-elementor"

# 2. Export de la DB
make db-export

# 3. Synchroniser les fichiers
rsync -avz web/app/uploads/ user@production:/path/to/uploads/

# 4. Sur le serveur de production
make db-import file=backup.sql
make wp cmd="search-replace 'https://myproject.arxama.local' 'https://myproject.com'"
```

## 🐛 Troubleshooting Elementor

### Éditeur Elementor blanc ou erreurs

```bash
# Vérifier les logs PHP
make logs-wordpress

# Augmenter la mémoire PHP
# Éditer Dockerfile et reconstruire
```

### Impossible de sauvegarder avec Elementor

```bash
# Vérifier les permissions
make shell-root
chown -R www-data:www-data /var/www/html/web/app/uploads

# Vérifier la limite upload
docker compose exec wordpress php -i | grep upload_max_filesize
```

### Polices Google Fonts ne se chargent pas

```bash
# Vérifier la connectivité
make shell
curl -I https://fonts.googleapis.com

# Alternative : héberger localement avec OMGF
make composer cmd="require wpackagist-plugin/host-webfonts-local"
make wp cmd="plugin activate host-webfonts-local"
```

## 📚 Ressources

- [Documentation Elementor](https://elementor.com/help/)
- [Hello Theme](https://github.com/elementor/hello-theme)
- [Elementor Developers](https://developers.elementor.com/)
- [Elementor Community](https://www.facebook.com/groups/Elementors/)

## 🎓 Tutoriels recommandés

### Créer un header personnalisé
1. Installer Header Footer for Elementor
2. Créer un template de type "Header"
3. Assigner à "Entire Site"

### Optimiser les performances
1. Activer le CSS Print Method "Internal"
2. Désactiver les Google Fonts non utilisées
3. Utiliser Redis Object Cache
4. Installer WP Rocket ou LiteSpeed Cache

### Créer un thème complet
1. Créer un thème enfant de Hello Elementor
2. Utiliser Elementor Theme Builder
3. Créer des templates : Header, Footer, Archive, Single
4. Utiliser les Global Colors et Fonts

## 💡 Tips & Tricks

1. **Keyboard Shortcuts** : Cmd/Ctrl + S pour sauvegarder rapidement
2. **Templates** : Créer une bibliothèque de sections réutilisables
3. **Responsive** : Toujours tester en mobile/tablet
4. **Global Widgets** : Utiliser les Global Widgets pour les éléments répétés
5. **Custom CSS** : Préférer les classes CSS personnalisées aux !important

---

**Bon développement avec Elementor ! 🚀**
