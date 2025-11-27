Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"
  $ . "${TESTDIR}/../scripts/wifi.sh"

  $ R logger -t cram "Starting EHT Operations test ..."

Stop prplMesh:

  $ R "/etc/init.d/prplmesh stop 2>&1 > /dev/null" 2>&1 > /dev/null

Set AutoChannelEnable=0 on all WiFi.Radio. interfaces:

  $ R "ba-cli -j -l WiFi.Radio.*.AutoChannelEnable=0" | sed '/^$/d'
  [{"WiFi.Radio.1.":{"AutoChannelEnable":0},"WiFi.Radio.2.":{"AutoChannelEnable":0},"WiFi.Radio.3.":{"AutoChannelEnable":0}}]

Configure radio:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].OperatingChannelBandwidth='40MHz'\"" | sed '/^$/d'
  40MHz

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].OperatingChannelBandwidth='80MHz'\"" | sed '/^$/d'
  80MHz

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].OperatingChannelBandwidth='160MHz'\"" | sed '/^$/d'
  160MHz

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].Channel='1'\"" | sed '/^$/d'
  1

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].Channel='36'\"" | sed '/^$/d'
  36

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].Channel='37'\"" | sed '/^$/d'
  37

  $ R "ba-cli -l \"WiFi.Radio.*.OperatingStandardsFormat='Legacy'\"" | sed '/^$/d'
  Legacy
  Legacy
  Legacy

  $ R "ba-cli -l \"WiFi.Radio.*.OperatingStandards='be'\"" | sed '/^$/d'
  be
  be
  be

Enable private vaps radios:

  $ R "ba-cli -l \"WiFi.AccessPoint.1.Enable=1\"" > 1&2>/dev/null
  $ R "ba-cli -l \"WiFi.AccessPoint.2.Enable=1\"" > 1&2>/dev/null
  $ R "ba-cli -l \"WiFi.AccessPoint.3.Enable=1\"" > 1&2>/dev/null

  $ sleep 10

  $ check_ap_ref_ssid 1 Up
  WiFi.AccessPoint.1 SSID Reference is Up

  $ check_ap_ref_ssid 2 Up
  WiFi.AccessPoint.2 SSID Reference is Up

  $ check_ap_ref_ssid 3 Up
  WiFi.AccessPoint.3 SSID Reference is Up

#########################################
#    test 2.4GHz getEHTOperations       #
#########################################

  $ R logger -t cram "Test getEHTOperations on 2.4GHz"

Check ChannelsInUse:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].ChannelsInUse?\"" | sed '/^$/d'
  1,2,3,4,5

Check EhtPhyCapabilities, EhtPhyCapabilitiesStr, CurrentEhtOperatingIE and getEHTOperations():

  $ R logger -t cram "Check EHT Capabilities"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].EhtPhyCapabilities?\"" | sed '/^$/d'
  +AEDYjjkghID

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].EhtPhyCapabilitiesStr?\"" | sed '/^$/d'
  NDP_4XEHT_LTF,PARTIAL_BW_ULMUMIMO,SU_BEAMFORMER,SU_BEAMFORMEE,BEAMFORMEE_SS_80MHZ,NB_SOUNDING_80MHZ,NG16_SU_FEEDBACK,TGD_SU_BEAMFORMING_FEEDBACK,TGD_MU_BEAMFORMING_PARTIAL_BW,MUPPDU_4XEHT_LTF,MAX_NC,RX_1024_4096_QAM_242TONE_RU,COMMON_NOMINAL_PACKET_PADDING,MAX_SUPPORTED_EHT_LTFS,EHTDUP_MCS14_6GHZ,NON_OFDMA_ULMIMO_80MHZ,MU_BEAMFORMER_80MHZ,RX_1024QAM_WIDER_BW,RX_4096QAM_WIDER_BW

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AAFVVVVVAQMAAAA=

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=1431655765
  CCFS0=3
  CCFS1=0
  ControlChannelWidth=1
  DisabledSubchannelBitmap=0
  DisabledSubchannelBitmapPresent=0
  EHTOperationInformationPresent=1

