# 🎨 Configuration Blank (Starter basique)

Ce guide détaille l'utilisation du starter pack avec une **installation basique** sans thème spécifique.

## 📦 Ce qui est installé

- **Twenty Twenty-Four** - Thème WordPress par défaut (block-based)
- WordPress Core
- Dépendances Bedrock de base
- Aucun page builder

## 🚀 Installation

### Installation automatique

```bash
./scripts/install-with-theme.sh
# Choisir option 3 (Blank)
```

### Installation manuelle

```bash
# Utiliser le composer.json par défaut
make init
make up
```

## 🎯 Pour qui est cette option ?

Cette option est idéale si vous souhaitez :

1. **Développer un thème custom** from scratch
2. **Utiliser un autre page builder** (Oxygen, Bricks, etc.)
3. **Avoir un contrôle total** sur les dépendances
4. **Partir d'une base minimale** et ajouter ce dont vous avez besoin

## 🛠️ Créer votre propre thème

### Structure de base

```bash
mkdir -p web/app/themes/mon-theme
cd web/app/themes/mon-theme
```

### Fichiers minimaux requis

**style.css**
```css
/*
Theme Name: Mon Thème Custom
Author: Votre Nom
Description: Description de votre thème
Version: 1.0.0
Requires at least: 6.0
Tested up to: 6.7
Requires PHP: 8.0
License: MIT
*/
```

**index.php**
```php
<?php get_header(); ?>

<main>
    <?php
    if (have_posts()) :
        while (have_posts()) : the_post();
            the_content();
        endwhile;
    endif;
    ?>
</main>

<?php get_footer(); ?>
```

**functions.php**
```php
<?php
/**
 * Theme Functions
 */

// Enqueue styles
add_action('wp_enqueue_scripts', function() {
    wp_enqueue_style('theme-style', get_stylesheet_uri());
});

// Theme support
add_theme_support('post-thumbnails');
add_theme_support('title-tag');
add_theme_support('automatic-feed-links');

// Register menu
register_nav_menus([
    'primary' => __('Primary Menu', 'mon-theme')
]);
```

**header.php**
```php
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<header>
    <h1><?php bloginfo('name'); ?></h1>
    <?php wp_nav_menu(['theme_location' => 'primary']); ?>
</header>
```

**footer.php**
```php
<footer>
    <p>&copy; <?php echo date('Y'); ?> <?php bloginfo('name'); ?></p>
</footer>

<?php wp_footer(); ?>
</body>
</html>
```

### Activer votre thème

```bash
make wp cmd="theme activate mon-theme"
```

## 🎨 Frameworks recommandés

### Tailwind CSS

```bash
# Installer Tailwind
make npm cmd="install -D tailwindcss postcss autoprefixer"
make npm cmd="run tailwindcss init -p"
```

**tailwind.config.js**
```javascript
module.exports = {
  content: [
    './web/app/themes/mon-theme/**/*.php',
    './web/app/themes/mon-theme/**/*.js',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

### Bootstrap

```bash
make npm cmd="install bootstrap @popperjs/core"
```

**functions.php**
```php
add_action('wp_enqueue_scripts', function() {
    wp_enqueue_style('bootstrap', 
        'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css'
    );
    wp_enqueue_script('bootstrap', 
        'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js',
        [],
        null,
        true
    );
});
```

### Timber (Twig templates)

```bash
make composer cmd="require timber/timber"
```

**functions.php**
```php
use Timber\Timber;

Timber::init();

add_filter('timber/context', function($context) {
    $context['menu'] = new Timber\Menu('primary');
    return $context;
});
```

**index.php**
```php
<?php
$context = Timber::context();
$context['posts'] = new Timber\PostQuery();
Timber::render('index.twig', $context);
```

## 🔌 Plugins recommandés

### Développement

```bash
# Query Monitor (debugging)
make composer cmd="require wpackagist-plugin/query-monitor"
make wp cmd="plugin activate query-monitor"

# Debug Bar
make composer cmd="require wpackagist-plugin/debug-bar"
make wp cmd="plugin activate debug-bar"
```

### SEO

```bash
# Rank Math
make composer cmd="require wpackagist-plugin/seo-by-rank-math"
make wp cmd="plugin activate seo-by-rank-math"
```

### Performance

```bash
# LiteSpeed Cache
make composer cmd="require wpackagist-plugin/litespeed-cache"
make wp cmd="plugin activate litespeed-cache"
```

### Sécurité

```bash
# Wordfence
make composer cmd="require wpackagist-plugin/wordfence"
make wp cmd="plugin activate wordfence"
```

## 🚀 Starter Themes recommandés

### Underscores (_s)

```bash
# Télécharger depuis underscores.me
curl -o underscores.zip https://underscores.me/?underscoresme_generate=1&underscoresme_name=mon-theme
unzip underscores.zip -d web/app/themes/
make wp cmd="theme activate mon-theme"
```

### Sage (Roots)

```bash
# Installer Sage dans web/app/themes/
composer create-project roots/sage web/app/themes/sage
cd web/app/themes/sage
composer install
npm install
npm run build
```

### GeneratePress

```bash
make composer cmd="require wpackagist-theme/generatepress"
make wp cmd="theme activate generatepress"
```

## 🎓 Workflows modernes

### Avec Vite (déjà configuré)

```bash
# Dans votre thème
cd web/app/themes/mon-theme

