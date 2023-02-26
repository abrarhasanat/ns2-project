#! /bin/bash
cca=("agileSD" "cubic"  "compound")
vaiables=("#Node" "#Flow" "#Packet" "#Queue")
num_of_nodes=(20 40 60 80 100)
num_of_flows=(10 20 30 40 50)
num_of_packets=(100 200 300 400 500)
num_of_queue=(5 10 20 50 100)
values=("${num_of_nodes[@]}" "${num_of_flows[@]}" "${num_of_packets[@]}" "${num_of_queue[@]}")
base_values=(40 20 200 5)

simulation_file="simulation_wired.tcl"

len=${#vaiables[@]}

# base_area=500
# base_node=40
# base_flow=20
# base_queue=5
echo "" >out.txt
# echo "Area, Throughput, Average Delay, Delivery Ratio, Drop Ratio" > $vaiables.csv

echo "" >log.log
len_algo=${#cca[@]}
for ((curr = 0 ;curr < len_algo; curr++)); do

for ((i = 0; i < $len; i++)); do
    # echo "i: $i"
    # echo "len: $len"
    # # echo "values: ${values[$i]}"
    # echo "base_values: ${base_values[$i]}"
    # echo "vaiables: ${vaiables[$i]}"
    # if [ $i -ne 2 ]; then
    #     continue
    # fi
    echo "${vaiables[$i]}, Throughput, Average Delay, Delivery Ratio, Drop Ratio" > output_${vaiables[$i]}_${cca[$curr]}.csv
    array_size=${#num_of_flows[@]}
    for ((j = i * array_size; j < (i + 1) * array_size; j++)); do
        # echo -n "${values[$j]}, " {vaiables[$i]}: ${values[$j]}" >> log.log

        echo "Nodes: ${base_values[0]} Flows: ${base_values[1]} PPS: ${base_values[2]} Queue: ${base_values[3]} ===> ${vaiables[$i]}: ${values[$j]}" >>out.txt

        echo "Nodes: ${base_values[0]} Flows: ${base_values[1]} PPS: ${base_values[2]} Queue: ${base_values[3]} ===> ${vaiables[$i]}: ${values[$j]}" >>log.log
        echo -n "${values[$j]}," >>output_${vaiables[$i]}_${cca[$curr]}.csv
        echo ${cca[$curr]}
        if [ $i -eq 0 ]; then
            ns $simulation_file $((${values[$j]})) $((${base_values[1]})) $((${base_values[2]})) $((${base_values[3]})) ${cca[curr]}>>log.log
            
        elif [ $i -eq 1 ]; then
            ns $simulation_file $((${base_values[0]})) $((${values[$j]})) $((${base_values[2]})) $((${base_values[3]})) ${cca[$curr]}>>log.log
        elif [ $i -eq 2 ]; then
            ns $simulation_file $((${base_values[0]})) $((${base_values[1]})) $((${values[$j]})) $((${base_values[3]})) ${cca[$curr]}>>log.log
        elif [ $i -eq 3 ]; then
            ns $simulation_file $((${base_values[0]})) $((${base_values[1]})) $((${base_values[3]})) $((${values[$j]})) ${cca[$curr]}>>log.log
        fi
        # awk -f parse_${vaiables[$i]}.awk trace.tr >> out.txt
        python3 wired_parse.py output_${vaiables[$i]}_${cca[$curr]}.csv >>out.txt
        echo ""
        echo "" >>out.txt
        echo "" >>log.log
    done
    echo ""
done
done

python plot_all.py