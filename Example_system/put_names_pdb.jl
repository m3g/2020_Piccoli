# Script to Read simul_teste.pdb and put its format in a suitable shape (for gmd.sh program)
# vinicius piccoli 
########################################################

# Changing "0.00   " by "0.00   UBQ"
name = "simul_teste.pdb"
open("simul_alt.pdb","w") do action        
  open(name, "r") do f
    for line in eachline(f)
      a =replace(line,"0.00            " => "0.00       UBQ",count = 1)
      write(action,"$a\n")          
    end
  end
  close(action)
end

# Adjusting molecules names in the pdb file
for line in eachline(open("simul_alt.pdb","r+"))
  if  occursin("SOL",line)
    println(replace(line,"UBQ" => "SOL",count = 1))
  elseif occursin("BMI",line)
    println(replace(line,"UBQ" => "BMI",count = 1))
  elseif occursin("NC ",line)
    println(replace(line,"UBQ" => "NC ",count = 1))
  elseif occursin("Cl ",line)
    println(replace(line,"UBQ" => "Cl ",count = 1))
  elseif occursin("Br ",line)
    println(replace(line,"UBQ" => "Br ",count = 1))
  elseif occursin("BF4",line)
    println(replace(line,"UBQ" => "BF4",count = 1))
  elseif occursin("MS ",line)
    println(replace(line,"UBQ" => "MS ",count = 1))
  elseif occursin("TCM",line)
    println(replace(line,"UBQ" => "TCM",count = 1))
  elseif occursin("EMI",line)
    println(replace(line,"UBQ" => "EMI",count = 1))
  elseif occursin("NA ",line)
    println(replace(line,"NA " => "OMI",count = 1)) 
  else 
    println(line)
  end
end

