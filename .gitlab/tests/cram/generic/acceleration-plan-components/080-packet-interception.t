Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check PacketInterception root datamodel and Status:

  $ R "ba-cli -l PacketInterception.Status?" | awk NF
  Disabled

Check that no iptables rules are being configured:

  $ R "iptables -t mangle -L INTERCEPT_Forward"
  Chain INTERCEPT_Forward (0 references)
  target     prot opt source               destination         

Enable interception of packets and check Status:

  $ R "ba-cli -l PacketInterception.Enable=True" | awk NF
  1

  $ R "ba-cli -l PacketInterception.Status?" | awk NF
  Enabled

Add a new CommunicationConfig

  $ R "ba-cli -l PacketInterception.CommunicationConfig.Socket.+{Alias=test_socket,Enable=True,URI=/var/run/packetinterception/test_sock,Event=True}"| awk NF
  test_socket

Add a new PacketHandler
  $ R "ba-cli -l PacketInterception.PacketHandler.+{Alias=test_handler,Enable=True}" | awk NF
  test_handler

Add a new Condition (DNS)
  $ R "ba-cli -l PacketInterception.Condition.+{Alias=test_condition,Protocol=UDP,DestPort=53}" | awk NF
  test_condition

Add another Condition (local_traffic)
  $ R "ba-cli -l PacketInterception.Condition.+{Alias=test_condition2,IPVersion=4,SourceIP=127.0.0.1}" | awk NF
  test_condition2

Add a new Interception
  $ R "ba-cli -l PacketInterception.Interception.+{Alias=test,Enable=True,TrafficRoute=OUTPUT}" | awk NF
  test

Add a new Bypass to the Interception
  $ R "ba-cli -l PacketInterception.Interception.test.Bypass.+{Alias=test,Enable=1,Condition=test_condition2,Direction=reply}" | awk NF
  test

Add a new Intercept to the Interception

  $ R "ba-cli -l PacketInterception.Interception.test.Intercept.+{Alias=test,Enable=1,Condition=test_condition,NumberOfPackets=1,PacketHandler=test_handler}" | awk NF
  test

Add the new CommunicationConfig to the Intercept

  $ R "ba-cli -l PacketInterception.Interception.test.Intercept.test.CommunicationConfig.+{Alias=test,Priority=1,CommunicationConfig=test_socket}" | awk NF
  test

Check that iptables rule are correct

  $ R "iptables -t mangle -L INTERCEPT_test"
  Chain INTERCEPT_test (1 references)
  target     prot opt source               destination         
  RETURN     all  --  anywhere             prplOS.lan          
  NFQUEUE    udp  --  anywhere             anywhere             connbytes 0:1 connbytes mode packets connbytes direction original udp dpt:domain NFQUEUE num 3

Send out one DNS packet

  $ R nslookup -type=A example.com. 8.8.8.8 | grep Server
  Server:		8.8.8.8

Check that packet was intercepted using the Stats

  $ R "ba-cli -l PacketInterception.PacketHandler.test_handler.Stats.NrOfPacketsReceived?" | awk NF
  1

  $ R "ba-cli -l PacketInterception.PacketHandler.test_handler.Stats.NrOfPacketsAccepted?" | awk NF
  1

Disable interception of packets:

  $ R "ba-cli -l PacketInterception.Enable=False" | awk NF
  0

Check that no interception is being configured:

  $ R "iptables -t mangle -L INTERCEPT_test"
  Chain INTERCEPT_test (0 references)
  target     prot opt source               destination         
