## Traceroute in scapy ##

# finds the route packets trace to network host
# @return: list of found IPs, '* * *' if not known
def trr (pac: scapy.layers.inet.IP) ->list[str]:
    ips=[]
    maxfail, failures = 5, 0
    for t in range (1,42):
        # Set TTL of @pac and send it
        pac['IP'].ttl = t
        res = sr1 (pac, timeout=1, verbose=0)
        if res != None and res.haslayer(IP):
            if res.haslayer(ICMP) and res['ICMP'].type == 3:
                print (f"** Destination Unreachable, from {res['IP'].src} **")
                break
            failures = 0
            rip = res['IP'].src
            ips.append (rip)
            if rip == pac['IP'].dst:
                break
        else:
            ips.append ('* * *')
            failures += 1
            if failures >= maxfail:
                break
    return ips



## Usage Examples ##

# Ping traceroute
trr( IP(dst='8.8.8.8') / ICMP() )

# DNS traceroute
ns_req = DNS( qd=[DNSQR(qname='gmail.com')] )
trr( IP(dst='8.8.8.8') / UDP(sport=33666) / ns_req )
