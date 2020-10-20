% couple the various things that we want to do with estimators, namely run them,
% report how long they took to run, and save the estimates to disk. this is not the
% most elegant POC (I blame MATLAB's arbitrary distinction between arrays and cell
% arrays and ill-founded distate for heterogeneity). Given a cell array of strings
% corresponding to estimation methods and an integer representing the number of
% Monte Carlo iterations to do, return a three-tuple: run the estimation for a given
% iteration, report how long it took at the end, and save the estiamtes to disk.
function [ runEstimates, reportEstimates, saveEstimates ] = makeEstimators(estimationMethods, size)
    if ischar(estimationMethods)
        estimationMethods = { estimationMethods };
    end
    numMethods = length(estimationMethods);
    iteration = 1;
    storage = arrayfun(@(i_) zeros(size, 2), 1:numMethods, 'UniformOutput', false);
    
    estimatorMap = containers.Map({ 'ACF' 'LP' }, { @estimateACF @estimateLP });
    estimators = cell(1, numMethods);
    reporters = cell(1, numMethods);
    
    for imethod = 1:numMethods
        method = estimationMethods{imethod};
        [estimators{imethod}, reporters{imethod}] = makeTimed(sprintf("estimating %s", method), estimatorMap(method), size);
    end
        
    function doRun(data, globals)
        for i = 1:numMethods
            storage{i}(iteration, :) = estimators{i}(data, globals);
        end
        
        iteration = iteration + 1;
    end

    function doReport()
        for i = 1:numMethods
            reporters{i}();
        end
    end

    function doSave(dgp, measureError)
        for i = 1:numMethods
            e = estimationMethods{i};
            beta = storage{i};
            filename = sprintf('%s_DGP%02d_Err%0.1f_%s.mat', e, dgp, measureError, date);
            save(filename, 'beta');
            fprintf('Wrote estimates to %s\n', filename);
            meanEstimate = mean(beta, 1);
            sdEstimate = std(beta, 1);
            fprintf('Estimate betaL (%s): %.4f (%.4f)\n', e, meanEstimate(1), sdEstimate(1));
            fprintf('Estimate betaK (%s): %.4f (%.4f)\n\n', e, meanEstimate(2), sdEstimate(2));
        end
    end

    runEstimates = @doRun;
    reportEstimates = @doReport;
    saveEstimates = @doSave;
end