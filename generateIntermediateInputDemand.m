function data = generateIntermediateInputDemand(data, globals)
% assumption is that intermediate input demand is determined based on
% "true" labor demand, while data (seen to the econometrician)
% is affected by some measurement error.

    trueLabor = data.lnLabor;
    optimError = globals.sigmaOptimErrL * randn(globals.nperiodsTotal, globals.nfirms);
    data.lnLabor = trueLabor + optimError;
    
    data.lnIntermedInput = globals.beta0 + globals.betaL * trueLabor + ...
        globals.betaK * data.lnKapital + data.omegaT;
    
end