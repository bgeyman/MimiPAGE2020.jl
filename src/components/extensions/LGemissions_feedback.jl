# SF6 defined as "linear gas" or gas 4 in PAGE 2009; equations are the same as for gas 3 (CH4) in PAGE2002
@defcomp LGemissions begin
    region = Index()

    # global emissions
    e_globalLGemissions = Variable(index=[time], unit="Mtonne/year")
    # baseline emissions
    e0_baselineLGemissions = Parameter(index=[region], unit="Mtonne/year")
    # regional emissions
    e_regionalLGemissions = Variable(index=[time,region], unit="Mtonne/year")
    # growth rate by region
    er_LGemissionsgrowth = Parameter(index=[time,region], unit="%")

    # read in counterfactual GDP in absence of growth effects (gdp_leveleffects) and actual GDP
    gdp = Parameter(index=[time, region], unit="\$M")
    gdp_leveleffect   = Parameter(index=[time, region], unit="\$M")
    emfeed_emissionfeedback = Parameter(unit="none", default=1.)

    function run_timestep(p, v, d, t)

        # eq.4 in Hope (2006) - regional LG emissions as % change from baseline
        for r in d.region
            v.e_regionalLGemissions[t,r] = p.er_LGemissionsgrowth[t,r] * p.e0_baselineLGemissions[r] / 100

            # rescale emissions based on GDP deviation from original scenario pathway
            if p.emfeed_emissionfeedback == 1.
                v.e_regionalLGemissions[t,r] = v.e_regionalLGemissions[t,r] * (p.gdp[t,r] / p.gdp_leveleffect[t,r])
            end
        end

        # eq. 5 in Hope (2006) - global LG emissions are sum of regional emissions
        v.e_globalLGemissions[t] = sum(v.e_regionalLGemissions[t,:])
    end
end
