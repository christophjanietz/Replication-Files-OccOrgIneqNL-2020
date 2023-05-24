/*=============================================================================* 
* Supplementary Analysis: Decomposition by Time Period (t1=2006-2012; t2=2013-2018)
*==============================================================================*
 	Project: Occupations, Organizations, and Wage Inequality
	Author: Christoph Janietz (University of Amsterdam)
	Article: Janietz, C. & Bol, T. (2020).
			 Occupations, organizations, and the structure of wage inequality in 
			 the Netherlands.
			 Research in Social Stratification and Mobility 70
			 https://doi.org/10.1016/j.rssm.2019.100468
	Last update: 18-11-2019
	
	Purpose: Produces estimates for Table A2 in the final article
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		0.  Settings 
		1. 	FIRM FEs (separately for t1 & t2)
		2. 	ORGA WEIGHT (separately for t1 & t2)
		3.  SAMPLE PREPARATION (separately for t1 & t2)
		4.  ANALYSIS (Period 1)
		5.  ANALYSIS (Period 2)
		6.  CLOSE LOG FILE
	
* --------------------------------------------------------------------------- */
* 0. SETTINGS 
* ---------------------------------------------------------------------------- * 

*** Settings - run config file
	global dir 			"H:/Christoph/art1"
	do 					"${dir}/06_dofiles/config"

*** Open log file
	log using 			"$logfiles/04_analysis_timetrend.log", replace	
	
* --------------------------------------------------------------------------- */
* 1. FIRM FEs (separately for t1 & t2)
* ---------------------------------------------------------------------------- * 

*** AKM PERIOD 1
	use "${data}/akm.dta", replace
	
	keep if YEAR<=2012
	keep if cs==1
	
	egen rin = group(RIN)
	egen beid = group(sbeid)
	
	drop ft_factor_beid RIN cs
	
	reghdfe, compile
	ftools, compile
	
	// Model
	reghdfe log_real_hwage_bonus2 age age2 i.YEAR, absorb(i_fe = i.rin j_fe = i.beid) pool(1)
	
	*Saving fixed effects	
	preserve
	egen tag = tag(sbeid) if e(sample)==1
	keep if tag==1
	keep sbeid j_fe
	
	*Recenter with mean = 0
	sum j_fe
	replace j_fe = j_fe-(r(mean))
	
	save "${data}/j_P1.dta", replace
	restore
	
*** AKM PERIOD 2
	use "${data}/akm.dta", replace
	
	keep if YEAR>=2013
	keep if cs==1
	
	egen rin = group(RIN)
	egen beid = group(sbeid)
	
	drop ft_factor_beid RIN cs
	
	reghdfe, compile
	ftools, compile
	
	// Model
	reghdfe log_real_hwage_bonus2 age age2 i.YEAR, absorb(i_fe = i.rin j_fe = i.beid) pool(1)
	
	*Saving fixed effects	
	preserve
	egen tag = tag(sbeid) if e(sample)==1
	keep if tag==1
	keep sbeid j_fe
	
	*Recenter with mean = 0
	sum j_fe
	replace j_fe = j_fe-(r(mean))
	
	save "${data}/j_P2.dta", replace
	restore
	
* --------------------------------------------------------------------------- */
* 2. ORGA WEIGHT (separately for t1 & t2)
* ---------------------------------------------------------------------------- * 

*** PERIOD 1
********************************************************************
*** Append the yearly Full Polis Size_Sector frequencies in one file
********************************************************************
	
	foreach year of num 2006/2012 {
		import excel "${tables}/wgt/SzSc_FP.xlsx", sheet("SzSc_`year'") clear
		
		rename (A B) (size_sect_real freq)
		gen YEAR = `year'
		order YEAR, before(size_sect_real)
		tempfile temp`year'
		save "`temp`year''"
	}
	*
	
	append using "`temp2006'" "`temp2007'" "`temp2008'" "`temp2009'" "`temp2010'" ///
		"`temp2011'" 
	sort size_sect_real YEAR
	
