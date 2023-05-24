/*=============================================================================* 
* DATA PREPARATIONS - EBB Sample & Polis
*==============================================================================*
 	Project: Occupations, Organizations, and Wage Inequality
	Author: Christoph Janietz (University of Amsterdam)
	Article: Janietz, C. & Bol, T. (2020).
			 Occupations, organizations, and the structure of wage inequality in 
			 the Netherlands.
			 Research in Social Stratification and Mobility 70
			 https://doi.org/10.1016/j.rssm.2019.100468
	Last update: 15-11-2019
	
	Purpose: Preparation of the final sample.
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		0.  Settings 
		1. 	Appending EBB 2006-2018
		2. 	Selecting EBB sample (one unique RIN per calendar year)
		3.  Merge (S)POLIS
		4. 	Identify main jobs; Drop non-covered job IDs; Calculate caly job summary
		5.  Merge BETAB variables
		6.  Merge educational levels based on CTO
		7.  Append yearly files
		8.  Collapse jobs in same BEID 
		9.  Prepare Variables
		------------------------------------------------------------------------
		10. Sample Selections
		11. Weights
		12. Reduce Variable Set 
		13. Close Log File
		
* --------------------------------------------------------------------------- */
* 0. SETTINGS 
* ---------------------------------------------------------------------------- * 

*** Settings - run config file
	global dir 			"H:/Christoph/art1"
	do 					"${dir}/06_dofiles/config"
	
*** Open log file
	log using 			"$logfiles/01_ebbsample.log", replace

* --------------------------------------------------------------------------- */
* 1. APPENDING EBB 2006-2018
* ---------------------------------------------------------------------------- *


