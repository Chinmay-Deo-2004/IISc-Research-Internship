function [lowerBound,upperBound] = wilson_interval(errors,numTrials,alpha)

if nargin < 3
    alpha = 0.05;
end

z = sqrt(2) * erfcinv(alpha);

errorRate = errors / numTrials;

normalization = 1 + z^2 / numTrials;

variance = errorRate * (1 - errorRate) / numTrials + ...
           z^2 / (4 * numTrials^2);

lowerBound = max(0, ...
    (errorRate + z^2/(2*numTrials) - z*sqrt(variance)) / normalization);

upperBound = min(1, ...
    (errorRate + z^2/(2*numTrials) + z*sqrt(variance)) / normalization);

end