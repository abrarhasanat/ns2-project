import pandas as pd 
import matplotlib.pyplot as plt

def my_plot(files, name):
    throuhput_list = []
    delay_list = []
    del_ratio_list = []
    drop_ratio_list = []
    for file in files:
        data = pd.read_csv(file, nrows=5)
        headers = data.columns.values.tolist()
        x = data[headers[0]].values.tolist()
        throuhput_list.append(data[headers[1]].values.tolist())
        delay_list.append (data[headers[2]].values.tolist())
        del_ratio_list.append(data[headers[3]].values.tolist())
        drop_ratio_list.append(data[headers[4]].values.tolist())

    data_list = [throuhput_list, delay_list, del_ratio_list, drop_ratio_list]

    file_name = ["throughput", "delay", "delivery_ratio" , "drop_ratio"]
    for idx,list in enumerate(data_list):
    
        df = pd.DataFrame({
            name : x,
            'agile_sd' : list[0],
            'compound' : list[1],
            'cubic' : list[2],
        })

        plt.plot(name, 'agile_sd', data=df)
        plt.plot(name, 'compound', data=df)
        plt.plot(name, 'cubic', data=df)
        

        plt.legend()
        #plt.show()
        plt.savefig(name+"_"+file_name[idx] +".png")
        plt.clf();


flow_files   = ["output_#Flow_agileSD.csv", "output_#Flow_compound.csv", "output_#Flow_cubic.csv"]
node_files   = ["output_#Node_agileSD.csv", "output_#Node_compound.csv", "output_#Node_cubic.csv"]
packet_files = ["output_#Packet_agileSD.csv", "output_#Packet_compound.csv", "output_#Packet_cubic.csv"]
queue_files  = ["output_queue_size_agileSD.csv", "output_queue_size_compound.csv", "output_queue_size_cubic.csv"]
coverage_area_files  = ["output_Coverage_Area_agileSD.csv", "output_Coverage_Area_compound.csv", "output_Coverage_Area_cubic.csv"]


# node_files = 

my_plot(flow_files, "flows") 
my_plot(node_files,  'nodes')
my_plot(packet_files,  'packet')
my_plot(coverage_area_files, 'coverage_area')
my_plot(queue_files,  'queue')

