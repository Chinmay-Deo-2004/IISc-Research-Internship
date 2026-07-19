function symbols = qam_modulate(bits,modulation)

bitsPerSymbol = qam_bits_per_symbol(modulation);

bitMatrix = reshape(bits,bitsPerSymbol,[]).';

if strcmpi(modulation,'QPSK')

    symbols = ((1 - 2*bitMatrix(:,1)) + ...
               1j*(1 - 2*bitMatrix(:,2))) / sqrt(2);

else

    bitsPerAxis = bitsPerSymbol / 2;

    constellationLevels = -(2^bitsPerAxis-1):2:(2^bitsPerAxis-1);
    scaleFactor = sqrt((2/3) * (2^(2*bitsPerAxis) - 1));

    iGray = bitMatrix(:,1:bitsPerAxis) * (2.^(bitsPerAxis-1:-1:0)).';
    qGray = bitMatrix(:,bitsPerAxis+1:end) * (2.^(bitsPerAxis-1:-1:0)).';

    iIndex = gray_to_binary(iGray);
    qIndex = gray_to_binary(qGray);

    symbols = (constellationLevels(iIndex+1).' + ...
               1j*constellationLevels(qIndex+1).') / scaleFactor;

end

symbols = symbols(:);

end


function binary = gray_to_binary(gray)

binary = gray;
mask = floor(gray/2);

while any(mask)

    binary = bitxor(binary,mask);
    mask = floor(mask/2);

end

end