********************************************************************
*** Calculate the relevant frequencies for the sample
********************************************************************
	
	// Pool all years 
	bys size_sect_real: egen freq_all = total(freq)
	egen select = tag(size_sect_real)
	keep if select==1
	drop YEAR freq select
	// Calculate overall number of main jobs in 20+ employee orgas
	egen total_20 = total(freq_all) if size_sect_real>=5000
	// Calculate Size-Sector Frequencies for weight
	gen SzSc_FP_20 = freq_all / total_20
	drop freq_all total_20
	
	save "${data}/SzSc_P1.dta", replace
	
*** PERIOD 2
********************************************************************
*** Append the yearly Full Polis Size_Sector frequencies in one file
********************************************************************
	
	foreach year of num 2013/2018 {
		import excel "${tables}/wgt/SzSc_FP.xlsx", sheet("SzSc_`year'") clear
		
		rename (A B) (size_sect_real freq)
		gen YEAR = `year'
		order YEAR, before(size_sect_real)
		tempfile temp`year'
		save "`temp`year''"
	}
	*
	
	append using "`temp2013'" "`temp2014'" "`temp2015'" "`temp2016'" "`temp2017'"
	sort size_sect_real YEAR
	
********************************************************************
*** Calculate the Relevant frequencies for the sample
********************************************************************
	
	// Pool all years 
	bys size_sect_real: egen freq_all = total(freq)
	egen select = tag(size_sect_real)
	keep if select==1
	drop YEAR freq select
	// Calculate overall number of main jobs in 20+ employee orgas
	egen total_20 = total(freq_all) if size_sect_real>=5000
	// Calculate Size-Sector Frequencies for weight
	gen SzSc_FP_20 = freq_all / total_20
	drop freq_all total_20
	
	save "${data}/SzSc_P2.dta", replace
	
	
* --------------------------------------------------------------------------- */
* 3. SAMPLE PREPARATION (separately for t1 & t2)
* ---------------------------------------------------------------------------- *
	
	use "${data}/EBB_core_prep", replace

*** PERIOD 1

	merge m:1 sbeid using "${data}/j_P1.dta", keep(match) keepusing(j_fe) nogen

*********************
*** SAMPLE SELECTIONS
*********************

	*YEAR
	keep if YEAR<=2012

	*Drop respondents with missing wages
	drop if log_real_hwage_bonus2==.
	
	* Set age range to 16-65
	keep if EbbAflLft>=16 & EbbAflLft<=65
	
	// ISCO Major group 0
	*Drop armed forces
	keep if ISCO2008_4>=1000
	
	// Organizational size
	*Keep Organizations with 20+ employees
	keep if emplsize>=5 & emplsize<=10 
	
	// Duplicates
	*Drop persons who appear multiple times (Keep 1st observation)
	sort RIN YEAR
	bys RIN: gen rin_n = _n
	keep if rin_n==1
	drop rin_n
	
	// Drop 0- / Missing survey weights
	drop if EbbGewJaarGewichtA==0 | EbbGewJaarGewichtA==.
	
********************************
*** ORGANIZATIONS & OCCUPATIONS
********************************

	//Organization 
	*Keep organization clusters with 10+ employees
	bys beid: gen beid_N = _N
	drop if beid_N<10
	drop if beid==.
	drop beid_N
	
	//Occupation
	clonevar occ = ISCO2008_4
	recode occ (9999=.)
	
	*Occupation - ISCO08 first digit main groups
	gen big_occ = int(occ/1000)
	
	*Keep occupation clusters with 10+ employees
	bys occ: gen occ_N = _N
	drop if occ_N<10
	drop if occ==.
	drop occ_N
	
	// Min. 10 Rule
	*Second Iteration*
	bys beid: gen beid_N = _N
	drop if beid_N<10
	bys occ: gen occ_N = _N
	drop if occ_N<10
	drop beid_N occ_N
	
	*Third Iteration*
	bys beid: gen beid_N = _N
	drop if beid_N<10
	// -> no additional drop
	drop beid_N
	
	save "${posted}/EBB_core_analysis_P1", replace
	
	*Identify occupations
	egen tag = tag(occ)
	keep if tag==1
	keep occ
	sort occ
	save "${data}/occ_P1", replace

