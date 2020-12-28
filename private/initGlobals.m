% we will hold global variables in a named struct. using the global
% modifier in matlab is strongly discouraged, and matlab doesn't have very
% flexible scoping. instead, we pass parameters between function calls,
% sort of like an environment in R.
function initGlobals()
global globals

globals = struct();
setDGP = @(dgp, measureError) doSetDGP(dgp, measureError);

% set this to something non-zero to get investment shocks.
globals.sigmaLogK = 0.;

% the simulation size. in testing found that it takes ~nperiodsTotal
% periods to achieve a steady state, of which we will take the last
% nperiodsKeep
globals.nfirms = 1000;
globals.nperiodsTotal = 111;
globals.nperiodsKeep = 11;
globals.niterations = 50;

% the true coefficient values
globals.beta0 = 1;
globals.betaK = 0.4;
globals.betaL = 0.6;
globals.betaM = 1;

% setup for investment optimization. sigmaPhi is across-firm
% variation in adjustment costs
globals.sigmaPhi = 0.6;
globals.discountRate = 0.95;
globals.deprecRate = 0.2;

end