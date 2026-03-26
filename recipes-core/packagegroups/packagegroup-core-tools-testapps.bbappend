# Remove connman — conflicts with systemd-networkd
RDEPENDS:${PN}:remove = "connman-tools connman-tests connman-client connman-wait-online connman-conf"
