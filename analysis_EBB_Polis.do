/*=============================================================================* 
* ANALYSIS - EBB-Polis Sample
*==============================================================================*
 	Project: Occupations, Organizations, and Wage Inequality
	Author: Christoph Janietz (University of Amsterdam)
	Article: Janietz, C. & Bol, T. (2020).
			 Occupations, organizations, and the structure of wage inequality in 
			 the Netherlands.
			 Research in Social Stratification and Mobility 70
			 https://doi.org/10.1016/j.rssm.2019.100468
	Last update: 18-11-2019
	
	Purpose: Produces estimates for Table 1; Table A1; Figure 1-9 in the final 
			 article
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		0.  Settings 
		1. 	Z-Scores
		2. 	Sample Descriptives
		3.  Data Preparation for Graphs
		4.  Mean Firm Effects by Selected Covariates
		5.  Regressions - Decomposition by Organizations
		6.  Regressions - Decomposition by Occupations
		7.  Close log file
		
* --------------------------------------------------------------------------- */
* 0. SETTINGS 
* ---------------------------------------------------------------------------- * 

*** Settings - run config file
	global dir 			"H:/Christoph/art1"
	do 					"${dir}/06_dofiles/config"
	
*** Open log file
	log using 			"$logfiles/03_analysis_EBB_polis.log", replace
	
	
* --------------------------------------------------------------------------- */
* 1. Z-SCORES
* ---------------------------------------------------------------------------- *

	use "${posted}/EBB_core_analysis", replace

	global controls female age age_int 

	//We prepare z-scores to recover meaningful effects on the residual variance
	*Individual-level controls
	foreach var of var $controls {
		egen z_`var'=std(`var')
	}
	*
	global zcontrols z_female z_age z_age_int
	*Organizational FE from AKM Model
	egen z_j_fe=std(j_fe3)
	
	*YEAR FE
	tab YEAR, gen(year_)
	foreach x of num 1/13 {
		egen z_year`x'=std(year_`x')
	}
	drop year_*
	global z_year z_year2 z_year3 z_year4 z_year5 z_year6 z_year7 z_year8 ///
		z_year9 z_year10 z_year11 z_year12 z_year13
	
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
	
	
* --------------------------------------------------------------------------- */
* 2. SAMPLE DESCRIPTIVES
* ---------------------------------------------------------------------------- *

	
******************************************	
*** RETRIEVE GRAND MEAN & OVERALL VARIANCE
******************************************
 
	sum log_real_hwage_bonus2 [aw=wgt], det
	gen totvar=r(Var)
	gen mwage=r(mean)

********************************	
***  TABLE 1
********************************
	* Structures: Nr. of unique occupations and organizations (Min / Max Cluster Size)
	* Wage: Grand mean & SD
	* Covariates: Gender, Age, [Migback, Education, Tenure]
	* Organizations: Bonus Generosity
	*(Weighted)
	
	putexcel set "${tables}/descr/sample_descr", sheet("sample") modify
	
	putexcel A1 = ("Variables") B1 = ("Source") C1 = ("n") D1 = ("Mean") ///
	E1 = ("SD") F1 = ("Min") G1 = ("Max"), colwise

	sum log_real_hwage_bonus2 [aw=wgt]
	putexcel A2 = ("Log hourly wage") B2 = ("POLIS") C2 = (r(N)) D2 = (r(mean)) ///
		E2 = (r(sd)) F2 = (r(min)) G2 = (r(max)), colwise
	putexcel A3 = ("Ind. Controls"), colwise
	sum female [aw=wgt]
	putexcel A4 = ("Female") B4 = ("EBB") C4 = (r(N)) D4 = (r(mean)) E4 = ("") ///
		F4 = (r(min)) G4 = (r(max)), colwise
	sum age [aw=wgt]
	putexcel A5 = ("Age") B5 = ("EBB") C5 = (r(N)) D5 = (r(mean)) E5 = (r(sd)) ///
		F5 = (r(min)) G5 = (r(max)), colwise
	putexcel A6 = ("Org. Controls"), colwise
	sum j_fe3 [aw=wgt]
	putexcel A7 = ("Firm FEs") B7 = ("POLIS (AKM model)") ///
		C7 = (r(N)) D7 = (r(mean)) E7 = (r(sd)) F7 = (r(min)) G7 = (r(max)), colwise
	putexcel A8 = ("Structures") B8 = ("Source") C8 = ("N") D8 = ("Min") ///
		E8 = ("Max"), colwise
	distinct beid 
	putexcel A9 = ("Organizations") B9 = ("POLIS") C9 = (r(ndistinct)), colwise
	distinct occ
	putexcel A10 = ("Occupations") B10 = ("EBB") C10 = (r(ndistinct)), colwise
	bys occ: gen N_occ = _N
	bys beid: gen N_sbeid = _N
	sum N_sbeid
	putexcel D9 = (r(min)) E9 = (r(max)), colwise
	sum N_occ
	putexcel D10 = (r(min)) E10 = (r(max)), colwise

	
