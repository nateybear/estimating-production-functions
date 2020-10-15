function [ p, c ] = makeLags(data)
    p = @(X) prev(X, data);
    c = @(X) curr(X, data);
end

function p = prev(X, data)
   if ischar(X)
       X = data.(X);
   end
   p = reshape(X(1:(end-1), :), [], 1);
end

function c = curr(X, data)
   if ischar(X)
       X = data.(X);
   end
   c = reshape(X(2:end, :), [], 1);
end