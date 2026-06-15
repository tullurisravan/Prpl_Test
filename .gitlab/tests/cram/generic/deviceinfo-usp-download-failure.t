Create R alias and find the host IP; skip if obuspa is absent:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ export SERVER_IP="`ip route | grep "192.168.1.0/24" | grep -o "src [0-9.]*" | cut -d' ' -f2 | head -1`"
  $ R "command -v obuspa > /dev/null" || exit 80

Start a plain (8888) and an always-401 (8889) HTTP server:

  $ mkdir -p /tmp/cram-usp-dl
  $ python3 -m http.server 8888 --directory /tmp/cram-usp-dl > usp-http-$LABGRID_TARGET.log 2>&1 &
  $ open_pid="$!"
  $ python3 -c "import http.server as H
  > class A(H.BaseHTTPRequestHandler):
  >  def do_GET(s): s.send_response(401); s.send_header('Content-Length', '0'); s.end_headers()
  >  def log_message(s, *a): pass
  > H.HTTPServer(('0.0.0.0', 8889), A).serve_forever()" > usp-http401-$LABGRID_TARGET.log 2>&1 &
  $ auth_pid="$!"
  $ sleep 1

Check the servers answer 404 and 401:

  $ R "curl -s -o /dev/null -w '%{http_code}\n' http://$SERVER_IP:8888/firmware-not-found.swu"
  404
  $ R "curl -s -o /dev/null -w '%{http_code}\n' http://$SERVER_IP:8889/firmware.swu"
  401

Select the inactive firmware bank:

  $ IMG=$(R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.*.Status'" | grep -v '=> Active' | grep -oE 'FirmwareImage\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ test -n "$IMG"

Without an OperationComplete subscription the async Download() is refused:

  $ R "for i in \$(obuspa -c get 'Device.LocalAgent.Subscription.*.ID' | grep -F 'cram-usp-dl' | grep -oE 'Subscription\.[0-9]+' | grep -oE '[0-9]+'); do obuspa -c del \"Device.LocalAgent.Subscription.\$i\"; done" > /dev/null 2>&1
  $ R "obuspa -c operate 'Device.DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://$SERVER_IP:8888/x.swu\", AutoActivate=false)'" 2>&1 | grep -oE 'OperationComplete subscription must be set'
  OperationComplete subscription must be set

Subscribe to OperationComplete on the Download:

  $ SUB=$(R "obuspa -c add 'Device.LocalAgent.Subscription.'" | grep -oE 'Subscription\.[0-9]+' | grep -oE '[0-9]+' | head -1)
  $ R "obuspa -c set 'Device.LocalAgent.Subscription.$SUB.ID' 'cram-usp-dl'" > /dev/null
  $ R "obuspa -c set 'Device.LocalAgent.Subscription.$SUB.NotifType' 'OperationComplete'" > /dev/null
  $ R "obuspa -c set 'Device.LocalAgent.Subscription.$SUB.ReferenceList' 'Device.DeviceInfo.FirmwareImage.$IMG.Download()'" > /dev/null
  $ R "obuspa -c set 'Device.LocalAgent.Subscription.$SUB.Enable' 'true'" > /dev/null

Connection refused is reported as curl error (7):

  $ R "obuspa -c operate 'Device.DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://$SERVER_IP:9099/x.swu\", AutoActivate=false)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -qF '(7) Error' && break; sleep 2; done
  $ R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -oE '\(7\) Error'
  (7) Error

DNS resolution failure is reported as curl error (6):

  $ R "obuspa -c operate 'Device.DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://no-such-host.invalid/x.swu\", AutoActivate=false)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -qF '(6) Error' && break; sleep 2; done
  $ R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -oE '\(6\) Error'
  (6) Error

HTTP 401 (no credentials) is reported as 401 Unauthorized:

  $ R "obuspa -c operate 'Device.DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://$SERVER_IP:8889/firmware.swu\", AutoActivate=false)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -qF '401 Unauthorized' && break; sleep 2; done
  $ R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -oE '401 Unauthorized'
  401 Unauthorized

HTTP 404 (missing file) is reported as DownloadFailed with 404 Not Found:

  $ R "obuspa -c operate 'Device.DeviceInfo.FirmwareImage.$IMG.Download(URL=\"http://$SERVER_IP:8888/firmware-not-found.swu\", AutoActivate=false)'" > /dev/null 2>&1
  $ for i in $(seq 1 20); do R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -qF '404 Not Found' && break; sleep 2; done
  $ R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.Status'" | grep -oE 'Status => [A-Za-z]+'
  Status => DownloadFailed
  $ R "obuspa -c get 'Device.DeviceInfo.FirmwareImage.$IMG.BootFailureLog'" | grep -oE '404 Not Found'
  404 Not Found

Clean up the subscription and HTTP servers:

  $ R "obuspa -c del 'Device.LocalAgent.Subscription.$SUB'" > /dev/null 2>&1
  $ kill -9 "$open_pid" "$auth_pid" 2>/dev/null
