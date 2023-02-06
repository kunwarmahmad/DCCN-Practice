#FA20-BSE-064
#Lab Terminal 
#Q2,Part 2

set ns [new Simulator]
set nf [open o.nam w]
$ns namtrace-all $nf

set tcpReno1 [open out0.tr w]
set tcpReno2 [open out1.tr w]

$ns rtproto DV

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]


#a) Mesh Topology (where all nodes are interconnected with each other)
#b)
$ns duplex-link $n1 $n2 30Mb 10ms DropTail
$ns duplex-link $n1 $n5 30Mb 10ms DropTail
$ns duplex-link $n1 $n4 30Mb 10ms DropTail
$ns duplex-link $n1 $n3 30Mb 10ms DropTail
$ns duplex-link $n1 $n8 30Mb 10ms DropTail
$ns duplex-link $n1 $n2 30Mb 10ms DropTail
$ns duplex-link $n2 $n4 30Mb 10ms DropTail
$ns duplex-link $n2 $n5 30Mb 10ms DropTail
$ns duplex-link $n5 $n1 30Mb 10ms DropTail
$ns duplex-link $n5 $n4 30Mb 10ms DropTail
$ns duplex-link $n5 $n6 30Mb 10ms DropTail

$ns duplex-link $n5 $n7 30Mb 10ms FQ
$ns duplex-link $n7 $n4 30Mb 10ms FQ
$ns duplex-link $n7 $n6 30Mb 10ms FQ
$ns duplex-link $n6 $n4 30Mb 10ms FQ
$ns duplex-link $n6 $n3 30Mb 10ms FQ
$ns duplex-link $n3 $n8 30Mb 10ms FQ
$ns duplex-link $n3 $n4 30Mb 10ms FQ
$ns duplex-link $n3 $n7 30Mb 10ms FQ
$ns duplex-link $n4 $n8 30Mb 10ms FQ




#c)  TCP/Reno on n1, n3, n5, n7
set tcp1 [new Agent/TCP/Reno]
$ns attach-agent $n1 $tcp1

set tcp3 [new Agent/TCP/Reno]
$ns attach-agent $n3 $tcp3

set tcp5 [new Agent/UDP/Reno]
$ns attach-agent $n5 $tcp5

set tcp7 [new Agent/UDP/Reno]
$ns attach-agent $n7 $tcp7

#FTP for n1, n3
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set packet_size_ 1000

set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ftp3 set packet_size_ 1000


#CBR for n5, n7
set cbr5 [new Application/Traffic/CBR]
$cbr5 attach-agent $tcp5
$cbr5 set packet_size_ 1000

set cbr7 [new Application/Traffic/CBR]
$cbr7 attach-agent $tcp7
$cbr7 set packet_size_ 1000


#c) TCPSink on n2, n4
set tcpsync1 [new Agent/TCPSink]
$ns attach-agent $n2 $tcpsync1

set tcpsync2 [new Agent/TCPSink]
$ns attach-agent $n4 $tcpsync2


$ns connect $tcp1 $tcpsync1
$ns connect $tcp3 $tcpsync1
$ns connect $tcp5 $tcpsync1
$ns connect $tcp7 $tcpsync1

$ns connect $tcp1 $tcpsync2
$ns connect $tcp3 $tcpsync2
$ns connect $tcp5 $tcpsync2
$ns connect $tcp7 $tcpsync2



# comparing throughput
proc traffic {} {
    global tcpsync1 tcpsync2 tcpTahoe UDPFile
    set ns [Simulator instance] 
    set time 0.5
    set bwtcp [$tcpsync1 set bytes_] 
    set bwudp [$tcpsync2 set bytes_]
    set now [$ns now]
    puts $tcpTahoe "$now [expr $bwtcp/$time*8/1000000]" 
    puts $UDPFile "$now [expr $bwudp/$time*8/1000000]"
    $tcpsync1 set bytes_ 0
    $tcpsync2 set bytes_ 0
    $ns at [expr $now+$time] "traffic" 
}




proc finish {} {
    global ns nf tcpTahoe UDPFile
    $ns flush-trace
    close $nf
    close $tcpTahoe
    close $UDPFile
    exec nam o.nam &
    exec xgraph out0.tr out1.tr &
    exit 0
}


#d) handle Fail iink
$ns rtmodel-at 10.0 down $n1 $n4
$ns rtmodel-at 10.5 up $n1 $n4

$ns rtmodel-at 10.6 down $n2 $n4
$ns rtmodel-at 11.0 up $n2 $n4

$ns rtmodel-at 11.2 down $n3 $n4
$ns rtmodel-at 11.5 up $n3 $n4

$ns rtmodel-at 11.7 down $n5 $n6
$ns rtmodel-at 12.3 up $n5 $n6


$ns at 0.0 "traffic"

$ns at 1.0 "$ftp1 start"
$ns at 18.0 "$ftp1 stop"
$ns at 0.3 "$ftp3 start"
$ns at 18.5 "$ftp3 stop"

$ns at 1.0 "$udp5 start"
$ns at 18.0 "$udp5 stop"
$ns at 5.0 "$udp7 start"
$ns at 19.0 "$udp7 stop"


$ns at 20.0 "finish"
$ns run






