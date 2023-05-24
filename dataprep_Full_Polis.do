/*=============================================================================* 
* DATA PREPARATIONS - Full Polis
*==============================================================================*
 	Project: Occupations, Organizations, and Wage Inequality
	Author: Christoph Janietz (University of Amsterdam)
	Article: Janietz, C. & Bol, T. (2020).
			 Occupations, organizations, and the structure of wage inequality in 
			 the Netherlands.
			 Research in Social Stratification and Mobility 70
			 https://doi.org/10.1016/j.rssm.2019.100468
	Last update: 18-11-2019
	
	Purpose: Calculation of relative size-sector frequencies (worker level) for
			 organizational reweighting procedure.
			 Preparation and estimation of AKM decomposition with full workforce
			 (see Table 2 in final article).
* ---------------------------------------------------------------------------- *

	INDEX: 
		0.  Settings 
		1. 	Prepare full (S)polis
		2. 	ORGA WEIGHT: Size-Sector Frequencies for reweighting of EBB sample
		3.  AKM Models (for firm FE)
		4.  Close log file
	
* --------------------------------------------------------------------------- */
* 0. SETTINGS 
* ---------------------------------------------------------------------------- * 

*** Settings - run config file
	global dir 			"H:/Christoph/art1"
	do 					"${dir}/06_dofiles/config"
	
*** Open log file
	log using 			"$logfiles/02_fullpolis.log", replace

* --------------------------------------------------------------------------- */
* 1. PREPARE FULL (S)POLIS 
* ---------------------------------------------------------------------------- *

*** TABLE: Average of BEID affiliations 
	putexcel set "${tables}/descr/fp_descr", sheet("PERS_BEID") replace
	putexcel A1 = ("Year") B1 = ("Unique_PERS_BEID") C1 = ("Unique_PERS"), colwise
	
******************************************************************
*** Select Main Job (Highest Paying BEID) & Aggregate at Job-Level
******************************************************************

*** 2006-2009: POLIS
	local row=2
	foreach year of num 2006/2009 {
		use rinpersoons rinpersoon baanrugid aanvbus eindbus baandagen basisloon ///
			basisuren bijzonderebeloning extrsal incidentsal lningld lnowrk ///
			overwerkuren reisk vakbsl voltijddagen contractsoort polisdienstverband ///
			beid caosector datumaanvangikv datumeindeikv sect soortbaan ///
			using "${polis`year'}", replace
		
		*Harmonize variable names
		foreach var of var baandagen basisloon basisuren bijzonderebeloning extrsal ///
			incidentsal lningld lnowrk overwerkuren reisk vakbsl voltijddagen ///
			contractsoort polisdienstverband beid caosector datumaanvangikv ///
			datumeindeikv sect soortbaan {
			rename `var' s`var' 
		}
		rename (aanvbus eindbus) (sdatumaanvangiko sdatumeindeiko)
	
		*Summarize Total Earnings per person - establishment (defines main job)
		bys rinpersoons rinpersoon sbeid: egen slningld_caly_beid = total(slningld)
		bys rinpersoons rinpersoon: egen max_slningld_caly_beid = max(slningld_caly_beid)
		
		// Check & Export: Average Nr. of BEID Affiliations
		putexcel set "${tables}/descr/fp_descr", sheet("PERS_BEID") modify
		putexcel A`row' = (`year')
		egen rin_beid = tag(rinpersoons rinpersoon sbeid)
		count if rin_beid==1
		putexcel B`row' = (r(N))
		egen rin = tag(rinpersoons rinpersoon)
		count if rin==1
		putexcel C`row' = (r(N))
		drop rin_beid rin
	
		************************************************************************
		// SELECTION - Main job = Beid affiliation with highest overall earnings in caly
		************************************************************************
		keep if (slningld_caly_beid==max_slningld_caly_beid)
		sort rinpersoons rinpersoon baanrugid sdatumaanvangiko
		drop max_slningld_caly_beid
		
		*Prepare date indicators
		gen job_start_exact = date(sdatumaanvangiko, "YMD")
		gen job_end_exact = date(sdatumeindeiko, "YMD")
		gen job_start_caly = date(sdatumaanvangikv, "YMD")
		gen job_end_caly = date(sdatumeindeikv, "YMD")
		format job_start_exact job_end_exact job_start_caly job_end_caly %d

		************************************************************************
		*JOB Summary statistics for whole calendar year (all obs per unique job ID)
		************************************************************************
		foreach var of var sbaandagen-svoltijddagen {
			bys baanrugid: egen `var'_caly = total(`var')
		}
		*
	
		*Select only one exact observation per job ID to reduce file-size
		gen rndm = runiform()
		sort baanrugid rndm

		egen select = tag(baanrugid)
		keep if select==1
		drop select rndm
		sort rinpersoons rinpersoon baanrugid sdatumaanvangiko
		
		*Create full-time-factor on job-level
		gen ft_factor = svoltijddagen_caly / sbaandagen_caly
		
		sort sbeid
		
		*Merge GKSBS from BETAB
		rename sbeid beid
		merge m:1 beid using "${betab`year'}", keepusing (gksbs) ///
			keep(master match) nogen
		rename beid sbeid
		
		sort rinpersoons rinpersoon

		*Merge Geslacht / Migratieachtergrond / Geboortejaar
		merge m:1 rinpersoons rinpersoon using "${GBAPERSOON2009}", ///
			keepusing(gbageslacht gbageneratie gbageboortejaar gbageboortemaand) ///
			nogen keep(match master)
	
		*Merge Hoogste Opleiding
		merge m:1 rinpersoons rinpersoon using "${hoogsteopl`year'}", ///
			keepusing(oplnrhb oplnrhg gewichthoogsteopl) ///
			nogen keep(match master)
	
		save "${data}/fullpolis_`year'.dta", replace
		local ++row
	}
	*



