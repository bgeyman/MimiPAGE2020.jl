@defcomp MarketDamagesBurke_annual begin

    region = Index()
    year = Index()

    # Configuration

    interpolate_parameters = Parameter{Bool}(default=false)

    # Parameters and Variable

    yagg_periodspan = Parameter(index=[time], unit="year") # added for doing in-component summation

    # incoming parameters from Climate
    rtl_realizedtemperature = Parameter(index=[time, region], unit="degreeC")
    rtl_realizedtemperature_ann = Parameter(index=[year, region], unit="degreeC")

    # tolerability and impact variables from PAGE damages that Burke damages also require
    rcons_per_cap_SLRRemainConsumption = Parameter(index=[time, region], unit="\$/person") # only used with interpolation
    rcons_per_cap_SLRRemainConsumption_ann = Variable(index=[year, region], unit="\$/person")
    rgdp_per_cap_SLRRemainGDP = Parameter(index=[time, region], unit="\$/person") # only used with interpolation
    rgdp_per_cap_SLRRemainGDP_ann = Variable(index=[year, region], unit="\$/person")
    save_savingsrate = Parameter(unit="%", default=15.)
    wincf_weightsfactor_market = Parameter(index=[region], unit="")
    ipow_MarketIncomeFxnExponent = Parameter(default=0.0)
    GDP_per_cap_focus_0_FocusRegionEU = Parameter(unit="\$/person", default=34298.93698672955)

    # added impact parameters and variables specifically for Burke damage function
    rtl_abs_0_realizedabstemperature = Parameter(index=[region]) # 1979-2005 means, Yumashev et al. 2019 Supplementary Table 16, table in /data directory
    rtl_0_realizedtemperature = Parameter(index=[region]) # temperature change between PAGE base year temperature and rtl_abs_0 (?)
    impf_coeff_lin = Parameter(default=-0.00829990966469437) # rescaled coefficients from Burke
    impf_coeff_quadr = Parameter(default=-0.000500003403703578)
    tcal_burke = Parameter(default=21.) # calibration temperature for the impact function
    nlag_burke = Parameter(default=1.) # Yumashev et al. (2019) allow for one or two lags

    i_burke_regionalimpact_ann = Variable(index=[year, region], unit="degreeC")
    i1log_impactlogchange_ann = Variable(index=[year, region])

    # impact variables from PAGE damages that Burke damages also require
    isatg_impactfxnsaturation = Parameter(unit="unitless")
    rcons_per_cap_MarketRemainConsumption = Parameter(index=[time, region], unit="\$/person")
    rcons_per_cap_MarketRemainConsumption_ann = Variable(index=[year, region], unit="\$/person")
    rgdp_per_cap_MarketRemainGDP = Parameter(index=[time, region], unit="\$/person")
    rgdp_per_cap_MarketRemainGDP_sum = Variable(unit="\$/person") # for analysis
    rgdp_per_cap_MarketRemainGDP_ann = Variable(index=[year, region], unit="\$/person")
    rgdp_per_cap_MarketRemainGDP_ann_sum = Variable(unit="\$/person") # for analysis
    iref_ImpactatReferenceGDPperCap_ann = Variable(index=[year, region])
    igdp_ImpactatActualGDPperCap = Parameter(index=[time, region])
    igdp_ImpactatActualGDPperCap_ann = Variable(index=[year, region])

    isat_ImpactinclSaturationandAdaptation_ann = Variable(index=[year, region])
    isat_per_cap_ImpactperCapinclSaturationandAdaptation = Parameter(index=[time,region])
    isat_per_cap_ImpactperCapinclSaturationandAdaptation_sum = Variable(unit="\$/person") # for analysis
    isat_per_cap_ImpactperCapinclSaturationandAdaptation_ann = Variable(index=[year, region], unit="\$/person")
    isat_per_cap_ImpactperCapinclSaturationandAdaptation_ann_sum = Variable(unit="\$/person") # for analysis


    function run_timestep(p, v, d, t)

        if p.interpolate_parameters
            # interpolate the parameters that require interpolation:
            interpolate_parameters_marketdamagesburke(p, v, d, t) # NB: always run, so get rcons_pc_slr_ann
        end

        for r in d.region
            # calculate  for this specific year
            if is_first(t)
                for annual_year = 2015:(gettime(t))
                    calc_marketdamagesburke(p, v, d, t, annual_year, r)
                end
                if isequal(r, 8)
                    v.rgdp_per_cap_MarketRemainGDP_sum = sum(p.rgdp_per_cap_MarketRemainGDP[t,:]) * p.yagg_periodspan[t]
                    v.isat_per_cap_ImpactperCapinclSaturationandAdaptation_sum = sum(p.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,:]) * p.yagg_periodspan[t]
                end
            else
                for annual_year = (gettime(t - 1) + 1):(gettime(t))
                    calc_marketdamagesburke(p, v, d, t, annual_year, r)

                     # for analysis
                    if isequal(annual_year, 2300)
                        if isequal(r, 8)
                            v.rgdp_per_cap_MarketRemainGDP_ann_sum = sum(v.rgdp_per_cap_MarketRemainGDP_ann[:,:])
                            v.isat_per_cap_ImpactperCapinclSaturationandAdaptation_ann_sum = sum(v.isat_per_cap_ImpactperCapinclSaturationandAdaptation_ann[:,:])
                        end
                    end
                end
                if isequal(r, 8)
                    v.rgdp_per_cap_MarketRemainGDP_sum = v.rgdp_per_cap_MarketRemainGDP_sum + sum(p.rgdp_per_cap_MarketRemainGDP[t,:]) * p.yagg_periodspan[t]
                    v.isat_per_cap_ImpactperCapinclSaturationandAdaptation_sum = v.isat_per_cap_ImpactperCapinclSaturationandAdaptation_sum + sum(p.isat_per_cap_ImpactperCapinclSaturationandAdaptation[t,:]) * p.yagg_periodspan[t]
                end
            end

        end

    end
