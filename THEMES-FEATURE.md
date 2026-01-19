# 🎨 Nouveauté : Support Multi-Thèmes Starter

## 📢 Annonce

Le **Bedrock Starter Pack** supporte maintenant **3 configurations de thèmes** au moment de l'installation !

Vous pouvez désormais choisir entre :
- **Elementor** (gratuit)
- **Divi** (premium)
- **Blank** (base minimale)

## 🚀 Comment ça marche

### Installation rapide

```bash
./scripts/install-with-theme.sh
```

Le script vous demande de choisir votre thème :

```
📦 Choisissez votre thème starter :

  1) Elementor - Hello Elementor + Elementor plugin (gratuit)
  2) Divi - Divi theme (premium - installation manuelle)
  3) Blank - Installation basique sans thème

Votre choix [1-3]: _
```

Ensuite, le script :
1. ✅ Configure le `composer.json` approprié
2. ✅ Installe les dépendances
3. ✅ Lance les containers Docker
4. ✅ Active le thème et les plugins
5. ✅ Configure WordPress

## 📦 Ce qui a été ajouté

### Nouveaux fichiers

```
bedrock-starter-pack/
├── 📄 THEMES.md                          # Guide de sélection des thèmes
├── scripts/
│   └── install-with-theme.sh             # Script d'installation interactif
└── themes-config/                        # Configurations par thème
    ├── elementor/
    │   ├── composer.json                 # Dépendances Elementor
    │   └── README.md                     # Guide Elementor (100+ lignes)
    ├── divi/
    │   ├── composer.json                 # Dépendances Divi
    │   └── README.md                     # Guide Divi (150+ lignes)
    └── blank/
        └── README.md                     # Guide développement custom (200+ lignes)
```

### Documentation complète

Chaque thème dispose de sa propre documentation détaillée incluant :

- ✅ Instructions d'installation
- ✅ Plugins recommandés
- ✅ Configurations optimales
- ✅ Best practices
- ✅ Optimisations de performance
- ✅ Troubleshooting
- ✅ Ressources d'apprentissage
- ✅ Tips & tricks

## 🎯 Détails des configurations

### 1. Elementor (Gratuit)

**Inclus automatiquement :**
- Hello Elementor theme (officiel)
- Elementor plugin (gratuit)

**Installation :**
```bash
./scripts/install-with-theme.sh
# Choisir option 1
```

**Résultat :**
Site prêt avec Elementor activé et configuré.

**Documentation :** [themes-config/elementor/README.md](themes-config/elementor/README.md)

---

### 2. Divi (Premium - 89$/an)

**Prérequis :**
- Licence Elegant Themes active
- Fichier Divi.zip téléchargé

**Installation :**
```bash
./scripts/install-with-theme.sh
# Choisir option 2
# Suivre les instructions pour installer Divi
```

**Résultat :**
Site prêt, Divi doit être installé manuellement.

**Documentation :** [themes-config/divi/README.md](themes-config/divi/README.md)

---

### 3. Blank (Gratuit)

**Inclus automatiquement :**
- Twenty Twenty-Four (thème WordPress par défaut)
- Dépendances minimales

**Installation :**
```bash
./scripts/install-with-theme.sh
# Choisir option 3
```

**Résultat :**
Installation basique, prête pour développement custom.

**Documentation :** [themes-config/blank/README.md](themes-config/blank/README.md)

## 📚 Guide THEMES.md

Un nouveau fichier `THEMES.md` a été créé pour aider à choisir le bon thème :

- 🎯 Description de chaque option
- ✅ Avantages et inconvénients
- 📊 Tableau comparatif
- 💡 Recommandations par type de projet
- 🎓 Ressources d'apprentissage
- ❓ FAQ

## 🔧 Personnalisation

### Installation manuelle avec un thème spécifique

```bash
# Pour Elementor
cp themes-config/elementor/composer.json composer.json
make init
make up

# Pour Divi
cp themes-config/divi/composer.json composer.json
make init
make up
# Puis installer Divi manuellement

# Pour Blank
# Utiliser le composer.json par défaut
make init
make up
```

### Changer de thème après installation

```bash
# Copier la nouvelle config
cp themes-config/elementor/composer.json composer.json

# Mettre à jour les dépendances
make composer cmd="update"

# Activer le nouveau thème
make wp cmd="theme activate hello-elementor"
make wp cmd="plugin activate elementor"
```

