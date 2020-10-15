function estimate = estimateACF(data, globals)
    % regress data on labor, capital, intermed input
    % to get estimates of phiacf for all time periods
    phiHat = firstStageEstimate(data, globals);
    
    [ prev, curr ] = makeLags(data);

    phiPrev = prev(phiHat);
    phiCurr = curr(phiHat);
    lPrev = prev('lnLabor');
    lCurr = curr('lnLabor');
    kPrev = prev('lnKapital');
    kCurr = curr('lnKapital');
    
    % creating an anonymous reference to an outer function makes it run
    % much faster than creating a nested function (i.e. nesting
    % objectiveFun inside of this function)
    obj = @(theta) objectiveFun(theta, phiPrev, phiCurr,...
                                        lPrev, lCurr, kPrev, kCurr);

    estimate = fminsearch(obj, [globals.betaL globals.betaK]);
end

function obj = objectiveFun(theta, phiPrev, phiCurr, ...
                            lPrev, lCurr, kPrev, kCurr)
        % get omegas back from first step phi estimate
        omegaPrev = phiPrev - theta(1) * lPrev - theta(2) * kPrev;
        omegaCurr = phiCurr - theta(1) * lCurr - theta(2) * kCurr;
        
        % given fixed betaL and betaK, concentrate estimate rho to get xsi term
        xsi = fitlm(omegaPrev, omegaCurr).Residuals.Raw;
        
        % moment condition is that xsi is uncorrelated with l_t-1 and k_t
        moments = xsi .* [lPrev kCurr];
        
        obj = size(moments, 1) * mean(moments,1) * inv(cov(moments)) * mean(moments, 1).';
    end

function phiHat = firstStageEstimate(data, globals)
    X = [data.lnLabor(:) data.lnKapital(:) data.lnIntermedInput(:)];
    phiHat = fitlm(X,data.lnOutput(:)).Fitted;
    phiHat = reshape(phiHat, globals.nperiodsKeep, globals.nfirms);
end