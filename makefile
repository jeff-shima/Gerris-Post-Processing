all: .done

.done: settlefunc_plot.pdf Cmat.Rdata Cmat.csv
	Rscript connect-mat.r
