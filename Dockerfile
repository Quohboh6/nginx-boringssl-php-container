FROM ubuntu:24.04
    
ENV DEBIAN_FRONTEND=noninteractive
    
RUN    export NGINX_VERSION=1.27.3 \
    && export WWW_DATA_FIXED_GID=55009 \
    && export WWW_DATA_FIXED_UID=55009 \
    && echo "###############################################" \
    && echo " Using Nginx version ${NGINX_VERSION}" \
    && echo "###############################################" \
    && sleep 4 \
    && echo " System update and upgrade" \
    && echo "###############################################" \
    && sleep 4 \
    && apt-get update \
    && apt-get upgrade -y \
    && echo "###############################################" \
    && echo " Set time zone" \
    && echo "###############################################" \
    && sleep 4 \
    && ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime \
    && echo "Europe/London" > /etc/timezone \
    && apt-get install -y tzdata \
    && dpkg-reconfigure -f noninteractive tzdata \
    && echo "###############################################" \
    && echo " Installing packages" \
    && echo "###############################################" \
    && sleep 4 \
    && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    gnupg \
    libpcre3-dev \
    zlib1g-dev \
    libunwind-dev \
    libgd-dev \
    libgeoip-dev \
    libaio-dev \
    libgd-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    pkg-config \
    software-properties-common \
    php-cli \
    php-fpm \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    php-gd \
    php-pgsql \
    php-mysql \
    cron \
    jq \
    && echo "###############################################" \
    && sleep 4 \
    && echo " We change the standard GID and UID for" \
    && echo " the www-data user and group so that" \
    && echo " they do not overlap with the same ones" \
    && echo " in the host system." \
    && echo "###############################################" \
    && sleep 4 \
    && apt-get install -y adduser \
    && groupdel www-data || true \
    && deluser www-data || true \
    && groupadd -g ${WWW_DATA_FIXED_GID} www-data \
    && useradd -u ${WWW_DATA_FIXED_UID} -g ${WWW_DATA_FIXED_GID} -d /var/www -s /usr/sbin/nologin -c "www-data" www-data \
    && mkdir -p /var/www /etc/nginx /home/www-data \
    && find /var/www /etc/nginx /home/www-data -user 33 -exec chown -h ${WWW_DATA_FIXED_UID}:${WWW_DATA_FIXED_GID} {} \; \
    && id www-data \
    && export PHP_MAJOR_MINOR=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") \
    && echo "###############################################" \
    && echo " PHP VERSION ${PHP_MAJOR_MINOR}" \
    && echo "###############################################" \
    && sleep 4 \
    && echo "###############################################" \
    && echo " Cleaning after installation" \
    && echo "###############################################" \
    && sleep 4 \
    && apt-get clean \
    && echo "###############################################" \
    && echo " Loading BoringSSL" \
    && echo "###############################################" \
    && sleep 4 \
    && git clone https://boringssl.googlesource.com/boringssl /usr/src/boringssl \
    && echo "###############################################" \
    && echo " Preparing BoringSSL for compilation" \
    && echo "###############################################" \
    && sleep 4 \
    && mkdir /usr/src/boringssl/build \
    && cd /usr/src/boringssl/build \
    && cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/boringssl .. \
    && echo "###############################################" \
    && echo " BoringSSL compilation" \
    && echo "###############################################" \
    && sleep 4 \
    && make \
    && echo "###############################################" \
    && echo " BoringSSL installation" \
    && echo "###############################################" \
    && sleep 4 \
    && make install \
    && echo "###############################################" \
    && echo " Copy the BoringSSL crypto libraries" \
    && echo " to .openssl/lib so nginx can find the" \
    && echo "###############################################" \
    && sleep 4 \
    && mkdir -p /usr/src/boringssl/.openssl/ \
    && mkdir -p /usr/src/boringssl/.openssl/lib \
    && cd /usr/src/boringssl/.openssl \
    && ln -s ../include include \
    && cd /usr/src/boringssl \
    && cp build/crypto/libcrypto.a .openssl/lib \
    && cp build/ssl/libssl.a .openssl/lib \
    && cd /usr/src \
    && echo "###############################################" \
    && echo " Make the necessary directories to prepare" \
    && echo " for the Nginx configuration" \
    && echo "###############################################" \
    && sleep 4 \
    && mkdir -p /var/log/nginx /var/www/html /var/lib/nginx/{body,fastcgi,proxy,scgi,uwsgi,modules} \
    && chown -R www-data:www-data /var/log/nginx /var/www/html \
    && chown -R www-data:root /var/lib/nginx \
    && echo "###############################################" \
    && echo " Nginx loading and checking the checksum" \
    && echo "###############################################" \
    && sleep 4 \
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys D6786CE303D9A9022998DC6CC8464D549AF75C0A \
    && gpg --verify nginx-${NGINX_VERSION}.tar.gz.asc nginx-${NGINX_VERSION}.tar.gz \
    && tar -xvzf nginx-${NGINX_VERSION}.tar.gz \
    && echo "###############################################" \
    && echo " Nginx preparing for compilation" \
    && echo "###############################################" \
    && sleep 4 \
    && cd /usr/src/nginx-${NGINX_VERSION} \
    && CC=gcc CXX=g++ ./configure \
    --prefix=/usr/share/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --modules-path=/usr/lib/nginx/modules \
    --with-file-aio \
    --with-threads \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_image_filter_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-imap \
    --with-imap_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module \
    --with-stream_ssl_preread_module \
    --with-debug \
    --with-pcre \
    --with-pcre-jit \
    --with-compat \
    --with-debug \
    --user=www-data \
    --group=www-data \
    --with-cc-opt="-g -O2 -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -I/usr/src/boringssl/.openssl/include" \
    --with-ld-opt="-Wl,-Bsymbolic-functions -Wl,-z,relro -L/usr/local/boringssl/lib -lssl -lcrypto -lz -lstdc++ -Wl,-E" \
    && echo "###############################################" \
    && echo " Fix "Error 127" during build" \
    && echo "###############################################" \
    && sleep 4 \
    && touch "/usr/src/boringssl/.openssl/include/openssl/ssl.h" \
    && echo "###############################################" \
    && echo " Nginx compilation" \
    && echo "###############################################" \
    && sleep 4 \
    && make \
    && echo "###############################################" \
    && echo " Nginx installation" \
    && echo "###############################################" \
    && sleep 4 \
    && make install \
    && cd / \
    && echo "###############################################" \
    && echo " Cleaning" \
    && echo "###############################################" \
    && sleep 4 \
    && rm /usr/src/nginx-${NGINX_VERSION}.tar.gz \
    && rm -rf /var/lib/apt/lists/*
    
COPY update_cloudflare_ips.sh /usr/local/bin/update_cloudflare_ips.sh
RUN  chmod +x /usr/local/bin/update_cloudflare_ips.sh
    
COPY update_cloudflare_ips.cron /etc/cron.d/update_cloudflare_ips
RUN  chmod 0644 /etc/cron.d/update_cloudflare_ips && crontab /etc/cron.d/update_cloudflare_ips

COPY start.sh /start.sh
RUN  chmod +x /start.sh

RUN touch /etc/nginx/cloudflare_ip_range

ENV PATH="/usr/local/boringssl/bin:$PATH"
    
ENTRYPOINT ["/start.sh"]

