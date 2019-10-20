#!/bin/bash
set -e

if [[ ! -f /etc/.setupdone ]]; then

    echo "=============================================="
    echo "               OpenSID SETUP"
    echo "=============================================="
    echo " "

    if [[ ! -f /usr/local/bin/dockerize ]]; then
        if [[ ! -f /root/dockerize.tar.gz ]]; then
            wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz -O /root/dockerize.tar.gz
        fi
        tar -C /usr/local/bin -xzvf /root/dockerize.tar.gz
        rm /root/dockerize.tar.gz
        chmod +x /usr/local/bin/dockerize
    fi

    # SETUP USER
    echo "Membuat user ${USERNAME} ..."
    mkdir -p $HOME/opensid
    addgroup -g 1000 $USERGROUP
    adduser -D -u 1000 -h $HOME -s /bin/bash -G $USERGROUP $USERNAME

    # SETUP SSH
    echo "Mengatur server SSH ..."
    /usr/bin/ssh-keygen -A
    sed -ri "s/^#Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config
    sed -ri 's/^#ListenAddress\s0+.*/ListenAddress 0\.0\.0\.0/' /etc/ssh/sshd_config
    sed -ri 's/^#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -ri 's/^#?RSAAuthentication\s+.*/RSAAuthentication yes/' /etc/ssh/sshd_config
    sed -ri 's/^#?PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    mkdir -p $HOME/.ssh

    echo "SSH Login diaktifkan pada Port : ${SSH_PORT}"
    if [[ -v SSH_PUBLIC_KEY ]]; then
        sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        echo "${SSH_PUBLIC_KEY}" > $HOME/.ssh/authorized_keys
        chmod 600 $HOME/.ssh/authorized_keys
        echo "SSH login dengan RSA Public Key diaktifkan."
    elif [[ -v SSH_PASSWORD ]]; then
        echo "$USERNAME:${SSH_PASSWORD}" | chpasswd &> /dev/null
        echo "Username : ${USERNAME}"
        echo "Password : ${SSH_PASSWORD}"
    else
        echo "$USERNAME:$USERNAME" | chpasswd &> /dev/null
        echo "Username : ${USERNAME}"
        echo "Password : ${USERNAME}"
    fi
    echo "--"

    chown -R $USERNAME:$USERGROUP $HOME/.ssh
    chmod 700 $HOME/.ssh

    # SETUP NGINX
    mkdir -p $HOME/logs
    mkdir -p /var/cache/nginx
    touch $HOME/logs/access.log
    rm /etc/nginx/conf.d/*
    chown -R $USERNAME:$USERGROUP $HOME/logs
    chown -R $USERNAME:$USERGROUP /var/lib/nginx
    chown -R $USERNAME:$USERGROUP /var/tmp/nginx
    chown -R $USERNAME:$USERGROUP /var/log/nginx
    chown -R $USERNAME:$USERGROUP /var/cache/nginx
    dockerize -template /template/nginx-conf.tmpl > /etc/nginx/nginx.conf

    # SETUP PHP
    mkdir -p /var/lib/php
    chown -R $USERNAME:$USERGROUP /var/lib/php
    rm /usr/local/etc/php-fpm.d/*.conf
    dockerize -template /template/php-fpm-pool.tmpl > /usr/local/etc/php-fpm.d/www.conf
    dockerize -template /template/php-extra.tmpl > $PHP_INI_DIR/conf.d/00-custom.ini
    dockerize -template /template/opcache.ini.tmpl > $PHP_INI_DIR/conf.d/10-opcache.ini

    if [[ -f "${PHP_INI_DIR}/php.ini-production" ]]; then
        cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
    fi

    # INSTALL OPENSID
    if [[ ! -f "${HOME}/opensid/desa/config/database.php" ]]; then
        if [[ $OPENSID_VERSION = 'latest' ]]; then
            export OPENSID_VERSION=$(curl --silent "https://api.github.com/repos/OpenSID/OpenSID/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        fi
        echo "Mengunduh OpenSID versi ${OPENSID_VERSION}"
        echo "................"
        if [[ -f /template/opensid.tar.gz ]]; then
            cp /template/opensid.tar.gz $HOME/opensid.tar.gz
        else
            curl -sS "https://codeload.github.com/OpenSID/OpenSID/tar.gz/v${OPENSID_VERSION}" -o $HOME/opensid.tar.gz
        fi
        echo "Menginstall OpenSID di ${HOME}/opensid"
        echo "................"
        rm -rf $HOME/opensid
        tar xzf $HOME/opensid.tar.gz -C $HOME
        mv $HOME/OpenSID-$OPENSID_VERSION $HOME/opensid
        mv $HOME/opensid/desa-contoh $HOME/opensid/desa
        rm -f $HOME/opensid.tar.gz
        echo "Direktori desa anda telah siap di ${HOME}/opensid/desa"
        echo "................"
        if [[ -v DATABASE_HOSTNAME && -v DATABASE_USERNAME && -v DATABASE_PASSWORD && -v DATABASE_NAME ]]; then
            dockerize -template /template/config-database.tmpl > $HOME/opensid/desa/config/database.php
            CONTOH_DATA=$(find ${HOME}/opensid -type f -name 'contoh_data_awal_*')
            echo "Membuat database contoh data awal"
            echo "................"
            mysql -u $DATABASE_USERNAME -h $DATABASE_HOSTNAME -p$DATABASE_PASSWORD \
                -e "CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME};"
            mysql --init-command="SET SESSION sql_mode='ALLOW_INVALID_DATES';" -f \
                -u $DATABASE_USERNAME -h $DATABASE_HOSTNAME -p$DATABASE_PASSWORD -D $DATABASE_NAME < $CONTOH_DATA
            chmod 440 $HOME/opensid/desa/config/database.php
            echo "----------------------------------------------------------"
            echo "SELAMAT, OpenSID berhasil di Install!"
            DATABASE_INSTALLED=1
        else
            echo "----------------------------------------------------------"
            echo "OpenSID belum terinstall dengan benar!"
            echo "Silahkan konfigurasi database secara manual dengan petunjuk dari :"
            echo "https://github.com/OpenSID/OpenSID/wiki/Panduan-Install-OpenSID#4-buat-database-sid"
            DATABASE_INSTALLED=0
        fi

        if [[ -f "${HOME}/opensid/desa/config/config.php" ]]; then
            echo "\$config['index_page'] = '';" >> $HOME/opensid/desa/config/config.php
        fi

        echo "----------------------------------------------------------"
        echo "Akses Admin Area http://${SERVER_NAME}/siteman"

        if [[ -v ADMIN_USERNAME && -v ADMIN_PASSWORD && $DATABASE_INSTALLED = '1' ]]; then
            MD5PASS=$(echo -n $ADMIN_PASSWORD | md5sum | awk '{print $1}')
            mysql -u $DATABASE_USERNAME -h $DATABASE_HOSTNAME -p"${DATABASE_PASSWORD}" -D $DATABASE_NAME \
                -e "UPDATE user SET username = '${ADMIN_USERNAME}', password = '${MD5PASS}' WHERE id = '1';"
            echo "Username : ${ADMIN_USERNAME}"
            echo "Password : ${ADMIN_PASSWORD}"
        else
            echo "Username : admin"
            echo "Password : sid304"
            echo "PERHATIAN! Setelah Login pastikan langsung mengubah password anda."
        fi
    else
        echo "----------------------------------------------------------------------------"
        echo "WARNING!!! Direktori openSID telah tersedia dan sudah terinstall sebelumnya."
        echo "----------------------------------------------------------------------------"
    fi

    chown -R $USERNAME:$USERGROUP $HOME
    echo " "
    echo " "
    echo "=============================================="
    echo "            OpenSID SETUP FINISH"
    echo "=============================================="
    echo " "

    # MARK CONTAINER AS INSTALLED
    rm -rf /template
    rm /usr/local/bin/dockerize
    touch /etc/.setupdone
fi

/usr/bin/supervisord -n -c /etc/supervisord.conf

exec "$@"
