## Easy TCP in scapy ##

## IMPORTANT ##
# This class does NOT use the standard kernel interface for TCP.
# To prevent the kernel from generating reset packets, so
# it's important to drop them:
#   `iptables -A OUTPUT -p tcp --tcp-flags RST RST -j DROP`
# This rule should be deleted after testing.

# EasyTCP class
# To create and manipulate tcp packets
class EasyTCP(TCP):
    fields_desc = TCP.fields_desc
    def __init__(self, **kargs):
        tout = kargs.pop('timeout', 4)
        super().__init__(**kargs)
        self.timeout = tout
        self.total_len = 0
        self.pac_seq = 1000
        self.seq1, self.ack1 = -1, -1
    def __tcp__(self):
        return super().__tcp__()
    def __getitem__(self, layer):
        if layer is TCP:
            return self
        return super().__getitem__(layer)
    def copy(self):
        # Call the parent copy method
        new_copy = super().copy()
        # Copy the custom field(s)
        new_copy.timeout = self.timeout
        return new_copy

    def __update_seq_number(self, pack):
        if pack != None and pack[TCP] != None:
            self.seq1 = pack[TCP].seq + 1
            self.ack1 = pack[TCP].ack
            self.pac_seq += 1
        else:
            self.seq1, self.ack1 = -1, -1

    def __sr1(self, pac):
        return sr1 (pac, timeout=self.timeout, verbose=0)
    def __new_seq(self) ->int:
        return self.pac_seq + self.total_len
    def is_initialized(self) ->bool:
        return (self.seq1 != -1 and self.ack1 != -1)

    def mk_raw_tcp (self, pac: TCP) ->TCP:
        pac.dport = self.dport
        pac.sport = self.sport
        pac.seq = self.__new_seq()
        if not self.is_initialized():
            # Only happens in the `bind` function
            return self[IP] / pac
        pac.ack = self.seq1
        dp = self[IP] / pac
        if dp.haslayer(Raw):
            self.total_len += len(dp[Raw].load)
        if not dp.haslayer(IP):
            dp /= self[IP]
        return dp

    def bind(self, dest_addr: str):
        self.sport = random.randint(1024,65535)
        self /= IP(dst=dest_addr)
        syn = self.mk_raw_tcp (TCP(flags='S'))
        ack = self.__sr1 (syn)
        if ack == None or ack[TCP] == None:
            print (f"Got empty SYN ACK, is {self[IP].dst}:{self.dport} reachable?")
            return None
        self.__update_seq_number(ack)
        ack = self.mk_raw_tcp (TCP(flags='A'))
        send (ack, verbose=0)
        return self

    def fin(self):
        ack = self.__sr1 (self.mk_raw_tcp (TCP(flags='FA')))
        self.__update_seq_number(ack)
        send (self.mk_raw_tcp (TCP(flags='A')), verbose=0)
        self.seq1, self.ack1 = -1, -1
        self.total_len = 0
        self.pac_seq = 0
        return self

    def push(self, load: bytes):
        self.__sr1 (self.mk_raw_tcp( TCP(flags='PA') / Raw(load=load) ))
        return self
    def push_many(self, loads: [bytes]):
        for load in loads:
            self.push(load)
        return self



## Usage Examples ##

# Using push functions
EasyTCP(dport=8080).bind("127.0.0.1").push_many(["Hi\r\n", "Test\n"]).fin()

# Advanced (creating manual TCP segments)
# This function sends `Hi` 3 times
def test(dst_ip: str, dst_port: int):
    # Establish the connection
    etcp = EasyTCP(dport=dst_port).bind(dst_ip)
    if etcp == None:
        return

    # Create a simple PUSH ACK packet
    my_pack = TCP(flags='PA') / Raw("Hi\n")
    for _ in range (3):
        # Update internals of my_packet & send it
        __pac = etcp.mk_raw_tcp (my_pack)
        sr1 (__pac)

    # FIN
    etcp.fin()

test (dst_ip="127.0.0.1", dst_port=8080)
