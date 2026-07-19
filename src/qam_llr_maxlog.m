function llr = qam_llr_maxlog(symbols,modulation,noiseVariance)

% Max-log soft demapper.
% Positive LLR values indicate that a zero bit is more likely.

bitsPerSymbol = qam_bits_per_symbol(modulation);

bitPatterns = false(2^bitsPerSymbol,bitsPerSymbol);

for bitIdx = 1:bitsPerSymbol
    bitPatterns(:,bitIdx) = ...
        bitget((0:2^bitsPerSymbol-1).',bitsPerSymbol-bitIdx+1);
end

constellation = qam_modulate(reshape(bitPatterns.',[],1),modulation);

symbols = symbols(:);
llr = zeros(numel(symbols),bitsPerSymbol);

for bitIdx = 1:bitsPerSymbol

    zeroSymbols = constellation(bitPatterns(:,bitIdx) == 0);
    oneSymbols  = constellation(bitPatterns(:,bitIdx) == 1);

    distanceToZero = min(abs(symbols - zeroSymbols.').^2,[],2);
    distanceToOne  = min(abs(symbols - oneSymbols.').^2,[],2);

    llr(:,bitIdx) = ...
        (distanceToOne - distanceToZero) / max(noiseVariance,eps);

end

llr = reshape(llr.',[],1);

end