********************************************************************************
	
	use "${data}/EBB_core_prep", replace

	
	
*** PERIOD 2

	merge m:1 sbeid using "${data}/j_P2.dta", keep(match) keepusing(j_fe) nogen
	
*********************
*** SAMPLE SELECTIONS
*********************

	*YEAR
	keep if YEAR>=2013

	*Drop respondents with missing wages
	drop if log_real_hwage_bonus2==.
	
	* Set age range to 16-65
	keep if EbbAflLft>=16 & EbbAflLft<=65
	
	// ISCO Major group 0
	*Drop armed forces
	keep if ISCO2008_4>=1000
	
	// Organizational size
	*Keep Organizations with 20+ employees
	keep if emplsize>=5 & emplsize<=10 
	
	// Duplicates
	*Drop persons who appear multiple times (Keep 1st observation)
	sort RIN YEAR
	bys RIN: gen rin_n = _n
	keep if rin_n==1
	drop rin_n
	
	// Drop 0- / Missing survey weights
	drop if EbbGewJaarGewichtA==0 | EbbGewJaarGewichtA==.
	
********************************
*** ORGANIZATIONS & OCCUPATIONS
********************************

	//Organization 
	*Keep organization clusters with 10+ employees
	bys beid: gen beid_N = _N
	drop if beid_N<10
	drop if beid==.
	drop beid_N
	
	//Occupation
	clonevar occ = ISCO2008_4
	recode occ (9999=.)
		
	*Occupation - ISCO08 first digit main groups
	gen big_occ = int(occ/1000)
	
	*Keep occupation clusters with 10+ employees
	bys occ: gen occ_N = _N
	drop if occ_N<10
	drop if occ==.
	drop occ_N
	
	// Min. 10 Rule
	*Second Iteration*
	bys beid: gen beid_N = _N
	drop if beid_N<10
	bys occ: gen occ_N = _N
	drop if occ_N<10
	drop beid_N occ_N
	
	*Third Iteration*
	bys beid: gen beid_N = _N
	drop if beid_N<10
	// -> no additional drop
	drop beid_N
	
	save "${posted}/EBB_core_analysis_P2", replace
	
	*Identify occupations
	egen tag = tag(occ)
	keep if tag==1
	keep occ
	sort occ
	save "${data}/occ_P2", replace

	****************************************************************************
	*Identify shared occupations
	merge 1:1 using "${data}/occ_P1"
	keep if _merge==3
	drop _merge
	gen sample=1
	save "${data}/occ_ALL", replace
	erase "${data}/occ_P1"
	erase "${data}/occ_P2"
	****************************************************************************
	
	*Reduce to comparable occupation set
	foreach x of num 1/2 {
		use "${posted}/EBB_core_analysis_P`x'", replace
		merge m:1 occ using "${data}/occ_ALL"
		keep if sample==1
		drop sample

		bys beid: gen beid_N = _N
		drop if beid_N<10
		bys occ: gen occ_N = _N
		drop if occ_N<10
		drop beid_N occ_N
		save "${posted}/EBB_core_analysis_P`x'", replace
	}
	*
	
**************************************
*** Construct Final Weights (Period 1)
**************************************

	use "${posted}/EBB_core_analysis_P1", replace

*** Preparation of HOURS weights
	// Already calculated (defined as usual hours worked by week given POLIS info)
	gen hours_wgt = ft_factor_beid
	
