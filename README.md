This is the basic workflow of cumulative cascades using MD in LAMMPS with USER EPH.

Refer to the respective pages of LAMMPS and USER EPH to set things up. 

Cascades are applied sequentially, each cascade being assigned a number n = 1, 2, 3, ... and so on.
The output of each cascade run n serves as the input for n+1:st run. 

The pristine cell, i.e. 0:th system, is first created manually by assigning atomic positions within the cell, in this case FCC structure, and running thermalization to the desired ambient temperature. Additionally, you should run `make_Tin.sh` file to create the electronic grid (refer to USER EPH). In the file, set up the correct temperature. Running make_Tin.sh creates T.in.$E file. The system is thermalized by running initialize_system.sh. 

```bash
  sbatch initialize_system.sh
```
The LAMMPS instructions are located in `therm_base.lmp` file. During the simulation, the system is coupled to a Nose-Hoover barostat to drive the system towards the desired temperature and to remove excess external pressure, reproducing npt dynamics. After around 30000 steps, npt is replaced by user-eph, and then the dynamics are run for additional 30000. After thermalization make sure that the system is actually at the desired temperature and has no significant excess pressure. If not, repeat the simulation by feeding the struc_out.data file back as the input for thermalization

```bash
  mv struc_out.data struc_in.data
```

When done, move struc_out.data in place of struc-0.data

```bash
  mv struc_out.data ./cumulative_runs/struc-0.data
```

`runcascades.sh` file lets you do cumulative cascades. LAMMPS instructions for each individual cascade are located inside `casc_in_eph.lmp` file. In the current code, each cascade proceeds as follows:

1. Read struc-${n-1}.data
2. Choose a random nickel atom in the system and give it velocity corresponding to $E in a random direction
3. Apply user-eph fix and run the dynamics for 10000 steps (~15 ps)
4. Remove user eph and apply Nose-Hoover barostat to remove excess heat and pressure. Run the dynamics for 3000 steps
5. Remove Nose-Hoover and apply user-eph again. Run the dynamics for 1000 steps
6. Write struc-${n}.data

After each simulation, structure files will be collected in `cumulative_runs` , and `casc_out.data` files will be stored in  `casc_out` folder. "Cascouts" contain information about the temperature, pressure and potential energy of the system during the cascade. 


This text will be expanded, do not worry
