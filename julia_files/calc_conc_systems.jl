 # Code to read simul.pdb file and return number of each species and its concentration in mol L-1 - viniciusp
 # first function

 using Statistics 

 function conc( Nan::Float64, Ncat::Float64, Nh2o::Float64, Name::String, BOX::Vector)
   conc = round((Nan / (BOX[1]*BOX[2]*BOX[3])) * ( 1 / (6.02e-4)), digits = 2)
   conc_cat = round((Ncat / (BOX[1]*BOX[2]*BOX[3])) * ( 1 / (6.02e-4)), digits = 2)
   concw = round((Nh2o / (BOX[1]*BOX[2]*BOX[3])) * ( 1 / (6.02e-4)), digits = 2)  
   println("System : Protein with $Name")
   println("Water -> molecules : $Nh2o / concentration (mol/L) : $concw   ")
   println("Ions of ionicliquids")
   println("Cations : $Ncat / concentration (mol/L) : $conc_cat ")
   println("Anions  : $Nan  / concentration (mol/L) : $conc")
   m = (BOX[1] + BOX[2] + BOX[3]) / 3
   println("Avarage cubic box length = $m") 
 end

 function read_pdb(arquivo::String)
   nan = 0
   nwat = 0
   nan2 = 0
   ncat = 0

   # simulations that contais EMIMDCA, BMIMDCA or EMIMBF4, BMIMBF4 or both. 
   f = open("system.pdb","r+")
   for line in eachline(f)
     if occursin("NC",line)
       nan = nan + 1
     elseif occursin("SOL",line)
       nwat = nwat + 1
     elseif occursin("BF4",line)
       nan2 = nan2 + 1
     elseif occursin("BMI",line) || occursin("EMI",line)  # for systems with one cation, search for EMI or BMI.
       ncat = ncat + 1
     end
   end 
   close(f)

   nan = nan/5 
   nwat = nwat / 3
   nan2 = nan2 / 5
   ncat = ncat / 20
   box = zeros(3)

   file = open(arquivo,"r")
   for line in eachline(file)
     if occursin("CRYST1",line)
       data = split(line)
       box[1] = parse(Float64,data[2])
       box[2] = parse(Float64,data[3]) 
       box[3] = parse(Float64,data[4]) 
     else
       continue
     end
   end
   
   box_n =  box   #(box[1] + box[2] + box[3]   
   return nan, nwat, nan2, ncat, box_n
 end 
 
 LIS   = ["EMIMDCABF4" ]
 lista = ["0.50","1.00","1.50","2.00","2.50","3.00"]  

  for i in lista
   cd("work_dir/teste/$(LIS[1])/$i/00") 

   nan,nwater,nan2,ncat,box = read_pdb("system.pdb")
   
   println("*****************************************") 
   println("Main folder - initial concentration $i")
   conc(nan,ncat,nwater,"EMIMDCABF4",box)
   println("*****************************************")
    
 end 