## 💼 Cas d'usage

### Agence qui développe avec Elementor

```bash
# Configuration par défaut pour tous les projets
cp themes-config/elementor/composer.json composer.json.default

# Pour chaque nouveau projet
cp composer.json.default composer.json
make init
```

### Agence avec licence Divi

```bash
# Configuration Divi par défaut
cp themes-config/divi/composer.json composer.json.default

# Script automatisé
./scripts/install-with-theme.sh
# → Choisir Divi
# → Installer Divi.zip automatiquement depuis un répertoire partagé
```

### Développeur freelance full-stack

```bash
# Commencer avec Blank pour contrôle total
./scripts/install-with-theme.sh
# → Choisir Blank
# → Créer un thème custom from scratch
```

## 🎓 Exemples d'utilisation

### Exemple 1 : Site vitrine Elementor

```bash
cd projets
git clone <repo> site-vitrine-client
cd site-vitrine-client

# Choisir Elementor
./scripts/install-with-theme.sh

# Installer des plugins additionnels
make composer cmd="require wpackagist-plugin/essential-addons-for-elementor-lite"
make wp cmd="plugin activate essential-addons-for-elementor-lite"
```

### Exemple 2 : Site d'agence avec Divi

```bash
cd projets
git clone <repo> site-agence
cd site-agence

# Choisir Divi
./scripts/install-with-theme.sh

# Copier Divi depuis le dossier partagé
cp ~/licenses/Divi.zip /tmp/
make wp cmd="theme install /tmp/Divi.zip --activate"

# Activer la licence
make wp cmd="divi-license-activate YOUR_API_KEY YOUR_USERNAME"
```

### Exemple 3 : Application web custom

```bash
cd projets
git clone <repo> webapp-custom
cd webapp-custom

# Choisir Blank
./scripts/install-with-theme.sh

# Installer Timber pour templates Twig
make composer cmd="require timber/timber"

# Créer un thème custom
mkdir -p web/app/themes/webapp-theme
# Développer le thème...
```

## 📈 Roadmap

### Prochains thèmes à supporter

- [ ] **Oxygen Builder** (premium)
- [ ] **Bricks Builder** (premium)
- [ ] **GeneratePress** (gratuit/premium)
- [ ] **Kadence** (gratuit/premium)
- [ ] **Astra** (gratuit/premium)
- [ ] **Gutenberg FSE** (Full Site Editing)
- [ ] **Headless** (avec Next.js/React)

### Améliorations prévues

- [ ] Détection automatique de licence Divi
- [ ] Installation Divi depuis URL privée
- [ ] Templates de projets pré-configurés
- [ ] Intégration avec Elementor Cloud
- [ ] Support multisite WordPress

## 🎯 Bénéfices

### Pour les développeurs

- ✅ Gain de temps sur l'installation
- ✅ Configuration optimale garantie
- ✅ Documentation complète
- ✅ Bonnes pratiques intégrées

### Pour les agences

- ✅ Standardisation des projets
- ✅ Onboarding rapide des nouveaux dev
- ✅ Support de plusieurs workflows
- ✅ Maintenance simplifiée

### Pour les clients

- ✅ Sites plus rapides et optimisés
- ✅ Éditeur intuitif (Elementor/Divi)
- ✅ Infrastructure professionnelle
- ✅ Sécurité renforcée

## 📊 Statistiques

Grâce à cette mise à jour :

- **3 configurations** de thèmes supportées
- **450+ lignes** de documentation ajoutées
- **0 breaking changes** (rétrocompatible)
- **1 commande** pour installer avec le thème de votre choix

## 🔗 Liens utiles

- [THEMES.md](THEMES.md) - Guide complet de sélection
- [themes-config/elementor/README.md](themes-config/elementor/README.md) - Doc Elementor
- [themes-config/divi/README.md](themes-config/divi/README.md) - Doc Divi
- [themes-config/blank/README.md](themes-config/blank/README.md) - Doc Blank
- [CHANGELOG.md](CHANGELOG.md) - Historique complet

## 💬 Feedback

Cette fonctionnalité est en constante amélioration. Vos retours sont précieux :

- 📧 Email : dev@arxama.com
- 💬 Issues GitHub : [github.com/arxama/bedrock-starter/issues]
- 💡 Suggestions de thèmes à ajouter : toujours bienvenues !

---

**La flexibilité et la puissance d'un starter pack professionnel ! 🚀**
