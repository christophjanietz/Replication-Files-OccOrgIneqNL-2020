/*=============================================================================* 
* CONFIGURATIONS - SETTINGS 
*==============================================================================*
 	Project: Occupations, Organizations, and Wage Inequality
	Author: Christoph Janietz (University of Amsterdam)
	Article: Janietz, C. & Bol, T. (2020).
			 Occupations, organizations, and the structure of wage inequality in 
			 the Netherlands.
			 Research in Social Stratification and Mobility 70
			 https://doi.org/10.1016/j.rssm.2019.100468
	Last update: 09-05-2019
* ---------------------------------------------------------------------------- */

*** General settings
	version 14
	set more off, perm 
	cap log close
	set seed 12345 // take the same random sample every time
	set scheme plotplain, perm // set scheme graphs
	set matsize 11000, perm 
	set maxvar 32767, perm
	matrix drop _all

*** Set paths to folders
	// to folders 
	global dir 			"H:/Christoph/art1"
	global data			"$dir/01_data" 		// (S)POLIS/BEID FILES (reduced)
	global posted		"$dir/02_posted"	// ANALYSIS FILES
	global logfiles		"$dir/03_logfiles"
	global tables		"$dir/04_tables"
	global figures		"$dir/05_figures"
	global dofiles 		"$dir/06_dofiles"
	
	// to microdata files (use converted files when possible)
	
	global ebb2006 "G:\Arbeid\EBB\2006\geconverteerde data\EBB 2006V8.DTA"
	global ebb2007 "G:\Arbeid\EBB\2007\geconverteerde data\EBB 2007V7.DTA"
	global ebb2008 "G:\Arbeid\EBB\2008\geconverteerde data\EBB 2008V7.DTA" 
	global ebb2009 "G:\Arbeid\EBB\2009\geconverteerde data\EBB 2009V7.DTA"
	global ebb2010 "G:\Arbeid\EBB\2010\geconverteerde data\EBB 2010V10.DTA"
	global ebb2011 "G:\Arbeid\EBB\2011\geconverteerde data\EBB 2011V8.DTA"
	global ebb2012 "G:\Arbeid\EBB\2012\geconverteerde data\EBB2012V11.DTA"
	global ebb2013 "G:\Arbeid\EBB\2013\geconverteerde data\EBB2013V9.DTA"
	global ebb2014 "G:\Arbeid\EBB\2014\geconverteerde data\EBB2014V5.DTA"
	global ebb2015 "G:\Arbeid\EBB\2015\geconverteerde data\EBB2015V5.DTA"
	global ebb2016 "G:\Arbeid\EBB\2016\geconverteerde data\EBB2016V3.DTA"
	global ebb2017 "G:\Arbeid\EBB\2017\geconverteerde data\EBB2017V2.DTA"
	global ebb2018 "G:\Arbeid\EBB\2018\geconverteerde data\EBB2018V1.DTA"
	
	global polis2006 "G:\Polis\POLISBUS\2006\geconverteerde data\POLISBUS 2006V1.DTA"
	global polis2007 "G:\Polis\POLISBUS\2007\geconverteerde data\POLISBUS 2007V1.DTA"
	global polis2008 "G:\Polis\POLISBUS\2008\geconverteerde data\POLISBUS 2008V1.DTA"
	global polis2009 "G:\Polis\POLISBUS\2009\geconverteerde data\POLISBUS 2009V1.DTA"
	
	global spolis2010 "G:\Spolis\SPOLISBUS\2010\geconverteerde data\SPOLISBUS 2010V1.DTA"
	global spolis2011 "G:\Spolis\SPOLISBUS\2011\geconverteerde data\SPOLISBUS 2011V1.DTA"
	global spolis2012 "G:\Spolis\SPOLISBUS\2012\geconverteerde data\SPOLISBUS 2012V1.dta"
	global spolis2013 "G:\Spolis\SPOLISBUS\2013\geconverteerde data\SPOLISBUS 2013V2_new.DTA"
	global spolis2014 "G:\Spolis\SPOLISBUS\2014\geconverteerde data\SPOLISBUS 2014V1.DTA"
	global spolis2015 "G:\Spolis\SPOLISBUS\2015\geconverteerde data\SPOLISBUS 2015V3.DTA"
	global spolis2016 "G:\Spolis\SPOLISBUS\2016\geconverteerde data\SPOLISBUS2016V3.DTA"
	global spolis2017 "G:\Spolis\SPOLISBUS\2017\geconverteerde data\SPOLISBUS2017V2.DTA"
	global spolis2018 "G:\Spolis\SPOLISBUS\2018\geconverteerde data\SPOLISBUS2018V4.DTA"
	
	global betab2006 "G:\Arbeid\BETAB\2006\geconverteerde data\140707 BETAB 2006V1.DTA" 
	global betab2007 "G:\Arbeid\BETAB\2007\geconverteerde data\140707 BETAB 2007V1.DTA" 
	global betab2008 "G:\Arbeid\BETAB\2008\geconverteerde data\140707 BETAB 2008V1.DTA"
	global betab2009 "G:\Arbeid\BETAB\2009\geconverteerde data\140707 BETAB 2009V1.DTA" 
	global betab2010 "G:\Arbeid\BETAB\2010\geconverteerde data\140707 BETAB 2010V1.DTA" 
	global betab2011 "G:\Arbeid\BETAB\2011\geconverteerde data\140707 BETAB 2011V1.DTA" 
	global betab2012 "G:\Arbeid\BETAB\2012\geconverteerde data\140707 BETAB 2012V1.DTA" 
	global betab2013 "G:\Arbeid\BETAB\2013\geconverteerde data\141215 BETAB 2013V1.DTA" 
	global betab2014 "G:\Arbeid\BETAB\2014\geconverteerde data\BE2014TABV2.dta" 
	global betab2015 "G:\Arbeid\BETAB\2015\geconverteerde data\BE2015TABV125.DTA" 
	global betab2016 "G:\Arbeid\BETAB\2016\geconverteerde data\BE2016TABV124.DTA" 
	global betab2017 "G:\Arbeid\BETAB\2017\geconverteerde data\BE2017TABV124.DTA"
	global betab2018 "G:\Arbeid\BETAB\2018\geconverteerde data\BE2018TABV061.DTA"
	
	global hoogsteopl2006 "G:\Onderwijs\HOOGSTEOPLTAB\2006\geconverteerde data\120619 HOOGSTEOPLTAB 2006V1.dta"
	global hoogsteopl2007 "G:\Onderwijs\HOOGSTEOPLTAB\2007\geconverteerde data\120619 HOOGSTEOPLTAB 2007V1.dta"
	global hoogsteopl2008 "G:\Onderwijs\HOOGSTEOPLTAB\2008\geconverteerde data\120619 HOOGSTEOPLTAB 2008V1.dta"
	global hoogsteopl2009 "G:\Onderwijs\HOOGSTEOPLTAB\2009\geconverteerde data\120619 HOOGSTEOPLTAB 2009V1.dta"
	global hoogsteopl2010 "G:\Onderwijs\HOOGSTEOPLTAB\2010\geconverteerde data\120918 HOOGSTEOPLTAB 2010V1.dta"
	global hoogsteopl2011 "G:\Onderwijs\HOOGSTEOPLTAB\2011\geconverteerde data\130924 HOOGSTEOPLTAB 2011V1.dta"
	global hoogsteopl2012 "G:\Onderwijs\HOOGSTEOPLTAB\2012\geconverteerde data\141020 HOOGSTEOPLTAB 2012V1.dta"
	global hoogsteopl2013 "G:\Onderwijs\HOOGSTEOPLTAB\2013\geconverteerde data\HOOGSTEOPL2013TABV2.dta"
	global hoogsteopl2014 "G:\Onderwijs\HOOGSTEOPLTAB\2014\geconverteerde data\HOOGSTEOPL2014TABV2.dta"
	global hoogsteopl2015 "G:\Onderwijs\HOOGSTEOPLTAB\2015\geconverteerde data\HOOGSTEOPL2015TABV2.DTA" 
	global hoogsteopl2016 "G:\Onderwijs\HOOGSTEOPLTAB\2016\geconverteerde data\HOOGSTEOPLTAB2016V1.DTA"
	global hoogsteopl2017 "G:\Onderwijs\HOOGSTEOPLTAB\2017\geconverteerde data\HOOGSTEOPLTAB2017V1.dta" 
	global hoogsteopl2018 "G:\Onderwijs\HOOGSTEOPLTAB\2017\geconverteerde data\HOOGSTEOPLTAB2017V1.dta"
	
	global GBAPERSOON2009 "G:\Bevolking\GBAPERSOONTAB\2009\geconverteerde data\GBAPERSOON2009TABV1.DTA"
	// CBS recommends to use GBAPERSOONTAB2009 for years prior 2009
	global GBAPERSOON2018 "G:\Bevolking\GBAPERSOONTAB\2018\geconverteerde data\GBAPERSOON2018TABV1.dta"
	
	global CTO "K:\Utilities\Code_Listings\SSBreferentiebestanden\Geconverteerde data\CTOREFV8.dta"

	global KOPPELBAANID "G:\Arbeid\KOPPELTABELIKVIDBAANRUGIDTAB\geconverteerde data\KOPPELTABELIKVIDBAANRUGID2010TABV4.DTA"
	
	global abr2006 "G:\Bedrijven\ABR\2006\geconverteerde data\110525 BE_OG_ABR 2006V3.dta"
	global abr2007 "G:\Bedrijven\ABR\2007\geconverteerde data\110525 BE_OG_ABR 2007V3.dta"
	global abr2008 "G:\Bedrijven\ABR\2008\geconverteerde data\110525 BE_OG_ABR 2008V2.dta"
	global abr2009 "G:\Bedrijven\ABR\2009\geconverteerde data\120626 BE_OG_ABR 2009V3.dta"
	global abr2010 "G:\Bedrijven\ABR\2010\geconverteerde data\120329 BE_OG_ABR 2010V3.dta"
	global abr2011 "G:\Bedrijven\ABR\2011\geconverteerde data\120402 BE_OG_ABR 2011V1.dta"
	global abr2012 "G:\Bedrijven\ABR\2012\geconverteerde data\130311 BE_OG_ABR 2012V1.dta"
	global abr2013 "G:\Bedrijven\ABR\2013\geconverteerde data\140313 BE_OG_ABR 2013V1.DTA"
	global abr2014 "G:\Bedrijven\ABR\2014\geconverteerde data\BE_OG_ABR 2014V1.DTA"
	global abr2015 "G:\Bedrijven\ABR\2015\geconverteerde data\BE_OG_ABR2015V1.DTA"
	global abr2016 "G:\Bedrijven\ABR\2016\geconverteerde data\BE_OG_ABR2016V1.DTA"
	global abr2017 "G:\Bedrijven\ABR\2017\geconverteerde data\BE_OG_ABR2017V1.DTA"
	
	global nfo2006 "G:\Bedrijven\NFO\2006\geconverteerde data\110909 NFO 2006V3.dta"
	global nfo2007 "G:\Bedrijven\NFO\2007\geconverteerde data\110909 NFO 2007V3.dta"
	global nfo2008 "G:\Bedrijven\NFO\2008\geconverteerde data\110909 NFO 2008V4.dta"
	global nfo2009 "G:\Bedrijven\NFO\2009\geconverteerde data\120611 NFO 2009V2.dta"
	global nfo2010 "G:\Bedrijven\NFO\2010\geconverteerde data\130522 NFO 2010V2.dta"
	global nfo2011 "G:\Bedrijven\NFO\2011\geconverteerde data\140312 NFO 2011V2.dta"
	global nfo2012 "G:\Bedrijven\NFO\2012\geconverteerde data\NFO2012V3.dta"
	global nfo2013 "G:\Bedrijven\NFO\2013\geconverteerde data\NFO2013V2.dta"
	global nfo2014 "G:\Bedrijven\NFO\2014\geconverteerde data\NFO2014V3.dta"
	global nfo2015 "G:\Bedrijven\NFO\2015\geconverteerde data\NFO2015V4.dta"
	global nfo2016 "G:\Bedrijven\NFO\2016\geconverteerde data\NFO2016V4.dta"
	global nfo2017 "G:\Bedrijven\NFO\2017\geconverteerde data\NFO2017V2.dta"
	
	global sfgo2006 "H:\Christoph\art1\01_data\SFGO\DANFLEX2006V1.dta"
	global sfgo2007 "H:\Christoph\art1\01_data\SFGO\DANFLEX2007V1.dta"
	global sfgo2008 "H:\Christoph\art1\01_data\SFGO\DANFLEX2008V1.dta"
	global sfgo2009 "H:\Christoph\art1\01_data\SFGO\DANFLEX2009V1.dta"
	global sfgo2010 "H:\Christoph\art1\01_data\SFGO\DANFLEX2010V1.dta"
	global sfgo2011 "H:\Christoph\art1\01_data\SFGO\DANFLEX2011V1.dta"
	global sfgo2012 "H:\Christoph\art1\01_data\SFGO\DANFLEX2012V1.dta"
	global sfgo2013 "H:\Christoph\art1\01_data\SFGO\DANFLEX2013V1.dta"
	global sfgo2014 "H:\Christoph\art1\01_data\SFGO\DANFLEX2014V1.dta"
	global sfgo2015 "H:\Christoph\art1\01_data\SFGO\DANFLEX2015V2.dta"
	global sfgo2016 "H:\Christoph\art1\01_data\SFGO\DANFLEX2016V1.dta"
	global sfgo2017 "H:\Christoph\art1\01_data\SFGO\DANFLEX2017V2.dta"
	