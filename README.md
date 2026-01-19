# 🚀 Symfony Docker Starter (Zero Config)

Ce projet fournit un environnement de développement **automatisé** pour Symfony 6/7.
Il est conçu pour être "Plug & Play" : au premier lancement, il détecte l'absence de projet, installe Symfony, configure la base de données et lance le serveur sans intervention humaine.

## 🛠 La Stack Technique

* **Nginx** (Alpine) : Serveur Web performant.
* **PHP 8.2 FPM** : Moteur PHP avec extensions requises (Intl, PDO, Zip, Opcache).
* **MariaDB 10.6** : Base de données.
* **phpMyAdmin** : Interface de gestion SQL.
* **Script d'auto-provisionning** : Entrypoint Bash personnalisé.

## 📋 Prérequis

* **Docker Desktop** (Mac/Windows) ou Docker Engine (Linux).
* **Ports disponibles** : 8080 (Web) et 8081 (PMA).

> **🍎 Note pour les utilisateurs macOS :**
> Pour des performances optimales lors de l'installation des vendors, activez **VirtioFS** dans *Docker Desktop > Settings > Resources > File sharing*.

## ⚡️ Installation & Démarrage

1.  **Cloner ou créer les fichiers** du projet.
2.  **Lancer l'environnement** :

    ```bash
    docker-compose up -d --build
    ```

3.  **Attendre l'initialisation** (1 à 3 minutes).
    * Docker va télécharger les images.
    * Le script va télécharger Symfony et installer les dépendances (Composer).
    * Vous pouvez suivre la progression avec :
        ```bash
        docker logs -f auto_symfony_php
        ```

4.  **Accéder au projet** :
    * Une fois les logs indiquant "Prêt à coder !", ouvrez **[http://localhost:8080](http://localhost:8080)**.

---

## 🧠 Comment ça marche ? (L'automatisation)

Ce projet utilise un `entrypoint` personnalisé (`docker/php/docker-entrypoint.sh`). À chaque démarrage du conteneur PHP, le script effectue les vérifications suivantes :

1.  **Check du projet** : Si le dossier est vide (pas de `composer.json`), il télécharge le squelette `symfony/webapp-skeleton`.
2.  **Dépendances** : Si le dossier `vendor` est manquant, il lance `composer install`.
3.  **Attente BDD** : Il ping le service `db` jusqu'à ce qu'il soit prêt à accepter des connexions.
4.  **Setup BDD** : Il lance les commandes `doctrine:database:create` et `migrations:migrate` automatiquement.
5.  **Démarrage** : Il lance enfin `php-fpm`.

## ⚙️ Configuration & Base de Données

La connexion à la base de données est **injectée dynamiquement** via les variables d'environnement Docker.

**⚠️ Important :** Vous n'avez PAS besoin de modifier le fichier `.env` situé à la racine du code Symfony. Docker force la configuration suivante :

* **Host** : `db` (Nom du service Docker)
* **Database** : `app_db`
* **User** : `app_user`
* **Password** : `app_pass`
* **URL (Injectée)** : `mysql://app_user:app_pass@db:3306/app_db`

Pour accéder à la base de données via une interface graphique :
👉 **phpMyAdmin** : [http://localhost:8081](http://localhost:8081)

---

## 💻 Commandes Utiles

Pour exécuter des commandes Symfony, il faut passer par le conteneur PHP.

**Ouvrir un terminal dans le conteneur (recommandé) :**
```bash
docker exec -it auto_symfony_php bash
# Une fois dedans, vous pouvez taper directement :
# php bin/console make:entity
# composer require symfony/profiler