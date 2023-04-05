FROM rocker/r-ver:4.2.2

#RUN sudo apt-get remove -y rstudio-server # only if tidyverse or verse base images used


# TeX layer
RUN apt-get update && apt-get install -y pandoc pandoc-citeproc texlive-science texlive-latex-extra texlive-lang-german

# System dependency layer
COPY requirements-system.txt .
RUN apt-get update && apt-get -y install $(cat requirements-system.txt)

# Python layer
COPY requirements-python.txt .
RUN pip install -r requirements-python.txt

# R layer
COPY requirements-R.R .
RUN Rscript requirements-R.R


WORKDIR /c-dbr

CMD "R"
