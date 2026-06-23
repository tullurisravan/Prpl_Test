Create R alias and find the host IP:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ export SERVER_IP="`ip route | grep "192.168.1.0/24" | grep -o "src [0-9.]*" | cut -d' ' -f2 | head -1`"

Start a plain (8189) and an authenticated (8190) HTTP server:

  $ export PATH="$PATH:$HOME/.local/bin"
  $ pip install servefile >/dev/null 2>&1 || true
  $ mkdir -p /tmp/cram-download-fail
  $ echo dummy-firmware > /tmp/cram-download-fail/fw.swu
  $ servefile -l /tmp/cram-download-fail -p 8189 >/dev/null 2>&1 &
  $ open_pid="$!"
  $ servefile -a prpl:prpl -l /tmp/cram-download-fail -p 8190 >/dev/null 2>&1 &
  $ auth_pid="$!"
  $ sleep 1

Select the inactive firmware bank:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.*.Status?'" | grep -Ev '^(>|$)' > /tmp/cram-fwimg.txt
  $ IMG=$(grep -v '="Active"' /tmp/cram-fwimg.txt | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ test -n "$IMG"

Check the servers answer 404 and 401:

  $ R "curl -s -o /dev/null -w '%{http_code}\n' http://$SERVER_IP:8189/nonexistent.swu"
  404
  $ R "curl -s -o /dev/null -w '%{http_code}\n' http://$SERVER_IP:8190/fw.swu"
  401

Connection refused is reported as curl error (7):

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://$SERVER_IP:9099/fw.swu\",AutoActivate=0)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | tr -d '\\' | grep -qF '(7) Error' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Status?'" | grep -oE 'Status="[A-Za-z]+"'
  Status="DownloadFailed"
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | tr -d '\\' | grep -oE '\(7\) Error'
  (7) Error

DNS resolution failure is reported as curl error (6):

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://no-such-host.invalid/fw.swu\",AutoActivate=0)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | tr -d '\\' | grep -qF '(6) Error' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Status?'" | grep -oE 'Status="[A-Za-z]+"'
  Status="DownloadFailed"
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | tr -d '\\' | grep -oE '\(6\) Error'
  (6) Error

HTTP 401 (no credentials) is reported as 401 Unauthorized:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://$SERVER_IP:8190/fw.swu\",AutoActivate=0)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | grep -qF '401 Unauthorized' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Status?'" | grep -oE 'Status="[A-Za-z]+"'
  Status="DownloadFailed"
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | grep -oE '401 Unauthorized'
  401 Unauthorized

HTTP 404 (missing file) is reported as 404 Not Found:

  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://$SERVER_IP:8189/nonexistent.swu\",AutoActivate=0)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | grep -qF '404 Not Found' && break; sleep 2; done
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.Status?'" | grep -oE 'Status="[A-Za-z]+"'
  Status="DownloadFailed"
  $ R "ba-cli 'DeviceInfo.FirmwareImage.$IMG.BootFailureLog?'" | grep -oE '404 Not Found'
  404 Not Found

Clean up the HTTP servers:

  $ kill -9 "$open_pid" "$auth_pid"