*** 2010-2018: SPOLIS
	local row=6
	foreach year of num 2010/2018 {
		use rinpersoons rinpersoon ikvid sdatumaanvangiko sdatumeindeiko sbaandagen ///
			sbasisloon sbasisuren sbijzonderebeloning sextrsal sincidentsal ///
			slningld slnowrk soverwerkuren sreisk svakbsl svoltijddagen ///
			scontractsoort spolisdienstverband sbeid scaosector sdatumaanvangikv ///
			sdatumeindeikv ssect ssoortbaan using "${spolis`year'}", replace 
		
		*Summarize Total Earnings per person - establishment (defines main job)
		bys rinpersoons rinpersoon sbeid: egen slningld_caly_beid = total(slningld)
		bys rinpersoons rinpersoon: egen max_slningld_caly_beid = max(slningld_caly_beid)
		
		// Check & Export: Nr. of BEID Affiliations
		putexcel set "${tables}/descr", sheet("PERS_BEID") modify
		putexcel A`row' = (`year')
		egen rin_beid = tag(rinpersoons rinpersoon sbeid)
		count if rin_beid==1
		putexcel B`row' = (r(N))
		egen rin = tag(rinpersoons rinpersoon)
		count if rin==1
		putexcel C`row' = (r(N))
		drop rin_beid rin
		
		************************************************************************
		// SELECTION - Main job = Beid affiliation with highest overall earnings in caly
		************************************************************************
		keep if (slningld_caly_beid==max_slningld_caly_beid)
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
		drop max_slningld_caly_beid
		
		*Prepare date indicators
		gen job_start_exact = date(sdatumaanvangiko, "YMD")
		gen job_end_exact = date(sdatumeindeiko, "YMD")
		gen job_start_caly = date(sdatumaanvangikv, "YMD")
		gen job_end_caly = date(sdatumeindeikv, "YMD")
		format job_start_exact job_end_exact job_start_caly job_end_caly %d
	
		************************************************************************
		*JOB Summary statistics for whole calendar year (all obs per unique job ID)
		************************************************************************
		foreach var of var sbaandagen- svoltijddagen {
			bys ikvid: egen `var'_caly = total(`var')
		}
		*
	
		*Select only one exact observation per person to reduce file-size
		gen rndm = runiform()
		sort ikvid rndm

		egen select = tag(ikvid)
		keep if select==1
		drop select rndm
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
		
		*Create full-time-factor on job-level
		gen ft_factor = svoltijddagen_caly / sbaandagen_caly
	
		sort sbeid
		
		*Merge GKSBS from BETAB
		rename sbeid beid
		merge m:1 beid using "${betab`year'}", keepusing (gksbs) ///
			keep(master match) nogen
		rename beid sbeid
		
		sort rinpersoons rinpersoon
		
		*Merge Geslacht / Migratieachtergrond / Geboortejaar
		capture merge m:1 rinpersoons rinpersoon using "${GBAPERSOON2018}", ///
			keepusing(gbageslacht gbageneratie gbageboortejaar gbageboortemaand) ///
			nogen keep(match master)
		
		*Merge Hoogste Opleiding
		capture merge m:1 rinpersoons rinpersoon using "${hoogsteopl`year'}", ///
			keepusing(oplnrhb oplnrhg gewichthoogsteopl) ///
			nogen keep(match master)
	
		save "${data}/fullpolis_`year'.dta", replace
		local ++row
	}
	*
	
