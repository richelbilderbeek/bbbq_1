all: fig_bbbq_1_watermarked.png bbbq_1_percentages.latex bbbq_1_stats_covid.latex bbbq_1_stats_myco.latex

fig_bbbq_1_watermarked.png: watermark.jpeg fig_bbbq_1.png
	composite -tile -dissolve 5% -gravity center watermark.jpeg fig_bbbq_1.png fig_bbbq_1_watermarked.png

fig_bbbq_1.png: bbbq_1.Rmd
	Rscript -e 'rmarkdown::render("bbbq_1.Rmd")'

bbbq_1_percentages.latex: bbbq_1_percentages.csv
	csv2latex bbbq_1_percentages.csv --nohead > bbbq_1_percentages.latex

bbbq_1_stats_covid.latex: bbbq_1_stats_covid.csv
	csv2latex bbbq_1_stats_covid.csv --nohead > bbbq_1_stats_covid.latex

bbbq_1_stats_myco.latex: bbbq_1_stats_myco.csv
	csv2latex bbbq_1_stats_myco.csv --nohead > bbbq_1_stats_myco.latex

table_1.csv: bbbq_1.Rmd
	Rscript -e 'rmarkdown::render("bbbq_1.Rmd")'

clean:
	rm *.png *.latex *.csv *.pdf
