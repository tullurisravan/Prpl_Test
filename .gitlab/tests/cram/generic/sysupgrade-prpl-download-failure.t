
Create R alias and find the host IP:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ export SERVER_IP="`ip route | grep "192.168.1.0/24" | grep -o "src [0-9.]*" | cut -d' ' -f2 | head -1`"

Start a plain HTTP server (8189) over an empty directory (404 for any path):

  $ export PATH="$PATH:$HOME/.local/bin"
  $ pip install servefile >/dev/null 2>&1 || true
  $ mkdir -p /tmp/cram-sysupgrade-404
  $ servefile -l /tmp/cram-sysupgrade-404 -p 8189 >/dev/null 2>&1 &
  $ open_pid="$!"
  $ sleep 1

The server answers 404 for the missing image:

  $ R "curl -s -o /dev/null -w '%{http_code}\n' http://$SERVER_IP:8189/nonexistent.swu"
  404

Select the inactive firmware bank (the bank sysupgrade-prpl targets):

  $ R "ba-cli 'DeviceInfo.FirmwareImage.*.Status?'" | grep -Ev '^(>|$)' > /tmp/cram-sysupgrade-fwimg.txt
  $ IMG=$(grep -v '="Active"' /tmp/cram-sysupgrade-fwimg.txt | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ test -n "$IMG"

sysupgrade-prpl accepts the URL and dispatches Download() on the inactive bank:

  $ R "sysupgrade-prpl http://$SERVER_IP:8189/nonexistent.swu" | grep -oE 'Download\(\) returned'
  Download() returned

The 404 fails the download - the inactive bank reports DownloadFailed:

  $ for i in $(seq 1 20); do R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | grep -qF '404 Not Found' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Status?'" | grep -oE 'Status="[A-Za-z]+"'
  Status="DownloadFailed"
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | grep -oE '404 Not Found'
  404 Not Found

Clean up the HTTP server:

  $ kill -9 "$open_pid"
