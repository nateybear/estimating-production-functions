function estimate = estimateLP(data, globals)
    [ betaL, phiHat ] = firstStageEstimate(data, globals);
    
    [ prev, curr ] = makeLags(data);

    phiPrev = prev(phiHat);
    phiCurr = curr(phiHat);
    kPrev = prev('lnKapital');
    kCurr = curr('lnKapital');
    yCurr = curr('lnOutput');
    lCurr = curr('lnLabor');
    
    obj = @(theta) objectiveFun(theta, phiPrev, phiCurr, kPrev, kCurr, ...
                                    yCurr, lCurr, betaL);
                                
    betaK = fminsearch(obj, globals.betaK);
    
    estimate = [ betaL betaK ];
end

function obj = objectiveFun(theta, phiPrev, phiCurr, kPrev, kCurr, yCurr, ...
                                lCurr, betaL)
    omegaPrev = phiPrev - theta * kPrev;
    omegaCurr = phiCurr - theta * kCurr;
    
    omegaCurrFitted = fitlm(omegaPrev, omegaCurr).Fitted;
    
    xsiPlusEps = yCurr - betaL * lCurr - theta * kCurr - omegaCurrFitted;
    
    obj = sum(xsiPlusEps .^ 2);
end

function [ betaL, phiHat ] = firstStageEstimate(data, globals)
    X = [data.lnLabor(:) data.lnKapital(:) data.lnIntermedInput(:)];
    gamma = fitlm(X,data.lnOutput(:)).Coefficients.Estimate;
    betaL = gamma(2);
    phiHat = [ ones(size(X,1), 1)  X(:, [2 3]) ] * gamma([1 3 4]);
    phiHat = reshape(phiHat, globals.nperiodsKeep, globals.nfirms);
end