*** Preparation of ORGA weights
	*Merge prepared Full Polis frequencies
	merge m:1 size_sect_real using "${data}/SzSc_P1.dta", keepusing(SzSc_FP_20) ///	
		keep(matched master) nogen
	
	*Calculate EBB frequencies
	bys size_sect_real: gen SzSc_freq_EBB = _N
	gen SzSc_freq_EBB_tot = _N
	gen SzSc_EBB = SzSc_freq_EBB/SzSc_freq_EBB_tot
	
	*Calculate Organizational Weights 
	gen orga_wgt = SzSc_FP_20/SzSc_EBB
	sum orga_wgt // Looks good average approximates 1 and its normally distributed
	drop if orga_wgt==.
	drop SzSc_FP_20 SzSc_freq_EBB SzSc_freq_EBB_tot SzSc_EBB
	
*** Preparation of SURVEY Weights (all survey weights of a specific year sum up to 1)
	* (Use here EbbAflJaar - the reporting year on which the EBB weights are based)
	bys EbbAflJaar: egen sum_svyw = sum(EbbGewJaarGewichtA)
	gen svy_wgt = (EbbGewJaarGewichtA/sum_svyw)
	bys EbbAflJaar: egen chk_svywgt = sum(svy_wgt)
	bys EbbAflJaar: assert round(chk_svywgt)==1
	drop sum_svyw chk_svywgt
	
*** Preparation of YEARLY Weights
	bys YEAR: gen YEAR_freq = _N
	gen YEAR_freq_tot = _N
	gen YEAR_EBB = YEAR_freq/YEAR_freq_tot
	gen year_wgt = (1/13)/YEAR_EBB
	drop YEAR_freq YEAR_freq_tot YEAR_EBB
	
*** Combined Weight 
	gen w = svy_wgt*year_wgt*orga_wgt*hours_wgt
	
	*Rescale weight
	egen sum_w = sum(w)
	gen N=_N
	gen wgt = (w/sum_w)*N
	egen chk_wgt = sum(wgt)
	assert round(chk_wgt)==N
	drop w sum_w chk_wgt
	sum wgt
	
********************************
*** Reduce Variables (Period 1)
********************************

	keep RIN sbeid beid edu_cat3 edu_cat5 edu_cat8 edu_cat18 EbbAflHoelanGel1 ///
		EbbAflHerkomstGBA2d log_real_hwage_bonus2 log_real_hwage real_hwage_bonus2 ///
		real_hwage occ big_occ wgt female age age_int j_fe ssect emplsize sector ///
		industry ssoortbaan YEAR
		
	save "${posted}/EBB_core_analysis_P1", replace
	
	
**************************************
*** Construct Final Weights (Period 2)
**************************************

	use "${posted}/EBB_core_analysis_P2", replace

*** Preparation of HOURS weights
	// Already calculated (defined as usual hours worked by week given POLIS info)
	gen hours_wgt = ft_factor_beid
	
*** Preparation of ORGA weights
	*Merge prepared Full Polis frequencies
	merge m:1 size_sect_real using "${data}/SzSc_P2.dta", keepusing(SzSc_FP_20) ///	
		keep(matched master) nogen
	
	*Calculate EBB frequencies
	bys size_sect_real: gen SzSc_freq_EBB = _N
	gen SzSc_freq_EBB_tot = _N
	gen SzSc_EBB = SzSc_freq_EBB/SzSc_freq_EBB_tot
	
	*Calculate Organizational Weights 
	gen orga_wgt = SzSc_FP_20/SzSc_EBB
	sum orga_wgt // Looks good average approximates 1 and its normally distributed
	drop if orga_wgt==.
	drop SzSc_FP_20 SzSc_freq_EBB SzSc_freq_EBB_tot SzSc_EBB
	
*** Preparation of SURVEY Weights (all survey weights of a specific year sum up to 1)
	* (Use here EbbAflJaar - the reporting year on which the EBB weights are based)
	bys EbbAflJaar: egen sum_svyw = sum(EbbGewJaarGewichtA)
	gen svy_wgt = (EbbGewJaarGewichtA/sum_svyw)
	bys EbbAflJaar: egen chk_svywgt = sum(svy_wgt)
	bys EbbAflJaar: assert round(chk_svywgt)==1
	drop sum_svyw chk_svywgt
	
