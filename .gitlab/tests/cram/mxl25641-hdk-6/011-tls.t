Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that there is just single TLS library OpenSSL:

  $ R "opkg list-installed" | grep -E '(openssl|mbedtls|wolfssl|strongswan)' | sort | awk -F ' - ' '{print $1}'
  libopenssl-conf
  libopenssl.* (re)
  libustream-openssl.* (re)
  libwolfssl.* (re)
  lighttpd-mod-openssl
  openssl-util
  strongswan-mod-openssl
  strongswan-mod-wolfssl
