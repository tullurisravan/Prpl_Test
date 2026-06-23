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
  strongswan
  strongswan-charon
  strongswan-charon-cmd
  strongswan-full
  strongswan-ipsec
  strongswan-libnttfft
  strongswan-libtls
  strongswan-mod-addrblock
  strongswan-mod-aes
  strongswan-mod-af-alg
  strongswan-mod-agent
  strongswan-mod-attr
  strongswan-mod-attr-sql
  strongswan-mod-bliss
  strongswan-mod-blowfish
  strongswan-mod-ccm
  strongswan-mod-chapoly
  strongswan-mod-cmac
  strongswan-mod-connmark
  strongswan-mod-constraints
  strongswan-mod-coupling
  strongswan-mod-ctr
  strongswan-mod-curl
  strongswan-mod-curve25519
  strongswan-mod-des
  strongswan-mod-dhcp
  strongswan-mod-dnskey
  strongswan-mod-drbg
  strongswan-mod-duplicheck
  strongswan-mod-eap-dynamic
  strongswan-mod-eap-identity
  strongswan-mod-eap-md5
  strongswan-mod-eap-mschapv2
  strongswan-mod-eap-radius
  strongswan-mod-eap-tls
  strongswan-mod-farp
  strongswan-mod-fips-prf
  strongswan-mod-forecast
  strongswan-mod-gcm
  strongswan-mod-gcrypt
  strongswan-mod-gmp
  strongswan-mod-ha
  strongswan-mod-hmac
  strongswan-mod-kdf
  strongswan-mod-kernel-netlink
  strongswan-mod-ldap
  strongswan-mod-led
  strongswan-mod-load-tester
  strongswan-mod-md4
  strongswan-mod-md5
  strongswan-mod-mgf1
  strongswan-mod-mysql
  strongswan-mod-newhope
  strongswan-mod-ntru
  strongswan-mod-openssl
  strongswan-mod-pem
  strongswan-mod-pgp
  strongswan-mod-pkcs1
  strongswan-mod-pkcs11
  strongswan-mod-pkcs12
  strongswan-mod-pkcs7
  strongswan-mod-pkcs8
  strongswan-mod-pubkey
  strongswan-mod-random
  strongswan-mod-rc2
  strongswan-mod-resolve
  strongswan-mod-revocation
  strongswan-mod-sha1
  strongswan-mod-sha2
  strongswan-mod-sha3
  strongswan-mod-smp
  strongswan-mod-socket-default
  strongswan-mod-sql
  strongswan-mod-sqlite
  strongswan-mod-sshkey
  strongswan-mod-stroke
  strongswan-mod-test-vectors
  strongswan-mod-uci
  strongswan-mod-unity
  strongswan-mod-updown
  strongswan-mod-vici
  strongswan-mod-whitelist
  strongswan-mod-wolfssl
  strongswan-mod-x509
  strongswan-mod-xauth-eap
  strongswan-mod-xauth-generic
  strongswan-mod-xcbc
  strongswan-pki
  strongswan-swanctl
