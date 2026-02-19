Create R alias:
  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check MFG field:
  $ R "readmfg -s WLAN_PASSPHRASE; echo"
  prpl-E9F594

  $ R "readmfg -s SERIAL_NUMBER; echo"
  ospv2_0123456789