end

# Still need this function in order to set the parameters than depend on
# readpagedata, which takes model as an input. These cannot be set using
# the default keyword arg for now.

function addmarketdamagesburke_annual(model::Model)
    marketdamagesburkecomp = add_comp!(model, MarketDamagesBurke_annual)
    marketdamagesburkecomp[:rtl_abs_0_realizedabstemperature] = readpagedata(model, "data/rtl_abs_0_realizedabstemperature.csv")
    marketdamagesburkecomp[:rtl_0_realizedtemperature] = readpagedata(model, "data/rtl_0_realizedtemperature.csv")

    # fix the current bug which implements the regional weights from SLR and discontinuity also for market and non-market damages (where weights should be uniformly one)
    marketdamagesburkecomp[:wincf_weightsfactor_market] = readpagedata(model, "data/wincf_weightsfactor_market.csv")

    return marketdamagesburkecomp
end

function interpolate_parameters_marketdamagesburke(p, v, d, t)
    if is_first(t)
        for annual_year = 2015:(gettime(t))
            yr = annual_year - 2015 + 1
            for r in d.region

                # for the years before 2020, we assume the numbers to be the same as the figures of 2020
                v.rcons_per_cap_SLRRemainConsumption_ann[yr, r] = p.rcons_per_cap_SLRRemainConsumption[t, r]
                v.rgdp_per_cap_SLRRemainGDP_ann[yr,r] = p.rgdp_per_cap_SLRRemainGDP[t, r]
            end
        end
    else
        for annual_year = (gettime(t - 1) + 1):(gettime(t))
            yr = annual_year - 2015 + 1
            frac = annual_year - gettime(t - 1)
            fraction_timestep = frac / ((gettime(t)) - (gettime(t - 1)))

            for r in d.region

                if use_linear
                    # for the years after 2020, we use linear interpolation between the years of analysis
                    v.rcons_per_cap_SLRRemainConsumption_ann[yr, r] = p.rcons_per_cap_SLRRemainConsumption[t, r] * (fraction_timestep) +
                                    p.rcons_per_cap_SLRRemainConsumption[t - 1, r] * (1 - fraction_timestep)
                    v.rgdp_per_cap_SLRRemainGDP_ann[yr,r] = p.rgdp_per_cap_SLRRemainGDP[t, r] * (fraction_timestep) +
                                    p.rgdp_per_cap_SLRRemainGDP[t - 1, r] * (1 - fraction_timestep)
                elseif use_logburke
                    # for the years after 2020, we use linear interpolation between the years of analysis
                    v.rcons_per_cap_SLRRemainConsumption_ann[yr, r] = p.rcons_per_cap_SLRRemainConsumption[t, r]^(fraction_timestep) *
                                    p.rcons_per_cap_SLRRemainConsumption[t - 1, r]^(1 - fraction_timestep)
                    v.rgdp_per_cap_SLRRemainGDP_ann[yr,r] = p.rgdp_per_cap_SLRRemainGDP[t, r]^(fraction_timestep) *
                                    p.rgdp_per_cap_SLRRemainGDP[t - 1, r]^(1 - fraction_timestep)
                elseif use_logpopulation
                    # all linear
                    v.rcons_per_cap_SLRRemainConsumption_ann[yr, r] = p.rcons_per_cap_SLRRemainConsumption[t, r] * (fraction_timestep) +
                                    p.rcons_per_cap_SLRRemainConsumption[t - 1, r] * (1 - fraction_timestep)
                    v.rgdp_per_cap_SLRRemainGDP_ann[yr,r] = p.rgdp_per_cap_SLRRemainGDP[t, r] * (fraction_timestep) +
                                    p.rgdp_per_cap_SLRRemainGDP[t - 1, r] * (1 - fraction_timestep)
                elseif use_logwherepossible
                    # for the years after 2020, we use linear interpolation between the years of analysis
                    v.rcons_per_cap_SLRRemainConsumption_ann[yr, r] = p.rcons_per_cap_SLRRemainConsumption[t, r]^(fraction_timestep) *
                                    p.rcons_per_cap_SLRRemainConsumption[t - 1, r]^(1 - fraction_timestep)
                    v.rgdp_per_cap_SLRRemainGDP_ann[yr,r] = p.rgdp_per_cap_SLRRemainGDP[t, r]^(fraction_timestep) *
                                    p.rgdp_per_cap_SLRRemainGDP[t - 1, r]^(1 - fraction_timestep)
                else
                    error("NO INTERPOLATION METHOD SELECTED! Specify linear or logarithmic interpolation.")
                end
            end
        end
    end
