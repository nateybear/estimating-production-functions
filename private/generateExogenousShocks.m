% populate epsilon, omegaT, and omegaTminusB fields
function data = generateExogenousShocks(data, globals)
    
data = generateEpsilon(data, globals);
data = generateOmegas(data, globals);
    
end

function data = generateEpsilon(data, globals)
    
sigmaEpsilon = 0.1;
data.epsilon = randn(globals.nperiodsTotal, globals.nfirms) * sigmaEpsilon;

end

% omegas follow a modified AR(1) process
function data = generateOmegas(data, globals)   
    
Xi1 = globals.sigmaXiOmega1 * randn(globals.nperiodsTotal, globals.nfirms);
Xi2 = globals.sigmaXiOmega2 * randn(globals.nperiodsTotal, globals.nfirms);

data.omegaTminusB(1,:) = Xi1(1,:);
data.omegaT(1,:) = Xi2(1,:);

for period = 2:globals.nperiodsTotal
   data.omegaTminusB(period,:) = globals.rhoOmega1 * data.omegaT(period-1,:) + Xi1(period,:);                 
   data.omegaT(period, :) = globals.rhoOmega2 * data.omegaTminusB(period, :) + Xi2(period,:);
end
    
end

