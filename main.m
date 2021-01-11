% see readme for running instructions
function main(varargin)

rng(8675309); % set seed

% see parseInput below for the accepted arguments
inp = parseInput(varargin{:});

estimators = ifelse(ischar(inp.Estimator), { inp.Estimator }, inp.Estimator);
nEstimators = length(estimators);
estimatorMap = containers.Map({ 'ACF' 'LP' 'OP' }, { @estimateACF @estimateLP @estimateOP });

% loop over DGP and measure error scenarios
for idgp = 1:length(inp.DGP)
    dgp = inp.DGP(idgp); % current DGP
    for imErr = 1:length(inp.MeasureError)
        measureError = inp.MeasureError(imErr); % current measureError

        % init data structures
        globals = initGlobals(dgp, measureError);
        data = initDataStruct(globals);

        % pipeline to generate monte carlo data
        generateData = makePipe(@generateExogenousShocks, @generateWages,...
                @calculateInvestmentDemand, @calculateLaborDemand, ...
                @generateIntermediateInputDemand, @calculateFirmOutput, @keepLastN);

        % fns to add measurement error (not in data pipeline b/c it depends on
        % the estimation method which variable you are adding noise to)
        addInvestmentError = generateMeasureErrorIn('lnInvestment');
        addIntermedInputError = generateMeasureErrorIn('lnIntermedInput');


        % store estimates as a cell array of matrices
        estimates = cell(1, nEstimators);
        for iEstimator = 1:nEstimators
            estimates{iEstimator} = zeros(globals.niterations, 2);
        end

        % the actual Monte Carlo---generate data and estimate in a loop
        for iiteration = 1:globals.niterations
            data = generateData(data, globals);

            for iEstimator = 1:nEstimators
                estimator = estimators{iEstimator};
                f = estimatorMap(estimator);
                
                % if doing OP estimation, add error to invesetment, o.w. add it
                % to intermed input
                addMeasureError = ifelse(strcmp(estimators{iEstimator}, 'OP'), addInvestmentError, addIntermedInputError);
                data = addMeasureError(data, globals);
                
                estimates{iEstimator}(iiteration, :) = f(data, globals);
            end

        end

        % after the monte carlo, save the estimates to disk as .mat files
        for iEstimator = 1:nEstimators
            name = estimators{iEstimator};
            beta = estimates{iEstimator};
            filename = sprintf('%s_DGP%02d_Err%0.1f_%s.mat', name, dgp, measureError, date);
            save(filename, 'beta');
            fprintf('Wrote estimates to %s\n', filename);
            meanEstimate = mean(beta, 1);
            sdEstimate = std(beta, 1);
            fprintf('Estimate betaL (%s): %.4f (%.4f)\n', name, meanEstimate(1), sdEstimate(1));
            fprintf('Estimate betaK (%s): %.4f (%.4f)\n\n', name, meanEstimate(2), sdEstimate(2));
        end
    end
end

end

function inp = parseInput(varargin)
    p = inputParser();
    addParameter(p, 'DGP', [1 2 3]);
    addParameter(p, 'MeasureError', [0.0 0.1 0.2 0.5]);
    addParameter(p, 'Estimator', { 'ACF' 'LP' 'OP' });
    
    parse(p, varargin{:});
    
    inp = p.Results;
end

% matlab has no ternary operator. shame on them.
function out = ifelse(test, ifTrue, ifFalse)
    if test
        out = ifTrue;
    else
        out = ifFalse;
    end
end