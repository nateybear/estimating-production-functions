function data = generateMeasureError(data, globals)
    groupMeans = mean(data.lnIntermedInput, 1);
    withinvar = mean((data.lnIntermedInput - groupMeans).^2, 'all');
    data.lnIntermedInput = data.lnIntermedInput + globals.measureError * sqrt(withinvar) * randn(size(data.lnIntermedInput));
end