end

function calc_marketdamagesburke(p, v, d, t, annual_year, r)
    # setting the year for entry in lists.
    yr = annual_year - 2015 + 1 # + 1 because of 1-based indexing in Julia


    # calculate the regional temperature impact relative to baseline year and add it to baseline absolute value
    v.i_burke_regionalimpact_ann[yr,r] = (p.rtl_realizedtemperature_ann[yr,r] - p.rtl_0_realizedtemperature[r]) + p.rtl_abs_0_realizedabstemperature[r]


    # calculate the log change, depending on the number of lags specified
    v.i1log_impactlogchange_ann[yr,r] = p.nlag_burke * (p.impf_coeff_lin  * (v.i_burke_regionalimpact_ann[yr,r] - p.rtl_abs_0_realizedabstemperature[r]) +
                        p.impf_coeff_quadr * ((v.i_burke_regionalimpact_ann[yr,r] - p.tcal_burke)^2 -
                                              (p.rtl_abs_0_realizedabstemperature[r] - p.tcal_burke)^2))

    # calculate the impact at focus region GDP p.c.
    v.iref_ImpactatReferenceGDPperCap_ann[yr,r] = 100 * p.wincf_weightsfactor_market[r] * (1 - exp(v.i1log_impactlogchange_ann[yr,r]))

    # calculate impacts at actual GDP
    v.igdp_ImpactatActualGDPperCap_ann[yr,r] = v.iref_ImpactatReferenceGDPperCap_ann[yr,r] *
        (v.rgdp_per_cap_SLRRemainGDP_ann[yr,r] / p.GDP_per_cap_focus_0_FocusRegionEU)^p.ipow_MarketIncomeFxnExponent

    # send impacts down a logistic path if saturation threshold is exceeded
    if p.igdp_ImpactatActualGDPperCap[t,r] < p.isatg_impactfxnsaturation
        v.isat_ImpactinclSaturationandAdaptation_ann[yr,r] = v.igdp_ImpactatActualGDPperCap_ann[yr,r]
    else
        v.isat_ImpactinclSaturationandAdaptation_ann[yr,r] = p.isatg_impactfxnsaturation +
            ((100 - p.save_savingsrate) - p.isatg_impactfxnsaturation) *
            ((v.igdp_ImpactatActualGDPperCap_ann[yr,r] - p.isatg_impactfxnsaturation) /
            (((100 - p.save_savingsrate) - p.isatg_impactfxnsaturation) +
            (v.igdp_ImpactatActualGDPperCap_ann[yr,r] -
            p.isatg_impactfxnsaturation)))
    end

    v.isat_per_cap_ImpactperCapinclSaturationandAdaptation_ann[yr,r] = (v.isat_ImpactinclSaturationandAdaptation_ann[yr,r] / 100) * v.rgdp_per_cap_SLRRemainGDP_ann[yr,r]
    v.rcons_per_cap_MarketRemainConsumption_ann[yr,r] = v.rcons_per_cap_SLRRemainConsumption_ann[yr,r] - v.isat_per_cap_ImpactperCapinclSaturationandAdaptation_ann[yr,r]
    v.rgdp_per_cap_MarketRemainGDP_ann[yr,r] = v.rcons_per_cap_MarketRemainConsumption_ann[yr,r] / (1 - p.save_savingsrate / 100)
    if v.rgdp_per_cap_MarketRemainGDP_ann[yr,r] < 0
        v.rgdp_per_cap_MarketRemainGDP_ann[yr,r] = 0
    end

end
