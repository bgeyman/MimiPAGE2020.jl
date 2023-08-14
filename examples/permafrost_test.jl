#!/usr/bin/env julia

using Pkg
Pkg.add("Mimi")
cd("/Users/bengeyman/Documents/GitHub/MimiPAGE2020.jl/")
using Mimi
include("/Users/bengeyman/Documents/GitHub/MimiPAGE2020.jl/src/main_model.jl")

# -------------------------------------------------
# run model with benchmark emissions
# -------------------------------------------------
output_dir = "/Users/bengeyman/Downloads/"
for (model_string, output_name) in zip(["RCP2.6 & SSP1", "RCP4.5 & SSP2", "RCP8.5 & SSP5"], 
                                        ["1_26", "2_45", "5_85"])
    m = getpage(model_string)
    run(m)
    explore(m)
    # -- create DataFrame with permafrost thaw results --
    # these fields correspond to cumulative emissions of CO2 and CH4
    df = DataFrame(year=m[:PermafrostSiBCASA, :y_year], # Mtonne CO2
               perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               #perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],   # Mtonne CO2/year
               #perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],   # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )
    # -- create second DataFrame to store additional parameters about initial state
    df2 = DataFrame(perm_sib_ce_co2_0=m[:PermafrostSiBCASA, :perm_sib_ce_c_co2_0], # Mtonne CO2
                    perm_jul_ce_co2_0=m[:PermafrostJULES,   :perm_jul_ce_c_co2_0], # Mtonne CO2
                    )
    # -- write results to csv -- 
    using CSV
    # define output path as a string
    output_path = string(output_dir, "benchmark_", output_name, ".csv")
    # write DataFrame to csv
    CSV.write(output_path, df)

    output_path2 = string(output_dir, "benchmark_params_", output_name, ".csv")
    CSV.write(output_path2, df2)
end
    
# -------------------------------------------------
# run model 
m = getpage("RCP2.6 & SSP1")
run(m)
explore(m)

df = DataFrame(perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],  # Mtonne CO2/year
               perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],  # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )

# -- write results to csv -- 
using CSV
# define output path as a string
output_path = "/Users/bengeyman/Downloads/benchmark_1_26.csv"
# write DataFrame to csv
CSV.write(output_path, df)
# -------------------------------------------------

# -------------------------------------------------
# run model 
m = getpage("RCP4.5 & SSP2")
run(m)
explore(m)

df = DataFrame(perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],  # Mtonne CO2/year
               perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],  # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )

# -- write results to csv -- 
using CSV
# define output path as a string
output_path = "/Users/bengeyman/Downloads/benchmark_2_45.csv"
# write DataFrame to csv
CSV.write(output_path, df)
# -------------------------------------------------

# -------------------------------------------------
# run model 
m = getpage("RCP8.5 & SSP5")
run(m)
explore(m)

df = DataFrame(perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],  # Mtonne CO2/year
               perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],  # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )

# -- write results to csv -- 
using CSV
# define output path as a string
output_path = "/Users/bengeyman/Downloads/benchmark_5_85.csv"
# write DataFrame to csv
CSV.write(output_path, df)
# -------------------------------------------------

# -------------------------------------------------
# now run new model scenarios using my emissions
# -------------------------------------------------

# -------------------------------------------------
# run model 
m = getpage("custom2.6 & SSP1")
run(m)
explore(m)

df = DataFrame(perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],  # Mtonne CO2/year
               perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],  # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )

# -- write results to csv -- 
using CSV
# define output path as a string
output_path = "/Users/bengeyman/Downloads/custom_1_26.csv"
# write DataFrame to csv
CSV.write(output_path, df)
# -------------------------------------------------

# -------------------------------------------------
# run model 
m = getpage("custom4.5 & SSP2")
run(m)
explore(m)

df = DataFrame(perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],  # Mtonne CO2/year
               perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],  # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )

# -- write results to csv -- 
using CSV
# define output path as a string
output_path = "/Users/bengeyman/Downloads/custom_2_45.csv"
# write DataFrame to csv
CSV.write(output_path, df)
# -------------------------------------------------

# -------------------------------------------------
# run model 
m = getpage("custom3.4 & SSP5")
run(m)
explore(m)

df = DataFrame(perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],  # Mtonne CO2/year
               perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],  # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )

# -- write results to csv -- 
using CSV
# define output path as a string
output_path = "/Users/bengeyman/Downloads/custom_5_34.csv"
# write DataFrame to csv
CSV.write(output_path, df)
# -------------------------------------------------

# -------------------------------------------------
# run model 
m = getpage("custom8.5 & SSP5")
run(m)
explore(m)

df = DataFrame(perm_sib_ce_co2=m[:PermafrostTotal, :perm_sib_ce_co2], # Mtonne CO2
               perm_jul_ce_co2=m[:PermafrostTotal, :perm_jul_ce_co2], # Mtonne CO2
               perm_sib_e_co2=m[:PermafrostTotal, :perm_sib_e_co2],  # Mtonne CO2/year
               perm_jul_e_co2=m[:PermafrostTotal, :perm_jul_e_co2],  # Mtonne CO2/year               
               perm_sib_ce_ch4=m[:PermafrostTotal, :perm_sib_ce_ch4], # Mtonne CH4
               perm_jul_ce_ch4=m[:PermafrostTotal, :perm_jul_ce_ch4], # Mtonne CH4
               )

# -- write results to csv -- 
using CSV
# define output path as a string
output_path = "/Users/bengeyman/Downloads/custom_5_85.csv"
# write DataFrame to csv
CSV.write(output_path, df)
# -------------------------------------------------