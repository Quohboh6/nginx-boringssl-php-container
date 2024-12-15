# nginx-modules-borringssl-php-container

This container provides an optimized environment for working with Nginx, PHP, and supporting various PHP extensions. It uses Nginx version 1.27.3, PHP with support for popular extensions (such as PHP-FPM, cURL, mbstring, gd, and others), as well as necessary packages for running web applications. The container also includes automatic updates and installation of dependencies, timezone configuration, and the creation of the www-data user with unique UID and GID to prevent conflicts with the host system. It is designed for use in containerized environments and is ideal for developing and deploying web applications based on Nginx and PHP.

This container addresses the common "Error 127" during compilation by providing the correct parameters and dependencies for a successful build. It also resolves the conflict between the versions of QUICK described in BoringSSL and Nginx. For configuration, the container uses the following parameters:

--with-cc-opt="-g -O2 -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -I/usr/src/boringssl/.openssl/include" \
--with-ld-opt="-Wl,-Bsymbolic-functions -Wl,-z,relro -L/usr/local/boringssl/lib -lssl -lcrypto -lz -lstdc++ -Wl,-E"

This approach avoids using the deprecated --with-openssl= parameter, providing greater flexibility and compatibility. Two obsolete configuration parameters for Nginx are still present, and the libatomic_ops package is missing, which may be added in a future version of the container.

Additionally, the current placement of the process for changing the UID and GID of the www-data user is not optimal and may lead to issues with file permissions. In the future, this part will be moved higher to prevent problems with lost files if the distribution includes something belonging to the user with UID 33.

Additional materials:

https://forum.nginx.org/read.php?11,297680

https://forum.nginx.org/read.php?2,295227,295228#msg-295228
