
set ns [new Simulator] 
$ns color 1 Blue
$ns color 2 Pink
$ns color 3 Magenta
$ns color 4 Lightblue
$ns rtproto DV
set nf [open out.nam w] 

$ns namtrace-all $nf

set ntrace [open out.tr w]
$ns trace-all $ntrace


proc finish {} {
   
      global ns nf ntrace
      $ns flush-trace
      close $nf
      close $ntrace
      exec nam out.nam &
      exit 0
}


set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

$ns duplex-link $n0 $n2 2Mb 10ms DropTail 

$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 10ms DropTail 
$ns queue-limit $n2 $n3 8 


$ns duplex-link $n5 $n4 2Mb 10ms DropTail
$ns duplex-link $n6 $n4 2Mb 10ms DropTail
$ns duplex-link $n7 $n4 2Mb 10ms DropTail
$ns duplex-link $n4 $n2 1.7Mb 10ms DropTail
$ns duplex-link $n7 $n0 2Mb 10ms DropTail
$ns queue-limit $n4 $n2 2

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

$ns duplex-link-op $n4 $n2 orient right
$ns duplex-link-op $n5 $n4 orient right-up
$ns duplex-link-op $n7 $n4 orient right-down
$ns duplex-link-op $n6 $n4 orient right
$ns duplex-link-op $n7 $n0 orient right

$ns duplex-link-op $n2 $n3 queuePos 0.5 
$ns duplex-link-op $n4 $n2 queuePos 0.5 

set tcp [new Agent/TCP]
$tcp set class_ 2 
$ns attach-agent $n0 $tcp 

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

$ns connect $tcp $sink
$tcp set fid_ 1 


set ftp [new Application/FTP]
$ftp attach-agent $tcp 
$ftp set type_ FTP


set tcp1 [new Agent/TCP]
$tcp1 set class_ 2 
$ns attach-agent $n7 $tcp1

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

$ns connect $tcp1 $sink
$tcp1 set fid_ 3 

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP



set udp [new Agent/UDP]
$ns attach-agent $n1 $udp

set null [new Agent/Null]
$ns attach-agent $n3 $null

$ns connect $udp $null
$udp set fid_ 2 

set  cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR 
$cbr set packet_size_ 1000

$cbr set rate_ 1mb
$cbr set random_ false

set udp0 [new Agent/UDP]
$ns attach-agent $n5 $udp0

set null [new Agent/Null]
$ns attach-agent $n3 $null

$ns connect $udp0 $null
$udp0 set fid_ 4


set  cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp0
$cbr1 set type_ CBR 
$cbr1 set packet_size_ 1000

$cbr1 set rate_ 1mb
$cbr1 set random_ false

;#$ns at 0.1 "$cbr start" 
;#$ns at 0.1 "$cbr1 start"
$ns at 0.0 "$ftp start" 
$ns at 4.1 "$ftp1 start"
$ns rtmodel-at 5.0 down $n7 $n0 
$ns rtmodel-at 6.0 up $n7 $n0 

$ns at 4.0 "$ftp stop" 
$ns at 8.0 "$ftp1 stop" 
;#$ns at 2.5 "$cbr stop" 
;#$ns at 2.5 "$cbr1 stop"


$ns at 10.5 "$ns detach-agent $n0 $tcp"
$ns at 10.5 "$ns detach-agent $n7 $tcp1"
$ns at 10.5 "$ns detach-agent $n3 $sink"
$ns at 20.0 "finish"

$ns run
