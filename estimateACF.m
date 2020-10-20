function estimate = estimateACF(data, globals)

    phiHat = firstStageEstimate(data, globals);
    
    [ prev, curr ] = makeLags(data);

    phiPrev = prev(phiHat);
    phiCurr = curr(phiHat);
    lPrev = prev('lnLabor');
    lCurr = curr('lnLabor');
    kPrev = prev('lnKapital');
    kCurr = curr('lnKapital');
    
    obj = @(theta) objectiveFun(theta, phiPrev, phiCurr,...
                                        lPrev, lCurr, kPrev, kCurr);

    estimate = fminsearch(obj, [globals.betaL globals.betaK]);
end

% moment condition for ACF is that the lagged labor and current capital are both
% uncorrelated with the innovation term in the omega process.
function obj = objectiveFun(theta, phiPrev, phiCurr, ...
                            lPrev, lCurr, kPrev, kCurr)
    omegaPrev = phiPrev - theta(1) * lPrev - theta(2) * kPrev;
    omegaCurr = phiCurr - theta(1) * lCurr - theta(2) * kCurr;

    xsi = fitlm(omegaPrev, omegaCurr).Residuals.Raw;

    moments = xsi .* [lPrev kCurr];

    obj = size(moments, 1) * mean(moments,1) * inv(cov(moments)) * mean(moments, 1).';
end

% this is the same first stage estimate as LP, but assumes that betaL is precluded
% from identification. identification of betaL happens in the second stage now.
function phiHat = firstStageEstimate(data, globals)
    X = [data.lnLabor(:) data.lnKapital(:) data.lnIntermedInput(:)];
    phiHat = fitlm(X,data.lnOutput(:)).Fitted;
    phiHat = reshape(phiHat, globals.nperiodsKeep, globals.nfirms);
end