**********************************************************
*** Aggregate at BEID-Level & Prepare for further analysis
**********************************************************
	
*** 
	local row = 2
	foreach year of num 2006/2018 {
		use "${data}/CPI.dta", replace
		keep if YEAR==`year'
		tempfile temp
		save "`temp'" 
	
		use "${data}/fullpolis_`year'.dta", replace
		gen YEAR = `year'
		merge m:1 YEAR using "`temp'", nogen

*** Sum all establishment earnings of the same person
*  (if multiple job IDs exist at the time of the survey)
		foreach var of var sbaandagen_caly-sincidentsal_caly slnowrk_caly-svoltijddagen_caly {
			bys rinpersoons rinpersoon sbeid: egen `var'_beid = total(`var')
		}
		*
		
		order slningld_caly_beid, after(sincidentsal_caly_beid) // already generated
		gen ft_factor_beid = svoltijddagen_caly_beid/sbaandagen_caly_beid
		
		bys rinpersoons rinpersoon sbeid: egen job_start_caly_beid = min(job_start_caly)
		bys rinpersoons rinpersoon sbeid: egen job_end_caly_beid = max(job_end_caly)
		format job_start_caly_beid job_end_caly_beid %d

		
		// Check & Export: Nr. of overall jobs within RIN-BEID Affiliations
		putexcel set "${tables}/descr/fp_descr", sheet("PERS_BEID") modify
		count
		putexcel D`row' = (r(N))
		
		* Select one observation per BEID
		egen select = tag(rinpersoons rinpersoon sbeid)
		keep if select == 1
		drop select

		* Generate three hourly wage measures
		* Basis
		gen hwage = sbasisloon_caly_beid / sbasisuren_caly_beid
		* With Boni
		gen hwage_bonus = (slningld_caly_beid - slnowrk_caly_beid) / sbasisuren_caly_beid
		gen hwage_bonus2 = (sbasisloon_caly_beid + sbijzonderebeloning_caly_beid) / sbasisuren_caly_beid

		* Adjust for inflation (2015 prices)
		gen real_hwage = hwage/CPI
		gen real_hwage_bonus = hwage_bonus/CPI
		gen real_hwage_bonus2 = hwage_bonus2/CPI

		* Generate age variable
		gen byear = real(gbageboortejaar)
		gen age = `year'-byear
		
		*Create log of hourly wages
		gen log_real_hwage = log(real_hwage)
		gen log_real_hwage_bonus = log(real_hwage_bonus)
		gen log_real_hwage_bonus2 = log(real_hwage_bonus2)
		
		*Create numeric beid variable
		egen org = group(sbeid)
		
		save "${data}/fullpolis_`year'.dta", replace
		local ++row
	}
	*
	
