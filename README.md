

# rvispack

<!-- badges: start -->
<!-- badges: end -->

This [ggplot](https://ggplot2.tidyverse.org/) powered package is still
in development and includes several data visualization
techniques. Currently, the most complete function is to create
`violin` plots. However, other techniques are being implemented such
as `histograms` and `projections`. The later technique is generated as
a result of applying Principal Component Analysis.

## Docker containers

The visualizations implemented in the `rvispack` package are designed
to be containerized and executed from the command line.

- The GitHub repository can be found [here](https://github.com/rijksuniversiteit-groningen/docker-cds/tree/venus/feature/readme).
- The ReadTheDocs documentation can be found [here](https://docker-cds.readthedocs.io/en/latest/using/visualization/rvispack.html).

## Installation in R

You can install the development version of `rvispack` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rijksuniversiteit-groningen/cds-utils",subdir="rutils")
devtools::install_github("rijksuniversiteit-groningen/rvispack")
```

The main visualization functions implemented in `rvispack` receive an
`R list` object including information such as data file name,
variables and output format. However, a
[JSON](https://www.json.org/json-en.html) object stored in a file can
also be used. The JSON object is validated against a predefined [JSON
schema](https://www.json.org/json-en.html). In fact, the containerized
version works with JSON objects.

### A simple example

Given the following `violin_parameters_iris.json` file

```json
{
	"filename": "iris.csv",
	"y_variable": "sepal.length"
}
```

and `iris.csv` data file, the following source code can be used to
generate a violin plot.

```r
  # list of parameters lp
  lp <- rutils::validate_json_file("violin_parameters_iris.json")

  # Validating the JSON object against the violin schema
  validate_parameters("violin_parameters_iris.json","violin_schema.json")

  # creating the plot
  p <- c_violin(lp)
  p
```

![alt violin plot](./tests/testthat/results/Rplots.pdf.png)


## A more elaborated example

Given the following `mpg_params.json` and `ggplotmpg.csv` files. 

```json
{
    "filename": "ggplotmpg.csv",
    "y_variable": "hwy",
    "x_variable": "class",
    "colour": "class",
    "fill": "class",
    "rotxlabs": 45,
    "boxplot": {
        "addboxplot": true,
    	"width": 0.1
    },
    "save":{
	  "save": true,
	  "width": 15,
	  "height": 10,
	  "device": "png"
	  }
}
```

We can run

```r
  lp <- rutils::validate_json_file("mpg_params.json")

  validate_parameters("`mpg_params.json","violin_schema.json")

  p <- c_violin(lp)
```

![alt mpgviolin](tests/testthat/results/ggplotmpg.csv-violin-20221009_203930.png)

The files in the above example can be found in `tests/testhat/data`
and `tests/testhat/params`.

### List the implemented visualizations

```
help(package=rvispack)
```

### List required parameters
```
?<function name>
```

For example
```
?c_violin
```
