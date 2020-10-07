% higher-order function to compose our data pipeline
function f = pipe(varargin)
    function output = doPipe(output, globals)
        for ivar = 1:length(varargin)
            output = varargin{ivar}(output, globals);
        end
    end
    f = @doPipe;
end