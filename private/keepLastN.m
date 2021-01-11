% drop all but the last globals.nperiodsKeep observations from our
% generated data
function output = keepLastN(output, globals)
    
for field = string(fieldnames(output))'
    output.(field) = output.(field)((end-globals.nperiodsKeep+1):end,:); 
end

end