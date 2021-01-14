  

   julia input_gen.jl
  
   packmol < box.inp > box.log   
  
   gmx grompp -f mim.mdp -c system.pdb -p topol.top -o em.tpr -maxwarn 5
   gmx mdrun -v -deffnm em -nb gpu  -ntmpi 1


   gmx grompp -f nvt.mdp -c em.gro -r em.gro  -p topol.top -o nvt.tpr -maxwarn 5
   gmx mdrun -v -deffnm nvt -nb gpu -ntmpi 1
   

   gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro   -t nvt.cpt -p topol.top -o npt.tpr -maxwarn 5
   gmx mdrun -v -deffnm npt -nb gpu -ntmpi 1


   gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o free.tpr -maxwarn 5
   gmx mdrun -v -deffnm free -nb gpu -ntmpi 1 


   gmx grompp -f md_prod.mdp -c free.gro -t free.cpt -p topol.top -o md_prod.tpr -maxwarn 5
   gmx mdrun -v -deffnm md_prod -nb gpu -ntmpi 1 -s md_prod.tpr
   
   # commands to process the gromacs trajectory
  
     for a in "gro" "xtc"; do
 
         echo 1 0 |gmx trjconv -s md_prod.tpr -f md_prod."$a" -o processed."$a" -ur compact -pbc mol -center 
   
     done


