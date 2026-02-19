Create R alias:
  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Upgrade with SWUpdate:
  $ R "cd /tmp; tftp ${TARGET_LAN_TEST_HOST} -g -r prplos-intel_x86-lgm-tb341_wav700-image.swu -l prplos-intel_x86-lgm-tb341_wav700-image.swu"
  $ R "test -f /tmp/prplos-intel_x86-lgm-tb341_wav700-image.swu"
  $ R "swupdate -n -k /security/public.pem -i /tmp/prplos-intel_x86-lgm-tb341_wav700-image.swu -v -H ospv2:1.0.0 -e active,full 2>/dev/null | grep -F 'SWUpdate was successful'"
  [INFO ] : SWUPDATE running :  [endupdate] : SWUpdate was successful !