* --------------------------------------------------------------------------- */
* 3. DATA PREPARATION FOR GRAPHS
* ---------------------------------------------------------------------------- *
	
********************************	
***  Figure 1 - Percentile Graph
********************************

	clonevar log = log_real_hwage_bonus2
	clonevar real = real_hwage_bonus2
	
	foreach wage of var log real {
	foreach var of var occ beid {
		preserve
		collapse (mean) mwage_`var'= `wage' ///
				 [aw=wgt] ///
				 ,by(`var')
		xtile percentile = mwage_`var', n(100)
		collapse (median) mwage_`var' ///
				 ,by(percentile)
		tempfile temp`var'
		save "`temp`var''"
		restore
	}
	*
	
	preserve
	xtile percentile = `wage' [aw=wgt], n(100)
	collapse (median) mwage_pers=`wage' ///
			[aw=wgt] ///
			,by(percentile)
	
	merge 1:1 percentile using "`tempocc'", nogen
	merge 1:1 percentile using "`tempbeid'", nogen
	save "${posted}/`wage'percentile_pers_occ_beid", replace
	restore
	}
	*
	drop log real
	// Final graph produced in R
	
	
*****************************************	
***  WITHIN OCCUPATION Deciles of Firm FE
*****************************************
	
	// Generate the within-occupation deciles
/*  levelsof occ, local(occ)
	gen decile=.
	foreach x of local occ {
		xtile p_occ = z_j_fe if occ==`x' [aw=wgt], n(10)
		if `x'==1000 {
		replace decile = p_occ
		}
		else {
		replace decile = p_occ if decile==.
		}
		drop p_occ
	}
	*
	preserve
	collapse (median) z_j_fe big_occ ///
			,by(occ decile)
	save "${posted}/firmfe_within_occ", replace
	collapse (median) z_j_fe ///
			,by(big_occ decile)
	save "${posted}/firmfe_within_bigocc", replace
	restore
	drop decile
*/			
	
			
*********************************************************************	
***  Figure 5/7/8 - Average Firm FE by occ & Counterfactual Analysis
*********************************************************************
	
	// Generate counterfactual wage
	preserve
	gen cf_wage = log_real_hwage_bonus2-(j_fe3)
	
	// Collapse on occupational level
	collapse (mean) mean_occ_fac=log_real_hwage_bonus2 mean_occ_cf=cf_wage ///
			  mean_occ_realwage=real_hwage_bonus2 mean_firm_fe=z_j_fe big_occ ///
			 (sd) sd_occ_fac=log_real_hwage_bonus2 sd_occ_cf=cf_wage ///
			 (rawsum) n=wgt ///
			 [aw=wgt] ///
			 ,by(occ)
	
	// Calculate sd/mean rank-order
	sort sd_occ_fac
	gen r_sd = _n
	
	sort mean_occ_fac
	gen r_mean = _n
	
	// Calculate relative proportion
	egen N = total(n)
	gen p = n/N
	
	// Calculate occupational variance
	gen var_occ_fac= sd_occ_fac*sd_occ_fac
	gen var_occ_cf= sd_occ_cf*sd_occ_cf
	
	// Calculate grand mean (factual & counterfactual)
	egen mwage_fac = total(p*(mean_occ_fac))
	egen mwage_cf = total(p*(mean_occ_cf))
	
	*Change parameters*
	// Absolute change
	gen diff_mean = mean_occ_cf-mean_occ_fac
	gen diff_sd = sd_occ_cf-sd_occ_fac
	
	// Relative Change
	gen change_mean = ((mean_occ_cf/mean_occ_fac)-1)*100
	gen change_sd = ((sd_occ_cf/sd_occ_fac)-1)*100
	
	*VAR Components*
	// Calculate between-occupation inequality (factual & counterfactual)
	egen between_fac = total(p*(mean_occ_fac-mwage_fac)^2)
	egen between_cf = total(p*(mean_occ_cf-mwage_cf)^2)
	
	// Calculate within-occupation inequality (factual & counterfactual)
	egen within_fac = total(p*var_occ_fac)
	egen within_cf = total(p*var_occ_cf)
	
	save "${posted}/cf_analysis.dta", replace
	restore	
	
* --------------------------------------------------------------------------- */
* 4. Mean Firm Fixed Effects by Selected Covariates (Figure 3)
* ---------------------------------------------------------------------------- *
	
	putexcel set "${tables}/descr/firmfe_by_sub", modify
	putexcel A1 = ("variable") B1 = ("value") C1 = ("estimate") C1 = ("lb") C1 = ("ub")
	local row=2
	foreach var of var emplsize-industry {
		mean z_j_fe [aw=wgt], over(`var')
		local levels = e(over_namelist)
		foreach val of local levels {
			lincom `val'
			putexcel A`row' = ("`var'") B`row' = ("`val'") C`row' = (r(estimate)) ///
				D`row' = (r(lb)) E`row' = (r(ub)), colwise
			local ++row
		}
	}
	*
	putexcel clear	
	
* --------------------------------------------------------------------------- */
* 5. Regressions - Decomposition by Organization
* ---------------------------------------------------------------------------- *
	
*******************************************
*** ORGANIZATION BETWEEN- / WITHIN-VARIANCE
*******************************************
	
	//MODEL 1 - Baseline
	eststo: areg log_real_hwage_bonus2 [aw=wgt], a(beid)
	predict alpha1_org, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 [aw=wgt], a(beid)
	predict d_var, d
	gen delta1_org=_b[_cons]+d_var
	drop res res2 d_var
	
	//MODEL 2 - Individual-level covariates
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_year} [aw=wgt], a(beid)
	predict alpha2_org, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_year} [aw=wgt], a(beid)
	predict d_var, d
	gen delta2_org=_b[_cons]+d_var
	drop res res2 d_var
	
	//MODEL 3 - Individual-level covariates + Occupations
	*Set Occupation controls
	tab occ, gen(occ_)
	
	foreach var of varlist occ_* {
		egen z_`var'=std(`var')
	}
	*
	drop occ_*
	
	global zcontrols_occ z_female z_age z_age_int z_occ_*
	
	eststo: areg log_real_hwage_bonus2 ${zcontrols_occ} ${z_year} [aw=wgt], a(beid)
	predict alpha3_org, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols_occ} ${z_year} [aw=wgt], a(beid)
	predict d_var, d
	gen delta3_org=_b[_cons]+d_var
	drop res res2 d_var
	
	*Drop occupation controls
	drop z_occ_*
	
	*Save regression estimates
	esttab using "${tables}/regression/reg_org.csv", replace se r2 ar2 nobaselevels ///
		keep(z_female z_age z_age_int _cons)
	est clear
	
	//Collapse by ORGA
	preserve
	collapse	(mean) mwage mwage_org=log_real_hwage_bonus totvar ///
					alpha?_org delta?_org ///
				(rawsum) n=wgt ///
				[aw=wgt] ///
				,by(beid)
	
	egen N = total(n)
	gen p = n/N
	
	foreach x of num 1/3 {
		egen between`x' = total(p*(alpha`x'_org)^2)
		egen within`x' = total(p*delta`x'_org)
		gen total`x' = between`x' + within`x'
	}
	*
	
	// Save estimates
	save "${posted}/INEQ_org.dta", replace
	restore
	
	drop alpha1_org-delta3_org