# Créer assets/js/main.js et assets/css/style.css

# Développement
make npm cmd="run dev"

# Production
make npm cmd="run build"
```

**functions.php pour Vite**
```php
add_action('wp_enqueue_scripts', function() {
    if (defined('WP_ENV') && WP_ENV === 'development') {
        wp_enqueue_script('vite', 
            'http://localhost:3000/@vite/client', 
            [], 
            null, 
            true
        );
        wp_enqueue_script('main', 
            'http://localhost:3000/assets/js/main.js', 
            [], 
            null, 
            true
        );
    } else {
        // Lire le manifest.json pour production
        $manifest = json_decode(
            file_get_contents(get_template_directory() . '/dist/manifest.json'),
            true
        );
        wp_enqueue_script('main', 
            get_template_directory_uri() . '/dist/' . $manifest['assets/js/main.js']['file'],
            [],
            null,
            true
        );
    }
});
```

### Avec Webpack

```bash
make npm cmd="install -D webpack webpack-cli"
# Configurer webpack.config.js selon vos besoins
```

## 📦 Alternative Page Builders

### Oxygen Builder

```bash
# Installation manuelle requise (premium)
# Télécharger depuis oxygenbuilder.com
make wp cmd="plugin install /path/to/oxygen.zip --activate"
```

### Bricks Builder

```bash
# Installation manuelle requise (premium)
# Télécharger depuis bricksbuilder.io
make wp cmd="plugin install /path/to/bricks.zip --activate"
```

### Gutenberg amélioré

```bash
# Kadence Blocks
make composer cmd="require wpackagist-plugin/kadence-blocks"
make wp cmd="plugin activate kadence-blocks"

# Spectra (Formerly Ultimate Addons for Gutenberg)
make composer cmd="require wpackagist-plugin/ultimate-addons-for-gutenberg"
make wp cmd="plugin activate ultimate-addons-for-gutenberg"
```

## 🎨 Exemples de configurations

### Site portfolio

```bash
# Custom Post Types UI
make composer cmd="require wpackagist-plugin/custom-post-type-ui"

# Advanced Custom Fields
make composer cmd="require wpackagist-plugin/advanced-custom-fields"

# Portfolio Gallery
make composer cmd="require wpackagist-plugin/portfolio-gallery"
```

### Site e-commerce

```bash
# WooCommerce
make composer cmd="require wpackagist-plugin/woocommerce"
make wp cmd="plugin activate woocommerce"

# Configuration WooCommerce
make wp cmd="wc tool run install_pages"
```

### Site multilingue

```bash
# Polylang
make composer cmd="require wpackagist-plugin/polylang"
make wp cmd="plugin activate polylang"

# WPML (premium - installation manuelle)
```

## 📚 Ressources

- [WordPress Theme Handbook](https://developer.wordpress.org/themes/)
- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- [Underscores Starter Theme](https://underscores.me/)
- [Sage Starter Theme](https://roots.io/sage/)
- [GeneratePress Theme](https://generatepress.com/)

## 💡 Tips pour démarrer

1. **Commencez simple** : Un thème minimal fonctionne mieux qu'un thème complexe
2. **Utilisez un starter** : Underscores ou Sage pour gagner du temps
3. **Child themes** : Toujours créer un thème enfant si vous modifiez un thème existant
4. **Version control** : Committez régulièrement vos changements
5. **Testez en responsive** : Dès le début du développement

## 🔧 Configuration avancée

### Custom Post Types

```php
// Dans functions.php
add_action('init', function() {
    register_post_type('projet', [
        'labels' => [
            'name' => 'Projets',
            'singular_name' => 'Projet'
        ],
        'public' => true,
        'has_archive' => true,
        'supports' => ['title', 'editor', 'thumbnail'],
        'menu_icon' => 'dashicons-portfolio'
    ]);
});
```

### REST API personnalisée

```php
add_action('rest_api_init', function() {
    register_rest_route('mon-theme/v1', '/projets', [
        'methods' => 'GET',
        'callback' => function() {
            return get_posts(['post_type' => 'projet']);
        }
    ]);
});
```

### Hooks personnalisés

```php
// Créer un hook
do_action('mon_theme_avant_header');

// Utiliser le hook
add_action('mon_theme_avant_header', function() {
    echo '<div class="announcement">Promo -20%</div>';
});
```

---

**Bonne création ! 🚀**