*** Preparation of YEARLY Weights
	bys YEAR: gen YEAR_freq = _N
	gen YEAR_freq_tot = _N
	gen YEAR_EBB = YEAR_freq/YEAR_freq_tot
	gen year_wgt = (1/13)/YEAR_EBB
	drop YEAR_freq YEAR_freq_tot YEAR_EBB
	
*** Combined Weight 
	gen w = svy_wgt*year_wgt*orga_wgt*hours_wgt
	
	*Rescale weight
	egen sum_w = sum(w)
	gen N=_N
	gen wgt = (w/sum_w)*N
	egen chk_wgt = sum(wgt)
	assert round(chk_wgt)==N
	drop w sum_w chk_wgt
	sum wgt
	
********************************
*** Reduce Variables (Period 2)
********************************

	keep RIN sbeid beid edu_cat3 edu_cat5 edu_cat8 edu_cat18 EbbAflHoelanGel1 ///
		EbbAflHerkomstGBA2d log_real_hwage_bonus2 log_real_hwage real_hwage_bonus2 ///
		real_hwage occ big_occ wgt female age age_int j_fe3 ssect emplsize sector ///
		industry ssoortbaan YEAR
		
	save "${posted}/EBB_core_analysis_P2", replace
	
	
* --------------------------------------------------------------------------- */
* 4. ANALYSIS (Period 1) 
* ---------------------------------------------------------------------------- *

	use "${posted}/EBB_core_analysis_P1", replace

	global controls female age age_int 

	//We prepare z-scores to recover meaningful effects on the residual variance
	*Individual-level controls
	foreach var of var $controls {
		egen z_`var'=std(`var')
	}
	*
	global zcontrols z_female z_age z_age_int
	*Organizational FE from AKM Model
	egen z_j_fe=std(j_fe)
	
	*YEAR FE
	tab YEAR, gen(year_)
	foreach x of num 1/7 {
		egen z_year`x'=std(year_`x')
	}
	drop year_*
	global z_year z_year2 z_year3 z_year4 z_year5 z_year6 z_year7 
	
	*Organizational size
	tab emplsize, gen(emplsize_)
	foreach x of num 2/6 {
		egen z_emplsize`x'=std(emplsize_`x')
	}
	drop emplsize_?
	global z_emplsize z_emplsize2 z_emplsize3 z_emplsize4 z_emplsize5 z_emplsize6
	
	*Sector
	tab sector, gen(sector_)
	foreach x of num 2/3 {
		egen z_sector`x'=std(sector_`x')
	}
	drop sector_?
	global z_sector z_sector2 z_sector3 
	
	*Industry
	tab industry, gen(industry_)
	foreach x of num 1/19 {
		egen z_industry`x'=std(industry_`x')
	}
	drop industry_*
	global z_industry z_industry1 z_industry2 z_industry4 z_industry5 z_industry6 ///
		z_industry7 z_industry8 z_industry9 z_industry10 z_industry11 z_industry12 ///
		z_industry13 z_industry14 z_industry15 z_industry16 z_industry17 z_industry18 ///
		z_industry19
		
******************************************	
*** RETRIEVE GRAND MEAN & OVERALL VARIANCE
******************************************
 
	sum log_real_hwage_bonus2 [aw=wgt], det
	gen totvar=r(Var)
	gen mwage=r(mean)
	
