#!/bin/bash
#SBATCH --time=7:00:00
#SBATCH --mem-per-cpu=500M
#SBATCH --ntasks=48
#SBATCH --nodes=2
#SBATCH --mail-type=ALL
#SBATCH --begin=now

module load openmpi
module load gcc


srun /scratch/phys/t304029_numecascs/lammps_eph_nadia/lammps_2022/src/lmp_mpi -i therm_base.lmp





 
