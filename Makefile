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

all:
	echo "Run either 'make peregrine' on Peregrine, to create the data"
	echo "or run either 'make results' locally, to create the results"

peregrine: haplotypes.csv \
             covid_topology.csv human_topology.csv \
             covid_h26_ic50s.csv human_h26_ic50s.csv

results: table_tmh_binders_mhc1.latex table_tmh_binders_mhc2.latex
	echo "To create figures, run 'make figures'"
	Rscript fix_table_captions_and_labels.R

figures: table_1.csv table_2.csv
	Rscript create_figure.R mhc1
	Rscript create_figure.R mhc2

################################################################################
#
# 1. PEREGRINE
#
################################################################################

################################################################################
# Haplotypes
################################################################################
haplotypes.csv:
	Rscript create_haplotypes.R

################################################################################
# Targets
################################################################################

covid.fasta:
	Rscript get_proteome.R covid

human.fasta:
	Rscript get_proteome.R human

################################################################################
# Proteins
################################################################################

covid_proteins.csv: covid.fasta
	Rscript create_proteins.R covid

human_proteins.csv: human.fasta
	Rscript create_proteins.R human

################################################################################
# Topology, using sbatch
################################################################################

covid_topology.csv: covid_proteins.csv
	sbatch ../../peregrine/scripts/run_r_script.sh create_topology.R covid

human_topology.csv: human_proteins.csv
	sbatch ../../peregrine/scripts/run_r_script.sh create_topology.R human

################################################################################
# Peptides
################################################################################

covid_peptides.csv: covid_proteins.csv
	Rscript create_peptides.R covid

human_peptides.csv: human_proteins.csv
	Rscript create_peptides.R human

################################################################################
# IC50s, using sbatch
################################################################################
covid_h26_ic50s.csv: covid_peptides.csv haplotypes.csv
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h1
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h2
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h3
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h4
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h5
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h6
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h7
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h8
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h9
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h10
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h11
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h12
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h13
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h14
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h15
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h16
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h17
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h18
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h19
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h20
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h21
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h22
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h23
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h24
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h25
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R covid h26

human_h26_ic50s.csv: human_peptides.csv haplotypes.csv
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h1
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h2
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h3
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h4
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h5
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h6
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h7
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h8
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h9
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h10
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h11
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h12
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h13
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h14
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h15
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h16
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h17
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h18
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h19
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h20
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h21
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h22
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h23
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h24
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h25
	sbatch ../../peregrine/scripts/run_r_script.sh predict_ic50s.R human h26

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
	Rscript count_coincidence_tmh.R covid

human_coincidence.csv:
	echo "Expects 'human_topology.csv' to be created by Peregrine"
	echo "Expects 'human_peptides.csv' to be created by Peregrine"
	Rscript count_coincidence_tmh.R human

################################################################################
# Binders
################################################################################
covid_binders.csv:
	echo "Expects 'covid_h26_ic50s.csv' (and friends) to be created by Peregrine"
	Rscript count_binders_tmh.R covid

human_binders.csv:
	echo "Expects 'human_h26_ic50s.csv' (and friends) to be created by Peregrine"
	Rscript count_binders_tmh.R human

################################################################################
# Create the CSV tables for the binders
################################################################################

table_tmh_binders_raw.csv: covid_binders.csv human_binders.csv
	Rscript create_table_tmh_binders_raw.R

table_tmh_binders_mhc1.csv: table_tmh_binders_raw.csv
	Rscript create_table_tmh_binders_mhc.R mhc1

table_tmh_binders_mhc2.csv: table_tmh_binders_raw.csv
	Rscript create_table_tmh_binders_mhc.R mhc2

################################################################################
# Create all LaTeX tables
################################################################################

table_tmh_binders_mhc1.latex: table_tmh_binders_mhc1.csv
	python3 -m csv2latex
	mv LaTeX/table_tmh_binders_mhc1.tex table_tmh_binders_mhc1.latex
	rm -rf LaTeX

table_tmh_binders_mhc2.latex: table_tmh_binders_mhc2.csv
	python3 -m csv2latex
	mv LaTeX/table_tmh_binders_mhc2.tex table_tmh_binders_mhc2.latex
	rm -rf LaTeX

################################################################################
# Create the figures
################################################################################

figure_1.png: table_1.csv covid_coincidence.csv
	Rscript create_figure.R mhc1

figure_2.png: table_2.csv covid_coincidence.csv
	Rscript create_figure.R mhc2


#fig_bbbq_1.png: bbbq_1.Rmd
#	Rscript -e 'rmarkdown::render("bbbq_1.Rmd")'

#bbbq_1_percentages.latex: bbbq_1_percentages.csv
#	python3 -m csv2latex

#bbbq_1_stats_covid.latex: bbbq_1_stats_covid.csv
#	python3 -m csv2latex

#bbbq_1_stats_myco.latex: bbbq_1_stats_myco.csv
#	python3 -m csv2latex

#bbbq_1_percentages.csv: bbbq_1.Rmd
#	Rscript -e 'rmarkdown::render("bbbq_1.Rmd")'

#table_1.csv: bbbq_1.Rmd
#	Rscript -e 'rmarkdown::render("bbbq_1.Rmd")'

test_conversion:
	csv2latex bbbq_1_stats_covid.csv --nohead > 1.latex
	pip3 install --user csv2latex
	python3 -m csv2latex
	mv bbbq_1_stats_covid.latex 2.latex

update_packages:
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnuggetsr")'
	Rscript -e 'remotes::install_github("richelbilderbeek/mhcnpreds")'
	Rscript -e 'remotes::install_github("richelbilderbeek/bbbq")'

clean:
	rm *.png *.latex *.pdf
	echo "I kept the CSV files, as these are hard to calculate"
