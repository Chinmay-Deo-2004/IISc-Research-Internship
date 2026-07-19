function bits = qam_demodulate(symbols,modulation)

bitsPerSymbol = qam_bits_per_symbol(modulation);
symbols = symbols(:);

if strcmpi(modulation,'QPSK')

    bits = [real(symbols) < 0, ...
            imag(symbols) < 0].';

else

    bitsPerAxis = bitsPerSymbol / 2;

    constellationLevels = -(2^bitsPerAxis-1):2:(2^bitsPerAxis-1);
    scaleFactor = sqrt((2/3) * (2^(2*bitsPerAxis) - 1));

    [~,iIndex] = min(abs(real(symbols) * scaleFactor - constellationLevels),[],2);
    [~,qIndex] = min(abs(imag(symbols) * scaleFactor - constellationLevels),[],2);

    iGray = bitxor(iIndex-1,floor((iIndex-1)/2));
    qGray = bitxor(qIndex-1,floor((qIndex-1)/2));

    bits = [decimal_to_bits(iGray,bitsPerAxis), ...
            decimal_to_bits(qGray,bitsPerAxis)].';

end

bits = logical(bits(:));

end


function bitMatrix = decimal_to_bits(values,numBits)

bitMatrix = false(numel(values),numBits);

for bitIdx = 1:numBits

    bitMatrix(:,bitIdx) = bitget(values,numBits-bitIdx+1);

end

end