#!/bin/bash
#SBATCH --time=110:00:00
#SBATCH --mem-per-cpu=600M
#SBATCH --ntasks=120
#SBATCH --nodes=2
#SBATCH --output=/scratch/phys/t30429_numealloys/Ilja/cumulative_cascades/Ni/100K/slurm_output/%j.out

module load openmpi
module load gcc

dir="Ni"
# This is recoil mass. In all cases, it will be nickel
mass=58.71
n0=740
nmax=850
PKA_energy_eV=50000.0
unitconv=19297.062889418

### ----------- ###
for eV in $PKA_energy_eV ; do

	a=4

    for n in $(seq $n0 $nmax); do
		m=$(($n - 1))

		cp ./cumulative_runs/struc-$m.data ./struc_in.data

		boxx=$(awk "NR==6" struc_in.data|cut -d ' ' -f 2)
		boxyz=$(awk "NR==7" struc_in.data|cut -d ' ' -f 2)

		echo $boxx $boxyz

    		u1=`python3 -c 'import random; print(random.uniform(0,1))'`
    		u2=`python3 -c 'import random; print(random.uniform(0,1))'`
	
		theta1=`echo $u1 3.14159265359 | awk '{
	    	u  = $1;
	    	pi = $2;
		} END{
	    	x = 1.0 - 2.0 * u;
	    	num = atan2(sqrt(1-x*x), x);
	    	printf "%.3f", num / (2*pi) * 360.0;
		}'`
	
		phi1=`echo $u2 | awk '{
	    	v  = $1;
		} END{
	    	printf "%.3f", v * 180.0;
		}'`

		u3=`python3 -c 'import random; print(random.uniform(0,1))'`
    		u4=`python3 -c 'import random; print(random.uniform(0,1))'`

		xrec1=`python3 -c 'import random; print(random.uniform(-1,1))'`
		yrec1=`python3 -c 'import random; print(random.uniform(-1,1))'`
		zrec1=`python3 -c 'import random; print(random.uniform(-1,1))'`

		xrec1=$(echo "scale = 10; ${xrec1}*$boxx"|bc )
		yrec1=$(echo "scale = 10; ${yrec1}*$boxyz"|bc )
		zrec1=$(echo "scale = 10; ${zrec1}*$boxyz"|bc )

		PKA1=$(tail -n +18 struc_in.data |head -n +2916000|awk {'ID=$2; if (ID=="1") {print $0}'}|awk -v x=${xrec1} -v y=${yrec1} -v z=${zrec1} -v a=$a 'NR>2{dist=(x-$3)*(x-$3)+(y-$4)*(y-$4)+(z-$5)*(z-$5); a2=a*a; if (dist < 3*a2) {print $0;}}' | tail -1)
		
		PKAid1=$(echo ${PKA1} | awk '{print $1}')

		vel=$(echo $eV $unitconv $mass | awk '{v=sqrt($1*$2/$3); print v;}')

		recoilvel1=`awk -v v=$vel -v r=$r -v theta=${theta1} -v phi=${phi1} 'BEGIN {
            	pi=3.1415927;
            	thetarad=theta*pi/180;
            	phirad=phi*pi/180;
            	vx=v*sin(thetarad)*cos(phirad);
            	vy=v*sin(thetarad)*sin(phirad);
            	vz=v*cos(thetarad);

            printf "%.2f %.2f %.2f\n",vx,vy,vz;
        }'`


		xvel1=$(echo ${recoilvel1} | awk '{print $1;}')
		yvel1=$(echo ${recoilvel1} | awk '{print $2;}')
		zvel1=$(echo ${recoilvel1} | awk '{print $3;}')

		echo "Setting PKA velocities: ${xvel1} ${yvel1} ${zvel1} at ${xrec1} ${yrec1} ${zrec1} and PKA id ${PKAid1}" >> runs.log

		rm -f casc_in-$n.lmp

		sed -e "s/myrun/$n/" -e "s/PKAid1/${PKAid1}/" -e "s/xvel1/${xvel1} /" -e "s/yvel1/${yvel1} /" -e "s/zvel1/${zvel1} /" < casc_in_eph.lmp > casc_in-$n.lmp 

		# run lammps
		srun /scratch/phys/t304029_numecascs/lammps_eph_nadia/lammps_2022/src/lmp_mpi -i casc_in-$n.lmp	

		mv struc_out.data ./cumulative_runs/struc-$n.data
		mv casc_out.data ./casc_out/casc_out-$n.data
		
    done  # end loop over runs
done # end loop over energies



