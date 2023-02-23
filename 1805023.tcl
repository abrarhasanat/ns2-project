# simulator
set ns [new Simulator]


# ======================================================================
# Define options

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       5                    ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           AODV                 ;# ad-hoc routing protocol
set val(nn)           10                   ;# number of mobilenodes 
set areaSize          2
set val(nf)           20              ;# number of flows
set bandwidth 100000Mb
set delay 10ms
# =======================================================================

# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all-wireless $nam_file 500 500

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $areaSize $areaSize ;# 500m x 500m area

# set range [expr {$max - $min + 1}]
# set number [expr {int(rand() * $range) + $min}]
# general operation director for mobilenodes
create-god $val(nn)

set phy $val(netif)
$phy set bandwidth_ $bandwidth
$phy set delay_ $delay
$phy set txpower_ 0.008


# node configs
# ======================================================================

# $ns node-config -addressingType flat or hierarchical or expanded
#                  -adhocRouting   DSDV or DSR or TORA
#                  -llType	   LL
#                  -macType	   Mac/802_11
#                  -propType	   "Propagation/TwoRayGround"
#                  -ifqType	   "Queue/DropTail/PriQueue"
#                  -ifqLen	   50
#                  -phyType	   "Phy/WirelessPhy"
#                  -antType	   "Antenna/OmniAntenna"
#                  -channelType    "Channel/WirelessChannel"
#                  -topoInstance   $topo
#                  -energyModel    "EnergyModel"
#                  -initialEnergy  (in Joules)
#                  -rxPower        (in W)
#                  -txPower        (in W)
#                  -agentTrace     ON or OFF
#                  -routerTrace    ON or OFF
#                  -macTrace       ON or OFF
#                  -movementTrace  ON or OFF

# ======================================================================

$ns node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -topoInstance $topo \
    -channelType $val(chan) \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace OFF \
    -movementTrace OFF

# create nodes
proc myRand {min max} {
    set range [expr {$max - $min + 1}]
    return [expr {$min + int(rand() * $range)}]
}


for {set i 0} {$i < $val(nn) } {incr i} {
    set node($i) [$ns node] 

    $node($i) random-motion 1    ;# disable random motion
    $node($i) set rate_ 11000000000
    $node($i) set Pt_ 1000
    set limit [expr $areaSize - 1]

    $node($i) set X_ [myRand 0 $limit]

    $node($i) set Y_ [myRand 0 $limit]
    
    $node($i) set Z_ 0



    set rng_time [myRand 0 10]
    set rng_x [myRand 1  $limit]
    set rng_y [myRand 1  $limit]
    set randomSpeed [myRand 1 5]
    $ns at $rng_time "$node($i) setdest $rng_x $rng_y $randomSpeed"   
    # random movements
    #$node($(i)) set destX [myRand 0 500]
    #$node($(i)) set destY [myRand 0 500]

    $ns initial_node_pos $node($i) 20
}





# Traffic


for {set i 0} {$i < $val(nf)} {incr i} {
    set lim [expr $val(nn) - 1] 
    set src [myRand 0 $lim]
    set dest [myRand 0 $lim]
    while {abs($src - $dest) < 1}  {
        set src [myRand 0 $lim]
        set dest [myRand 0 $lim]

    } 

    # Traffic config
    # create agent
    set tcp [new Agent/TCP/Linux]
    set tcp_sink [new Agent/TCPSink]
    #$ns at 0 "$tcp select_ca tcp_naivereno.o"
    #$ns at 0 "$tcp select_ca naive_reno"
    
    
    $ns at 0 "$tcp select_ca highspeed"
    
    # attach to nodes
    $ns attach-agent $node($src) $tcp
    $ns attach-agent $node($dest) $tcp_sink
    # connect agents
    $ns connect $tcp $tcp_sink
    $tcp set fid_ $i
  

    # Traffic generator
    set ftp [new Application/FTP]
    # attach to agent
    $ftp attach-agent $tcp

    # start traffic generation
    $ns at 1.0 "$ftp start"
}



# End Simulation

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
}

# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at 50.0001 "finish"
$ns at 50.0002 "halt_simulation"




# Run simulation
puts "Simulation starting"
$ns run

