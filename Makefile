#
# Usage:
#
# Create the data on Peregrine
#
#   make peregrine
#
# Create the results locally, assume data is there
#
#   make results
#
.DELETE_ON_ERROR:
all: haplotypes_lut.csv \
     covid_proteins_lut.csv human_proteins_lut.csv myco_proteins_lut.csv \
     myco_h21_p3_counts.csv
	echo "Run either 'make peregrine' on Peregrine, to create the data"
	echo "or run either 'make results' locally, to create the results"

# Create the test proteomes
.DELETE_ON_ERROR:
use_test_proteomes_and_haplotypes:
	Rscript get_proteome.R test_covid
	Rscript get_proteome.R test_human
	Rscript get_proteome.R test_myco
	Rscript create_haplotypes_lut.R test

.DELETE_ON_ERROR:
peregrine: covid_ic50s human_ic50s myco_ic50s

.DELETE_ON_ERROR:
covid_ic50s: covid_topology.csv covid_h26_ic50s.csv

.DELETE_ON_ERROR:
human_ic50s: human_topology.csv human_h26_ic50s.csv

.DELETE_ON_ERROR:
myco_ic50s: myco_topology.csv myco_h26_ic50s.csv

.DELETE_ON_ERROR:
covid_results: covid_coincidence.csv covid_binders.csv

.DELETE_ON_ERROR:
human_results: human_coincidence.csv human_binders.csv

.DELETE_ON_ERROR:
myco_results: myco_coincidence.csv myco_binders.csv

.DELETE_ON_ERROR:
results: table_tmh_binders_mhc1.latex table_tmh_binders_mhc2.latex \
         fig_f_tmh_mhc1.png fig_f_tmh_mhc2.png \
         fig_ic50_distribution.png \
         table_ic50_binders.latex \
         table_f_tmh.latex

################################################################################
#
# 1. PEREGRINE
#
################################################################################

################################################################################
# Haplotypes
################################################################################
haplotypes_lut.csv:
	Rscript create_haplotypes_lut.R

################################################################################
# Targets
################################################################################

covid.fasta:
	Rscript get_proteome.R covid

human.fasta:
	Rscript get_proteome.R human

myco.fasta:
	Rscript get_proteome.R myco

################################################################################
# Protein LUT
################################################################################

covid_proteins_lut.csv: covid.fasta
	Rscript create_proteins_lut.R covid

human_proteins_lut.csv: human.fasta
	Rscript create_proteins_lut.R human

myco_proteins_lut.csv: myco.fasta
	Rscript create_proteins_lut.R myco

################################################################################
# Counts, using sbatch or not
################################################################################

# Local: will run all jobs
# On Peregrine: will submit max 987 jobs
myco_h21_p3_counts.csv:
	Rscript create_all_counts.R

################################################################################
#
# 2. RESULTS
#
################################################################################

################################################################################
# Coincidence
################################################################################
covid_coincidence.csv:
	echo "Expects 'covid_topology.csv' to be created by Peregrine"
	echo "Expects 'covid_peptides.csv' to be created by Peregrine"
	time Rscript count_coincidence_tmh.R covid

human_coincidence.csv:
	echo "Expects 'human_topology.csv' to be created by Peregrine"
	echo "Expects 'human_peptides.csv' to be created by Peregrine"
	time Rscript count_coincidence_tmh.R human

myco_coincidence.csv:
	echo "Expects 'myco_topology.csv' to be created by Peregrine"
	echo "Expects 'myco_peptides.csv' to be created by Peregrine"
	time Rscript count_coincidence_tmh.R myco

################################################################################
# Binders
################################################################################
covid_binders.csv: haplotypes.csv
	echo "Expects 'covid_h26_ic50s.csv' (and friends) to be created by Peregrine"
	time Rscript count_binders_tmh.R covid

human_binders.csv: haplotypes.csv
	echo "Expects 'human_h26_ic50s.csv' (and friends) to be created by Peregrine"
	time Rscript count_binders_tmh.R human

myco_binders.csv: haplotypes.csv
	echo "Expects 'myco_h26_ic50s.csv' (and friends) to be created by Peregrine"
	time Rscript count_binders_tmh.R myco

################################################################################
# Create the CSV tables for the binders
################################################################################

table_tmh_binders_raw.csv: covid_binders.csv myco_binders.csv
	time Rscript create_table_tmh_binders_raw.R

table_tmh_binders_mhc1.latex: table_tmh_binders_raw.csv
	time Rscript create_table_tmh_binders_mhc.R mhc1

table_tmh_binders_mhc2.latex: table_tmh_binders_raw.csv
	time Rscript create_table_tmh_binders_mhc.R mhc2

################################################################################
# Create all LaTeX tables
################################################################################

# Easy and general table
table_ic50_binders.latex: haplotypes.csv
	Rscript create_table_ic50_binders.R

table_f_tmh.latex:
	Rscript create_table_f_tmh.R

################################################################################
# Create the figures
################################################################################

fig_f_tmh_mhc1.png: table_tmh_binders_raw.csv \
                    covid_coincidence.csv myco_coincidence.csv 
	time Rscript create_figure.R mhc1

fig_f_tmh_mhc2.png: table_tmh_binders_raw.csv \
                    covid_coincidence.csv myco_coincidence.csv 
	time Rscript create_figure.R mhc2

fig_ic50_distribution.png: covid_h26_ic50s.csv haplotypes.csv
	Rscript create_fig_ic50_distribution.R

#bbbq_1_percentages.csv: bbbq_1.Rmd
#	Rscript -e 'rmarkdown::render("bbbq_1.Rmd")'

update_packages:
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnuggetsr")'
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnpreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/bbbq", ref = "develop")'

clean:
	rm -f *.png *.latex *.pdf *.fasta
	echo "I kept the CSV files, as these are hard to calculate"

clean_all:
	rm -f *.png *.latex *.pdf *.fasta *.csv