****************************
*** APPENDING EBB 2006-2018
****************************

	foreach year of num 2006/2009 {
		use rinpersoons rinpersoon EbbAflJaar EbbAflKwartaal EbbAflMaand EbbAlgEnqEE ///
			EbbAlgEnqJJ EbbAlgEnqMM EbbAlgEnqDD EbbAflAantWerk EbbWrkZelfstan ///
			EbbTypISCO EbbTypISCO2008 EbbHhbMV EbbAflLft EbbAflHerkomstGBA2d ///
			EbbTypCto2006HB EbbAflHoelanGel1 EbbCdlCodeVakb EbbGewJaarGewichtA ///
			using "${ebb`year'}"
		gen EbbTypCtoHB = ""
		order EbbTypCtoHB, after(EbbTypCto2006HB)
		tempfile temp`year'
		save "`temp`year''" 
	}
	*
	foreach year of num 2010/2011 {
		use rinpersoons rinpersoon EbbAflJaar EbbAflKwartaal EbbAflMaand EbbAlgEnqEE ///
			EbbAlgEnqJJ EbbAlgEnqMM EbbAlgEnqDD EbbAflAantWerk EbbWrkZelfstan ///
			EbbTypISCO EbbTypisco2008 EbbHhbMV EbbAflLft EbbAflHerkomstGBA2d ///
			EbbTypCto2006HB EbbAflHoelanGel1 EbbCdlCodeVakb EbbGewJaarGewichtA ///
			using "${ebb`year'}"
		gen EbbTypCtoHB = ""
		order EbbTypCtoHB, after(EbbTypCto2006HB)	
		rename EbbTypisco2008 EbbTypISCO2008
		tempfile temp`year'
		save "`temp`year''" 
	}
	*
	use RINPERSOONS RINPERSOON EbbAflJaar EbbAflKwartaal EbbAflMaand EbbAlgEnqEE ///
		EbbAlgEnqJJ EbbAlgEnqMM EbbAlgEnqDD EbbAflAantWerk EbbWrkZelfstan ///
		EbbTypISCO EbbTypISCO2008 EbbHhbMV EbbAflLft EbbAflHerkomstGBA2d ///
		EbbTypCto2006HB EbbAflHoelanGel1 EbbCdlCodeVakb EbbGewJaarGewichtA ///
		using "${ebb2012}"
	gen EbbTypCtoHB = ""
	order EbbTypCtoHB, after(EbbTypCto2006HB)
	rename RINPERSOONS RINPERSOON, lower
	tempfile temp2012
	save "`temp2012'" 

	foreach year of num 2013/2018 {
		use RINPERSOONS RINPERSOON EbbAflJaar EbbAflKwartaal EbbAflMaand EbbAlgEnqEE ///
			EbbAlgEnqJJ EbbAlgEnqMM EbbAlgEnqDD EbbAflAantWerk EbbWrkZelfstan ///
			EbbTypISCO EbbTypISCO2008 EbbHhbMV EbbAflLft EbbAflHerkomstGBA2d ///
			EbbTypCtoHB EbbAflHoelanGel1 EbbCdlCodeVakb EbbGewJaarGewichtA ///
			using "${ebb`year'}"
		gen EbbTypCto2006HB = ""
		order EbbTypCto2006HB, before(EbbTypCtoHB)
		rename RINPERSOONS RINPERSOON, lower
		tempfile temp`year'
		save "`temp`year''" 
	}
	*
	
	append using "`temp2006'" "`temp2007'" "`temp2008'" "`temp2009'" "`temp2010'" ///
		"`temp2011'" "`temp2012'" "`temp2013'" "`temp2014'" "`temp2015'" ///
		"`temp2016'" "`temp2017'"
	sort EbbAflJaar rinpersoons rinpersoon

************************
*** VARIABLE ADJUSTMENTS
************************

	*Create Combi-RINPERSOON
	gen RIN = rinpersoons+rinpersoon
	order RIN, before(rinpersoons)

	// Date variables
	*SURVEY
	gen SURVEY_Y = EbbAlgEnqJJ + 2000
	lab var SURVEY_Y "Year of Survey"

	gen SURVEY_YM = ym(SURVEY_Y, EbbAlgEnqMM)
	format SURVEY_YM %tm
	lab var SURVEY_YM "Month / Year of Survey"

	gen SURVEY_YMD = mdy(EbbAlgEnqMM, EbbAlgEnqDD, SURVEY_Y) 
	format SURVEY_YMD %d
	lab var SURVEY_YMD "Exact Date of Survey"

	*PUBLICATION
	gen PUB_YQ = yq(EbbAflJaar, EbbAflKwartaal)
	format PUB_YQ %tq
	lab var PUB_YQ "Quarter / Year of Publication"

	gen PUB_YM = ym(EbbAflJaar, EbbAflMaand)
	format PUB_YM %tm
	lab var PUB_YM "Month / Year of Publication"

	*ISCO
	*Set "XXXX" and "xxxx" in ISCO2008 variable as missing
	clonevar ISCO2008 = EbbTypISCO2008
	replace ISCO2008="" if (ISCO2008=="XXXX" | ISCO2008=="xxxx") 

	
* --------------------------------------------------------------------------- */
* 2. SELECTING EBB SAMPLE (ONE UNIQUE RIN PER CALENDAR YEAR)
* ---------------------------------------------------------------------------- *


*****************************
*** CREATE SELECTION VARIABLE
*****************************

*** Identifier - Sequential observation number for unique person per calendar year
	bys rinpersoons rinpersoon SURVEY_Y: gen nr_y = _n
	lab var nr_y "Sequential observation per RIN + Year"


*** Selection (Style 1): Use only one observation per RIN / Year 
	* Criterium: Use first observation with job + ISCO
	sort rinpersoons rinpersoon SURVEY_Y SURVEY_YMD nr_y

	gen select = .

	// [not the most elegant solution, but it does the trick]
	foreach nr of num 1/8 {
		bys rinpersoons rinpersoon SURVEY_Y: ///
			replace select = 1 if nr_y==`nr' & EbbAflAantWerk!=0 & ISCO2008!="" & ///
				(select[_n-1]!=1 | select[_n-2]!=1 | select[_n-3]!=1 | ///
				select[_n-4]!=1 | select[_n-5]!=1 | select[_n-6]!=1 | select[_n-7]!=1)
		bys rinpersoons rinpersoon SURVEY_Y: ///
			replace select = 0 if nr_y==`nr' & ///
				(EbbAflAantWerk==0 | ISCO2008=="" | select[_n-1]==1 | ///
				select[_n-2]==1 | select[_n-3]==1 | select[_n-4]==1 | ///
				select[_n-5]==1 | select[_n-6]==1 | select[_n-7]==1)
	}
	*

*** Selection (Style 2): Use only one observation per RIN / Year 
	* Criterium: Use random observation among the RIN / Year combinations with job + ISCO
	gen rndm = runiform()
	sort rinpersoons rinpersoon SURVEY_Y rndm

	egen select2 = tag(rinpersoons rinpersoon SURVEY_Y) ///
		if EbbAflAantWerk!=0 & EbbAflAantWerk!=. & ISCO2008!=""
	drop rndm

	sort rinpersoons rinpersoon SURVEY_Y

	// Variable labels
	lab var select "Selection - first valid observation per RIN / year"
	lab var select2 "Selection - random valid observation per RIN / year"

	// Descriptives Select / Select2
	* Total respondents left 1,552,627
	* Distribution over years is quite even (cases for 2011 are a bit lower)
	* RINPERSOONS "E" is 2.98% (comparable to orginal sample)
	* Survey months January / February / March are overrepresented due to selection 
	* 	criterium / newly found jobs are overrepresented in later months for "select"
	
	* --> Select2 is chosen!
	
*******************
*** APPLY SELECTION
*******************
	
*** Keep only selected cases (based on random selection)
	keep if select2==1

	drop nr_y select select2
	
	save "${data}/EBB_core", replace
	
	
* --------------------------------------------------------------------------- */
* 3. MERGE (S)POLIS
* ---------------------------------------------------------------------------- *

******************
*** MERGE (S)POLIS
******************

	/*
	1:m - The persons-year combis are unique, but multiple jobs might be in the data.
	--> Adjustments can be made post-merge
	*/

*** 2006-2009: POLIS
	foreach year of num 2006/2009 {
		use "${data}/EBB_core.dta", replace
		keep if SURVEY_Y == `year' 
		sort rinpersoons rinpersoon
		save "${data}/EBB_core_`year'.dta", replace 

		use rinpersoons rinpersoon baanrugid aanvbus eindbus aantsv ///
			baandagen basisloon basisuren bijzonderebeloning extrsal ///
			incidentsal lningld lnowrk overwerkuren reguliereuren reisk vakbsl ///
			voltijddagen contractsoort polisdienstverband wekarbduurklasse beid ///
			caosector datumaanvangikv datumeindeikv sect soortbaan ///
			using "${polis`year'}", replace 
		sort rinpersoons rinpersoon
		merge m:1 rinpersoons rinpersoon using "${data}/EBB_core_`year'.dta",  ///
			keep(using match)
		drop if _merge==2 //Check lost EBB
		drop _merge
		order RIN, before(rinpersoons)
		order EbbAflJaar-ISCO2008, after(rinpersoon)
		save "${data}/EBB_core_`year'.dta", replace 
	}
	*
	/// 2006: 14,907 not merged
	/// 2007: 14,472 not merged
	/// 2008: 15,135 not merged
	/// 2009: 14,594 not merged


*** 2010-2018: SPOLIS
	foreach year of num 2010/2018 {
		use "${data}/EBB_core.dta", replace
		keep if SURVEY_Y == `year' 
		sort rinpersoons rinpersoon
		save "${data}/EBB_core_`year'.dta", replace 

		use rinpersoons rinpersoon ikvid sdatumaanvangiko sdatumeindeiko saantsv ///
			sbaandagen sbasisloon sbasisuren sbijzonderebeloning sextrsal ///
			sincidentsal slningld slnowrk soverwerkuren sreguliereuren ///
			sreisk svakbsl svoltijddagen scontractsoort spolisdienstverband ///
			swekarbduurklasse sbeid scaosector sdatumaanvangikv sdatumeindeikv ///
			ssect ssoortbaan if rinpersoons=="R" using "${spolis`year'}", replace 
		sort rinpersoons rinpersoon
		merge m:1 rinpersoons rinpersoon using "${data}/EBB_core_`year'.dta",  ///
			keep(using match)
		drop if _merge==2 //Check lost EBB
		drop _merge
		order RIN, before(rinpersoons)
		order EbbAflJaar-ISCO2008, after(rinpersoon)
		save "${data}/EBB_core_`year'.dta", replace
	}
	*
	/// 2010: 16,369 not merged
	/// 2011: 13,335 not merged
	/// 2012: 20,725 not merged
	/// 2013: 17,985 not merged
	/// 2014: 18,027 not merged
	/// 2015: 16,934 not merged
	/// 2016: 18,845 not merged
	/// 2017: 19,567 not merged
	/// 2018: 22,187 not merged

* --------------------------------------------------------------------------- */
* 4. KEEP MAIN JOB; DROP NON-COVERED JOBS; CALCULATE CALENDAR YEAR JOB SUMMARY
* ---------------------------------------------------------------------------- *

*** Loops for POLIS (2006-2009)
	foreach year of num 2006/2009 {
		use "${data}/EBB_core_`year'.dta", replace
	
		*Harmonize variable names
		foreach var of var aantsv aantverlu baandagen basisloon basisuren /// 
			bijzonderebeloning extrsal lningld lnowrk overwerkuren ///
			reguliereuren reisk vakbsl voltijddagen contractsoort ///
			polisdienstverband wekarbduurklasse beid caosector datumaanvangikv ///
			datumeindeikv sect soortbaan {
				rename `var' s`var' 
		}
		rename (aanvbus eindbus) (sdatumaanvangiko sdatumeindeiko)
	
		*Prepare date indicators
		gen job_start_exact = date(sdatumaanvangiko, "YMD")
		gen job_end_exact = date(sdatumeindeiko, "YMD")
		gen job_start_caly = date(sdatumaanvangikv, "YMD")
		gen job_end_caly = date(sdatumeindeikv, "YMD")
		format job_start_exact job_end_exact job_start_caly job_end_caly %d
		
		************************************************************************
		// SELECTION 1 - Main job = Beid affiliation with highest overall earnings in caly
		************************************************************************
		*Summarize Total Earnings per person - establishment (defines main job)
		bys rinpersoons rinpersoon sbeid: egen slningld_caly_beid = total(slningld)
		bys rinpersoons rinpersoon: egen max_slningld_caly_beid = max(slningld_caly_beid)
		
		*Keep only those job IDs (RIN-Beid combination) with the highest overall combined income
		keep if (slningld_caly_beid==max_slningld_caly_beid)
		sort rinpersoons rinpersoon baanrugid sdatumaanvangiko
		drop max_slningld_caly_beid
		
		************************************************************************
		// SELECTION 2 - Use only job IDs that exist at the time of the survey
		************************************************************************
		*Drop jobs that do not coincide with the timing of the EBB survey
		keep if (SURVEY_YMD >= job_start_caly) & (SURVEY_YMD<= job_end_caly)
		
		************************************************************************
		// JOB Summary statistics for whole calendar year (all obs per unique job ID)
		************************************************************************
		foreach var of var saantsv-svoltijddagen {
			bys baanrugid: egen `var'_caly = total(`var')
		}
		*
		
		*Create full-time-factor (on job-level)
		gen ft_factor = svoltijddagen_caly / sbaandagen_caly
		
		************************************************************************
		*Create Tags for exact observation matching Survey date
		************************************************************************
		// Patchy jobs are supplemented with observations as of earlier
		sort rinpersoons rinpersoon baanrugid sdatumeindeiko
		gen exact_match = 0
		replace exact_match = 1 if (SURVEY_YMD >= job_start_exact) & (SURVEY_YMD<= job_end_exact) //tag exact survey-polis overlaps
		bys rinpersoons rinpersoon baanrugid: egen exact_match_job = total(exact_match) //tag all obs per respective job
		gen close_match = 0
		gen dist_s_p = SURVEY_YMD - job_end_exact //distance survey date - end polis obs (in days)
		replace close_match = 1 if exact_match_job==0 & dist_s_p<=28 & dist_s_p>=0 // if no exact match for a job -> tag polis obs within 28 days prior
		bys rinpersoons rinpersoon baanrugid: egen close_match_job = total(close_match) // number close matches in jobs
		bys rinpersoons rinpersoon baanrugid: replace close_match = 0 if close_match_job>1 & close_match[_n+1]==1 // untag earlier polis obs in case of multiple close matches 
		gen far_match = 0
		replace far_match = 1 if exact_match_job==0 & close_match_job==0 & dist_s_p>28 // if no exact / close match for a job -> tag earlier polis obs
		bys rinpersoons rinpersoon baanrugid: egen far_match_job = total(far_match) // number far matches in jobs
		bys rinpersoons rinpersoon baanrugid: replace far_match = 0 if far_match_job>1 & far_match[_n+1]==1 // untag earlier polis obs in case of multiple far matches
	
		drop exact_match_job close_match_job far_match_job dist_s_p
		keep if exact_match==1 | close_match==1 | far_match==1
		sort rinpersoons rinpersoon baanrugid sdatumaanvangiko
	
		*Generate auxiliary variables
		gen patchy = .
		replace patchy=0 if exact_match==1
		replace patchy=1 if close_match==1
		replace patchy=2 if far_match==1
	
		drop exact_match close_match far_match
	
		gen YEAR = `year'
		order YEAR, after(rinpersoon)
	
		bys rinpersoons rinpersoon: gen nr_job = _N
	
		bys sbeid: gen nr_beid = _N
	
		sort rinpersoons rinpersoon baanrugid sdatumaanvangiko
		save "${data}/EBB_core_`year'", replace	
	}
	*
	
*** Loops for SPOLIS (2010-2018)
	foreach year of num 2010/2018 {
		use "${data}/EBB_core_`year'.dta", replace
	
		*Prepare date indicators
		gen job_start_exact = date(sdatumaanvangiko, "YMD")
		gen job_end_exact = date(sdatumeindeiko, "YMD")
		gen job_start_caly = date(sdatumaanvangikv, "YMD")
		gen job_end_caly = date(sdatumeindeikv, "YMD")
		format job_start_exact job_end_exact job_start_caly job_end_caly %d
	
		*Recast string for 2016-2018 to enable merge
		recast str32 ikvid
		
		************************************************************************
		// SELECTION 1 - Main job = Beid affiliation with highest overall earnings in caly
		************************************************************************
		*Summarize Total Earnings per person - establishment (defines main job)
		bys rinpersoons rinpersoon sbeid: egen slningld_caly_beid = total(slningld)
		bys rinpersoons rinpersoon: egen max_slningld_caly_beid = max(slningld_caly_beid)
		
		*Keep only those job IDs (RIN-Beid combination) with the highest overall combined income
		keep if (slningld_caly_beid==max_slningld_caly_beid)
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
		drop max_slningld_caly_beid
		
		************************************************************************
		// SELECTION 2 - Use only job IDs that exist at the time of the survey
		************************************************************************
		*Drop jobs that do not coincide with the timing of the EBB survey
		keep if (SURVEY_YMD >= job_start_caly) & (SURVEY_YMD<= job_end_caly)
		
		************************************************************************
		*JOB Summary statistics for whole calendar year (all obs per unique job ID)
		************************************************************************
		foreach var of var saantsv-svoltijddagen {
			bys ikvid: egen `var'_caly = total(`var')
		}
		*
		
		*Create full-time-factor (on job-level)
		gen ft_factor = svoltijddagen_caly / sbaandagen_caly
		
		************************************************************************
		*Create Tags for exact observation matching Survey date
		************************************************************************
		// Patchy jobs are sublemented with exact observation of up to 4 weeks earlier
		sort rinpersoons rinpersoon ikvid sdatumeindeiko
		gen exact_match = 0
		replace exact_match = 1 if (SURVEY_YMD >= job_start_exact) & (SURVEY_YMD<= job_end_exact) //tag exact survey-polis overlaps
		bys rinpersoons rinpersoon ikvid: egen exact_match_job = total(exact_match) //tag all obs per respective job
		gen close_match = 0
		gen dist_s_p = SURVEY_YMD - job_end_exact //distance survey date - end polis obs (in days)
		replace close_match = 1 if exact_match_job==0 & dist_s_p<=28 & dist_s_p>=0 // if no exact match for a job & tag polis obs within 28 days prior
		bys rinpersoons rinpersoon ikvid: egen close_match_job = total(close_match) // number close matches in jobs
		bys rinpersoons rinpersoon ikvid: replace close_match = 0 if close_match_job>1 & close_match[_n+1]==1 // untag earlier polis obs in case of multiple close matches
		gen far_match = 0
		replace far_match = 1 if exact_match_job==0 & close_match_job==0 & dist_s_p>28 // if no exact / close match for a job -> tag earlier polis obs
		bys rinpersoons rinpersoon ikvid: egen far_match_job = total(far_match) // number far matches in jobs
		bys rinpersoons rinpersoon ikvid: replace far_match = 0 if far_match_job>1 & far_match[_n+1]==1 // untag earlier polis obs in case of multiple far matches
	
		drop exact_match_job close_match_job far_match_job dist_s_p
		keep if exact_match==1 | close_match==1 | far_match==1
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
		*Generate auxiliary variables
		gen patchy = .
		replace patchy=0 if exact_match==1
		replace patchy=1 if close_match==1
		replace patchy=2 if far_match==1
	
		drop exact_match close_match far_match
	
		gen YEAR = `year'
		order YEAR, after(rinpersoon)
	
		bys rinpersoons rinpersoon: gen nr_job = _N
	
		bys sbeid: gen nr_beid = _N
	
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
		save "${data}/EBB_core_`year'", replace	
	}
	*

* --------------------------------------------------------------------------- */
* 5. MERGE BETAB VARIABLES
* ---------------------------------------------------------------------------- * 

***************
*** MERGE BETAB
***************

	foreach year of num 2006/2009 {
		use "${data}/EBB_core_`year'", replace
		rename sbeid beid
		sort beid
	
		merge m:1 beid using "${betab`year'}", keepusing (SBI2008V`year' gksbs GEMHV`year') ///
			keep(master match) nogen
		rename (SBI2008V`year' GEMHV`year') (SBI2008VJJJJ gemhvjjjj)
		order SBI2008VJJJJ gksbs gemhvjjjj, after(beid)
		rename beid sbeid
	
		sort rinpersoons rinpersoon baanrugid sdatumaanvangiko
	
		save "${data}/EBB_core_`year'", replace
	}
	*
	foreach year of num 2010/2013 {
		use "${data}/EBB_core_`year'", replace
		rename sbeid beid
		sort beid
	
		merge m:1 beid using "${betab`year'}", keepusing (SBI2008V`year' gksbs GEMHV`year') ///
			keep(master match) nogen
		rename (SBI2008V`year' GEMHV`year') (SBI2008VJJJJ gemhvjjjj)
		order SBI2008VJJJJ gksbs gemhvjjjj, after(beid)
		rename beid sbeid
	
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
		save "${data}/EBB_core_`year'", replace
	}
	*
	foreach year of num 2014/2018 {
		use "${data}/EBB_core_`year'", replace
		rename sbeid beid
		sort beid
	
		merge m:1 beid using "${betab`year'}", keepusing (SBI2008VJJJJ gksbs gemhvjjjj) ///
			keep(master match) nogen
		order SBI2008VJJJJ gksbs gemhvjjjj, after(beid)
		rename beid sbeid
	
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
		save "${data}/EBB_core_`year'", replace
	}
	*	

* --------------------------------------------------------------------------- */
* 6. MERGE EDUCATIONAL LEVELS BASED ON CTO
* ---------------------------------------------------------------------------- *	

******************************
*** MERGE EDUCATION CATEGORIES
******************************

	foreach year of num 2006/2012 {
		use "${data}/EBB_core_`year'", replace
		
		rename EbbTypCto2006HB CTO
		drop EbbTypCtoHB
	
		merge m:1 CTO using "${CTO}", keepusing (OPLNIVSOI2016AGG4HB) ///
			keep(master match) nogen
		order OPLNIVSOI2016AGG4HB, after(CTO)
	
		sort rinpersoons rinpersoon
		
		save "${data}/EBB_core_`year'", replace
	}
	*
	
	foreach year of num 2013/2018 {
		use "${data}/EBB_core_`year'", replace
		
		rename EbbTypCtoHB CTO
		drop EbbTypCto2006HB
	
		merge m:1 CTO using "${CTO}", keepusing (OPLNIVSOI2016AGG4HB) ///
			keep(master match) nogen
		order OPLNIVSOI2016AGG4HB, after(CTO)
	
		sort rinpersoons rinpersoon
		
		save "${data}/EBB_core_`year'", replace
	}
	*
	
* --------------------------------------------------------------------------- */
* 7. APPEND YEARLY FILES
* ---------------------------------------------------------------------------- *

***********************
*** APPEND YEARLY FILES
***********************

	use "${data}/EBB_core_2018", replace
	foreach year of num 2006/2017 {
		append using "${data}/EBB_core_`year'"
	}
	*
	order baanrugid, before(ikvid)
	sort YEAR rinpersoons rinpersoon

*************************
*** VARIABLE DESCRIPTIONS
*************************

	lab var RIN 				"Combined unique person ID"
	lab var YEAR 				"Reference year (Year of survey participation) - caly"

	lab var job_start_exact 	"Date (sdatumaanvangiko)"
	lab var job_end_exact 		"Date (sdatumeindeiko)"
	lab var job_start_caly 		"Date (sdatumaanvangikv)"
	lab var job_end_caly 		"Date (sdatumeindeikv)"

	lab var patchy 				"Indicator Polis-EBB match"
	lab def patchy_lbl 			0 "Exact match" 1 "Close match (<28 days)" 2 "Far match (> 28 days)"
	lab val patchy patchy_lbl
	lab var nr_job 				"Number of (POLIS) jobs hold by the respondent at the time of the EBB survey"
	lab var nr_beid 			"Number of observations in the same organization in a given year"
	
	gen size_sect = gksbs + ssect
	lab var size_sect "Combined Grootte - Sector of BEID (string)"
	gen size_sect_real = real(size_sect)
	lab var size_sect "Combined Grootte - Sector of BEID (integer)"
	order size_sect size_sect_real, after(gksbs)

	destring spolisdienstverband swekarbduurklasse gksbs scaosector ssect ssoortbaan, replace

	lab def spolisdienstverband_lbl 1 "Volltijd" 2 "Deeltijd" 
	lab val spolisdienstverband spolisdienstverband_lbl

	lab def swekarbduurklasse_lbl 1 "<12 uur" 2 "12-<20 uur" 3 "20-<25 uur" 4 "25-<30 uur" ///
		5 "30-<35 uur" 6 "35 en meer uur"
	lab val swekarbduurklasse swekarbduurklasse_lbl

	lab def gksbs_lbl 0 "0 werkzame personen" 10 "1 werkzame personen" 21 "2 werkzame personen" ///
		22 "3-4 werkzame personen" 30 "5-9 werkzame personen" 40 "10-19 werkzame personen" ///
		50 "20-49 werkzame personen" 60 "50-99 werkzame personen" 71 "100-149 werkzame personen" ///
		72 "150-199 werkzame personen" 81 "200-249 werkzame personen" 82 "250-499 werkzame personen" ///
		91 "500-999 werkzame personen" 92 "1000-1999 werkzame personen" 93 ">=2000 werkzame personen"
	lab val gksbs gksbs_lbl

	lab def scaosector_lbl 1000 "Particuliere bedrijven" 2000 "Gesubsidieerde sector" ///
		3000 "Overheid (totaal)" 3100 "Rijksoverheid" 3200 "Onderwijs (totaal)" ///
		3210 "Funderend onderwijs" 3211 "Primair onderwijs" ///
		3212 "Voortgezet onderwijs (exclusief BVE)" 3213 "BVE onderwijs" ///
		3220 "Hoger beroepsonderwijs" 3230 "Universiteiten" 3240 "Academische ziekenhuizen" ///
		3250 "Onderzoeksinstellingen" 3290 "Restgroep onderwijs" 3300 "Defensie" ///
		3310 "Burgerpersoneel" 3320 "Militair personeel" 3400 "Politie" ///
		3500 "Rechterlijke macht" 3600 "Gemeenten" 3700 "Provincies" 3800 "Waterschappen"
	lab val scaosector scaosector_lbl

	lab def ssect_lbl 0 "Onbekend" 1 "Agrarisch bedrijf Premiegroep los" ///
		2 "Tabakverwerkende industrie" 3 "Bouwbedrijf Premiegroep los" 4 "Baggerbedrijf" ///
		5 "Hout, borstel en emballage-industrie" 6 "Timmerindustrie" ///
		7 "Meubel- en orgelbouwindustrie" 8 "Groothandel in hout en houtbereiding" ///
		9 "Grafische industrie excl fotografen" 10 "Metaalindustrie" ///
		11 "Elektronische industrie" 12 "Metaal- en technische bedrijven" ///
		13 "Bakkerijen" 14 "Suikerverwerkende industrie" 15 "Slagersbedrijven" ///
		16 "Slagers overig" 17 "Detailhandel" 18 "Reiniging" 19 "Grootwinkelbedrijf" ///
		20 "Havenbedrijven" 21 "Havenclassificeerders" 22 "Binnenscheepvaart" ///
		23 "Visserij" 24 "Koopvaardij" 25 "Vervoer KLM" 26 "Vervoer NS" ///
		27 "Vervoer posterijen" 28 "Taxi- en ambulancevervoer" 29 "Openbaar vervoer" ///
		30 "Besloten busvervoer" 31 "Overig personenvervoer land en lucht" ///
		32 "Overig goederenvervoer land en lucht" 33 "Horeca algemeen Premiegroep los" ///
		34 "Horeca catering" 35 "Gezondheid, geestelijke en maatsch bel" 38 "Banken" ///
		39 "Verzekeringswezen en ziekenfondsen" 40 "Uitgeverij" 41 "Groothandel I" ///
		42 "Groothandel II" 43 "Zakelijke dienstverlening I" 44 "Zakelijke dienstverlening II" ///
		45 "Zakelijke dienstverlening III" 46 "Zuivelindustrie" 47 "Textielindustrie" ///
		48 "Steen-,cement-,glas- en keramische ind" 49 "Chemise industrie" 50 "Voedingsindustrie" ///
		51 "Algemene industrie" 52 "Uitleenbedrijven" 53 "Bewakingsondernemingen" ///
		54 "Culturele instellingen Premiegroep los" 55 "Overige takken van bedrijf en beroep" ///
		56 "Schildersbedrijf Premiegroep los" 57 "Stukadoorsbedrijf" 58 "Dakdekkersbedrijf" ///
		59 "Mortelbedrijf" 60 "Steenhouwersbedrijf"61 "Overheid, onderwijs en wetenschappen" ///
		62 "Overheid,rijk,politie,rechterlijke macht" 63 "Overheid, defensie" ///
		64 "Overheid,prov,gemeenten,waterschappen" 65 "Overheid, openbare nutsbedrijven" ///
		66 "Overheid, overige instellingen" 67 "Werk en (re)Integratie" 68 "Railbouw" ///
		69 "Telecommunicatie" 99 "Onbekend"
	lab val ssect ssect_lbl

	lab def ssoortbaan_lbl 1 "Directeur groot aandeelhouder" 2 "Stagiare" 3 "WSW-er" ///
		4 "Uitzendkracht" 5 "Oproepkracht" 9 "Rest"
	lab val ssoortbaan ssoortbaan_lbl

	encode scontractsoort, gen(scontractsoort_new)
	drop scontractsoort
	rename scontractsoort_new scontractsoort
	order scontractsoort, after(ssoortbaan)

	recode scontractsoort (4=3)
	lab def scontractsoort_lbl 1 "Bepaalde tijd" 2 "Niet van toepassing" 3 "Onbepaalde tijd" 
	lab val scontractsoort scontractsoort_lbl
	
*** Merge CPI
	merge m:1 YEAR using "${data}/CPI.dta", nogen keep(matched)

* --------------------------------------------------------------------------- */
* 8. COLLAPSE JOBS IN SAME BEID
* ---------------------------------------------------------------------------- *	

*************************************
*** SUM JOB IDs in SAME BEID + REDUCE
*************************************

*** Sum all establishment earnings of the same person
*  (if multiple job IDs exist at the time of the survey)
	foreach var of var saantsv_caly-sextrsal_caly slnowrk_caly-svoltijddagen_caly {
		bys YEAR rinpersoons rinpersoon sbeid: egen `var'_beid = total(`var')
	}
	*

	order slningld_caly_beid, after(sextrsal_caly_beid) // already generated
	gen ft_factor_beid = svoltijddagen_caly_beid/sbaandagen_caly_beid
	
	bys YEAR rinpersoons rinpersoon sbeid: egen job_start_caly_beid = min(job_start_caly)
	bys YEAR rinpersoons rinpersoon sbeid: egen job_end_caly_beid = max(job_end_caly)

*** Keep only one observation per person-beid combination (JOB ID with most basic hours)
	bys YEAR rinpersoons rinpersoon sbeid: egen max_sbasisuren_caly = max(sbasisuren_caly)
	keep if (sbasisuren_caly==max_sbasisuren_caly)
	// Some Job-IDs in same Beid have equivalent hours
	egen select = tag(YEAR rinpersoons rinpersoon sbeid)
	keep if select == 1
	drop select

* --------------------------------------------------------------------------- */
* 9. PREPARE VARIABLES
* ---------------------------------------------------------------------------- *

*** Generate hourly wage measures
	// Basis
	gen hwage = sbasisloon_caly_beid / sbasisuren_caly_beid
	// With Boni
	gen hwage_bonus = (slningld_caly_beid - slnowrk_caly_beid) / sbasisuren_caly_beid
	gen hwage_bonus2 = (sbasisloon_caly_beid + sbijzonderebeloning_caly_beid) / sbasisuren_caly_beid

*** Adjust for inflation (2015 prices)
	gen real_hwage = hwage/CPI
	gen real_hwage_bonus = hwage_bonus/CPI
	gen real_hwage_bonus2 = hwage_bonus2/CPI
	
*** Prepare Occupation / Organization variables
	gen ISCO2008_3d = substr(ISCO2008,1,3)
	gen ISCO2008_3 = real(ISCO2008_3d)
	gen ISCO2008_4 = real(ISCO2008)
	
	egen beid = group(sbeid)
	
*** Prepare Education variables
	gen edu_cat3 = substr(OPLNIVSOI2016AGG4HB, 1, 1)
	destring edu_cat3, replace
	recode edu_cat3 (9 = .)
	lab def edu_cat3_lbl 1 "Low" 2 "Middle" 3 "High" 
	lab val edu_cat3 edu_cat3_lbl
	
	gen edu_cat5 = substr(OPLNIVSOI2016AGG4HB, 1, 2)
	destring edu_cat5, replace
	recode edu_cat5 (99 = .)
	lab def edu_cat5_lbl 11 "Basisonderwijs" 12 "Vmbo, havo-, vwo-onderbouw, mbo1" ///
		21 "Havo, vwo, mbo" 31 "Hbo-, wo-bachelor" 32 "Hbo-, wo-master, doctor"
	lab val edu_cat5 edu_cat5_lbl
	
	gen edu_cat8 = substr(OPLNIVSOI2016AGG4HB, 1, 3)
	destring edu_cat8, replace
	recode edu_cat8 (999 = .)
	lab def edu_cat8_lbl 111 "Basisonderwijs" 121 "Vmbo-b/k, mbo1" ///
		122 "Vmbo-g/t, havo-vwo-onderbouw" 211 "Mbo2 en mbo3" 212 "Mbo4" ///
		213 "Havo, vwo" 311 "Hbo-, wo-bachelor" 321 "Hbo-, wo-master, doctor"
	lab val edu_cat8 edu_cat8_lbl
	
	gen edu_cat18 = substr(OPLNIVSOI2016AGG4HB, 1, 4)
	destring edu_cat18, replace
	recode edu_cat18 (9999 = .)
	lab def edu_cat18_lbl 1111 "Basisonderwijs gr1-2" 1112 "Basisonderwijs gr3-8" ///
		1211 "Praktijkonderwijs" 1212 "Vmbo-b/k" 1213 "Mbo1" 1221 "Vmbo-g/t" ///
		1222 "Havo-, vwo-onderbouw" 2110 "Mbo2 en mbo3" 2111 "Mbo2" 2112 "Mbo3" ///
		2121 "Mbo4" 2131 "Havo-bovenbouw" 2132 "Vwo-bovenbouw" ///
		3111 "Hbo-associate degree" 3112 "Hbo-bachelor" 3113 "Wo-bachelor" ///
		3211 "Hbo-master" 3212 "Wo-master" 3213 "Doctor" 
	lab val edu_cat18 edu_cat18_lbl
	
*** Employer size
	gen emplsize = gksbs
	drop gksbs
	recode emplsize (10 = 1) (21 22 = 2) (30 = 3) (40 = 4) ///
		(50 = 5) (60 = 6) (71 72 = 7) (81 82 = 8) (91 92 = 9) (93 = 10)
		
	lab def size_lbl 0 "0 employees" 1 "1 employees" 2 "2-4 employees" ///
		3 "5-9 employees" 4 "10-19 employees" 5 "20-49 employees" ///
		6 "50-99 employees" 7 "100-199 employees" 8 "200-499 employees" ///
		9 "500-1999 employees" 10 ">=2000 employees"
	lab val emplsize size_lbl
	
*** Sector
	recode scaosector (1000 = 1) (2000 = 2) (3000/3800 = 3)
	gen sector = scaosector
	drop scaosector
		
	lab def sector_lbl 1"Private" 2 "Subsidized" 3 "State"
	lab val sector sector_lbl
	
*** Prepare Industry variables
	replace SBI2008VJJJJ = "" if SBI2008VJJJJ=="99999"
	replace SBI2008VJJJJ = substr(SBI2008VJJJJ,1,2)
	gen industry = real(SBI2008VJJJJ)
	*Drop missings
	drop if industry==.
	drop SBI2008VJJJJ
	recode industry (1/3 = 1) (6/9 = 2) (10/33 = 3) (35 = 4) (36/39 = 5) ///
		(41/43 = 6) (45/47 = 7) (49/53 = 8) (55/56 = 9) (58/63 = 10) ///
		(64/66 = 11) (68 = 12) (69/75 = 13) (77/82 = 14) (84=15) (85 = 16) ///
		(86/88 = 17) (90/93 = 18) (94/96 = 19) (97/98 = 20) (99 = 21)
			
	lab def industry_lbl 1"Agriculture, forestry, and fishing" 2"Mining and quarrying" ///
			3"Manufacturing" 4"Electricity, gas, steam, and air conditioning supply" ///
			5"Water supply; sewerage, waste management and remidiation activities" ///
			6"Construction" 7"Wholesale and retail trade; repair of motorvehicles and motorcycles" ///
			8"Transportation and storage" 9"Accomodation and food service activities" ///
			10"Information and communication" 11"Financial institutions" ///
			12"Renting, buying, and selling of real estate" ///
			13"Consultancy, research and other specialised business services" ///
			14"Renting and leasing of tangible goods and other business support services" ///
			15"Public administration, public services, and compulsory social security" ///
			16"Education" 17"Human health and social work activities" ///
			18"Culture, sports, and recreation" 19"Other service activities" ///
			20"Activities of households as employers" ///
			21"Extraterritorial organizations and bodies" 
	lab val industry industry_lbl
	
**********************
*** DEPENDENT VARIABLE
**********************
	
	* Set boundaries for low wages (upper boundary now removed)
	foreach var of var hwage hwage_bonus hwage_bonus2 {
		replace `var'=0  if `var'<0 
		replace real_`var'=0  if real_`var'<0 
	}
	*

	/// Dependent Var
	* Calculate Log
	gen log_real_hwage = log(real_hwage)
	gen log_real_hwage_bonus = log(real_hwage_bonus)
	gen log_real_hwage_bonus2 = log(real_hwage_bonus2)
	
********************************	
*** INDIVIDUAL-LEVEL CONTROLS
********************************

	gen female = EbbHhbMV
	recode female (1 = 0) (2 = 1)
	
	gen age = EbbAflLft
	gen age_int = age*age
	
********************************	
*** FIRM FEs from AKM model
********************************

	merge m:1 sbeid using "${data}/j3.dta", keep(match) keepusing(j_fe3) nogen
	
	save "${data}/EBB_core_prep", replace

	
********************************************************************************
********************************************************************************
********************************************************************************
	
* --------------------------------------------------------------------------- */
* 10. SAMPLE SELECTIONS 
* ---------------------------------------------------------------------------- *
	
	use "${data}/EBB_core_prep", replace
	
*********************
*** SAMPLE SELECTIONS
*********************

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
	
* --------------------------------------------------------------------------- */
* 11. WEIGHTS
* ---------------------------------------------------------------------------- *

*** Preparation of HOURS weights
	// Already calculated (defined as usual hours worked by week given POLIS info)
	gen hours_wgt = ft_factor_beid
	
*** Preparation of ORGA weights
	*Merge prepared Full Polis frequencies
	merge m:1 size_sect_real using "${data}/SzSc.dta", keepusing(SzSc_FP_20) ///	
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
	

* --------------------------------------------------------------------------- */
* 12. REDUCE VARIABLE SET
* ---------------------------------------------------------------------------- *

	keep RIN sbeid beid edu_cat3 edu_cat5 edu_cat8 edu_cat18 EbbAflHoelanGel1 ///
		EbbAflHerkomstGBA2d log_real_hwage_bonus2 log_real_hwage real_hwage_bonus2 ///
		real_hwage occ big_occ wgt female age age_int j_fe3 ssect emplsize sector ///
		industry ssoortbaan YEAR
		
	save "${posted}/EBB_core_analysis", replace
	

* --------------------------------------------------------------------------- */
* 13. CLOSE LOG FILE
* ---------------------------------------------------------------------------- *

	log close
