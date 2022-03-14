# subnet calculator

Script asks user for:

- IPv4 address (e. g. 192.168.8.14)
- subnet mask (e. g. 255.255.255.0 or /24)

and calculates:

- network address
- broadcast address
- number of hosts

## usage

```
$ perl subnetcalc.pl <ipv4 address> <subnet mask>
```

```
$ perl subnetcalc.pl <ipv4 address>/<cidr>
```

```
$ perl subnetcalc.pl
```

## examples

```
$ perl subnetcalc.pl 10.0.0.0 255.255.248.0
-------------------------------
Network: 10.0.0.0/21
Broadcast: 10.0.7.255
Mask: 255.255.248.0
Number of hosts: 2046
-------------------------------
```

```
$ perl subnetcalc.pl 10.0.0.0/21
-------------------------------
Network: 10.0.0.0/21
Broadcast: 10.0.7.255
Mask: 255.255.248.0
Number of hosts: 2046
-------------------------------
```

```
$ perl subnetcalc.pl
IPv4 address: 10.0.0.0
Subnet mask: /21
-------------------------------
Network: 10.0.0.0/21
Broadcast: 10.0.7.255
Mask: 255.255.248.0
Number of hosts: 2046
-------------------------------
```
