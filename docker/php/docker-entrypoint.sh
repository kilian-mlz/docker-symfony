#!/bin/bash

echo "🔄 Démarrage du script d'initialisation..."

# --- CORRECTIF RÉSEAU ---
# On force Composer à utiliser HTTPS et on augmente le timeout
composer config -g repo.packagist composer https://packagist.org
composer config -g process-timeout 2000

# 1. INSTALLATION AUTOMATIQUE
if [ ! -f "composer.json" ]; then
    echo "🚀 Aucun projet détecté. Tentative d'installation..."

    # On essaie d'installer le webapp-skeleton
    # On retire le --stability=stable strict pour laisser Composer trouver la meilleure version compatible
    composer create-project symfony/webapp-skeleton tmp_install --no-interaction

    # Si webapp-skeleton échoue (parfois capricieux), on tente le skeleton de base (plus léger)
    if [ ! -d "tmp_install" ]; then
        echo "⚠️ Webapp-skeleton introuvable, tentative avec le skeleton de base..."
        composer create-project symfony/skeleton tmp_install --no-interaction
        # Si ça marche, on ajoutera webapp plus tard
        IS_BASIC_SKELETON=1
    fi

    if [ -d "tmp_install" ]; then
        echo "📦 Déplacement des fichiers vers la racine..."
        cp -rp tmp_install/. .
        rm -rf tmp_install

        # Si on a dû utiliser le skeleton de base, on rajoute manuellement le pack webapp
        if [ "$IS_BASIC_SKELETON" = "1" ]; then
             echo "📦 Installation des composants WebApp manquants..."
             composer require webapp --no-interaction
        fi

        echo "✅ Symfony installé avec succès."
    else
        echo "❌ ÉCHEC TOTAL : Impossible de télécharger Symfony."
        echo "💡 Conseil : Vérifiez que vous avez bien ajouté 'dns: - 8.8.8.8' dans docker-compose.yml"
        exit 1
    fi
fi

# 2. INSTALLATION DES VENDORS
if [ -f "composer.json" ] && [ ! -d "vendor" ]; then
    echo "📦 Installation des dépendances..."
    composer install --prefer-dist --no-progress --no-interaction
fi

# 3. ATTENTE DE LA BDD
echo "⏳ Attente de MariaDB..."
until php -r "try { new PDO('mysql:host=db;dbname=${MYSQL_DATABASE}', '${MYSQL_USER}', '${MYSQL_PASSWORD}'); } catch (PDOException \$e) { exit(1); }" > /dev/null 2>&1; do
    echo "   ... MariaDB charge ..."
    sleep 2
done
echo "✅ Base de données connectée !"

# 4. CONFIGURATION BDD
if [ -f "bin/console" ]; then
    echo "🛠 Création de la base de données..."
    php bin/console doctrine:database:create --if-not-exists --no-interaction

    echo "🛠 Migration des données..."
    php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration
fi

if [ -d "var" ]; then
    chmod -R 777 var
fi

echo "🚀 PRÊT À CODER ! Serveur accessible sur http://localhost:8080"

exec docker-php-entrypoint php-fpm