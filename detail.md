## Guide to Data Construction and Analysis Files

This document outlines all files in this repository. These contain all files necessary to construct the data and conduct analysis in Carter and Wozniak JHR. U.S. Army personnel data cannot be shared, and some information in the data construction files using this source has been removed to preserve confidentiality. ACS data are readily obtainable from IPUMS-USA, and complete code to reconstruct that portion of the analysis from raw ACS files is included. The remainder of this document outlines files used in data construction and then in analysis reported in Carter and Wozniak JHR.

**Data Set Construction**

The tables and figures for “Making Big Decisions: The Impact of Moves on Marriage among U.S. Army Personnel” are created using data from the American Community Survey from 2008-2018 (Table 1) and from individual-level data on military servicemembers (all other Tables and Figures).  The military data is not publicly available outside of researcher with the Army and/or the Office of Economic and Manpower Analysis. 

The do files to create the data for our tables and figures are described below and were created using STATA/MP 16.1.  

- Army Personnel Data  
  - jhr_clean_FINAL.do creates the final datasets jhr_clean_for_tables.dta, evermarr_us_sample, figre_sample_fake_1.dta, data_for_graph_miles.dta, figs_3a_3b.dta, and app_fig_1.dta from de-identified data. 
  - jhr_creating_samples.do uses jhr_clean_for_tables.dta and creates the samples used for Tables 2-7, and Appendix Tables 1-4.  
  - Note that the data cannot be provided.  
- ACS data set up
  - ACS data is read in from raw downloads from IPUMS-USA using the file acs_moves_marriage. The Stata dictionary file provided by IPUMS is usa00027.do. Raw data can be reconstructed on IPUMS-USA using variable names in that file.

**Tables Construction**

Table 1. Civilian Moves and Marriage 
- acs_moves_marriage.do – Reads in raw ACS data from IPUMS-USA, cleans and codes for analysis, and conducts the analysis reported in Table 1 as well as additional tabulations. Output is in acs_moves_marriage.log.

Table 2 / Appendix Table B1:  Summary Statistics the Five Years of Service Sample of Enlisted Army Members
- jhr_table_2_table_b1_FINAL.do– Uses jhr_samples_created.dta to produce Table 2 and Table B1. LOG file: table_2_table_b1_FINAL.txt

Table 3 - Tests of Conditional Random Assignment, Dependent Variable: Total Number of Moves
- jhr_table_3_FINAL.do - Uses jhr_samples_created.dta to produce Table 3. LOG file: log_table_3_FINAL.txt. EXCEL Output: table_3.xls

Table 4 / Appendix Table C3: The Effect of Moves on Marriage Propensity
- jhr_table_4_table_c3_FINAL.do – Uses jhr_samples_created.dta to produce Table 4 & Table C3. LOG file: table_4_table_c3_FINAL.txt. EXCEL Output: table_4_panel_a.xls, table_4_panel_b.xls, table_4_panel_c.xls, app_c3_panel_a.xls, app_c3_panel_b.xls, app_c3_panel_c.xls

Table 5.- The Effect of Moves on Other Marriage and Family Outcomes 
-	jhr_table_5_FINAL.do – Uses jhr_samples_created.dta to produce Table 5.  LOG file: table_5_FINAL.txt. EXCEL Output: table_5_panel_a.xls, table_5_panel_b.xls, table_5_panel_c.xls

Table 6: The Effect of Moves on Other Marriage and Family Outcomes: Alternative Samples
-	jhr_table_6_FINAL.do – Uses jhr_samples_created.dta to produce Columns 1, 2, 4, and 5 of Table 6. LOG file: table_6_FINAL.txt. EXCEL Output: table_6_panel_a.xls, table_6_panel_b.xls, table_6_panel_c.xls, table_6_panel_d.xls, table_6_panel_e.xls
-	jhr_table_6_column3_final.do - Uses first_term_miles.dta to produce Column 3 of Table 6. LOG file: jhr_end_first_term_FINAL.txt. EXCEL Output: table_6_col3.xls

Table 7: Effect of Moves on Marriage Propensity, Adding Controls for Location Characteristics
-	jhr_table_7_FINAL.do – Uses jhr_samples_created.dta to produce Table 7. LOG file: log_table_7_FINAL.txt. EXCEL Output: table_7.xls

Table 8: Probability of Married Status in Year t1, t2, t3, t4, and t5 | Not Married when Enter
-	jhr_table_8_FINAL.do uses evermarr_us_sample.dta to produce Table 8. LOG file: jhr_table_8_FINAL.txt. EXCEL Output: table_8.xls

Table C1: Alternative Clustering Methods for Main Table 4 Impacts & Table C2: Table 4 Analysis with Clustering on Job x Rank x Year
-	jhr_app_tables_c1_c2_FINAL.do Uses jhr_samples_created.dta to produce Tables C1 and C2. LOG file: app_tables_c1_c2_FINAL.txt. EXCEL Output: app_c1_evermarr.xls, app_c1_marr_nm_ent.xls, app_c1_married.xls, app_c2_evermarr.xls, app_c2_marr_nm_ent.xls, app_c2_married.xls

Table C4: Non-linear & International Impacts of Moves
-	jhr_app_table_c4_FINAL.do Uses jhr_samples_created.dta to produce Tables C4. LOG file: app_table_c4_FINAL.txt. EXCEL Output: app_c4.xls

**Figures Construction**

Figure 1: Probability of a Marriage
-	jhr_fig_1_FINAL.do uses figre_sample_fake_1.dta to produce Figure 1. LOG file: fig_1_FINAL.txt

Figure 2 & 4: Figure 2. Share Married by Months to First Move, Residualized / Figure 4. Residualized Marriage Rates by Location of Moves
-	jhr_fig_2_fig_4_FINAL.do uses data_for_graph_miles.dta to produce Figures 2 and 4. LOG file: jhr_figs_2_4_FINAL.txt

Figure 3 - Figure 3A: Share Married by Months to Re-enlistment & Figure 3B: Share Experiencing First Move by Months to Re-enlistment
-	jhr_fig_3a_3b_FINAL.do – uses figs_3a_3b.dta to produce Figure 3. LOG file: jhr_figs_3a_3b_FINAL.txt

Appendix C Figure 1. Distribution of First Moves by Month from Start of Contract
-	jhr_app_fig_1_FINAL.do uses app_fig_1.dta to produce Appendix C Figure 1. Jhr_app_fig_1_FINAL.txt

