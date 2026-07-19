function coded = conv_encode(info)

% Rate-1/2 convolutional encoder with constraint length 3.
% Generator polynomials: (7,5) in octal.

state = false(1,2);

% Append two zero bits to terminate the trellis.
inputBits = [logical(info(:)); false(2,1)];

coded = false(2*numel(inputBits),1);

for bitIdx = 1:numel(inputBits)

    currentBit = inputBits(bitIdx);

    coded(2*bitIdx-1) = xor(xor(currentBit,state(1)),state(2));
    coded(2*bitIdx)   = xor(currentBit,state(2));

    % Shift register update.
    state = [currentBit state(1)];

end

end