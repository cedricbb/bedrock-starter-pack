# 🔗 Intégration avec Arxama Stack Dev

Ce document explique comment le **Bedrock Starter Pack** s'intègre avec la **Arxama Stack Dev**.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Navigateur (HTTPS)                    │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│              Traefik (Arxama Stack Dev)                  │
│  • Reverse Proxy                                         │
│  • TLS Termination (*.arxama.local)                      │
│  • Routage par Host                                      │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│         Réseau Docker 'backend' (externe)                │
│                                                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Nginx     │  │ WordPress   │  │   Node.js   │     │
│  │  (projet)   │  │ PHP 8.2 FPM │  │   (assets)  │     │
│  └──────┬──────┘  └──────┬──────┘  └─────────────┘     │
│         │                │                               │
│         └────────────────┘                               │
│                  │                                        │
│                  ▼                                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │        Services partagés (Arxama Stack)          │   │
│  │  • MariaDB (base de données)                     │   │
│  │  • Redis (cache)                                 │   │
│  │  • MailHog (emails)                              │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Réseau Docker

Le projet utilise le réseau Docker **`backend`** fourni par Arxama Stack Dev. Ce réseau permet :

1. **Communication inter-containers** : Tous les services peuvent communiquer entre eux
2. **Isolation** : Les projets sont isolés du réseau host
3. **Résolution DNS** : Les containers se trouvent par leur nom (ex: `mariadb`, `redis`)

### Configuration

Dans `docker-compose.yml` :

```yaml
networks:
  backend:
    external: true  # Utilise le réseau existant
```

## Services Arxama Stack utilisés

### 1. MariaDB (Base de données)

- **Container** : `mariadb`
- **Host dans .env** : `DB_HOST=mariadb`
- **Port interne** : 3306
- **Accès externe** : Via PhpMyAdmin (https://phpmyadmin.arxama.local)

Le projet se connecte directement au container MariaDB :

```bash
DB_HOST=mariadb
DB_NAME=wordpress
DB_USER=root
DB_PASSWORD=root
```

### 2. Redis (Cache)

- **Container** : `redis`
- **Host dans .env** : `REDIS_HOST=redis`
- **Port interne** : 6379

Configuration WordPress pour utiliser Redis :

```php
Config::define('WP_REDIS_HOST', env('REDIS_HOST'));
Config::define('WP_REDIS_PORT', env('REDIS_PORT') ?: 6379);
```

### 3. MailHog (Capture emails)

- **Container** : `mailhog`
- **SMTP Host** : `mailhog`
- **SMTP Port** : 1025
- **Interface web** : https://mailhog.arxama.local

Configuration dans .env :

```bash
MAIL_HOST=mailhog
MAIL_PORT=1025
```

### 4. Traefik (Reverse Proxy)

Le projet utilise des **labels Traefik** pour être routé automatiquement :

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myproject.rule=Host(`myproject.arxama.local`)"
  - "traefik.http.routers.myproject.entrypoints=websecure"
  - "traefik.http.routers.myproject.tls=true"
```

**Important** : 
- Le certificat SSL wildcard `*.arxama.local` est géré par Traefik
- Aucune configuration SSL n'est nécessaire dans Nginx
- Nginx écoute sur le port 80 (HTTP interne uniquement)

## Flux de requête

1. **Navigateur** → `https://myproject.arxama.local`
2. **Traefik** détecte le Host et route vers le container `nginx`
3. **Traefik** termine le TLS (HTTPS → HTTP)
4. **Nginx** reçoit la requête en HTTP sur le port 80
5. **Nginx** transfère les requêtes PHP à `wordpress:9000` (PHP-FPM)
6. **WordPress** traite la requête et accède à `mariadb:3306` si nécessaire

## Multi-projets

Vous pouvez lancer plusieurs projets Bedrock simultanément :

```bash
# Projet 1
cd /path/to/project1
# .env: PROJECT_NAME=project1
make up

# Projet 2
cd /path/to/project2
# .env: PROJECT_NAME=project2
make up
```

Chaque projet aura son propre domaine :
- https://project1.arxama.local
- https://project2.arxama.local

Tous partagent les mêmes services (MariaDB, Redis, etc.) via le réseau `backend`.

## Prérequis avant le lancement

Avant de démarrer un projet Bedrock, assurez-vous que :

1. **Arxama Stack Dev est lancée** :
   ```bash
   cd arxama-stack
   make up
   ```

2. **Le réseau backend existe** :
   ```bash
   docker network ls | grep backend
   ```

3. **Les services sont accessibles** :
   - https://traefik.arxama.local
   - https://phpmyadmin.arxama.local
   - https://mailhog.arxama.local

## Gestion des bases de données

### Créer une base de données dédiée

Par défaut, le projet utilise `DB_NAME=wordpress`. Pour un projet spécifique :

```bash
# Accéder à MariaDB
docker exec -it mariadb mysql -uroot -proot

# Créer une base de données
CREATE DATABASE myproject_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Quitter
exit
```

Puis mettre à jour `.env` :
```bash
DB_NAME=myproject_db
```

### PhpMyAdmin

Accédez à https://phpmyadmin.arxama.local pour :
- Gérer les bases de données
- Importer/Exporter des dumps
- Exécuter des requêtes SQL

**Connexion** :
- Serveur : `mariadb`
- Utilisateur : `root`
- Mot de passe : `root`

## Gestion du cache Redis

### Installer le plugin Redis Object Cache

```bash
make composer cmd="require wpackagist-plugin/redis-cache"
make wp cmd="plugin activate redis-cache"
make wp cmd="redis enable"
```

### Vérifier la connexion Redis

```bash
docker exec -it redis redis-cli ping
# Réponse : PONG
```

## Debugging

### Vérifier la connectivité réseau

```bash
# Depuis le container WordPress
make shell
ping mariadb
ping redis
ping mailhog
```

### Tester l'envoi d'emails

```bash
# Depuis le container WordPress
make wp cmd="eval 'wp_mail(\"test@example.com\", \"Test\", \"Test email\");'"
```

Puis vérifier dans https://mailhog.arxama.local

### Logs Traefik

```bash
cd arxama-stack
make logs
```

## Limitations et considérations

1. **Volumes partagés** : MariaDB et Redis stockent leurs données dans des volumes Docker nommés (partagés entre tous les projets)

2. **Performance** : Le partage des services peut impacter les performances si trop de projets tournent simultanément

3. **Isolation** : Les projets partagent la même instance de MariaDB/Redis. Pour une isolation totale, dupliquez la stack Arxama Dev

4. **Ports** : Évitez les conflits de ports en utilisant des `PROJECT_NAME` différents

## Optimisation pour la production

Pour un déploiement en production, il est recommandé de :

1. **Utiliser des services dédiés** (non partagés)
2. **Séparer les bases de données** par projet
3. **Utiliser des credentials sécurisés**
4. **Activer SSL/TLS natif** (pas via reverse proxy)
5. **Configurer des backups automatiques**

Le starter pack est optimisé pour le développement local avec Arxama Stack Dev.

---

Pour toute question sur l'intégration, consultez :
- [Documentation Arxama Stack](../arxama-stack/README.md)
- [Documentation Traefik](https://doc.traefik.io/traefik/)
- [Documentation Docker Networks](https://docs.docker.com/network/)
