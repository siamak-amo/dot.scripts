## Traceroute in scapy ##

# finds the route packets trace to network host
# @return: list of found IPs, '* * *' if not known
def trr (pac: scapy.layers.inet.IP, verbose=False) ->list[str]:
    ips=[]
    maxfail, failures = 5, 0
    if verbose:
        print(f"ttl  IP                Duration")
    for t in range (1,42):
        # Set TTL of @pac and send it
        pac['IP'].ttl = t
        _t0 = time.time()
        res = sr1 (pac, timeout=1, verbose=0)
        if res != None and res.haslayer(IP):
            if res.haslayer(ICMP) and res['ICMP'].type == 3:
                print (f"** Destination Unreachable, from {res['IP'].src} **")
                break
            failures = 0
            rip = res['IP'].src
            ips.append (rip)
            if verbose:
                print(f"{t:<3}  {rip:<15}   {1000*(res.time-_t0):.4f}ms")
            if rip == pac['IP'].dst:
                break
        else:
            ips.append ('* * *')
            if verbose:
                print(f"{t:<3}  * * *")
            failures += 1
            if failures >= maxfail:
                break
    return ips



## Usage Examples ##

# Ping traceroute
trr( IP(dst='8.8.8.8') / ICMP(),  verbose=True )

# DNS traceroute
ns_req = DNS( qd=[DNSQR(qname='gmail.com')] )
trr( IP(dst='8.8.8.8') / UDP(sport=33666) / ns_req )