Downgrade to AX operating mode:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].OperatingStandards='ax'\"" | sed '/^$/d'
  ax

  $ sleep 5

  $ R logger -t cram "Checks after downgrade to AX"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].EhtPhyCapabilities?\"" | sed '/^$/d'
  +AEDYjjkghID

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].EhtPhyCapabilitiesStr?\"" | sed '/^$/d'
  NDP_4XEHT_LTF,PARTIAL_BW_ULMUMIMO,SU_BEAMFORMER,SU_BEAMFORMEE,BEAMFORMEE_SS_80MHZ,NB_SOUNDING_80MHZ,NG16_SU_FEEDBACK,TGD_SU_BEAMFORMING_FEEDBACK,TGD_MU_BEAMFORMING_PARTIAL_BW,MUPPDU_4XEHT_LTF,MAX_NC,RX_1024_4096_QAM_242TONE_RU,COMMON_NOMINAL_PACKET_PADDING,MAX_SUPPORTED_EHT_LTFS,EHTDUP_MCS14_6GHZ,NON_OFDMA_ULMIMO_80MHZ,MU_BEAMFORMER_80MHZ,RX_1024QAM_WIDER_BW,RX_4096QAM_WIDER_BW

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AAAAAAAAAAAAAAA=

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=0
  CCFS0=0
  CCFS1=0
  ControlChannelWidth=0
  DisabledSubchannelBitmap=0
  DisabledSubchannelBitmapPresent=0
  EHTOperationInformationPresent=0

#########################################
#    test 5GHz getEHTOperations         #
#########################################

  $ R logger -t cram "Test getEHTOperations on 5GHz"

Check ChannelsInUse:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].ChannelsInUse?\"" | sed '/^$/d'
  36,40,44,48

Check EhtPhyCapabilities, EhtPhyCapabilitiesStr, CurrentEhtOperatingIE and getEHTOperations():

  $ R logger -t cram "Check EHT Capabilities"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].EhtPhyCapabilities?\"" | sed '/^$/d'
  +A0bYjjkgjYD

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].EhtPhyCapabilitiesStr?\"" | sed '/^$/d'
  NDP_4XEHT_LTF,PARTIAL_BW_ULMUMIMO,SU_BEAMFORMER,SU_BEAMFORMEE,BEAMFORMEE_SS_80MHZ,BEAMFORMEE_SS_160MHZ,NB_SOUNDING_80MHZ,NB_SOUNDING_160MHZ,NG16_SU_FEEDBACK,TGD_SU_BEAMFORMING_FEEDBACK,TGD_MU_BEAMFORMING_PARTIAL_BW,MUPPDU_4XEHT_LTF,MAX_NC,RX_1024_4096_QAM_242TONE_RU,COMMON_NOMINAL_PACKET_PADDING,MAX_SUPPORTED_EHT_LTFS,EHTDUP_MCS14_6GHZ,NON_OFDMA_ULMIMO_80MHZ,NON_OFDMA_ULMIMO_160MHZ,MU_BEAMFORMER_80MHZ,MU_BEAMFORMER_160MHZ,RX_1024QAM_WIDER_BW,RX_4096QAM_WIDER_BW

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AAFVVVVVAioAAAA=

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=1431655765
  CCFS0=42
  CCFS1=0
  ControlChannelWidth=2
  DisabledSubchannelBitmap=0
  DisabledSubchannelBitmapPresent=0
  EHTOperationInformationPresent=1

Disable channels 40,48:

  $ R logger -t cram "Disable channels 40,48"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].StaticPuncturing.DisabledSubChannels='40,48'\"" | sed '/^$/d'
  40,48

  $ sleep 5

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=1431655765
  CCFS0=42
  CCFS1=0
  ControlChannelWidth=2
  DisabledSubchannelBitmap=10
  DisabledSubchannelBitmapPresent=1
  EHTOperationInformationPresent=1

Disable channels 40,44,48:

  $ R logger -t cram "Disable channels 40,44,48"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].StaticPuncturing.DisabledSubChannels='40,44,48'\""  | sed '/^$/d'
  40,44,48

  $ sleep 5

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=1431655765
  CCFS0=42
  CCFS1=0
  ControlChannelWidth=2
  DisabledSubchannelBitmap=14
  DisabledSubchannelBitmapPresent=1
  EHTOperationInformationPresent=1

Expecting the EHT Operations IE puncturing bitmap to be updated:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AANVVVVVAioADgA=