* --------------------------------------------------------------------------- */
* 6. Regressions - Decomposition by Occupation
* ---------------------------------------------------------------------------- *
	
*******************************************
*** OCCUPATION BETWEEN- / WITHIN-VARIANCE
*******************************************
	
	//Model 1 - Baseline
	eststo: areg log_real_hwage_bonus2 [aw=wgt], a(occ)
	predict alpha1_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 [aw=wgt], a(occ)
	predict d_var, d
	gen delta1_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 2 - Individual-level covariates
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_year} [aw=wgt], a(occ)
	predict alpha2_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_year} [aw=wgt], a(occ)
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
	
	eststo: areg log_real_hwage_bonus2 ${zcontrols_org} ${z_year} [aw=wgt], a(occ)
	predict alpha3_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols_org} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta3_occ=_b[_cons]+d_var
	drop res res2 d_var
	drop z_beid_*
	
	//Model 4 - Individual-level covariates + Firm FE from AKM-model
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha4_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta4_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	*Model 4_Int - Individual-level covariates + Firm FE from AKM-model
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_year} z_j_fe c.z_j_fe#i.occ [aw=wgt], a(occ)
	*Recover the occupation-specific effects of firm premiums
	levelsof occ, local(occ)
	gen firmfe_occ=.
	foreach x of local occ {
		if `x'==1000 {
		replace firmfe_occ = _b[z_j_fe]
		}
		else {
		replace firmfe_occ = _b[z_j_fe]+_b[`x'.occ#c.z_j_fe] if occ==`x'
		}
	}
	*
	
	///
	*Additional analysis - where do firm effects come from?
	///
	
	//Model 5 - Individual-level covariates + Firm Size (not in final manuscript)
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_year} [aw=wgt], a(occ)
	predict alpha5_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_emplsize} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta5_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 6 - Individual-level covariates + Sector (not in final manuscript)
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_sector} ${z_year} [aw=wgt], a(occ)
	predict alpha6_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_sector} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta6_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 7 - Individual-level covariates + Industry
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict alpha7_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta7_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 8 - Individual-level covariates + all firm-level controls (not in final manuscript)
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict alpha8_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} [aw=wgt], a(occ)
	predict d_var, d
	gen delta8_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 9 - Individual-level covariates + Industry + Firm FE
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha9_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta9_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	//Model 10 - Individual-level covariates + all firm-level controls + Firm FE (not in final manuscript)
	eststo: areg log_real_hwage_bonus2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict alpha10_occ, d
	predict res, residual
	gen res2=res^2
	eststo: areg res2 ${zcontrols} ${z_emplsize} ${z_sector} ${z_industry} ${z_year} z_j_fe [aw=wgt], a(occ)
	predict d_var, d
	gen delta10_occ=_b[_cons]+d_var
	drop res res2 d_var
	
	
	*Save regression estimates
	esttab using "${tables}/regression/reg_occ.csv", replace se(%9.4g) r2 ar2 nobaselevels ///
		keep(z_female z_age z_age_int z_j_fe z_emplsize2 z_emplsize3 z_emplsize4 ///
		z_emplsize5 z_emplsize6 z_sector2 z_sector3 _cons) b(%9.4g)
	est clear
		
		
	//Collapse by Occupations
	preserve
	collapse	(mean) big_occ mwage totvar mwage_occ=log_real_hwage_bonus2 ///
					alpha*_occ delta*_occ firmfe_occ ///
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
	
	
	// Save estimates
	save "${posted}/INEQ_occ.dta", replace
	restore
	
	
	// Add Interaction effect also to cf_analysis (for graphs)
	preserve
	use "${posted}/cf_analysis.dta", replace
	merge 1:1 occ using "${posted}/INEQ_occ.dta", keepusing(firmfe_occ) nogen
	save "${posted}/cf_analysis.dta", replace
	restore
	
********************************************************************************
*** Prepare estimates for Decomposition bar charts in r (Figure 2 / 4 / 6)
********************************************************************************
	
	preserve
	local o=1
	foreach x in occ org {
		use "${posted}/INEQ_`x'.dta", replace
		keep between* within* total*
		keep in 1
		gen struc = "`x'"
		reshape long between within total, i(struc) j(model)
		tempfile temp`x'
		save "`temp`x''"
		local ++o
	}
	*
	append using "`tempocc'"
	save "${posted}/decomposition.dta", replace
	restore
	
* --------------------------------------------------------------------------- */
* 8. CLOSE LOG FILE
* ---------------------------------------------------------------------------- *

	log close
