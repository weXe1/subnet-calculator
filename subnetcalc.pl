#!/usr/bin/perl
use strict;
use warnings;

# -----> FUNCTIONS <-----

# decimal to binary, e. g. 5 => 101
# takes a decimal number as an argument
# returns the number in binary format
sub dec2bin {
    my $dec = shift;
    my $bin = '';
    while($dec) {
        $bin = $dec % 2 . $bin;
        $dec = int($dec / 2);
    }
    return $bin;
}

# binary to decimal, e. g. 101 => 5
# takes a binary number as an argument
# returns the number in decimal format
sub bin2dec {
    my $bin = shift;
    my $dec = 0;
    my @bin = split(//, $bin);
    for(my $i = 0; $i <= $#bin; $i++) {
        $dec += $bin[$#bin - $i] == 1 ? 2 ** $i : 0;
    }
    return $dec;
}

# convert to CIDR notation, e. g. 255.255.255.0 => /24
# takes a mask in dot-decimal format as an argument
# returns the mask in CIDR format
sub dotdec2cidr {
    my $mask = shift;
    my @octets = split(/\./, $mask);
    my $cidr = 0;
    foreach my $octet (@octets) {
        map{$cidr += $_}split(//, &dec2bin($octet));
    }
    $cidr = '/' . $cidr;
    return $cidr;
}

# convert from CIDR to mask, e. g. /24 => 255.255.255.0
# takes a mask in CIDR format as an argument
# returns the mask in dot-decimal format
sub cidr2dotdec {
    my $cidr = shift;
    $cidr =~ s/^\/// if $cidr =~ m/^\//;
    my $mask = 'X.X.X.X';
    my $mask_bin = 1 x $cidr . 0 x (32 - $cidr);
    for(my $offset = 0; $offset < length $mask_bin; $offset += 8) {
        my $octet = substr $mask_bin, $offset, 8;
        $octet = &bin2dec($octet);
        $mask =~ s/X/$octet/;
    }
    return $mask;
}

# dot-decimal to binary
# takes a string in dot-decimal format as an argument
# e. g. IPv4 address (192.168.8.1)
sub dotdec2bin {
    my $dotdec = shift;
    my $bin = '';
    my @octets = split(/\./, $dotdec);
    foreach my $octet (@octets) {
        my $octet_bin = &dec2bin($octet);
        if(length $octet_bin < 8) {
            $octet_bin = 0 x (8 - length $octet_bin) . $octet_bin;
        }
        map{$bin .= $_}split(//, $octet_bin);
    }
    return $bin;
}

# binary to dot-decimal
sub bin2dotdec {
    my $bin = shift;
    my $dotdec = 'X.X.X.X';
    for(my $offset = 0; $offset < length $bin; $offset += 8) {
        my $octet = substr $bin, $offset, 8;
        $octet = &bin2dec($octet);
        $dotdec =~ s/X/$octet/;
    }
    return $dotdec;
}

# calculate network prefix
# takes IPv4 address and mask in CIDR format as arguments
# returns network prefix
sub prefix {
    my($addr, $mask) = @_;
    my $prefix = substr &dotdec2bin($addr), 0, $mask;
    return $prefix;
}

# network and broadcast addresses
# takes IPv4 address and mask in CIDR format as arguments
# returns network and broadcast addresses
sub network_addrs {
    $_[1] =~ s/^\/// if $_[1] =~ m/^\//;
    my $net = &prefix(@_);
    my $broadcast = $net;
    my $hosts = 32 - $_[1];
    $net .= 0 x $hosts;
    $broadcast .= 1 x $hosts;
    return &bin2dotdec($net), &bin2dotdec($broadcast);
}

# number of hosts in the network
# takes mask in CIDR format as an argument
# returns number of hosts in the subnet
sub hosts_num {
    my $mask = shift;
    $mask =~ s/^\/// if $mask =~ m/^\//;
    my $hosts = $mask < 32 ? 1 x (32 - $mask) : 0;
    return &bin2dec($hosts) - 1;
}

# get IP address from the user
sub get_ip {
    my $ip;

    while() {
        print "IPv4 address: ";
        chomp($ip = <STDIN>);
        if($ip =~ /([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/) {
            last;
        }
        else {
            print "IP must be in dot-decimal format!\n";
            print "e. g. 192.168.8.14\n";
        }
    }
    return $ip;
}

# get subnet mask from the user
sub get_mask {
    my $mask;
    my $cidr = 0;

    while() {
        print "Subnet mask: ";
        chomp($mask = <STDIN>);
        if($mask =~ /([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/) {
            last;
        }
        elsif($mask =~ /\/[0-9]{1,2}/) {
            $cidr = 1;
            last;
        }
        else {
            print "Mask must be in dot-decimal or CIDR format!\n";
            print "e. g. 255.255.255.0  or /24\n";
        }
    }
    return $mask, $cidr;
}

# -----> INTERFACE <-----

sub main {
    my($ip, $mask);
    my $cidr = 0;

    # get IP address from the user
    $ip = &get_ip();

    # get subnet mask from the user
    ($mask, $cidr) = &get_mask();

    print "-" x 31 . "\n";

    if($cidr) {
        $cidr = $mask;
        $mask = &cidr2dotdec($cidr);
    }
    else {
        $cidr = &dotdec2cidr($mask);
    }
    $cidr =~ s/^\/// if $cidr =~ m/^\//;

    my($network, $broadcast) = &network_addrs($ip, $cidr);
    my $hosts = &hosts_num($cidr);

    print "Network: $network\/$cidr\n";
    print "Broadcast: $broadcast\n";
    print "Mask: $mask\n";
    print "Number of hosts: $hosts\n";
    print "-" x 31 . "\n";

    return;
}

&main();