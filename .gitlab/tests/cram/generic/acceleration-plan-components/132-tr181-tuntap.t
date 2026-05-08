Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check Device.Logical.TUN datamodel object:

  $ R "ubus -S call Device.Logical.TUN _get"
  {"Device.Logical.TUN.":{"InterfaceNumberOfEntries":0}}
  {}
  {"amxd-error-code":0}

Check Device.Logical.TAP datamodel object:

  $ R "ubus -S call Device.Logical.TAP _get"
  {"Device.Logical.TAP.":{"InterfaceNumberOfEntries":0}}
  {}
  {"amxd-error-code":0}

Ensure we start with no custom TUN devices:

  $ R "ip link show | grep -E 'tun[0-9]+:' || true"

Ensure we start with no custom TAP devices:

  $ R "ip link show | grep -E 'tap[0-9]+:' || true"

Create TUN interface:

  $ R "ba-cli 'Device.Logical.TUN.CreateInterface()'" | grep -v '>' | grep '[^[:space:]]'
  Device.Logical.TUN.CreateInterface() returned
  [
      0,
      {
          args = {
              FileDescriptor = "[0-9]+", (re)
              Interface = "Device.Logical.TUN.Interface.[0-9]+." (re)
          }
      }
  ]

Ensure TUN device is created:

  $ R "ip link show | grep -E \"tun[0-9]+:\" | sed 's/^[0-9]*: //'"
  tun[0-9]+: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN mode DEFAULT group default qlen 500 (re)

Capture created TUN interface alias:

  $ TUNALIAS=`R "ba-cli 'Device.Logical.TUN.Interface.?'" | grep "Alias" | sed 's/.*="\(.*\)"/\1/' | head -n 1`

Verify NetModel interface status:

  $ R "ba-cli 'NetModel.Intf.[Alias ~= \"tun-"$TUNALIAS"\"].Status_ext?'" | tail -n2 | head -n1
  NetModel.Intf.[0-9]+.Status_ext="Up" (re)

Create TAP interface:

  $ R "ba-cli 'Device.Logical.TAP.CreateInterface()'" | grep -v '>' | grep '[^[:space:]]'
  Device.Logical.TAP.CreateInterface() returned
  [
      0,
      {
          args = {
              FileDescriptor = "[0-9]+", (re)
              Interface = "Device.Logical.TAP.Interface.[0-9]+." (re)
          }
      }
  ]

Ensure TAP device is created:

  $ R "ip link show | grep -E \"tap[0-9]+:\" | sed 's/^[0-9]*: //'"
  tap[0-9]+: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN mode DEFAULT group default qlen 1000 (re)

Capture created TAP interface alias:

  $ TAPALIAS=`R "ba-cli 'Device.Logical.TAP.Interface.?'" | grep "Alias" | sed 's/.*="\(.*\)"/\1/' | head -n 1`

Verify NetModel interface status:

  $ R "ba-cli 'NetModel.Intf.[Alias ~= \"tap-"$TAPALIAS"\"].Status_ext?'" | tail -n2 | head -n1
  NetModel.Intf.[0-9]+.Status_ext="Unknown" (re)

Verify TUN and TAP DM entries are in sync:

  $ R "ba-cli 'Device.Logical.TUN.Interface.[Alias ~= \"'$TUNALIAS'\"].Enable?'" | grep -v '>' | grep '[^[:space:]]'
  Device.Logical.TUN.Interface.[0-9]+.Enable=1 (re)
  $ R "ba-cli 'Device.Logical.TAP.Interface.[Alias ~= \"'$TAPALIAS'\"].Enable?'" | grep -v '>' | grep '[^[:space:]]'
  Device.Logical.TAP.Interface.[0-9]+.Enable=1 (re)
  $ R "ba-cli 'Device.Logical.TUN.Interface.[Alias ~= \"'$TUNALIAS'\"].Status?'" | grep -v '>' | grep '[^[:space:]]'
  Device.Logical.TUN.Interface.[0-9]+.Status="Up" (re)
  $ R "ba-cli 'Device.Logical.TAP.Interface.[Alias ~= \"'$TAPALIAS'\"].Status?'" | grep -v '>' | grep '[^[:space:]]'
  Device.Logical.TAP.Interface.[0-9]+.Status="Unknown" (re)

Delete TUN interface:

  $ R "ba-cli 'Device.Logical.TUN.Interface.[Alias ~= \"'$TUNALIAS'\"].Delete()'" > /dev/null 2>&1
  $ R "ip link show | grep -E "tun[0-9]+:" | sed 's/^[0-9]*: //'"

Delete TAP interface:

  $ R "ba-cli 'Device.Logical.TAP.Interface.[Alias ~= \"'$TAPALIAS'\"].Delete()'" > /dev/null 2>&1
  $ R "ip link show | grep -E "tap[0-9]+:" | sed 's/^[0-9]*: //'"