*** While Person-Beid affiliations are unique in the dataset, persons are not
*** The reason is that some persons are registered with the exact same overall 
*** absolute wage in different beids (~0.05% of all; ~50% of them is 0) 
*** --> is this a coding mistake by CBS?
*** Starting from 2013, the share of duplicate becomes minimal (0.02%)
	// bys rinpersoons rinpersoon: gen N_rin = _N
	
	
****************************************************************
*** Drop variables at lower level of aggregation (tijdvak / job)
****************************************************************

	foreach year of num 2006/2018 {
		use "${data}/fullpolis_`year'.dta", replace
		drop sdatumaanvangiko-svoltijddagen sdatumaanvangikv sdatumeindeikv // Tijdvak
		drop ft_factor job_start_exact-svoltijddagen_caly // Job
		save "${data}/fullpolis_`year'.dta", replace
	}
	*
	
*********************
*** Merge SBI & GEMHV
*********************
	
	foreach year of num 2006/2009 {
		use "${data}/fullpolis_`year'.dta", replace
		rename beid org
		rename sbeid beid
		sort beid
	
		merge m:1 beid using "${betab`year'}", keepusing (SBI2008V`year' GEMHV`year') ///
			keep(master match) nogen
		rename (SBI2008V`year' GEMHV`year') (SBI2008VJJJJ gemhvjjjj)
		order SBI2008VJJJJ gemhvjjjj, after(gksbs)
		rename beid sbeid
	
		sort rinpersoons rinpersoon baanrugid
	
		save "${data}/fullpolis_`year'.dta", replace
	}
	*
	foreach year of num 2010/2013 {
		use "${data}/fullpolis_`year'.dta", replace
		rename beid org
		rename sbeid beid
		sort beid
	
		merge m:1 beid using "${betab`year'}", keepusing (SBI2008V`year' GEMHV`year') ///
			keep(master match) nogen
		rename (SBI2008V`year' GEMHV`year') (SBI2008VJJJJ gemhvjjjj)
		order SBI2008VJJJJ gemhvjjjj, after(gksbs)
		rename beid sbeid
	
		sort rinpersoons rinpersoon ikvid
	
		save "${data}/fullpolis_`year'.dta", replace
	}
	*
	foreach year of num 2014/2018 {
		use "${data}/fullpolis_`year'.dta", replace
		rename beid org
		rename sbeid beid
		sort beid
	
		merge m:1 beid using "${betab`year'}", keepusing (SBI2008VJJJJ gemhvjjjj) ///
			keep(master match) nogen
		order SBI2008VJJJJ gemhvjjjj, after(gksbs)
		rename beid sbeid
	
		sort rinpersoons rinpersoon ikvid
	
		save "${data}/fullpolis_`year'.dta", replace
	}
	*	
	
* --------------------------------------------------------------------------- */
* 2. ORGA WEIGHT: SIZE-SECTOR FREQUENCIES FOR REWEIGHTING OF EBB SAMPLE
* ---------------------------------------------------------------------------- *

*****************************************************************
*** Tabulate Size-Sector frequencies and store them in excel file
*****************************************************************

	foreach year of num 2006/2018 {
		use "${data}/fullpolis_`year'.dta", replace
		
		*Adjust to sample sample selection
		* Set age range to 16-65
		keep if age>=16 & age<=65
		
		putexcel set "${tables}/wgt/SzSc_FP", sheet("SzSc_`year'") modify
		gen size_sect = gksbs + ssect
		gen size_sect_real = real(size_sect)
		tab size_sect_real, matrow(rows) matcell(cells)
		putexcel A1 = matrix(rows) B1 = matrix(cells)
	}
	*
	
********************************************************************
*** Append the yearly Full Polis Size_Sector frequencies in one file
********************************************************************
	
	foreach year of num 2006/2018 {
		import excel "${tables}/wgt/SzSc_FP.xlsx", sheet("SzSc_`year'") clear
		
		rename (A B) (size_sect_real freq)
		gen YEAR = `year'
		order YEAR, before(size_sect_real)
		tempfile temp`year'
		save "`temp`year''"
	}
	*
	
	append using "`temp2006'" "`temp2007'" "`temp2008'" "`temp2009'" "`temp2010'" ///
		"`temp2011'" "`temp2012'" "`temp2013'" "`temp2014'" "`temp2015'" ///
		"`temp2016'" "`temp2017'"
	sort size_sect_real YEAR
	
	save "${data}/SzSc_FP.dta", replace
	
********************************************************************
*** Calculate the Relevant frequencies for the sample
********************************************************************

	use "${data}/SzSc_FP.dta", replace
	
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
	
	save "${data}/SzSc.dta", replace
	

* --------------------------------------------------------------------------- */
* 3. AKM MODELS (FOR FIRM FE)
* ---------------------------------------------------------------------------- *

****************************
*** Pooling of all Main Jobs
****************************

	foreach year of num 2006/2018 {
		use "${data}/fullpolis_`year'.dta", replace
		keep rinpersoons rinpersoon sbeid YEAR age ft_factor_beid ///
			log_real_hwage_bonus2 gksbs
			
		// Reduce to 16-65 years old
		keep if age>=16 & age<=65
		
		// Reduce to organizations with 20+ employees
		gen size = real(gksbs)
		drop gksbs
		keep if size>=50 & size!=.
		drop size
		
		// Combine person identifier
		gen RIN = rinpersoons+rinpersoon
		
		// Create Age^2
		gen age2 = age*age
		
		tempfile temp`year'
		save "`temp`year''"
	}
	*
	
	append using "`temp2006'" "`temp2007'" "`temp2008'" "`temp2009'" "`temp2010'" ///
		"`temp2011'" "`temp2012'" "`temp2013'" "`temp2014'" "`temp2015'" ///
		"`temp2016'" "`temp2017'"
		
	// Keep only non-missing wages
	keep if log_real_hwage_bonus2!=.

	// Identifying the largest connected set
	a2group, individual(RIN) unit(sbeid) groupvar(cs)

	
	save "${data}/akm.dta", replace
	
************************
*** Model Implementation
************************

	use "${data}/akm.dta", replace

	// Identify & select largest connected set
	keep if cs==1
	
	****************************************************************************
	// AKM decomposition - with a2reg
	a2reg log_real_hwage_bonus2 age age2, individual(RIN) unit(sbeid) ///
		indeffect(i_fe) uniteffect(j_fe) xb(xb) resid(res)
	
	// Save estimates
	putexcel set "${tables}/regression/akm.xlsx", sheet("a2reg") modify
	putexcel A1 = ("n") A2 = ("i") A3 = ("j") A4 = ("R2") A5 = ("sd_i") ///
		A6 = ("sd_j") A7 = ("sd_xb") A8 = ("sd_res") A9 = ("cov_ij") ///
		A10 = ("cov_ixb") A11 = ("cov_jxb")
	putexcel B1 = (e(N)) B2 = (e(nind)) B3 = (e(nunit)) B4 = (e(r2)) ///
		B5 = (e(sdind)) B6 = (e(sdunit))
	sum xb
	putexcel B7 = (r(sd))
	sum res
	putexcel B8 = (r(sd))
	corr i_fe j_fe, cov
	putexcel B9 = (r(cov_12))
	corr i_fe xb, cov
	putexcel B10 = (r(cov_12))
	corr j_fe xb, cov
	putexcel B11 = (r(cov_12))
	
	*Saving fixed effects	
	preserve
	egen tag = tag(sbeid)
	keep if tag==1
	keep sbeid j_fe
	save "${data}/j.dta", replace
	restore
	
	****************************************************************************
	// Alternative - reghdfe (without year FE) 
	egen rin = group(RIN)
	egen beid = group(sbeid)
	
	reghdfe, compile
	ftools, compile
	
	reghdfe log_real_hwage_bonus2 age age2, absorb(i_fe2 = i.rin j_fe2 = i.beid) ///
		groupvar(cs2) residuals(res2) 
	predict xb2 if e(sample)==1, xb
	
	// Save estimates
	putexcel set "${tables}/regression/akm.xlsx", sheet("reghdfe") modify
	putexcel A1 = ("n") A2 = ("i") A3 = ("j") A4 = ("R2") A5 = ("sd_i") ///
		A6 = ("sd_j") A7 = ("sd_xb") A8 = ("sd_res") A9 = ("cov_ij") ///
		A10 = ("cov_ixb") A11 = ("cov_jxb")
	putexcel B1 = (e(N)) B4 = (e(r2))
	distinct rin if e(sample)==1
	putexcel B2 = (r(ndistinct))
	distinct beid if e(sample)==1
	putexcel B3 = (r(ndistinct))
	sum i_fe2
	putexcel B5 = (r(sd))
	sum j_fe2
	putexcel B6 = (r(sd))
	sum xb2
	putexcel B7 = (r(sd))
	sum res2
	putexcel B8 = (r(sd))
	corr i_fe2 j_fe2, cov
	putexcel B9 = (r(cov_12))
	corr i_fe2 xb2, cov
	putexcel B10 = (r(cov_12))
	corr j_fe2 xb2, cov
	putexcel B11 = (r(cov_12))
	
	*Saving fixed effects	
	preserve
	egen tag = tag(sbeid) if e(sample)==1
	keep if tag==1
	keep sbeid j_fe2
	
	*Recenter with mean = 0
	sum j_fe2
	replace j_fe2 = j_fe2-(r(mean))
	
	save "${data}/j2.dta", replace
	restore
	
	****************************************************************************
	// Alternative - reghdfe (with year FE) 
	reghdfe log_real_hwage_bonus2 age age2 i.YEAR, absorb(i_fe3 = i.rin j_fe3 = i.beid) ///
		groupvar(cs3) residuals(res3) 
	predict xb3 if e(sample)==1, xb
	
	// Save estimates
	putexcel set "${tables}/regression/akm.xlsx", sheet("reghdfe + Year") modify
	putexcel A1 = ("n") A2 = ("i") A3 = ("j") A4 = ("R2") A5 = ("sd_i") ///
		A6 = ("sd_j") A7 = ("sd_xb") A8 = ("sd_res") A9 = ("cov_ij") ///
		A10 = ("cov_ixb") A11 = ("cov_jxb")
	putexcel B1 = (e(N)) B4 = (e(r2))
	distinct rin if e(sample)==1
	putexcel B2 = (r(ndistinct))
	distinct beid if e(sample)==1
	putexcel B3 = (r(ndistinct))
	sum i_fe3
	putexcel B5 = (r(sd))
	sum j_fe3
	putexcel B6 = (r(sd))
	sum xb3
	putexcel B7 = (r(sd))
	sum res3
	putexcel B8 = (r(sd))
	corr i_fe3 j_fe3, cov
	putexcel B9 = (r(cov_12))
	corr i_fe3 xb3, cov
	putexcel B10 = (r(cov_12))
	corr j_fe3 xb3, cov
	putexcel B11 = (r(cov_12))
	
	*Saving fixed effects	
	preserve
	egen tag = tag(sbeid) if e(sample)==1
	keep if tag==1
	keep sbeid j_fe3
	
	*Recenter with mean = 0
	sum j_fe3
	replace j_fe3 = j_fe3-(r(mean))
	
	save "${data}/j3.dta", replace
	restore

	
* --------------------------------------------------------------------------- */
* 4. CLOSE LOG FILE
* ---------------------------------------------------------------------------- *

	log close