Downgrade to AX operating mode:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].OperatingStandards='ax'\"" | sed '/^$/d'
  ax

  $ sleep 5

  $ R logger -t cram "Checks after downgrade to AX"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].EhtPhyCapabilities?\"" | sed '/^$/d'
  +A0bYjjkgjYD

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].EhtPhyCapabilitiesStr?\"" | sed '/^$/d'
  NDP_4XEHT_LTF,PARTIAL_BW_ULMUMIMO,SU_BEAMFORMER,SU_BEAMFORMEE,BEAMFORMEE_SS_80MHZ,BEAMFORMEE_SS_160MHZ,NB_SOUNDING_80MHZ,NB_SOUNDING_160MHZ,NG16_SU_FEEDBACK,TGD_SU_BEAMFORMING_FEEDBACK,TGD_MU_BEAMFORMING_PARTIAL_BW,MUPPDU_4XEHT_LTF,MAX_NC,RX_1024_4096_QAM_242TONE_RU,COMMON_NOMINAL_PACKET_PADDING,MAX_SUPPORTED_EHT_LTFS,EHTDUP_MCS14_6GHZ,NON_OFDMA_ULMIMO_80MHZ,NON_OFDMA_ULMIMO_160MHZ,MU_BEAMFORMER_80MHZ,MU_BEAMFORMER_160MHZ,RX_1024QAM_WIDER_BW,RX_4096QAM_WIDER_BW

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AAAAAAAAAAAAAAA=

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=0
  CCFS0=0
  CCFS1=0
  ControlChannelWidth=0
  DisabledSubchannelBitmap=0
  DisabledSubchannelBitmapPresent=0
  EHTOperationInformationPresent=0

Check channels 40,44,48 are still configured in Radio.StaticPuncturing

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].StaticPuncturing.DisabledSubChannels?\"" | sed '/^$/d'
  40,44,48

#########################################
#    test 6GHz getEHTOperations         #
#########################################

  $ R logger -t cram "Test getEHTOperations on 6GHz"

Check ChannelsInUse:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].ChannelsInUse?\"" | sed '/^$/d'
  33,37,41,45,49,53,57,61

Check EhtPhyCapabilities, EhtPhyCapabilitiesStr, CurrentEhtOperatingIE and getEHTOperations():

  $ R logger -t cram "Check EHT Capabilities"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].EhtPhyCapabilities?\"" | sed '/^$/d'
  +m3bYjjkgn4D

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].EhtPhyCapabilitiesStr?\"" | sed '/^$/d'
  320MHZ,NDP_4XEHT_LTF,PARTIAL_BW_ULMUMIMO,SU_BEAMFORMER,SU_BEAMFORMEE,BEAMFORMEE_SS_80MHZ,BEAMFORMEE_SS_160MHZ,BEAMFORMEE_SS_320MHZ,NB_SOUNDING_80MHZ,NB_SOUNDING_160MHZ,NB_SOUNDING_320MHZ,NG16_SU_FEEDBACK,TGD_SU_BEAMFORMING_FEEDBACK,TGD_MU_BEAMFORMING_PARTIAL_BW,MUPPDU_4XEHT_LTF,MAX_NC,RX_1024_4096_QAM_242TONE_RU,COMMON_NOMINAL_PACKET_PADDING,MAX_SUPPORTED_EHT_LTFS,EHTDUP_MCS14_6GHZ,NON_OFDMA_ULMIMO_80MHZ,NON_OFDMA_ULMIMO_160MHZ,NON_OFDMA_ULMIMO_320MHZ,MU_BEAMFORMER_80MHZ,MU_BEAMFORMER_160MHZ,MU_BEAMFORMER_320MHZ,RX_1024QAM_WIDER_BW,RX_4096QAM_WIDER_BW

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AAFEREREAycvAAA=

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=1145324612
  CCFS0=39
  CCFS1=47
  ControlChannelWidth=3
  DisabledSubchannelBitmap=0
  DisabledSubchannelBitmapPresent=0
  EHTOperationInformationPresent=1

Disable channels 49,53:

  $ R logger -t cram "Disable channels 49,53"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].StaticPuncturing.DisabledSubChannels='49,53'\"" | sed '/^$/d'
  49,53

  $ sleep 5

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=1145324612
  CCFS0=39
  CCFS1=47
  ControlChannelWidth=3
  DisabledSubchannelBitmap=48
  DisabledSubchannelBitmapPresent=1
  EHTOperationInformationPresent=1

