  # This script read pdb files and write inp inputs for using in packmol.
  # Vinicius   
  
  function measure_prot(nome)
  
  ## Variables - Measurement of the protein(X, Y and Z axis)
    pdbfile = nome
    segment = "all"
    restype = "all"
    atomtype = "all"
    firstatom = "all"
    lastatom = "all"
  
  ## Open the file - 
    file = open("$pdbfile","r+")
    natoms = 0
    var = 0
   
    for line in eachline(file)
  
      data = split(line)
      consider = false
      if data[1] == "ATOM" || data[1] == "HEATOM"
        natoms = natoms + 1
        ss = data[11]
        rt = data[4]
        at = data[3]
        consider = true
      else
        continue
      end  
  
      if firstatom != "all"
        if natoms < firstatom
          consider = false
        end
      end
  
      if lastatom != "all"    
        if natoms > lastatom  
          consider = false                                  
        end                    
      end                      
  
      if segment != "all"    
        if ss != segment  
          consider = false     
        end                    
      end                      
  
      if restype != "all"    
        if rt != restype  
          consider = false     
        end                    
      end                      
  
      if atomtype != "all"    
        if at != atomtype  
          consider = false     
        end                    
      end  
  
      if consider == true
        global x = parse(Float64,data[7])
        global y = parse(Float64,data[8])
        global z = parse(Float64,data[9])
      end
      
      if var == 1
        if x < xmin
            xmin = x
        end
        if y < ymin
            ymin = y
        end
        if z < zmin
            zmin = z
        end
        if x > xmax
            xmax = x
        end
        if y > ymax
            ymax = y
        end
        if z > zmax
            zmax = z
        end
      else
  
        global   xmin = x
        global   ymin = y
        global   zmin = z
        global   xmax = x
        global   ymax = y
        global   zmax = z
        var = 1
  
      end
  
    end
   
  ## Box size - add 30 A in each size of box
    bx = round(Int,((xmax - xmin) + 30 + 30)/2) 
    by = round(Int,((ymax - ymin) + 30 + 30)/2)
    bz = round(Int,((zmax - zmin) + 30 + 30)/2)
  
    return bx , by, bz
  
  end
  
  
  # Function to calculate number of components to put inside a box given a specific concentration
  
  function conc(MM::Float64,Nome::String,Nomean::String,MM2::Float64,Nome2::String,Nomean2::String, conc::Float64)
  
      # number of particles calculationa

      # volume of the box (L)
      vol_box(a,b,c) = a*b*c*1e-27;
  
      # protein volume (L)  
      vol_prot(m) = (m/(6.02e23))*1e-3;
     
      # Water volume (L)
      vol_wat(n,mw) = n * (mw/(6.02e23))*1e-3;
  
      # Solution volume
      vol_sol(vc,vp) = vc - vp;
  
      # number of ionic liquids molecules
      num_il(vs,cil) = round(Int128,(vs*cil*6.02e23));
  
      # Volume of ionic liquids moleculres
      v_il(nil,mil) = (nil*mil*1e-3)/(6.02e23);
  
      # each ionic liquid will occupy the half of the volume      
      
      # Number of water molecules
      num_wat(vs,vil) = round(Int128,((vs - vil) * 6.02e23) / (18*1e-3));
  
      println("vai calcular as dimensões")

      # Box dimensions
      lx,ly,lz = measure_prot("ubq.pdb") 

      println("calculou dimensões")
      
            
      # Total concentration of ions
      c = conc;
  
      vs   = vol_box(2*lx,2*ly,2*lz) - vol_prot(8560);              # solution volume
      nil  = round(Int,(num_il(vs,c)/2));                           # Number of IL molecules for a concentration
   
      nwat1 = num_wat(vs, v_il(nil,MM) +  v_il(nil,MM2));           # Number of water molecules
     #nwat2 = num_wat(vs,v_il(nil,MM2));
      nwat = nwat1
     
      io = open("box.inp","w")
      
      println(io,"tolerance 2.0")
      println(io,"output system.pdb")
      println(io,"add_box_sides 1.0")
      println(io,"filetype pdb")
      println(io,"seed -1")
      println(io,"                  ")
      println(io,"structure ubq.pdb")
      println(io," number 1")
      println(io," center")
      println(io," fixed 0. 0. 0. 0. 0. 0.")
      println(io,"end structure")
      println(io,"                  ") 
      println(io,"structure WATER.pdb")
      println(io," number $nwat")
      println(io," inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz).")
      println(io,"end structure")
      println(io,"                  ") 
      println(io,"structure $(Nome)_VSIL.pdb")
      println(io," number $(2*nil)")
      println(io," inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz).")
      println(io,"end structure")
      println(io,"                  ") 
      println(io,"structure $(Nomean2)_VSIL.pdb")
      println(io," number $nil")
      println(io," inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz).")
      println(io,"end structure")
   #   println(io,"                  ") 
   #   println(io,"structure $(Nome2)_VSIL.pdb")
   #   println(io," number $nil")
   #   println(io," inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz).")
   #   println(io,"end structure")
      println(io,"                  ") 
      println(io,"structure $(Nomean)_VSIL.pdb")
      println(io," number $nil")
      println(io," inside box -$(lx). -$(ly). -$(lz). $(lx). $(ly). $(lz).")
      println(io,"end structure")
  
      close(io)
  
      topa = open("topola.top","r+")
  
      # number of lines !
      nlines = 0
      for line in eachline(topa)
        nlines += 1
      end
  
      close(topa)
  
      topa = open("topola.top","r+")
      top = open("topol.top","w")
      ntline = 0

      for line in eachline(topa) 

        ntline += 1
      
        if occursin("AN1",line) && ntline != nlines && ntline < nlines - 4 
          println(top,replace(line,"AN1" => "$Nomean",count = 1))
        elseif occursin("CA1",line) && ntline < nlines - 4 
          println(top,replace(line,"CA1" => "$Nome",count = 1))
        elseif occursin("AN2",line) && ntline < nlines - 4 
          println(top,replace(line,"AN2" => "$Nomean2",count = 1))
        elseif occursin("CA2",line) && ntline < nlines - 4 
          println(top,replace(line,"CA2" => "$Nome2",count = 1))
        elseif ntline == (nlines - 4)
          println(top,replace(line,line => "SOL               $nwat",count = 1)) # 58 cristalization water molecules

        # data for the ions
                                                                                            
        elseif ntline == (nlines - 1)
          if Nomean == "DCA"
            println(top,replace(line,line => "NC                $nil",count = 1)) 
          elseif Nomean == "BF4"
            println(top,replace(line,line => "BF4                $nil",count = 1))  
          end                                                                                      
        elseif ntline == (nlines - 3) 
          println(top,replace(line,line => "$(Nome[1:3])                $(2*nil) ",count = 1))          
        elseif ntline == (nlines - 2)
          if Nomean2 == "DCA"
            println(top,replace(line,line => "NC                $nil",count = 1)) 
          elseif Nomean2 == "BF4"
            println(top,replace(line,line => "BF4                $nil",count = 1))
          end  
       # elseif  ntline == nlines
       #   println(top,replace(line,line => "$(Nome2[1:3])                $nil ",count = 1))        
        else
          println(top,line)
        end
      end
      close(top)
      close(topa)
  
  end
