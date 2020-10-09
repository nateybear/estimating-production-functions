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
            betaACF = zeros(globals.niterations, 2);

            % pipeline to generate monte carlo data
            dataPipeline = pipe(@generateExogenousShocks, @generateWages,...
                    @calculateInvestmentDemand, @calculateLaborDemand, ...
                    @generateIntermediateInputDemand, @calculateFirmOutput, ...
                    @addMeasureError, @keepLastN);

            % keep track of timings for each run
            [generateData, reportGenerateData] = timed("generating data", dataPipeline, globals.niterations);  
            [estimateACF, reportEstimateACF] = timed("estimating ACF", @acfEstimator, globals.niterations);

            % show progress bar. you can close it and it will keep running.
            runNumber = (idgp-1) * length(imErr) + imErr;
            progressBar = waitbar(0, sprintf("Running simulation (%d/%d)...", runNumber, totalRuns));

            % the actual Monte Carlo---generate data and estimate in a loop
            for iiteration = 1:globals.niterations
                data = generateData(data, globals);
                betaACF(iiteration, :) = estimateACF(data, globals);
                if isvalid(progressBar)
                    waitbar(iiteration/globals.niterations, progressBar);
                end
            end

            if isvalid(progressBar)
                close(progressBar);
            end

            % print timings for the run
            reportGenerateData();
            reportEstimateACF();

            % save estimates to disk
            filename = sprintf('ACF_DGP%02d_Err%0.1f_%s.mat', dgp, measureError, date);
            save(filename, 'betaACF');
            fprintf('Wrote estimates to %s\n', filename);
        end
    end
end

function inp = parseInput(varargin)
    p = inputParser();
    addParameter(p, 'DGP', [1 2 3]);
    addParameter(p, 'MeasureError', [0.0 0.1 0.2 0.5]);
    
    parse(p, varargin{:});
    
    inp = p.Results;
end