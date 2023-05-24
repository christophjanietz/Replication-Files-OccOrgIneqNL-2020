##########################################################
# R-Script for Graphs
# Author: Christoph Janietz, University of Amsterdam
# Project: Occupations, Organizations, and Wage Inequality
# Article: Janietz, C. & Bol, T. (2020).
#          Occupations, organizations, and the structure of
#          wage inequality in the Netherlands.
#          Research in Social Stratification and Mobility 70
#          https://doi.org/10.1016/j.rssm.2019.100468
# Date: 12-06-2019
##########################################################

library(haven)
library(ggplot2)
library(tidyverse)

### Load pre-processed datasets

# Load Decomposition Data
decomposition <- read_dta("H:/Christoph/art1/02_posted/decomposition.dta")

# Load Percentile Distribution
percentile_pers_occ_beid <- read_dta("H:/Christoph/art1/02_posted/percentile_pers_occ_beid.dta")

# Load Counterfactual Analysis
cf_analysis<- read_dta("H:/Christoph/art1/02_posted/cf_analysis.dta")

# Load Decile data
firmfe_within_bigocc<- read_dta("H:/Christoph/art1/02_posted/firmfe_within_bigocc.dta")


# Prepare ISCO 1st digit as factor
cf_analysis$big_occ.f <- factor(cf_analysis$big_occ, labels = c("Managers", "Professionals", "Technicians & Ass. Professionals", "Clerical Support Workers", "Services & Sales Workers", "Skilled Agricultural, Forestry & Fishery Workers", "Craft & Related Trades Workers", "Plant & Machine Tool Operators & Assemblers", "Elementary Occupations"))
firmfe_within_bigocc$big_occ.f <- factor(firmfe_within_bigocc$big_occ, labels = c("Managers", "Professionals", "Technicians & Ass. Professionals", "Clerical Support Workers", "Services & Sales Workers", "Skilled Agricultural, Forestry & Fishery Workers", "Craft & Related Trades Workers", "Plant & Machine Tool Operators & Assemblers", "Elementary Occupations"))

############
#Description
############

##############################################################################
# Figure 1 - Percentile distribution of occupations and organizations (Sample)
##############################################################################
names(percentile_pers_occ_beid)[2] <- "Individuals"
names(percentile_pers_occ_beid)[3] <- "Occupations"
names(percentile_pers_occ_beid)[4] <- "Organizations"
percentile_pers_occ_beid <- gather(percentile_pers_occ_beid, "Unit", "mwage", -percentile)

ggplot(percentile_pers_occ_beid, aes(x = percentile, y = mwage, group = Unit)) +
  geom_line(aes(colour = Unit)) +
  geom_point(aes(colour = Unit)) +
  labs(x="Percentile", y="Average Log Hourly Wage", caption = "Source: EBB / (S)POLIS, 2006-2018") +
  scale_color_discrete(name="") +
  theme_minimal() 
ggsave("F01_percentiles.pdf", path = "H:/Christoph/art1/05_figures/")

##############################################################################
# Figure 2 - M&K style decomposition (Baseline Comparison Org & Occ)
##############################################################################
decomposition <- gather(decomposition, "component", "value", -c(model, struc))
decomposition_f2 <- filter(decomposition, model==1 & component!="total")

ggplot(decomposition_f2, aes(fill = component, y = value, x = struc, label = value)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = sprintf("%.3f", value)), size = 3, position = position_stack(vjust = 0.5)) +
  scale_fill_discrete(name = "Variance\nComponent") +
  theme(legend.title = element_text(size = 8),
        legend.text = element_text(size = 6)) +
  labs(x="", y="", caption = "Source: EBB / (S)POLIS, 2006-2018") +
  scale_y_continuous(breaks = seq(0,0.3,0.1), limits = c(0,0.3)) +
  scale_x_discrete(labels = c("M1 - Baseline (Occupations)", "M1 - Baseline (Organizations)")) +
  theme_minimal() 
ggsave("F02_decomposition_baseline.pdf", path = "H:/Christoph/art1/05_figures/")


###########################
#Within-occupation analysis
###########################

##############################################################################
# Figure 4 - M&K style decomposition (Within-Occupation)
##############################################################################
decomposition_f4 <- filter(decomposition, struc=="occ" & component=="within")
decomposition_f4$model.f <- factor(decomposition_f4$model)
ggplot(decomposition_f4, aes(x = model.f, y = value)) +
  geom_bar(stat = "identity", fill = "#00BFC4") +
  labs(x="", y="Within-Component", caption = "Source: EBB / (S)POLIS, 2006-2018") +
  scale_x_discrete(labels = c("M1 - Baseline (occupations)", "M2 - M1 + Ind. Controls",
                              "M3 - M2 + Org. Dummies", "M4 - M2 +Org. FE")) +
  geom_text(aes(label = sprintf("%.3f", value), y = value), size = 3, vjust = 2) +
  theme_minimal()
ggsave("F04_decomposition_within.pdf", path = "H:/Christoph/art1/05_figures/")