*******************************************
*** OCCUPATION BETWEEN- / WITHIN-VARIANCE
*******************************************
	
	//Model 1 - Baseline
	areg log_real_hwage_bonus2 [aw=wgt], a(occ)
	predict alpha1_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 [aw=wgt], a(occ)
	predict d_var, d
	gen delta1_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 2 - Individual-level covariates
	areg log_real_hwage_bonus2 ${zcontrols} ${z_year} [aw=wgt], a(occ)
	predict alpha2_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta2_occ=_b[_cons]+d_var
	drop res res2 d_var
	

	//Model 3 - Individual-level covariates + Organizations
	*Set Organization controls
	tab beid, gen(beid_)
	
	foreach var of varlist beid_* {
		egen z_`var'=std(`var')
		drop `var'
	}
	*
	
	global zcontrols_org z_female z_age z_age_int z_beid_*
	
	areg log_real_hwage_bonus2 ${zcontrols_org} ${z_year} [aw=wgt], a(occ)
	predict alpha3_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols_org} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta3_occ=_b[_cons]+d_var
	drop res res2 d_var
	drop z_beid_*
	
	
	//Model 4 - Individual-level covariates + Firm FE from AKM-model
	areg log_real_hwage_bonus2 ${zcontrols} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha4_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta4_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	///
	*Additional analysis - where do firm effects come from?
	///
	
	//Model 5 - Individual-level covariates + Firm Size
	areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_year} [aw=wgt], a(occ)
	predict alpha5_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_emplsize} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta5_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 6 - Individual-level covariates + Sector
	areg log_real_hwage_bonus2 ${zcontrols} ${z_sector} ${z_year} [aw=wgt], a(occ)
	predict alpha6_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_sector} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta6_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 7 - Individual-level covariates + Industry
	areg log_real_hwage_bonus2 ${zcontrols} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict alpha7_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta7_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 8 - Individual-level covariates + all firm-level controls
	areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict alpha8_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta8_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 9 - Individual-level covariates + Industry + Firm FE
	areg log_real_hwage_bonus2 ${zcontrols} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha9_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta9_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 10 - Individual-level covariates + all firm-level controls + Firm FE
	areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha10_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta10_occ=_b[_cons]+d_var
	drop res res2 d_var
		
		
	//Collapse by Occupations
	collapse	(mean) big_occ mwage totvar mwage_occ=log_real_hwage_bonus2 ///
					alpha*_occ delta*_occ ///
				(sd) sd_occ=log_real_hwage_bonus2 ///
				(rawsum) n=wgt ///
				[aw=wgt] ///
				,by(occ)
	
	gen var_occ = sd_occ*sd_occ
	egen N = total(n)
	gen p = n/N
	
	foreach x of num 1/10 {
		egen between`x' = total(p*(alpha`x'_occ)^2)
		egen within`x' = total(p*delta`x'_occ)
		gen total`x' = between`x' + within`x'
	}
	*
	
	keep between* within* total*
	keep in 1
	gen style = "P1"
	reshape long between within total, i(style) j(model)
	
	save "${posted}/timetrend.dta", replace
	
* --------------------------------------------------------------------------- */
* 5. ANALYSIS (Period 2) 
* ---------------------------------------------------------------------------- *

	use "${posted}/EBB_core_analysis_P2", replace

	global controls female age age_int 

	//We prepare z-scores to recover meaningful effects on the residual variance
	*Individual-level controls
	foreach var of var $controls {
		egen z_`var'=std(`var')
	}
	*
	global zcontrols z_female z_age z_age_int
	*Organizational FE from AKM Model
	egen z_j_fe=std(j_fe)
	
	*YEAR FE
	tab YEAR, gen(year_)
	foreach x of num 1/6 {
		egen z_year`x'=std(year_`x')
	}
	drop year_*
	global z_year z_year2 z_year3 z_year4 z_year5 z_year6 
	
	*Organizational size
	tab emplsize, gen(emplsize_)
	foreach x of num 2/6 {
		egen z_emplsize`x'=std(emplsize_`x')
	}
	drop emplsize_?
	global z_emplsize z_emplsize2 z_emplsize3 z_emplsize4 z_emplsize5 z_emplsize6
	
	*Sector
	tab sector, gen(sector_)
	foreach x of num 2/3 {
		egen z_sector`x'=std(sector_`x')
	}
	drop sector_?
	global z_sector z_sector2 z_sector3 
	
	*Industry
	tab industry, gen(industry_)
	foreach x of num 1/19 {
		egen z_industry`x'=std(industry_`x')
	}
	drop industry_*
	global z_industry z_industry1 z_industry2 z_industry4 z_industry5 z_industry6 ///
		z_industry7 z_industry8 z_industry9 z_industry10 z_industry11 z_industry12 ///
		z_industry13 z_industry14 z_industry15 z_industry16 z_industry17 z_industry18 ///
		z_industry19
		
