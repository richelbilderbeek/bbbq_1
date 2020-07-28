all:

# local: fig_bbbq_1.png bbbq_1_percentages.latex bbbq_1_stats_covid.latex bbbq_1_stats_myco.latex

# Run tests first
mhc1_test.csv: predict_n_binders_tmh.R
	Rscript predict_n_binders_tmh.R mhc1 test

mhc2_covid.csv: predict_n_binders_tmh.R 
	Rscript predict_n_binders_tmh.R mhc2 test

# Covid is smallest
mhc1_covid.csv: predict_n_binders_tmh.R
	Rscript predict_n_binders_tmh.R mhc1 covid

mhc2_covid.csv: predict_n_binders_tmh.R
	Rscript predict_n_binders_tmh.R mhc2 covid

# LaTeX
mhc1_test.latex: mhc1_test.csv
	python3 -m csv2latex

mhc2_test.latex: mhc2_test.csv
	python3 -m csv2latex

mhc1_covid.latex: mhc1_covid.csv
	python3 -m csv2latex

mhc2_covid.latex: mhc2_covid.csv
	python3 -m csv2latex

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
	rm *.png *.latex *.csv *.pdf
