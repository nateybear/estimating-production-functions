% populates lnWage field in data following AR(1) process
function data = generateWages(data, globals)
    Xi = globals.sigmaXiWage * randn(globals.nperiodsTotal, globals.nfirms);
    
    data.lnWage(1,:) = Xi(1,:);
  
    for period = 2:globals.nperiodsTotal
        data.lnWage(period,:) = globals.rhoWage * data.lnWage(period-1,:) + Xi(period,:);
    end
end