% Store data in a named struct so we can easily refer to the fields. 
% Each field is a matrix with rows indexing the period and columns indexing the firm
function data = initDataStruct(globals)
    % TODO: lnOutputPrice does not look like it's used
    vars = { 'lnLabor' 'lnKapital' 'lnOutput'... 
                 'lnOutputPrice' 'lnWage' 'lnIntermedInput'  ...
                 'omegaT' 'omegaTminusB' 'epsilon' };
    data = struct();
    for ivar = 1:length(vars)
        data.(vars{ivar}) = zeros(globals.nperiodsTotal, globals.nfirms);
    end
end