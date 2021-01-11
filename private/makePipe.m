% higher-order function to compose our data pipeline
function f = makePipe(varargin)

f = @(output, globals) doPipe(output, globals, varargin{:});

end

function output = doPipe(output, globals, varargin)

for ivar = 1:length(varargin)
    output = varargin{ivar}(output, globals);
end
    
end