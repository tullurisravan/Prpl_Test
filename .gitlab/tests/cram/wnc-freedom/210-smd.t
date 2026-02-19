Create R alias:
  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check MFG field:
  $ R "readmfg -s WLAN_PASSPHRASE; echo"
  prpl-B13634

  $ R "readmfg -s SERIAL_NUMBER; echo"
  freedom_0123456789
