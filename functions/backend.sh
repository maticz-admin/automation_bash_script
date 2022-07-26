#!/usr/bin/env bash


# -------------------------------------------------------
# ------------- Install and config backend. -------------
# -------------------------------------------------------
backend_install()
{

    if [ X"${BACKEND}" == X'NODE' ]; then

        ECHO_INFO "Installing node using nvm"
        sleep 1
        su - ${SYSTEM_ACCOUNT_NAME}
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        source ~/.bashrc
        nvm install v14.19.2
        ECHO_INFO "Installing pm2."
        npm install ${PROCESS_MANAGEMENT} -g
        exit

        ECHO_INFO "Changing folder permission"

        chown -R ${SYSTEM_ACCOUNT_NAME}:${SYS_GROUP_WEB} /var/www

        if [ X"${ssl_configuration}" == X'SSLPURCHASED' ]; then

        ECHO_INFO "add the proxy at apache2 server"

        sed -i -e '18,27 {s/#//g}' ${HTTP_CONF_DIR_AVAILABLE_SITES}/${APACHE2_CONF_SITE_DEFAULT_SSL}

        #enable http2 htaccess rewrite 
         a2enmod proxy proxy_balancer proxy_http proxy_http2 proxy_wstunnel

        # starting apache2
         ECHO_INFO "Restart service: ${APACHE2_RC_SCRIPT_NAME}."
         service_control restart ${APACHE2_RC_SCRIPT_NAME}

        elif [ X"${ssl_configuration}" == X'LETSENCRYPT' ]; then

         ECHO_INFO "add the proxy at apache2 server"

        sudo sed -i '25 i <Proxy *>\nOrder deny,allow\nAllow from all\n</Proxy>\nSSLProxyEngine On\nProxyRequests Off\nProxyPreserveHost On\nProxyPass / http://127.0.0.1:2053/\nProxyPassReverse / http://127.0.0.1:2053/\n' ${HTTP_CONF_DIR_AVAILABLE_SITES}/000-default-le-ssl.conf

        #enable http2 htaccess rewrite 
         a2enmod proxy proxy_balancer proxy_http proxy_http2 proxy_wstunnel

        # starting apache2
         ECHO_INFO "Restart service: ${APACHE2_RC_SCRIPT_NAME}."
         service_control restart ${APACHE2_RC_SCRIPT_NAME}

        fi

        echo 'export status_backend_setup="DONE"' >> ${STATUS_FILE}

    fi
    
}
