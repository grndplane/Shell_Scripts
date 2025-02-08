#!/bin/bash
############################################################################################
#                                                                                          #
#  Checks which hwmon path belongs to which chipset name and creates a /etc/hwmon file.    #
#                                                                                          #
#  With command:  amdgpupath=$(cat /etc/hwmon | grep amdgpu | awk '{print $2}')            #
#  you have always the correct /sys/class/hwmon folder for reading temps, fanspeeds, etc.  #
#                                                                                          #
#  Run at boot via rc.local                                                                #
#                                                  Koentje (remon@cobrasoft.nl)            #
############################################################################################

hwmonfile="/etc/hwmon"
sudo rm -f "$hwmonfile"

arr=$(ls /sys/class/hwmon)

for hwmon in ${arr[@]}
do

     path="/sys/class/hwmon/$hwmon"
     name=$(cat $path/name)

     # if name = nvme then find out which nvme it is!
     if [ "$name" = "nvme" ]; then
       name=$(find $path/device/ -maxdepth 1 -printf "%f\n" | grep nvme)
       name=${name:0:5}
     fi

     if [ "$1" = "silent" ]; then
      echo "$name $path" | sudo tee -a "$hwmonfile" > /dev/null
     else
      printf "SYSFS HWMON: "
      echo "$name $path" | sudo tee -a "$hwmonfile"
     fi

done

# Now you always have the correct hwmon folder and files with the correct chipset! # 

# For example if you want fan2 speed of nct6687 chipset then run: # 
# echo "$(cat $(cat /etc/hwmon | grep nct6687 | awk '{print $2}')/fan2_input)" # 

# In conky you can use this as follow: # 
# ${exec echo "$(cat $(cat /etc/hwmon | grep nct6687 | awk '{print $2}')/fan2_input)"} # 
