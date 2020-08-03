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
             covid_peptides.csv human_peptides.csv \
             covid_topology.csv human_topology.csv

results: table_1.latex table_2.latex
	echo "To create figures, run 'make figures'"

figures: table_1.csv table_2.csv
	Rscript create_figure.R mhc1
	Rscript create_figure.R mhc2

################################################################################
# Haplotypes
################################################################################
haplotypes.csv:
	Rscript create_haplotypes.R

################################################################################
# Targets
################################################################################

covid.fas:
	Rscript get_proteome.R covid

human.fas:
	Rscript get_proteome.R human

################################################################################
# Proteins
################################################################################

covid_proteins.csv: covid.fas
	Rscript create_proteins.R covid

human_proteins.csv: human.fas
	Rscript create_proteins.R human

################################################################################
# Topology
################################################################################

covid_topology.csv: covid_proteins.csv
	Rscript create_topology.R covid

human_topology.csv: human_proteins.csv
	Rscript create_topology.R human

################################################################################
# Peptides
################################################################################

covid_peptides.csv: covid_proteins.csv
	Rscript create_peptides.R covid

human_peptides.csv: human_proteins.csv
	Rscript create_peptides.R human

################################################################################
# Create the raw data (old)
################################################################################

#peregrine:
#	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R mhc1 covid
#	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R mhc2 covid
#	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_coincidence_tmh.R covid

################################################################################
# Create the CSV tables for the binders
################################################################################

table_1.csv: create_table.R
	echo "Assume the data is present. If not, run 'make peregrine'"
	Rscript create_table.R mhc1

table_2.csv: create_table.R
	echo "Assume the data is present. If not, run 'make peregrine'"
	Rscript create_table.R mhc2

################################################################################
# Create all LaTeX tables
################################################################################

table_1.latex: table_1.csv
	python3 -m csv2latex
	mv LaTeX/table_1.tex table_1.latex
	rm -rf LaTeX

table_2.latex: table_2.csv
	python3 -m csv2latex
	mv LaTeX/table_2.tex table_2.latex
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

clean:
	rm *.png *.latex *.pdf
	echo "I kept the CSV files, as these are hard to calculate"
