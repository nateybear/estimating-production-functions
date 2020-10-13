function data = addMeasureError(data, globals)
    groupMeans = mean(data.lnIntermedInput, 1);
    withinvar = var((data.lnIntermedInput - groupMeans), 0, 'all');
    data.lnIntermedInput = data.lnIntermedInput + globals.measureError * sqrt(withinvar) * randn(size(data.lnIntermedInput));
end