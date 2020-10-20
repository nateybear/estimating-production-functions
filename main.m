% Optional arguments are the DGP to run (as a scalar int or row vector), measurement
% error (as a scalar double or row vector), and estimation method to use (as a scalar
% string or cell array of strings). See the parseInput function for defaults.
function main(varargin)
    rng(239482398);
    
    inp = parseInput(varargin{:});
    
    totalRuns = length(inp.DGP) * length(inp.MeasureError);
    
    for idgp = 1:length(inp.DGP)
        dgp = inp.DGP(idgp); % current DGP
        for imErr = 1:length(inp.MeasureError)
            measureError = inp.MeasureError(imErr); % current measureError
            
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

            % close the progressBar (stupid you have to always check isvalid)
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