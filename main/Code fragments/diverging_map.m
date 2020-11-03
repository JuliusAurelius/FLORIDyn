function map = diverging_map(resolutionSteps,from,to)
diff=to-from;
map = repmat(from,length(resolutionSteps),1)+...
    repmat(diff,length(resolutionSteps),1).*repmat(resolutionSteps',1,3);
end