#Define Predefined Libraries
set val(cha) Channel/WirelessChannel ;#channel type
set val(pro) Propagation/TwoRayGround ;# radio-propagation model
set val(nif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(iqt) Queue/DropTail/PriQueue ;# interface queue type
set val(llt) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(pkt) 50 ;# max packet in iqt
set val(rp) DSDV ;# routing protocol

set ns [new Simulator]

#Setup Trace File
set ntrace [open out.tr w]
$ns trace-all $ntrace
set nf [open out.nam w]
$ns namtrace-all-wireless $nf 500 500

set outfile1 [open "cwnd1.xg" w]
set outfile2 [open "cwnd2.xg" w]

#Procedure
proc stop {} {
 global ns ntrace
 $ns flush-trace
 close $ntrace
 exec nam out.nam &
 exit 0
}

proc plotwindow1 { tcpSource outfile1 } {
	global ns
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	puts $outfile1 "$now $cwnd"
	$ns at [expr $now+0.1] "plotwindow1 $tcpSource $outfile1"
}

proc plotwindow2 { tcpSource outfile2 } {
	global ns
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	puts $outfile2 "$now $cwnd"
	$ns at [expr $now+0.1] "plotwindow2 $tcpSource $outfile2"
}

#Setup Grid Size
set topo [new Topography]
$topo load_flatgrid 500 500

#General Object Directory-Declare Global Variables
create-god 10
$ns node-config -adhocRouting $val(rp) \
 -llType $val(llt) \
 -macType $val(mac) \
 -ifqType $val(iqt) \
 -ifqLen $val(pkt) \
 -antType $val(ant) \
 -propType $val(pro) \
 -phyType $val(nif) \
 -channelType $val(cha) \
 -topoInstance $topo \
 -agentTrace ON \
 -routerTrace ON \
 -macTrace OFF \
 -movementTrace OFF

$ns color 1 Blue
$ns color 2 Green

set n0 [$ns node] 
set n1 [$ns node]
set n2 [$ns node] 
set n3 [$ns node]
set n4 [$ns node] 
set n5 [$ns node]
set n6 [$ns node] 
set n7 [$ns node]
set n8 [$ns node] 
set n9 [$ns node]

#Define Positions
$n0 set X_ 150.0
$n0 set Y_ 100.0
$n0 set Z_ 0.0

$n1 set X_ 350.0
$n1 set Y_ 100.0
$n1 set Z_ 0.0

$n2 set X_ 250.0
$n2 set Y_ 200.0
$n2 set Z_ 0.0

$n3 set X_ 300.0
$n3 set Y_ 300.0
$n3 set Z_ 0.0

$n4 set X_ 400.0
$n4 set Y_ 400.0
$n4 set Z_ 0.0

$n5 set X_ 500.0
$n5 set Y_ 500.0
$n5 set Z_ 0.0

$n6 set X_ 450.0
$n6 set Y_ 500.0
$n6 set Z_ 0.0

$n7 set X_ 550.0
$n7 set Y_ 200.0
$n7 set Z_ 0.0

$n8 set X_ 350.0
$n8 set Y_ 350.0
$n8 set Z_ 0.0

$n9 set X_ 400.0
$n9 set Y_ 250.0
$n9 set Z_ 0.0

#Initialize Nodes
$ns initial_node_pos $n0 50
$ns initial_node_pos $n1 50
$ns initial_node_pos $n2 50
$ns initial_node_pos $n3 50
$ns initial_node_pos $n4 50
$ns initial_node_pos $n5 50
$ns initial_node_pos $n6 50
$ns initial_node_pos $n7 50
$ns initial_node_pos $n8 50
$ns initial_node_pos $n9 50

#Setup Mobility
$ns at 0.1 "$n8 setdest 70.0 70.0 100.0"
$ns at 0.2 "$n9 setdest 150.0 150.0 100.0"

$ns at 1.5 "$n8 setdest 450.0 50.0 100.0"
$ns at 2.0 "$n9 setdest 350.0 150.0 100.0"
$ns at 3.0 "$n8 setdest 100.0 450.0 100.0" 
$ns at 5.0 "$n9 setdest 400.0 100.0 100.0"

$ns at 0.1 "$n3 setdest 100.0 70.0 100.0"
$ns at 0.2 "$n7 setdest 200.0 150.0 100.0"

$ns at 1.5 "$n3 setdest 250.0 50.0 100.0"
$ns at 2.0 "$n7 setdest 50.0 150.0 100.0"
$ns at 3.0 "$n3 setdest 60.0 450.0 100.0" 
$ns at 5.0 "$n7 setdest 70.0 100.0 100.0"

#Setup TCP Connection
set tcp [new Agent/TCP]
$ns attach-agent $n8 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n9 $sink
$ns connect $tcp $sink

#Setup FTP Over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#Setup TCP Connection
set tcp1 [new Agent/TCP]
$ns attach-agent $n3 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n7 $sink1
$ns connect $tcp1 $sink1

#Setup FTP Over TCP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$tcp set fid_ 1
$tcp1 set fid_ 2

#Setup Timer
$ns at 0.0 "plotwindow1 $tcp $outfile1"
$ns at 0.0 "plotwindow2 $tcp1 $outfile2"
$ns at 2.5 "$ftp start"
$ns at 2.0 "$ftp1 start"
$ns at 5.5 "$ns detach-agent $n8 $tcp"
$ns at 5.5 "$ns detach-agent $n9 $sink"
$ns at 5.5 "$ns detach-agent $n3 $tcp1"
$ns at 5.5 "$ns detach-agent $n7 $sink1"
$ns at 5.7 "stop"

$ns run
