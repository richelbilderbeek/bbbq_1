all: view.sh article.pdf
	./view.sh

article.pdf: create.sh article.tex ks/table_1.latex ks/ks.latex ks/fig_1_watermarked.png
	aspell -t -c article.tex
	./create.sh

ks/fig_1_watermarked.png: ks/watermark.jpeg ks/fig_1.png
	composite -tile -dissolve 5% -gravity center ks/watermark.jpeg ks/fig_1.png ks/fig_1_watermarked.png

ks/fig_1.png: ks/render.sh ks/ks.Rmd
	cd ks; ./render.sh; cd ..

ks/ks.latex: ks/ks.csv
	csv2latex ks/ks.csv --nohead > ks/ks.latex

ks/table_1.latex: ks/table_1.csv
	csv2latex ks/table_1.csv --nohead > ks/table_1.latex

ks/table_1.csv: ks/render.sh ks/ks.Rmd
	cd ks; ./render.sh; cd ..

frans: bbbq.zip

bbbq.zip: zip.sh article.pdf
	./zip.sh
