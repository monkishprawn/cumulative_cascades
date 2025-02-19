#!/bin/bash
# Input
a=3.156
n_cell=150
E=50
T_0=100
Heatcap_file="NULL"
## -----------------##

xhigh=$(echo $n_cell $a | awk '{print $1*$2/2*1}')
ncell_e=$(echo $xhigh | awk '{print int($1*6/25)}')
len=$(echo $xhigh | awk '{print $1*3}')



rm T.in.$E

echo "# " >> T.in.$E
echo "# (2)" >> T.in.$E
echo "# i j k T_e S rho_e C_e kappa_e updateTemp ReadFile" >> T.in.$E
echo "$ncell_e $ncell_e $ncell_e 1" >> T.in.$E
echo "-$len $len" >> T.in.$E
echo "-$len $len" >> T.in.$E
echo "-$len $len" >> T.in.$E
echo "$Heatcap_file" >> T.in.$E

for (( n=0;n<$ncell_e;n++ )); do
        for (( m=0;m<$ncell_e;m++ )); do
	        for (( l=0;l<$ncell_e;l++ )); do

                        if [ $n -eq 0 ] || [ $m -eq 0 ] || [ $l -eq 0 ]
	                	then echo $l $m $n "$T_0 0.000000e+00 1.000000e+00 3.5e-06 0.14932315 1 0" >> T.in.$E
                        else
	                        echo $l $m $n "$T_0 0.000000e+00 1.000000e+00 3.5e-06 0.14932315 1 0" >> T.in.$E
                        fi

	        done
        done
done