###############################################################################
# Figure 5 - Deciles of Firm FE within Occupations (aggregated to Major Groups)
###############################################################################
ggplot(firmfe_within_bigocc, aes(x = decile, y = z_j_fe, group = big_occ.f)) +
  geom_hline(yintercept=0) +
  geom_line(aes(colour = big_occ.f)) +
  geom_point(aes(colour = big_occ.f)) +
  labs(x="Decile", y="Decile Firm FE within detailed occupations\n (by ISCO08 Major Groups)", caption = "Source: EBB / (S)POLIS, 2006-2018") +
  scale_color_discrete(name="ISCO08 Major Groups") +
  scale_x_continuous(breaks = seq(1,10,1)) +
  theme_minimal()
ggsave("F05_withinocc_deciles_bigocc.pdf", path = "H:/Christoph/art1/05_figures/")

##############################################################################
# Figure 6 - Counterfactual change of within-occ SD if firm FE is set to 0
##############################################################################
ggplot(cf_analysis, aes(x = r_sd, y = change_sd, color = big_occ.f)) +
  geom_point(aes(size = n)) +
  scale_size(guide = 'none') +
  scale_color_discrete(name = "ISCO08 Major Groups") +
  theme(legend.title = element_text(size = 8),
        legend.text = element_text(size = 6),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank()) +
  geom_hline(yintercept=0) +
  labs(x="Occupations ranked by factual within-group SD", y="Counterfactual change of Within-occupation SD (%)",
       caption = "Source: EBB / (S)POLIS, 2006-2018") 
ggsave("F06_CF_SD.pdf", path = "H:/Christoph/art1/05_figures/")


############################
#Between-occupation analysis
############################

##############################################################################
# Figure 7 - M&K style decomposition (Between-Occupation)
##############################################################################
decomposition_f7 <- filter(decomposition, struc=="occ" & component=="between")
decomposition_f7$model.f <- factor(decomposition_f7$model)
ggplot(decomposition_f7, aes(x = model.f, y = value)) +
  geom_bar(stat = "identity", fill = "#F8766D") +
  labs(x="", y="Between-Component", caption = "Source: EBB / (S)POLIS, 2006-2018") +
  scale_x_discrete(labels = c("M1 - Baseline (occupations)", "M2 - M1 + Ind. Controls",
                              "M3 - M2 + Org. Dummies", "M4 - M2 +Org. FE")) +
  geom_text(aes(label = sprintf("%.3f", value), y = value), size = 3, vjust = 2) +
  theme_minimal()
ggsave("F07_decomposition_between.pdf", path = "H:/Christoph/art1/05_figures/")

##############################################################################
# Figure 8 - Average Firm FE by Occupation
##############################################################################
ggplot(cf_analysis, aes(x = mean_firm_fe, y = mean_occ_fac, color = big_occ.f)) +
  geom_vline(xintercept=0) +
  geom_point(aes(size = n)) +
  scale_size(guide = 'none') +
  scale_color_discrete(name = "ISCO08 Major Groups") +
  theme(legend.title = element_text(size = 8),
        legend.text = element_text(size = 6)) +
  labs(x="Average Firm FE (standardized)", y="Average log hourly wage (Occ.)",
       caption = "Source: EBB / (S)POLIS, 2006-2018")
ggsave("F08_MEANFE.pdf", path = "H:/Christoph/art1/05_figures/")

##############################################################################
# Figure 9 - Occupation-specific effect of Firm FE
##############################################################################
ggplot(cf_analysis, aes(x = firmfe_occ, y = mean_occ_fac, color = big_occ.f)) +
  geom_vline(xintercept=0) +
  geom_point(aes(size = n)) +
  scale_size(guide = 'none') +
  scale_color_discrete(name = "ISCO08 Major Groups") +
  theme(legend.title = element_text(size = 8),
        legend.text = element_text(size = 6)) +
  labs(x="Occupation-specific effect of Firm FE", y="Average log hourly wage (Occ.)",
       caption = "Source: EBB / (S)POLIS, 2006-2018")
ggsave("F09_Firmfe_Occ_Interact.pdf", path = "H:/Christoph/art1/05_figures/")

##############################################################################
# Figure 10 - Counterfactual change of occupation mean if firm FE is set to 0
##############################################################################
ggplot(cf_analysis, aes(x = r_mean, y = change_mean, color = big_occ.f)) +
  geom_hline(yintercept=0) +
  geom_point(aes(size = n)) +
  scale_size(guide = 'none') +
  scale_color_discrete(name = "ISCO08 Major Groups") +
  theme(legend.title = element_text(size = 8),
        legend.text = element_text(size = 6),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank()) +
  labs(x="Occupations ranked by factual average wage", y="Counterfactual change of occupation mean (%)",
       caption = "Source: EBB / (S)POLIS, 2006-2018")
ggsave("F10_CF_MEAN.pdf", path = "H:/Christoph/art1/05_figures/")
  
 
