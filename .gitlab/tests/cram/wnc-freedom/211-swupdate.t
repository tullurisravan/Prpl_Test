Create R alias:
  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Upgrade with SWUpdate:
  $ R "cd /tmp; tftp ${TARGET_LAN_TEST_HOST} -g -r prplos-ipq95xx-generic-prpl_freedom-image.swu -l prplos-ipq95xx-generic-prpl_freedom-image.swu"
  $ R "test -f /tmp/prplos-ipq95xx-generic-prpl_freedom-image.swu"
  $ R "swupdate -n -k /security/public.pem -i /tmp/prplos-ipq95xx-generic-prpl_freedom-image.swu -v -H freedom:1.0.0 -e active,full 2>/dev/null | grep -F 'SWUpdate was successful'"
  [INFO ] : SWUPDATE running :  [endupdate] : SWUpdate was successful !
