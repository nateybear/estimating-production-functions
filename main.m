% run from command window as "main" to run all Monte Carlo scenarios, or 
% main('DGP', 1, 'MeasureError', 0.1) for a specific scenario. The DGP and
% MeasureError arguments can be row vectors if you want to run multiple scenarios.
function main(varargin)
    rng(239482398);
    
    inp = parseInput(varargin{:});
    
    totalRuns = length(inp.DGP) * length(inp.MeasureError);
    
    for idgp = 1:length(inp.DGP)
        dgp = inp.DGP(idgp);
        for imErr = 1:length(inp.MeasureError)
            measureError = inp.MeasureError(imErr);
            
            % init data structures
            globals = initGlobals(dgp, measureError);
            data = initDataStruct(globals);

            % pipeline to generate monte carlo data
            dataPipeline = makePipe(@generateExogenousShocks, @generateWages,...
                    @calculateInvestmentDemand, @calculateLaborDemand, ...
                    @generateIntermediateInputDemand, @calculateFirmOutput, ...
                    @keepLastN, @generateMeasureError);

            % keep track of timings for each run
            [generateData, reportGenerateData] = makeTimed("generating data", dataPipeline, globals.niterations);
            [ runEstimates, reportEstimates, saveEstimates ] = makeEstimators(inp.Estimator, globals.niterations);

            % show progress bar. you can close it and it will keep running.
            runNumber = (idgp-1) * length(inp.MeasureError) + imErr;
            progressBar = waitbar(0, sprintf("Running simulation (%d/%d)...", runNumber, totalRuns));

            % the actual Monte Carlo---generate data and estimate in a loop
            for iiteration = 1:globals.niterations
                data = generateData(data, globals);
                runEstimates(data, globals);
                if isvalid(progressBar)
                    waitbar(iiteration/globals.niterations, progressBar);
                end
            end

            if isvalid(progressBar)
                close(progressBar);
            end

            % print timings for the run
            reportGenerateData();
            reportEstimates();

            % save estimates to disk
            saveEstimates(dgp, measureError);
        end
    end
end

function inp = parseInput(varargin)
    p = inputParser();
    addParameter(p, 'DGP', [1 2 3]);
    addParameter(p, 'MeasureError', [0.0 0.1 0.2 0.5]);
    addParameter(p, 'Estimator', { 'ACF' 'LP' });
    
    parse(p, varargin{:});
    
    inp = p.Results;
end