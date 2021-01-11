# Identification Properties of Recent Production Function Estimators

This is a transcription of the GAUSS code written for Ackerberg, Caves and Frazer (2015) into MATLAB. The original code is available at the [Econometric Society website](https://www.econometricsociety.org/publications/econometrica/2015/11/01/identification-properties-recent-production-function-estimators). It runs a series of Monte Carlo trials that compare the Ackerberg-Caves-Frazer, Levinsohn-Petrin, and Olley-Pakes production function estimators.

# How to run
## main.m
Run the `main.m` function. The `main.m` function will save the outcome of each Monte Carlo run in a separate .mat file. Each .mat file contains a single variable, beta, which is an nx2 matrix with estimates of the coefficient on labor in the first column and capital in the second column.

Optionally, you can use the following parameters to control the trials that are run:
* `DGP`: The particular data-generating process to use from the ACF paper (1, 2, or 3). Can be specified as a single integer or as a vector of DGPs to run. Default is `[1 2 3]`.

* `MeasureError`: The standard deviation of the investment/intermediate input shocks used in the DGPs. Specified as either a single number or a vector of numbers. Default is `[0.0 0.1 0.2 0.5]`.

* `Estimator`: Which estimation technique to use (ACF, LP, or OP). Can be a string or a cell array of strings. Default is `{ 'ACF' 'LP' 'OP' }`

Here is an example call:
```matlab
main('DGP', 1, 'MeasureError', [0.0 0.1], 'Estimator', 'LP')
```
## initGlobals.m
Note that all of the parameters for the simulation are set in `initGlobals.m`. In particular, you may want to adjust `globals.niterations` if you wish to run a smaller Monte Carlo sample for testing purposes.
