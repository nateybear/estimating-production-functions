# Monte Carlo Experiments with ACF Estimator

This is a transcription of the ACF estimation technique from GAUSS into MATLAB. For the original GAUSS code, see the supplemental materials on the [Econometric Society website](https://www.econometricsociety.org/publications/econometrica/2015/11/01/identification-properties-recent-production-function-estimators).

This code is a series of Monte Carlo trials to verify the robustness of the estimator proposed by Ackerberg, Caves, and Frazer in "Identification Properties of Recent Production Function Estimators." Specifically, it imposes various amounts of optimization error in labor demand and measurement error in intermediate input demand and compares the ACF estimator with those given by [Pakes and Olley](https://www.econometricsociety.org/publications/econometrica/1996/11/01/dynamics-productivity-telecommunications-equipment-industry) and [Levinsohn and Petrin](https://econpapers.repec.org/article/ouprestud/v_3a70_3ay_3a2003_3ai_3a2_3ap_3a317-341.htm) to estimate production in the presence of serially correlated, unobserved shocks.

# How to run

Clone this repository and open the `main.m` script. Run main with the desired data-generating process (1, 2, or 3) and the desired amount of measurement error. Estimates will be written in the same directory as `main.m` with a separate .mat file for each estimation technique.

# TODOs

1. ACF estimator looks incorrect for non-zero amounts of measurement error.
  * Verify that measurement error is being generated correctly (particularly the *proportional to within variance* part)
  * Verify that investment is being generated correctly
  * Revist ACF estimation code. This seems fine.

2. Add LP and OP estimation