******************************************	
*** RETRIEVE GRAND MEAN & OVERALL VARIANCE
******************************************
 
	sum log_real_hwage_bonus2 [aw=wgt], det
	gen totvar=r(Var)
	gen mwage=r(mean)
	
*******************************************
*** OCCUPATION BETWEEN- / WITHIN-VARIANCE
*******************************************
	
	//Model 1 - Baseline
	areg log_real_hwage_bonus2 [aw=wgt], a(occ)
	predict alpha1_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 [aw=wgt], a(occ)
	predict d_var, d
	gen delta1_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 2 - Individual-level covariates
	areg log_real_hwage_bonus2 ${zcontrols} ${z_year} [aw=wgt], a(occ)
	predict alpha2_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta2_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	
	//Model 3 - Individual-level covariates + Organizations
	*Set Organization controls
	tab beid, gen(beid_)
	
	foreach var of varlist beid_* {
		egen z_`var'=std(`var')
		drop `var'
	}
	*
	
	global zcontrols_org z_female z_age z_age_int z_beid_*
	
	areg log_real_hwage_bonus2 ${zcontrols_org} ${z_year} [aw=wgt], a(occ)
	predict alpha3_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols_org} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta3_occ=_b[_cons]+d_var
	drop res res2 d_var
	drop z_beid_*
	
	
	//Model 4 - Individual-level covariates + Firm FE from AKM-model
	areg log_real_hwage_bonus2 ${zcontrols} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha4_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta4_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	///
	*Additional analysis - where do firm effects come from?
	///
	
	//Model 5 - Individual-level covariates + Firm Size
	areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_year} [aw=wgt], a(occ)
	predict alpha5_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_emplsize} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta5_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 6 - Individual-level covariates + Sector
	areg log_real_hwage_bonus2 ${zcontrols} ${z_sector} ${z_year} [aw=wgt], a(occ)
	predict alpha6_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_sector} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta6_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 7 - Individual-level covariates + Industry
	areg log_real_hwage_bonus2 ${zcontrols} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict alpha7_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta7_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 8 - Individual-level covariates + all firm-level controls
	areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict alpha8_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta8_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 9 - Individual-level covariates + Industry + Firm FE
	areg log_real_hwage_bonus2 ${zcontrols} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha9_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta9_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 10 - Individual-level covariates + all firm-level controls + Firm FE
	areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha10_occ, d
	predict res, residual
	gen res2=res^2
	areg res2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta10_occ=_b[_cons]+d_var
	drop res res2 d_var
		
		
	//Collapse by Occupations
	collapse	(mean) big_occ mwage totvar mwage_occ=log_real_hwage_bonus2 ///
					alpha*_occ delta*_occ ///
				(sd) sd_occ=log_real_hwage_bonus2 ///
				(rawsum) n=wgt ///
				[aw=wgt] ///
				,by(occ)
	
	gen var_occ = sd_occ*sd_occ
	egen N = total(n)
	gen p = n/N
	
	foreach x of num 1/10 {
		egen between`x' = total(p*(alpha`x'_occ)^2)
		egen within`x' = total(p*delta`x'_occ)
		gen total`x' = between`x' + within`x'
	}
	*
	
	keep between* within* total*
	keep in 1
	gen style = "P2"
	reshape long between within total, i(style) j(model)
	
	append using "${posted}/timetrend.dta"
	save "${posted}/timetrend.dta", replace
	
* --------------------------------------------------------------------------- */
* 6. CLOSE LOG FILE
* ---------------------------------------------------------------------------- *

	log close
	
	