#FA20-BSE-064
#Lab Terminal 
#Q2,Part 1

set ns [new Simulator]
set nf [open o.nam w]
$ns namtrace-all $nf

set tcpTahoe [open out0.tr w]
set UDPFile [open out1.tr w]

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

$n1 color blue
$n2 color green
$n3 color pink
$n4 color blue
$n5 color green
$n6 color brown
$n7 color pink
$n8 color purple

#a) 
$ns duplex-link $n1 $n2 50Mb 5ms FQ
$ns duplex-link $n2 $n3 50Mb 5ms FQ
$ns duplex-link $n2 $n5 50Mb 5ms FQ
$ns duplex-link $n3 $n4 50Mb 5ms FQ
$ns duplex-link $n3 $n8 50Mb 5ms FQ
$ns duplex-link $n4 $n7 50Mb 5ms FQ
$ns duplex-link $n4 $n6 50Mb 5ms FQ
$ns duplex-link $n7 $n8 50Mb 5ms FQ
$ns duplex-link $n7 $n5 50Mb 5ms FQ
$ns duplex-link $n8 $n6 50Mb 5ms FQ
$ns duplex-link $n6 $n5 50Mb 5ms FQ

#a) links-colors
$ns duplex-link-op $n1 $n2 color red
$ns duplex-link-op $n2 $n3 color blue
$ns duplex-link-op $n2 $n5 color red
$ns duplex-link-op $n3 $n4 color yellow
$ns duplex-link-op $n3 $n8 color blue
$ns duplex-link-op $n4 $n7 color red
$ns duplex-link-op $n4 $n6 color pink
$ns duplex-link-op $n7 $n8 color brown
$ns duplex-link-op $n7 $n5 color blue
$ns duplex-link-op $n8 $n6 color purple
$ns duplex-link-op $n6 $n5 color green



#b) starting nodes
#TCP/Tahoe on n1, n3
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1

set tcp3 [new Agent/TCP]
$ns attach-agent $n3 $tcp3

# UDP on n5, n7
set udp5 [new Agent/UDP]
$ns attach-agent $n5 $udp5

set udp7 [new Agent/UDP]
$ns attach-agent $n7 $udp7

#FTP for n1, n3
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set packet_size_ 1000

set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ftp3 set packet_size_ 1000


#CBR for n5, n7
set cbr5 [new Application/Traffic/CBR]
$cbr5 attach-agent $udp5
$cbr5 set packet_size_ 1000

set cbr7 [new Application/Traffic/CBR]
$cbr7 attach-agent $udp7
$cbr7 set packet_size_ 1000


#c) TCPSink on n2, n4
set tcpsync1 [new Agent/TCPSink]
$ns attach-agent $n2 $tcpsync1

set tcpsync2 [new Agent/TCPSink]
$ns attach-agent $n4 $tcpsync2


$ns connect $tcp1 $tcpsync1
$ns connect $tcp3 $tcpsync1
$ns connect $udp5 $tcpsync1
$ns connect $udp7 $tcpsync1

$ns connect $tcp1 $tcpsync2
$ns connect $tcp3 $tcpsync2
$ns connect $udp5 $tcpsync2
$ns connect $udp7 $tcpsync2


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























