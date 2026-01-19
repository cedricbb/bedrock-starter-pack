# ⚡ Quick Migration Guide

Guide ultra-rapide pour migrer un WordPress vers Bedrock en 10 minutes.

## 🚀 Migration automatique

### Méthode 1 : Script automatique (Le plus simple)

```bash
# 1. Aller dans votre WordPress existant
cd /var/www/html/mon-site-wordpress

# 2. Lancer le script de migration
/chemin/vers/bedrock-starter-pack/scripts/migration/migrate-to-bedrock.sh

# 3. Répondre aux questions
# ✓ Le script fait tout automatiquement !

# 4. Aller dans le projet Bedrock créé
cd ../mon-site-bedrock

# 5. Installer et lancer
composer install
make up
make db-import file=dumps/migration-*.sql
make wp cmd="search-replace 'https://ancien.com' 'https://nouveau.arxama.local' --all-tables"
```

**C'est tout ! ✅**

---

## 📋 Checklist rapide

### Avant migration
- [ ] Sauvegarder la base de données
- [ ] Sauvegarder tous les fichiers
- [ ] Noter l'URL actuelle
- [ ] Lister les plugins actifs
- [ ] Vérifier le thème actif

### Pendant migration
- [ ] Exécuter le script de migration
- [ ] Vérifier que tous les fichiers sont copiés
- [ ] Vérifier le fichier .env créé

### Après migration
- [ ] `composer install`
- [ ] `make up`
- [ ] Importer la DB
- [ ] Search-replace des URLs
- [ ] Tester le site
- [ ] Activer les plugins
- [ ] Flush permalinks
- [ ] Tester les formulaires

---

## 🎯 Différences principales

| WordPress Classique | Bedrock |
|---------------------|---------|
| `wp-content/` | `web/app/` |
| `wp-config.php` | `.env` + `config/` |
| Core mélangé | Core dans `web/wp/` |
| Updates manuelles | Composer |

---

## ⚠️ Points d'attention

### NE PAS copier :
- ❌ `wp-admin/`
- ❌ `wp-includes/`
- ❌ Le core WordPress

### Copier uniquement :
- ✅ `wp-content/plugins/` → `web/app/plugins/`
- ✅ `wp-content/themes/` → `web/app/themes/`
- ✅ `wp-content/uploads/` → `web/app/uploads/`
- ✅ `wp-content/mu-plugins/` → `web/app/mu-plugins/`

### Convertir :
- 🔄 `wp-config.php` → `.env`
- 🔄 Salts WordPress → `.env`
- 🔄 URLs dans la DB

---

## 🐛 Dépannage rapide

### Site blanc ?
```bash
make logs-wordpress
make shell-root
chown -R www-data:www-data /var/www/html
```

### Images manquantes ?
```bash
# Vérifier les uploads
ls -la web/app/uploads/

# Mettre à jour les URLs
make wp cmd="search-replace 'OLD_URL' 'NEW_URL' --all-tables"
```

### Plugins ne marchent pas ?
```bash
make wp cmd="plugin list"
make wp cmd="plugin activate --all"
```

### Permaliens cassés ?
```bash
make wp cmd="rewrite flush"
```

---

## 💡 Après migration

### Optimisations recommandées

1. **Activer Redis**
   ```bash
   make composer cmd="require wpackagist-plugin/redis-cache"
   make wp cmd="plugin activate redis-cache"
   make wp cmd="redis enable"
   ```

2. **Setup Git**
   ```bash
   git init
   git add .
   git commit -m "Initial commit after migration"
   gh repo create
   ```

3. **CI/CD**
   - Configurer GitHub Actions
   - Setup déploiement automatique

---

## 📞 Besoin d'aide ?

Consultez la [documentation complète](README.md) pour plus de détails.

---

**Migration WordPress → Bedrock en 10 minutes ! 🚀**
