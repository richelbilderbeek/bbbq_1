#
# Usage:
#
# Create tables and figures, assume real data is there (to
# create the real data, use 'make peregrine')
#
#   make
#
# Run the real data on Peregrine
#
#   make peregrine
#
# Run the tests on Peregrine
#
#   make peregrine_test
#

all: table_1.latex table_2.latex
	echo "To create figures, run 'make figures'"

#figures: fig_bbbq_1.png
#	echo "To create figures, run 'make figures'"

################################################################################
# Create the raw data
################################################################################

peregrine_test:
	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R test_mhc test
	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R test_mhc test

peregrine:
	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R mhc1 test
	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R mhc2 test
	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R mhc1 covid
	sbatch ~/GitHubs/peregrine/scripts/run_r_script.sh predict_n_binders_tmh.R mhc2 covid

################################################################################
# Create the CSV tables
################################################################################

table_1.csv: create_table.R \
             mhc1_test.csv \
             mhc1_covid.csv
	Rscript create_table.R mhc1

table_2.csv: create_table.R \
             mhc2_test.csv \
             mhc2_covid.csv
	Rscript create_table.R mhc2

################################################################################
# Create the LaTeX tables
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
