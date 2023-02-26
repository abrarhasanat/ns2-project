#! /bin/bash

vaiables=("#Node" "#Flow" "#Packet" "Coverage_Area" "queue_size")
num_of_nodes=(20 40 60 80 100)
num_of_flows=(10 20 30 40 50)
num_of_packets=(100 200 300 400 500)
coverage_area=(1 2 3 4 5)
queue_size=(5 10 20 50 100)
cca=("agileSD" "cubic"  "compound")
values=("${num_of_nodes[@]}" "${num_of_flows[@]}" "${num_of_packets[@]}" "${coverage_area[@]}" "${queue_size[@]}")
base_values=(40 20 200 2 5)

len=${#vaiables[@]}

# base_area=500
# base_node=40
# base_flow=20
echo "" >out.txt
# echo "Area, Throughput, Average Delay, Delivery Ratio, Drop Ratio" > $vaiables.csv

echo "" >log.log
algo_len=${#cca[@]}
echo $algo_len
for ((curr=0; curr <$algo_len;curr++));do
echo ${cca[$curr]}
for ((i = 0; i < $len; i++)); do
    echo "i: $i"
    # echo "len: $len"
    # # echo "values: ${values[$i]}"
    # echo "base_values: ${base_values[$i]}"
    # echo "vaiables: ${vaiables[$i]}"
    # if [ $i -ne 2 ]; then
    #     continue
    # fi
    echo "${vaiables[$i]}, Throughput, Average Delay, Delivery Ratio, Drop Ratio, Energy Per Packet, Energy Per byte" > output_${vaiables[$i]}_${cca[$curr]}.csv
    array_size=${#num_of_flows[@]}
    for ((j = i * array_size; j < (i + 1) * array_size; j++)); do
         echo ${values[$j]}
        # echo -n "${values[$j]}, " {vaiables[$i]}: ${values[$j]}" >> log.log

        echo "Nodes: ${base_values[0]} Flows: ${base_values[1]} PPS: ${base_values[2]} Area: ${base_values[3]} ===> ${vaiables[$i]}: ${values[$j]}" >>out.txt

        echo "Nodes: ${base_values[0]} Flows: ${base_values[1]} PPS: ${base_values[2]} Area: ${base_values[3]} ===> ${vaiables[$i]}: ${values[$j]}" >>log.log
        echo -n "${values[$j]}," >>output_${vaiables[$i]}_${cca[$curr]}.csv
        if [ $i -eq 0 ]; then
            ns simulation.tcl $((${values[$j]})) $((${base_values[1]})) $((${base_values[2]})) $((${base_values[3]})) $((${base_values[4]}))  ${cca[$curr]}>>log.log
        elif [ $i -eq 1 ]; then
            ns simulation.tcl $((${base_values[0]})) $((${values[$j]})) $((${base_values[2]})) $((${base_values[3]})) $((${base_values[4]}))  ${cca[$curr]}>>log.log
        elif [ $i -eq 2 ]; then
            ns simulation.tcl $((${base_values[0]})) $((${base_values[1]})) $((${values[$j]})) $((${base_values[3]})) $((${base_values[4]}))  ${cca[$curr]}>>log.log

        elif [ $i -eq 3 ]; then 
            ns simulation.tcl $((${base_values[0]})) $((${base_values[1]})) $((${base_values[2]})) $((${values[$j]})) $((${base_values[4]}))  ${cca[$curr]}>>log.log
        else 
            ns simulation.tcl $((${base_values[0]})) $((${base_values[1]})) $((${base_values[2]}))  $((${base_values[3]})) $((${values[$j]})) ${cca[$curr]} >>log.log

        fi
        # awk -f parse_${vaiables[$i]}.awk trace.tr >> out.txt
        python3 parse.py output_${vaiables[$i]}_${cca[$curr]}.csv >>out.txt
        echo ""
        echo "" >>out.txt
        echo "" >>log.log
    done
    echo ""
done
done
python3 plot.py