package function;
use Net::Telnet ();
use config;

$dbg = $config::debug;

sub print_debug {
    print "\n  DEBUG: $_[0]";
}

sub connect {
    print "\n>>> connect: Connecting to $config::ap";
#   $t = new Net::Telnet (Timeout =>10, Errmode=>'die', Prompt => '/\$ $/i'); sleep 1;
    $t = new Net::Telnet (Timeout =>10, Errmode=>'die'); sleep 1;
    @lines = $t->open($config::ap); sleep 1; if ($dbg) { print_debug(@lines); }
#   if ($dbg) { print_debug("user=$config::AP_Login pswd=$config::AP_Password"); }
    $t->waitfor('/login: $/i'); sleep 1; if ($dbg) { print_debug('wait for login:'); }
    $t->print($config::AP_Login); sleep 1; if ($dbg) { print_debug('login:'); }
    $t->waitfor('/Password: $/i'); sleep 1; if ($dbg) { print_debug('wait for pasword:'); }
    $t->print($config::AP_Password); sleep 1; if ($dbg) { print_debug('password:'); }
#   @lines = $t->login($config::AP_Login, $config::AP_Password); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub commit {
    print "\n>>> Committing changes to $config::ap";
    @lines = $t->cmd("nvram commit"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub disconnect {
    print "\n>>> Exiting from $config::ap";
    $t->errmode(sub {die @_ unless $_[0] =~ /eof/});  # Be quiet about getting eof
    @lines = $t->cmd("exit"); if ($dbg) { print_debug(@lines); }
    print "\n>>> Closing telnet connection to $config::ap";
    @lines = $t->close; if ($dbg) { print_debug(@lines); }
}

sub reboot {
    print "\n>>> Rebooting $config::ap . Wait 40s \n";
    $t->errmode(sub {die @_ unless $_[0] =~ /eof/});  # Be quiet about getting eof
    $t->cmd("reboot");
    sleep 40;
    print "\n>>> Shall be rebooted \n";
}

sub reset {
    print "\n>>> Reseting $config::ap";
    ssid($config::ssid_2g);
    mode($config::default_mode);
    auth($config::default_auth);
    channel($config::channel_2g);
    radiusip($config::EAP_Server);
    radiussecret($config::EAP_Secret);
# wep
    key("1",$config::KEYVALUE1);
    key("2",$config::KEYVALUE2);
    key("3",$config::KEYVALUE3);
    key("4",$config::KEYVALUE4);
#
    bcast("enable");
    rate("0");
    channelwidth("0");
    beacon("100");
    dtim("1");
    rts("2347");
    frag("2346");
#   function::qos(off);
# other settings
    print "\n$config::ap set router_name=vlado-test-ap8";
    @lines = $t->cmd("nvram set router_name=vlado-test-ap8"); sleep 1; if ($dbg) { print_debug(@lines); }
    print "\n$config::ap set auth_dnsmasq=0";
    @lines = $t->cmd("nvram set auth_dnsmasq=0"); sleep 1; if ($dbg) { print_debug(@lines); }
    print "\n$config::ap set dhcp_dnsmasq=0";
    @lines = $t->cmd("nvram set dhcp_dnsmasq=0"); sleep 1; if ($dbg) { print_debug(@lines); }
    print "\n$config::ap set dns_dnsmasq=0";
    @lines = $t->cmd("nvram set dns_dnsmasq=0"); sleep 1; if ($dbg) { print_debug(@lines); }
    print "\n$config::ap set dhcpfwd_ip=192.168.102.20";
    @lines = $t->cmd("nvram set dhcpfwd_ip=192.168.102.20"); sleep 1; if ($dbg) { print_debug(@lines); }
    print "\n$config::ap set  wl0_frameburst=on";
    @lines = $t->cmd("nvram set wl0_frameburst=on"); sleep 1; if ($dbg) { print_debug(@lines); }
    print "\n$config::ap set  wl_frameburst=on";
    @lines = $t->cmd("nvram set wl_frameburst=on"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub ssid {
# AP: Linksys E2000 
# System: DD-WRT v24-sp2
# Parameter: wl_ssid                                                          
    print "\n$config::ap set SSID to $_[0]";
    @lines = $t->cmd("nvram set wl_ssid=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub channel {
# AP: Linksys E2000 
# System: DD-WRT v24-sp2
# Parameter: wl_channel                                                          
    print "\n$config::ap set CHANNEL to $_[0]";
    @lines = $t->cmd("nvram set wl_channel=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
    @lines = $t->cmd("nvram set wl0_channel=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub channelwidth {
# AP: Linksys E2000 
# System: DD-WRT v24-sp2
# Parameter: wl0_nbw Values: 0,10,20,40
# Parameter: wl0_nctrlsb Values: lower
    print "\n$config::ap set CHANNEL-WIDTH to $_[0]";
    if ($_[0] eq "40"){
	@lines = $t->cmd("nvram set wl0_nbw=40"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nctrlsb=lower"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "20"){
	@lines = $t->cmd("nvram set wl0_nbw=20"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nctrlsb=none"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "10"){
	@lines = $t->cmd("nvram set wl0_nbw=10"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nctrlsb=lower"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "0"){
	@lines = $t->cmd("nvram set wl0_nbw=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nctrlsb="); sleep 1; if ($dbg) { print_debug(@lines); }
    }
}

sub uptime {
    @lines = $t->cmd("uptime"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub mode {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_net_mode
# Values: a-only, b-only, g-only, bg-mixed, ng-only, na-only, n2-only, n5-only
    print "\n$config::ap set MODE to $_[0]";
    if ($_[0] eq "A-ONLY"){
	print "\n>>> WARNING: A-ONLY not implemented";
	@lines = $t->cmd("nvram set wl_net_mode=a-only"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "B-ONLY"){
	print "\n>>> WARNING: B-ONLY not implemented";
	@lines = $t->cmd("nvram set wl_net_mode=b-only"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "G-ONLY"){
	@lines = $t->cmd("nvram set wl_net_mode=g-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_net_mode=g-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_gmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nband=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nmode=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nreqd=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_gmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nband=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nmode=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nreqd=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_bandlist=ba"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_phytype=g"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "N2.4-ONLY"){
	@lines = $t->cmd("nvram set wl_net_mode=n2-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_net_mode=n2-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nreqd=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nreqd=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nband=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nband=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_bandlist=ba"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_phytype=n"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "N5-ONLY"){
	@lines = $t->cmd("nvram set wl_net_mode=n5-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_net_mode=n5-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nreqd=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nreqd=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nband=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nband=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_bandlist=ab"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_phytype=n"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "BG-MIXED"){
	print "\n>>> WARNING: BG-MIXED not implemented";
	@lines = $t->cmd("nvram set wl_net_mode=bg-mixed"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "NG-MIXED"){
	@lines = $t->cmd("nvram set wl_net_mode=ng-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_net_mode=ng-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_gmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nband=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nreqd=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_gmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nband=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nreqd=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_bandlist=ba"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_phytype=g"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "NA-MIXED"){
	@lines = $t->cmd("nvram set wl_net_mode=na-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_net_mode=na-only"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_gmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nband=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_nreqd=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_gmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nband=1"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nmode=2"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_nreqd=0"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_bandlist=ab"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_phytype=n"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
}

sub auth {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_akm alias wl0_security_mode
# Values: disabled, wep, psk, psk2, wpa, wpa2, psk psk2, wpa wpa2, radius
    print "\n$config::ap set AUTH to $_[0]";
    if (($_[0] eq "disable") || ($_[0] eq "open")){
	@lines = $t->cmd("nvram set wl0_akm=disabled"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_security_mode=disabled"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if (($_[0] eq "wep") || ($_[0] eq "shared")){
	@lines = $t->cmd("nvram set wl0_akm=wep"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_security_mode=wep"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_wep=enabled"); sleep 1; if ($dbg) { print_debug(@lines); }
    } else {
	@lines = $t->cmd("nvram set wl0_wep=disabled"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "psk") {
	@lines = $t->cmd("nvram set wl0_akm=psk"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_security_mode=psk"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "psk2") {
	@lines = $t->cmd("nvram set wl0_akm=psk"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_security_mode=psk2"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "wpa") {
	@lines = $t->cmd("nvram set wl0_akm=wpa"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_security_mode=wpa"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "wpa2") {
	@lines = $t->cmd("nvram set wl0_akm=wpa"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_security_mode=wpa2"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "psk_psk2") {
	print "\n>>> WARNING: psk_psk2 not implemented";
    }
    if ($_[0] eq "wpa_wpa2") {
	print "\n>>> WARNING: psk_psk2 not implemented";
    }
    if ($_[0] eq "radius") {
	print "\n>>> WARNING: radius not implemented";
    }
}

sub crypto {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_crypto
# Values: tkip, aes, tkip+aes
    print "\n$config::ap set CRYPTO to $_[0]";
    @lines = $t->cmd("nvram set wl0_crypto=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub radiusip {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
    print "\n$config::ap set RADIUS-IP to $_[0]";
    @lines = $t->cmd("nvram set wl0_radius_ipaddr=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub radiussecret {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
    print "\n$config::ap set RADIUS-SECRET to $_[0]";
    @lines = $t->cmd("nvram set wl0_radius_key=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub bcast {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_closed
# Values: 0, 1
    print "\n$config::ap set BCAST to $_[0]";
    if ($_[0] eq "enable") {
	@lines = $t->cmd("nvram set wl0_closed=0"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "disable") {
	@lines = $t->cmd("nvram set wl0_closed=1"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
}

sub encrypt {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_wep_bit
# Values: 64, 128
    print "\n$config::ap set wep ENCRYPT to $_[0]";
    if ($_[0] eq "64") {
	@lines = $t->cmd("nvram set wl_wep_bit=64"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_wep_bit=64"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
    if ($_[0] eq "128") {
	@lines = $t->cmd("nvram set wl_wep_bit=128"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl0_wep_bit=128"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
}

sub keyidx {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_key
# Values: 1,2,3,4
    print "\n$config::ap set wep KEYIDX to $_[0]";
    @lines = $t->cmd("nvram set wl_key=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
    @lines = $t->cmd("nvram set wl0_key=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub key {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_key1, wl0_key2, wl0_key3, wl0_key4
# Values: <hex>
    print "\n$config::ap set wep KEY$_[0] to $_[1]";
    @lines = $t->cmd("nvram set wl_key$_[0]=$_[1]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub beacon {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_bcn
# Values: 10 - 65535
    print "\n$config::ap set BEACON to $_[0]";
    @lines = $t->cmd("nvram set wl_bcn=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
    @lines = $t->cmd("nvram set wl0_bcn=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub dtim {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_dtim
# Values: 1 - 255
    print "\n$config::ap set DTIM to $_[0]";
    @lines = $t->cmd("nvram set wl_dtim=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
    @lines = $t->cmd("nvram set wl0_dtim=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub frag {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_frag
# Values: 256 - 2346
    print "\n$config::ap set FRAG to $_[0]";
    @lines = $t->cmd("nvram set wl_frag=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
    @lines = $t->cmd("nvram set wl0_frag=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub rts {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_rts
# Values: 0 - 2347
    print "\n$config::ap set RTS to $_[0]";
    @lines = $t->cmd("nvram set wl_rts=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
    @lines = $t->cmd("nvram set wl0_rts=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
}

sub rate {
# AP: Linksys E2000
# System: DD-WRT v24-sp2
# Parameter: wl0_rate
# Values: 0,1,2,5.5,6,9,11,12,18,24,36,48,54 (0=default)
    print "\n$config::ap set RATE to $_[0]";
    if ($_[0] eq "0") {
	@lines = $t->cmd("nvram set wl0_rate=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_rate=$_[0]"); sleep 1; if ($dbg) { print_debug(@lines); }
    } elsif ($_[0] eq "5.5") {
	@lines = $t->cmd("nvram set wl0_rate=5500000"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_rate=5500000"); sleep 1; if ($dbg) { print_debug(@lines); }
    } else {
	@lines = $t->cmd("nvram set wl0_rate=$_[0]000000"); sleep 1; if ($dbg) { print_debug(@lines); }
	@lines = $t->cmd("nvram set wl_rate=$_[0]000000"); sleep 1; if ($dbg) { print_debug(@lines); }
    }
}
