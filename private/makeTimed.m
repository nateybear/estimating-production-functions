% higher-order function to add timings to a function. returns the wrapped
% function and a function to print summary stats to the console.
function [f, r] = makeTimed(task, g, varargin)
    calls = [];
    i = 1;
    
    % varargin is used to supply an optional number of calls, so we can
    % pre-allocate the call data
    if nargin > 2
        calls = zeros(1, varargin{1});
    end
    function output = doTimed(varargin)
        tStart = tic;
        output = g(varargin{:});
        tEnd = toc(tStart);
        calls(i) = tEnd;
        i = i+1;
    end
    function doReport
        fprintf(['********************************************\n'...
            'Runtime (in seconds) of %s:\n'...
            'Min %.2f\tMedian %.2f\tMax %.2f\n' ...
            'Mean %.2f\tSD %.2f\n'...
            'Total time: %.2f seconds\n'...
            '********************************************\n\n'],...
            task, min(calls), median(calls), max(calls),...
            mean(calls), std(calls), sum(calls));
    end
    f = @doTimed;
    r = @doReport;
end
