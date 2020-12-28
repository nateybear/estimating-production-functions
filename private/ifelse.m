% matlab has no ternary operator. shame on them.
function out = ifelse(test, ifTrue, ifFalse)
if test
    out = ifTrue;
else
    out = ifFalse;
end
end