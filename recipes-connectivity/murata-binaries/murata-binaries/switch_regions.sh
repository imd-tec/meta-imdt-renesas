#!/bin/sh

# NXP WLAN regulatory region configuration
# Called with no args at boot to set regulatory domain from wifi_mod_para.conf
# Called with a country code (US, EU, JP, CA) to change the region immediately and persist

VERSION="5.0"

CONF=/lib/firmware/nxp/wifi_mod_para.conf

# Map NXP region name to ISO 3166-1 alpha-2 country code
# EU is not a valid ISO code; use DE (Germany) as the ETSI representative
nxp_to_iso() {
  case $1 in
    EU) echo "DE" ;;
    US) echo "US" ;;
    JP) echo "JP" ;;
    CA) echo "CA" ;;
    *)  echo "" ;;
  esac
}

# Read the current region from wifi_mod_para.conf (SDIW416 section only)
get_current_region() {
  sed -n '/^SDIW416/,/^}/p' "$CONF" | grep 'txpwrlimit_cfg=' | head -1 | sed 's/.*txpower_\([A-Za-z]*\)\.bin.*/\1/'
}

# Set the cfg80211 regulatory domain via iw and verify
set_iw_reg() {
  local region=$1
  local alpha2

  alpha2=$(nxp_to_iso "$region")
  if [ -z "$alpha2" ]; then
    echo "ERROR: Unknown region '${region}'" >&2
    exit 1
  fi

  echo "Setting regulatory domain to ${alpha2} (NXP region: ${region})"
  iw reg set "$alpha2"
  iw reg get
  echo ""
  echo "TX power limits applied to device:"
  iw list | grep -A1 "Frequencies:" | head -4
}

# Update wifi_mod_para.conf SDIW416 section for the new region
modify_conf() {
  local country=$1

  # Update txpower region in SDIW416 section only
  sed -i "/^SDIW416/,/^}/ s/txpwrlimit_cfg=nxp\/txpower_[A-Za-z]*\.bin/txpwrlimit_cfg=nxp\/txpower_${country}.bin/" "$CONF"

  # Remove ed_mac.bin line from SDIW416 section only
  sed -i "/^SDIW416/,/^}/ {/init_hostcmd_cfg=nxp\/ed_mac\.bin/d}" "$CONF"

  # Re-add ed_mac.bin for EU (ETSI requires adaptive MAC / ED threshold)
  if [ "$country" = "EU" ]; then
    sed -i "/^SDIW416/,/^}/ s/txpwrlimit_cfg=nxp\/txpower_EU\.bin/&\n\tinit_hostcmd_cfg=nxp\/ed_mac.bin/" "$CONF"
  fi
}

usage() {
  echo ""
  echo "Version: $VERSION"
  echo ""
  echo "Usage:"
  echo "  $0 [country code]"
  echo ""
  echo "  No arguments: set regulatory domain from current config (used at boot)"
  echo ""
  echo "  Country codes:"
  echo "     CA - Canada"
  echo "     EU - European Union"
  echo "     JP - Japan"
  echo "     US - United States"
  echo ""
}

# No args: boot mode — read region from conf and set via iw
if [ $# -eq 0 ]; then
  REGION=$(get_current_region)
  set_iw_reg "$REGION"
  exit 0
fi

# With args: change region immediately and persist
case ${1} in
  US|us) COUNTRY=US ;;
  EU|eu) COUNTRY=EU ;;
  JP|jp) COUNTRY=JP ;;
  CA|ca) COUNTRY=CA ;;
  *)
    usage
    exit 1
    ;;
esac

modify_conf "$COUNTRY"
set_iw_reg "$COUNTRY"
echo "Region persisted as ${COUNTRY} in ${CONF}"
