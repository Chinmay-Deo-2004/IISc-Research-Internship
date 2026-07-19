function infoBits = viterbi_decode_soft(llr,numInfoBits)

% Soft-decision Viterbi decoder matched to conv_encode().
% Positive LLR values indicate that a zero bit is more likely.

numSteps = numel(llr) / 2;

assert(mod(numel(llr),2) == 0, ...
    'LLR vector must contain an even number of elements.');

numStates = 4;

pathMetric = inf(numStates,1);
pathMetric(1) = 0;

survivorState = zeros(numStates,numSteps,'uint8');
survivorInput = false(numStates,numSteps);

for step = 1:numSteps

    nextMetric = inf(numStates,1);

    for state = 0:numStates-1

        if ~isfinite(pathMetric(state+1))
            continue;
        end

        stateMemory = [bitget(state,2) bitget(state,1)];

        for inputBit = 0:1

            encodedBits = [ ...
                xor(xor(inputBit,stateMemory(1)),stateMemory(2)), ...
                xor(inputBit,stateMemory(2))];

            signedLlr = ...
                (1 - 2*encodedBits) .* llr(2*step-1:2*step).';

            % Stable negative log-likelihood for the branch.
            branchMetric = sum( ...
                max(0,-signedLlr) + ...
                log1p(exp(-abs(signedLlr))));

            nextState = bitshift(inputBit,1) + stateMemory(1);

            candidateMetric = ...
                pathMetric(state+1) + branchMetric;

            if candidateMetric < nextMetric(nextState+1)

                nextMetric(nextState+1) = candidateMetric;
                survivorState(nextState+1,step) = state;
                survivorInput(nextState+1,step) = logical(inputBit);

            end

        end

    end

    pathMetric = nextMetric;

end

%% Traceback

state = 0;
decodedBits = false(numSteps,1);

for step = numSteps:-1:1

    decodedBits(step) = survivorInput(state+1,step);
    state = survivorState(state+1,step);

end

infoBits = decodedBits(1:numInfoBits);

end