% run from command window as "main" or "main X" where X is the DGP number
function main(varargin)
    rng(239482398);
    
    % init data structures
    globals = initGlobals(varargin{:});
    data = initDataStruct(globals);
    betaACF = zeros(globals.niterations, 2);
    
    % pipeline to generate monte carlo data
    dataPipeline = pipe(@generateExogenousShocks, @generateWages,...
            @calculateInvestmentDemand, @calculateLaborDemand, ...
            @generateIntermediateInputDemand, @calculateFirmOutput, @keepLastN);
       
    % run data generation and estimate in a loop
    [generateData, reportGenerateData] = timed("generating data", dataPipeline, globals.niterations);  
    [estimateACF, reportEstimateACF] = timed("estimating ACF", @acfEstimator, globals.niterations);
    
    % show progress bar. you can close it and it will keep running.
    progress = waitbar(0, "Running simulation...");
    
    for iiteration = 1:globals.niterations
        data = generateData(data, globals);
        betaACF(iiteration, :) = estimateACF(data, globals);
        if isvalid(progress)
            waitbar(iiteration/globals.niterations, progress);
        end
    end
    
    if isvalid(progress)
        close(progress);
    end
    
    % print timings for the run
    reportGenerateData();
    reportEstimateACF();
    
    % save estimates to disk
    filename = sprintf('ACF_DGP%02d.mat', globals.dgp);
    save(filename, 'betaACF');
    fprintf('Wrote estimates to %s\n', filename);
end