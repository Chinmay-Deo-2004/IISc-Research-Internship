function bitsPerSymbol = qam_bits_per_symbol(modulation)

switch upper(modulation)

    case 'QPSK'
        bitsPerSymbol = 2;

    case '16QAM'
        bitsPerSymbol = 4;

    case '64QAM'
        bitsPerSymbol = 6;

    otherwise
        error('Unsupported modulation scheme.');

end

end