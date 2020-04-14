all: fig_1_watermarked.png ks.latex table_1.latex table_1.csv

fig_1_watermarked.png: watermark.jpeg fig_1.png
	composite -tile -dissolve 5% -gravity center watermark.jpeg fig_1.png fig_1_watermarked.png

fig_1.png: render.sh ks.Rmd
	./render.sh

ks.latex: ks.csv
	csv2latex ks.csv --nohead > ks.latex

table_1.latex: table_1.csv
	csv2latex table_1.csv --nohead > table_1.latex

table_1.csv: render.sh ks.Rmd
	./render.sh

