function data = addMeasureError(data, globals)
    withinstd = std(data.lnIntermedInput, 1); % columns index time period...
    data.lnIntermedInput = data.lnIntermedInput + globals.measureError * withinstd .* randn(size(data.lnIntermedInput));
end