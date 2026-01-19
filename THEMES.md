# 🎨 Guide des Thèmes Starter

Ce guide vous aide à choisir le bon thème starter pour votre projet WordPress.

## 📋 Options disponibles

Le Bedrock Starter Pack supporte **3 configurations de thèmes** :

### 1. 🟦 Elementor (Gratuit)

**Idéal pour :**
- Développeurs front-end qui préfèrent un page builder
- Sites vitrines et landing pages
- Clients qui veulent éditer facilement
- Projets avec beaucoup de contenu visuel

**Inclus :**
- Hello Elementor theme (officiel, léger)
- Elementor plugin (version gratuite)
- Configuration optimisée pour la performance

**Avantages :**
- ✅ 100% gratuit
- ✅ Très populaire (millions d'utilisateurs)
- ✅ Grande communauté et ressources
- ✅ Visual builder intuitif
- ✅ Responsive design facile
- ✅ Nombreux addons gratuits

**Inconvénients :**
- ⚠️ Peut être lourd (nécessite optimisation)
- ⚠️ Dépendance au plugin
- ⚠️ Fonctionnalités limitées sans la version Pro

**Upgrade disponible :**
- Elementor Pro (payant) : widgets avancés, theme builder, WooCommerce builder

---

### 2. 🟪 Divi (Premium - 89$/an)

**Idéal pour :**
- Agences WordPress professionnelles
- Projets clients haut de gamme
- Sites complexes avec beaucoup de pages
- Utilisateurs qui veulent le meilleur visual builder

**Inclus :**
- Divi theme (premium)
- Divi Builder (intégré)
- Licence Elegant Themes requise

**Avantages :**
- ✅ Visual builder le plus avancé
- ✅ Design professionnel out-of-the-box
- ✅ Bibliothèque de layouts massive
- ✅ Mises à jour régulières
- ✅ Support premium
- ✅ Inclus Bloom et Monarch

**Inconvénients :**
- ⚠️ Licence payante requise (89$/an)
- ⚠️ Code moins propre qu'un thème custom
- ⚠️ Courbe d'apprentissage
- ⚠️ Installation manuelle requise

**Note importante :**
Divi est un thème premium. Vous devez :
1. Avoir une licence Elegant Themes active
2. Télécharger Divi manuellement
3. L'installer après l'installation du starter pack

---

### 3. ⚪ Blank (Gratuit)

**Idéal pour :**
- Développeurs qui codent leur thème
- Projets custom sur mesure
- Maximum de contrôle et flexibilité
- Apprentissage WordPress

**Inclus :**
- Twenty Twenty-Four (thème WordPress par défaut)
- Dépendances minimales
- Canvas vierge pour votre créativité

**Avantages :**
- ✅ 100% gratuit
- ✅ Contrôle total du code
- ✅ Performance optimale
- ✅ Aucune dépendance
- ✅ Idéal pour l'apprentissage

**Inconvénients :**
- ⚠️ Nécessite de tout coder
- ⚠️ Pas de page builder
- ⚠️ Plus de temps de développement

**Recommandé avec :**
- Timber (templates Twig)
- Underscores starter theme
- Sage (Roots framework)
- Tailwind CSS ou Bootstrap

---

## 🤔 Comment choisir ?

### Choisissez **Elementor** si :
- ✅ Vous débutez avec WordPress
- ✅ Vous voulez un builder gratuit
- ✅ Le client veut éditer le site lui-même
- ✅ Vous avez un budget limité
- ✅ Vous voulez démarrer rapidement

### Choisissez **Divi** si :
- ✅ Vous êtes une agence professionnelle
- ✅ Vous avez déjà une licence Elegant Themes
- ✅ Vous voulez le meilleur visual builder
- ✅ Le client a un budget pour du premium
- ✅ Vous créez des sites complexes régulièrement

### Choisissez **Blank** si :
- ✅ Vous êtes développeur full-stack
- ✅ Vous voulez un contrôle total
- ✅ Vous créez un thème custom unique
- ✅ Vous optimisez au maximum les performances
- ✅ Vous utilisez un autre page builder (Oxygen, Bricks)

---

## 📊 Comparaison détaillée

| Critère | Elementor | Divi | Blank |
|---------|-----------|------|-------|
| **Prix** | Gratuit | 89$/an | Gratuit |
| **Visual Builder** | Oui (frontend) | Oui (frontend + backend) | Non |
| **Courbe d'apprentissage** | Facile | Moyenne | Difficile |
| **Performance (out of box)** | Moyenne | Moyenne | Excellente |
| **Flexibilité design** | Élevée | Très élevée | Totale |
| **Communauté** | Très grande | Grande | Universelle |
| **Addons tiers** | Nombreux | Moyens | Illimités |
| **WooCommerce** | Bon (Pro) | Excellent | À coder |
| **SEO-friendly** | Bon | Bon | Excellent |
| **Code propre** | Moyen | Moyen | Excellent |
| **Temps de dev** | Rapide | Très rapide | Long |

---

## 🚀 Installation selon votre choix

### Installation automatique (recommandée)

```bash
./scripts/install-with-theme.sh
```

Le script vous demandera de choisir :
```
1) Elementor
2) Divi
3) Blank
```

### Installation manuelle

#### Pour Elementor
```bash
cp themes-config/elementor/composer.json composer.json
make init
make up
make wp cmd="theme activate hello-elementor"
make wp cmd="plugin activate elementor"
```

#### Pour Divi
```bash
cp themes-config/divi/composer.json composer.json
make init
make up
# Puis installer Divi manuellement
make wp cmd="theme install /path/to/Divi.zip --activate"
```

#### Pour Blank
```bash
# Utiliser le composer.json par défaut
make init
make up
```

---

## 📚 Documentation détaillée

Chaque thème a sa propre documentation :

- **[Elementor](themes-config/elementor/README.md)** - Configuration, plugins, optimisation
- **[Divi](themes-config/divi/README.md)** - Installation licence, best practices
- **[Blank](themes-config/blank/README.md)** - Créer un thème custom, frameworks

---

## 💡 Recommandations par type de projet

### Site vitrine simple
**→ Elementor** (gratuit, rapide)

### Landing page marketing
**→ Elementor ou Divi** (selon budget)

### Site corporate multi-pages
**→ Divi** (bibliothèque de layouts)

### Portfolio créatif
**→ Blank** (design unique sur mesure)

### E-commerce WooCommerce
**→ Divi** (intégration WooCommerce excellente)

### Blog/Magazine
**→ Elementor ou Blank** (selon compétences)

### Application web
**→ Blank** (avec REST API custom)

### Site multilingue
**→ Tous** (avec Polylang ou WPML)

---

## 🔄 Changer de thème après installation

Vous pouvez changer de thème après l'installation :

```bash
# Installer un nouveau thème
make composer cmd="require wpackagist-theme/nouveau-theme"
make wp cmd="theme activate nouveau-theme"

# Ou remplacer le composer.json
cp themes-config/elementor/composer.json composer.json
make composer cmd="update"
```

⚠️ **Attention** : Changer de page builder (Elementor ↔ Divi) peut casser le contenu existant.

---

## 🎓 Ressources d'apprentissage

### Elementor
- [Documentation officielle](https://elementor.com/help/)
- [Elementor Academy](https://academy.elementor.com/)
- [YouTube - Elementor](https://www.youtube.com/user/elementorbuilder)

### Divi
- [Divi Documentation](https://www.elegantthemes.com/documentation/divi/)
- [Divi Space](https://divi.space/)
- [YouTube - Elegant Themes](https://www.youtube.com/user/elegantthemes)

### Développement WordPress
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [WPBeginner](https://www.wpbeginner.com/)
- [Roots Documentation](https://roots.io/docs/)

---

## 🆘 Support et aide

### Pour Elementor
- Forum officiel : [Elementor Community](https://www.facebook.com/groups/Elementors/)
- Support : [Elementor Support](https://elementor.com/support/)

### Pour Divi
- Forum officiel : [Elegant Themes Forum](https://www.elegantthemes.com/forum/)
- Support : Inclus avec la licence
- Facebook : [Divi Theme Users](https://www.facebook.com/groups/DiviThemeUsers/)

### Pour WordPress/Bedrock
- [WordPress Support](https://wordpress.org/support/)
- [Roots Discourse](https://discourse.roots.io/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/wordpress)

---

## 🔮 Évolutions futures

Le starter pack évoluera pour supporter :
- [ ] Gutenberg amélioré (Full Site Editing)
- [ ] Oxygen Builder
- [ ] Bricks Builder
- [ ] GeneratePress
- [ ] Thèmes headless (avec Next.js / React)

---

## ❓ FAQ

### Puis-je utiliser plusieurs thèmes dans le même projet ?
Non, WordPress ne supporte qu'un thème actif à la fois. Cependant, vous pouvez avoir plusieurs thèmes installés et basculer entre eux.

### Elementor Pro en vaut-il la peine ?
Si vous créez des sites professionnels régulièrement, oui. Le Theme Builder et les widgets avancés sont très utiles.

### Puis-je migrer d'Elementor vers Divi ?
Techniquement oui, mais vous devrez reconstruire tout le contenu. La migration est manuelle.

### Comment optimiser les performances avec un page builder ?
1. Utiliser Redis (déjà configuré)
2. Installer WP Rocket ou LiteSpeed Cache
3. Optimiser les images
4. Utiliser un CDN
5. Activer le CSS statique (Divi) ou minifier (Elementor)

### Quel thème est le plus rapide ?
Un thème custom (Blank) bien codé sera toujours le plus rapide. Entre Elementor et Divi, les performances sont similaires avec une bonne optimisation.

---

**Choisissez le thème qui correspond à vos compétences et aux besoins du projet ! 🚀**
