Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check GRE root datamodel:

  $ R "ubus -S call GRE _get"
  {"GRE.":{"FilterNumberOfEntries":0,"TunnelNumberOfEntries":0}}
  {}
  {"amxd-error-code":0}

Make sure we start with no custom GRE devices:

  $ R "ip link show | grep \"gre.*-t.*\" || true"

Create a GRE tunnel instance with invalid configuration:

  $ R "ba-cli 'GRE.Tunnel.+{Alias=\"test_tunnel\", Enable=1, DeliveryHeaderProtocol=\"IPv6\", RemoteEndpoints=\"203.0.113.5\"}'" > /dev/null 2>&1
  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Status?'" | grep -v '>' | grep -F 'Status='
  GRE.Tunnel.[0-9]+.Status="Error" (re)

Provide valid tunnel configuration:

  $ R "ba-cli 'GRE.Tunnel.test_tunnel.DeliveryHeaderProtocol=\"IPv4\"'" > /dev/null 2>&1
  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Status?'" | grep -v '>' | grep -F 'Status='
  GRE.Tunnel.[0-9]+.Status="Enabled" (re)

Create underlying traffic flow:

  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.+{Alias=\"test_interface\", Enable=1}'" > /dev/null 2>&1
  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.test_interface.Status?'" | grep -v '>' | grep -F 'Status='
  GRE.Tunnel.[0-9]+.Interface.[0-9]+.Status="Unknown" (re)

Ensure GRE device is created:

  $ R "ip link show | grep \"gre.*-t.*\" | sed 's/^[0-9]*: //'"
  gre[0-9]+-t[0-9]+@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 (re)

Verify NetModel interface status:

  $ GREIFACE=`R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.test_interface.Alias?'" | sed -ne 2p | awk -F= '{print $2}' | sed -e s/'\"'//g`
  $ R "ba-cli 'NetModel.Intf.[Alias ~= \"gre-"$GREIFACE"\"].Status_ext?'" | grep -v '>' | grep -F 'Status_ext='
  NetModel.Intf.[0-9]+.Status_ext="Unknown" (re)

Create a second interface:

  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.+{Alias=\"test_interface2\", Enable=1}'" > /dev/null 2>&1
  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.test_interface2.Status?'" | grep -v '>' | grep -F 'Status='
  GRE.Tunnel.[0-9]+.Interface.[0-9]+.Status="NotPresent" (re)

Provide a unique key identifier:

  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.test_interface2.KeyIdentifierGenerationPolicy=\"Provisioned\"'" > /dev/null 2>&1
  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.test_interface2.KeyIdentifier=1'" > /dev/null 2>&1

  $ R "ba-cli 'GRE.Tunnel.test_tunnel.Interface.test_interface2.Status?'" | grep -v '>' | grep -F 'Status='
  GRE.Tunnel.[0-9]+.Interface.[0-9]+.Status="Unknown" (re)

Verify NetModel interface status:

  $ R "ba-cli 'NetModel.Intf.[Alias ~= \"gre-"$GREIFACE"\"].Status_ext?'" | grep -v '>' | grep -F 'Status_ext='
  NetModel.Intf.[0-9]+.Status_ext="Unknown" (re)
  NetModel.Intf.[0-9]+.Status_ext="Unknown" (re)

Ensure GRE device is created

  $ R "ip link show | grep \"gre.*-t.*\" | sed 's/^[0-9]*: //'"
  gre[0-9]+-t[0-9]+@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 (re)
  gre[0-9]+-t[0-9]+@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1472 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000 (re)

Cleanup:

  $ R "ba-cli 'GRE.Tunnel.test_tunnel-'" >/dev/null 2>&1
