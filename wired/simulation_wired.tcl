

#============================check if the number of arguments is correct============================
if { $argc != 5 } {
    puts "Usage: ns $argv0 <number of nodes> <number of flows>  <number of packets/sec>"
    exit 1
}



 proc hsvToRgb {h s v} {
    set Hi [expr { int( double($h) / 60 ) % 6 }]
    set f [expr { double($h) / 60 - $Hi }]
    set s [expr { double($s)/255 }]
    set v [expr { double($v)/255 }]
    set p [expr { double($v) * (1 - $s) }]
    set q [expr { double($v) * (1 - $f * $s) }]
    set t [expr { double($v) * (1 - (1 - $f) * $s) }]
    switch -- $Hi {
        0 {
            set r $v
            set g $t
            set b $p
        }
        1 {
            set r $q
            set g $v
            set b $p
        }
        2 {
            set r $p
            set g $v
            set b $t
        }
        3 {
            set r $p
            set g $q
            set b $v
        }
        4 {
            set r $t
            set g $p
            set b $v
        }
        5 {
            set r $v
            set g $p
            set b $q
        }
        default {
            error "Wrong Hi value in hsvToRgb procedure! This should never happen!"
        }
    }
    set r [expr {round($r*255)}]
    set g [expr {round($g*255)}]
    set b [expr {round($b*255)}]
    return [list $r $g $b]
 }

proc getRandomColor {} {
    set h [expr { int(100 * rand())  + 100}]
    set s [expr { int(100 * rand())  + 100}]
    set v [expr { int(100 * rand())  + 100}]

    lassign [hsvToRgb $h $s $v] r g b

    return [format "#%02x%02x%02x" $r $g $b]
}

#============================Define options============================
set val(nn)                 [lindex $argv 0];# number of nodes
set val(nf)                 [lindex $argv 1];# number of flows
# set val(area)               [lindex $argv 2];# area size
set val(packrate)           [lindex $argv 2];# number of packets/sec
set val(simtime)            40 ;            # simulation time
set val(pktsize)            512             ;# packet size
set val(qsize)              [lindex $argv 3]
set val(cca)                [lindex $argv 4]
#======================================================================

# simulator
set ns [new Simulator]


# trace file
set trace_file [open trace.tr w]
$ns trace-all $trace_file

# nam file
set nam_file [open animation.nam w]
$ns namtrace-all $nam_file


# generate random integer number in the range [min,max]
# (the range is inclusive)
proc random_int {min max} {
    return [expr {int(rand()*($max-$min+1)+$min)}]
}

# divide the area size into 2 parts (divide the x axis)
# keep all the source nodes in the left part 
# and all the destination nodes in the right part
# create a node in the left part (determined source node)
# create a node in the right part (determined destination node)
# deduct 2 from val(nn)
# keep the 0 to num_nodes/2 nodes in the left part (source nodes)
# keep the num_nodes/2 to num_nodes nodes in the right part (destination nodes)

# connect them the determined source node with the determined destination node
# connect all the other source node with determined source node
# connect all the other destination node with determined destination node

# determined source and destination
set node_determined_source [$ns node]

set node_determined_destination [$ns node]

$ns duplex-link $node_determined_source $node_determined_destination 100000Mb 20ms DropTail
$ns queue-limit $node_determined_source $node_determined_destination $val(qsize)
$ns duplex-link-op $node_determined_source $node_determined_destination orient right
# deduce 2 from val(nn)
set val(nn) [expr {$val(nn) - 2}]

puts $val(nn)




# Create source nodes
for {set i 0} {$i < [expr {$val(nn) / 2}]} {incr i} {
    set node_s($i) [$ns node]
    $ns duplex-link $node_s($i) $node_determined_source 100000Mb 2ms DropTail 
    $ns queue-limit $node_s($i) $node_determined_source $val(qsize) 

    # $ns duplex-link-op $node_determined_source $node_s($i) orient left
}

# # Create destination nodes
for {set i 0} {$i < [expr {$val(nn) / 2}]} {incr i} {
    set node_d($i) [$ns node]
    $ns duplex-link $node_d($i) $node_determined_destination 100000Mb 2ms DropTail
    $ns queue-limit $node_d($i) $node_determined_destination $val(qsize)
    
   
    # $ns duplex-link-op $node_determined_destination $node_d($i) orient right
}


# Stop nodes
for {set i 0} {$i < [expr {$val(nn) / 2}]} {incr i} {
    $ns at $val(simtime) "$node_s($i) reset"
    $ns at $val(simtime) "$node_d($i) reset"
}

expr { srand(47) }
for {set i 0} {$i < $val(nf)} {incr i} {
    set source [expr int(rand() * ($val(nn)/2))]
    set dest [expr int(rand() * ($val(nn)/2))]
    set tcp_($i) [new Agent/TCP/Linux]
    set sink_($i) [new Agent/TCPSink]
    $ns at 0 "$tcp_($i) select_ca $val(cca)"
    $ns attach-agent $node_s($source) $tcp_($i)
    $ns attach-agent $node_d($dest) $sink_($i)
    #$ns at 0 "$tcp select_ca naive_reno"

    # [$ns create-connection TCP $node_(s$source) TCPSink $node_(d$dest) $i]
    $tcp_($i) set packetSize_ $val(pktsize)
    $tcp_($i) set window_ [expr 10 *($val(packrate) / 100)]

    $ns connect $tcp_($i) $sink_($i)
    $tcp_($i) set fid_ $i

    # $tcp_($i) trace cwnd_
    # set trace_ch_($i) [open "cwnd($i).tr" w]
    # $tcp_($i) attach $trace_ch_($i)

    set ftp_($i) [new Application/FTP]
    $ftp_($i) attach-agent $tcp_($i)

    $ns at 0.5 "$ftp_($i) start"
}


# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
    exit 0
}




$ns at [expr $val(simtime) + 0.01] "finish"




# Run simulation
puts "Simulation starting"
$ns run