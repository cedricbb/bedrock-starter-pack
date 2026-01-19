# 🚀 Quick Start Guide

## Installation en 3 étapes

### 1️⃣ Prérequis

Assurez-vous que la **Arxama Stack Dev** est lancée :

```bash
cd ../stack-dev-arxama
make up
```

### 2️⃣ Installation automatique

```bash
git clone <repo> my-wordpress-project
cd my-wordpress-project
./scripts/install.sh
```

### 3️⃣ C'est prêt ! 🎉

Accédez à votre site : **https://myproject.arxama.local**

- Username: `admin`
- Password: `admin`

---

## Commandes essentielles

```bash
make up      # Démarrer
make down    # Arrêter
make logs    # Voir les logs
make shell   # Accéder au container
make help    # Toutes les commandes
```

## Personnaliser le projet

1. **Changer le nom** : Éditer `PROJECT_NAME` dans `.env`
2. **Ajouter au hosts** : `echo "127.0.0.1 nouveaunom.arxama.local" | sudo tee -a /etc/hosts`
3. **Redémarrer** : `make restart`

## Installer des plugins

```bash
# Via Composer (recommandé)
make composer cmd="require wpackagist-plugin/akismet"

# Via WP-CLI
make wp cmd="plugin install akismet --activate"
```

## Problèmes courants

**Network backend not found**
→ Lancez la stack Arxama : `cd ../arxama-stack && make up`

**Database connection error**
→ Attendez que MariaDB soit prêt (30 secondes après le démarrage)

**Page blanche**
→ Vérifiez les logs : `make logs-wordpress`

---

Pour plus de détails, consultez le **[README.md](README.md)** complet.
