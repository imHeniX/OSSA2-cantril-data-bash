## CITS4407 Assignment 2

The assignment involves creating two Bash scripts to perform data cleaning and analysis on a dataset related to world happiness.

### Cantril data cleaning

- The Cantril Data Cleaning script is used to clean the three input files which produces an `output.tsv` file

- To run the script, first make it executable:

```bash
chmod +x cantril_data_cleaning

```

To execute `cantril_data_cleaning`:

```bash
./cantril_data_cleaning gdp-vs-happiness.tsv homicide-rate-unodc.tsv life-satisfaction-vs-life-expectancy.tsv

```

### Best predictor script

- This script compares the correlation of each predictor in the input file and outputs the best predictor among them.

```bash
chmod +x best_predictor

```

- To execute the script run the following command.

```bash
./best_predictor output.tsv