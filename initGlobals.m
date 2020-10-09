% we will hold global variables in a named struct. using the global
% modifier in matlab is strongly discouraged, and matlab doesn't have very
% flexible scoping. instead, we pass parameters between function calls,
% sort of like an environment in R.
function globals = initGlobals(dgp, measureError)
    
    globals = struct();
    
    % set DGP-specific vars
    globals.dgp = dgp;
    switch dgp
        case 1
            globals.sigmaLogWage = 0.1;
            globals.timeB = 0.5;
            globals.sigmaOptimErrL = 0.;
        case 2
            globals.sigmaLogWage = 0.;
            globals.timeB = 0.;
            globals.sigmaOptimErrL = 0.37;
        case 3
            globals.sigmaLogWage = 0.1;
            globals.timeB = 0.5; 
            globals.sigmaOptimErrL = 0.37;
    end
    
    globals.measureError = measureError;
    
    % the simulation size. in testing found that it takes ~nperiodsTotal
    % periods to achieve a steady state, of which we will take the last
    % nperiodsKeep
    globals.nfirms = 1000;
    globals.nperiodsTotal = 111;
    globals.nperiodsKeep = 11;
    globals.niterations = 1000;
    
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
    
    % set up for wage process. variance of the innovation term must be
    % backed out from the desired overall process variance.
    globals.rhoWage = 0.7;
    globals.sigmaXiWage = sqrt((1-globals.rhoWage^2) * globals.sigmaLogWage^2);
   
    % set up for omega processes. this time have to decompose omega into
    % the partially observed omega_{t-b} where firms make their investment
    % decision
    globals.sigmaOmega = 0.3;
    globals.rhoOmega = 0.7;
    globals.rhoOmega1 = globals.rhoOmega^(1-globals.timeB);
    globals.rhoOmega2 = globals.rhoOmega^globals.timeB;
    globals.sigmaXiOmega = sqrt((1-globals.rhoOmega^2)*globals.sigmaOmega^2);
    globals.sigmaXiOmega1 = sqrt((1-globals.rhoOmega1^2)*globals.sigmaOmega^2);
    globals.sigmaXiOmega2 = sqrt((1-globals.rhoOmega2^2)*globals.sigmaOmega^2);
end