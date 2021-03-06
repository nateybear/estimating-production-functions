% analytical solution to firm's labor demand problem (appendix section A.2) 
function data = calculateLaborDemand(data, globals)

data.lnLabor = ((globals.sigmaXiOmega2^2)/2 + log(globals.betaL) + globals.beta0 + globals.rhoOmega2 * ...
    data.omegaTminusB - data.lnWage + globals.betaK * data.lnKapital)/(1-globals.betaL);

end