Disable channels 53,57,61:

  $ R logger -t cram "Disable channels 53,57,61"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].StaticPuncturing.DisabledSubChannels='53,57,61'\"" | sed '/^$/d'
  53,57,61

  $ sleep 5

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=1145324612
  CCFS0=39
  CCFS1=47
  ControlChannelWidth=3
  DisabledSubchannelBitmap=224
  DisabledSubchannelBitmapPresent=1
  EHTOperationInformationPresent=1

Expecting the EHT Operations IE:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AANEREREAycv4AA=

Downgrade to AX operating mode:

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].OperatingStandards='ax'\"" | sed '/^$/d'
  ax

  $ sleep 5

  $ R logger -t cram "Checks after downgrade to AX"

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].EhtPhyCapabilities?\"" | sed '/^$/d'
  +m3bYjjkgn4D

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].EhtPhyCapabilitiesStr?\"" | sed '/^$/d'
  320MHZ,NDP_4XEHT_LTF,PARTIAL_BW_ULMUMIMO,SU_BEAMFORMER,SU_BEAMFORMEE,BEAMFORMEE_SS_80MHZ,BEAMFORMEE_SS_160MHZ,BEAMFORMEE_SS_320MHZ,NB_SOUNDING_80MHZ,NB_SOUNDING_160MHZ,NB_SOUNDING_320MHZ,NG16_SU_FEEDBACK,TGD_SU_BEAMFORMING_FEEDBACK,TGD_MU_BEAMFORMING_PARTIAL_BW,MUPPDU_4XEHT_LTF,MAX_NC,RX_1024_4096_QAM_242TONE_RU,COMMON_NOMINAL_PACKET_PADDING,MAX_SUPPORTED_EHT_LTFS,EHTDUP_MCS14_6GHZ,NON_OFDMA_ULMIMO_80MHZ,NON_OFDMA_ULMIMO_160MHZ,NON_OFDMA_ULMIMO_320MHZ,MU_BEAMFORMER_80MHZ,MU_BEAMFORMER_160MHZ,MU_BEAMFORMER_320MHZ,RX_1024QAM_WIDER_BW,RX_4096QAM_WIDER_BW

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].CurrentEhtOperatingIE?\"" | sed '/^$/d'
  AAAAAAAAAAAAAAA=

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].getEHTOperations()\"" | awk '/^\[/ {f=1; next} /^\]/ {f=0} f'  | tr -d ' {}[],'  | sed '/^$/d' | sort
  BasicEHT-MCSAndNssSet=0
  CCFS0=0
  CCFS1=0
  ControlChannelWidth=0
  DisabledSubchannelBitmap=0
  DisabledSubchannelBitmapPresent=0
  EHTOperationInformationPresent=0

Check channels 40,44,48 are still configured in Radio.StaticPuncturing

  $ R "ba-cli -l \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].StaticPuncturing.DisabledSubChannels?\"" | sed '/^$/d'
  53,57,61

#########################################
#    Restore defaults                   #
#########################################

  $ R logger -t cram "Finishing EHT operation test"

Restore defaults:

  $ R "ba-cli -l \"WiFi.Radio.*.OperatingStandardsFormat='Standard'\"" | sed '/^$/d'
  Standard
  Standard
  Standard

  $ R "ba-cli  -l \"WiFi.Radio.*.StaticPuncturing.DisabledSubChannels=''\"" | sed '/^$/d'

  $ R "ba-cli -l  \"WiFi.Radio.[OperatingFrequencyBand=='2.4GHz'].OperatingStandards='b,g,n,ax,be'\"" | sed '/^$/d'
  b,g,n,ax,be

  $ R "ba-cli -l  \"WiFi.Radio.[OperatingFrequencyBand=='5GHz'].OperatingStandards='a,n,ac,ax,be'\"" | sed '/^$/d'
  a,n,ac,ax,be

  $ R "ba-cli -l  \"WiFi.Radio.[OperatingFrequencyBand=='6GHz'].OperatingStandards='ax,be'\"" | sed '/^$/d'
  ax,be

  $ R "ba-cli -l \"WiFi.AccessPoint.*.Enable=0\"" > 1&2>/dev/null

  $ sleep 5

  $ R logger -t cram "Restart prplmesh"

  $ R "( /etc/init.d/prplmesh gateway_mode ; sleep 2 ) > /tmp/prplmesh-gw-mode.log 2>&1 ; logger -t prplmesh-gateway-mode < /tmp/prplmesh-gw-mode.log"

  $ R logger -t cram "Test finished!"
