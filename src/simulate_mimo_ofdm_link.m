function result = simulate_mimo_ofdm_link(cfg,snrDb)

schedule = make_frame_schedule( ...
    cfg.nOFDMSymbols, ...
    cfg.nTx, ...
    cfg.pilotPeriod);

dataSymbols = find(schedule == 0);
numDataSymbols = numel(dataSymbols);

bitsPerSymbol = qam_bits_per_symbol(cfg.modulation);
frameCapacity = cfg.nFFT * numDataSymbols * cfg.nStreams * bitsPerSymbol;

%% Generate transmit bits

if cfg.enableCoding

    numInfoBits = floor(frameCapacity/2) - 2;

    txBits = randi([0 1],numInfoBits,1,'logical');

    codedBits = conv_encode(txBits);

    mappedBits = [codedBits;
                  false(frameCapacity-numel(codedBits),1)];

else

    txBits = randi([0 1],frameCapacity,1,'logical');
    mappedBits = txBits;

end

%% Modulation

txSymbols = qam_modulate(mappedBits,cfg.modulation);

dataGrid = reshape(txSymbols, ...
                   cfg.nFFT, ...
                   numDataSymbols, ...
                   cfg.nStreams);

txGrid = zeros(cfg.nFFT,cfg.nOFDMSymbols,cfg.nTx);

for tx = 1:cfg.nTx
    txGrid(:,schedule==tx,tx) = 1;
end

txGrid(:,dataSymbols,1:cfg.nStreams) = dataGrid;

%% Channel

channelResponse = generate_channel(cfg);

noiseVariance = 10^(-snrDb/10);

rxGrid = zeros(cfg.nFFT,cfg.nOFDMSymbols,cfg.nRx);

for symbol = 1:cfg.nOFDMSymbols

    for subcarrier = 1:cfg.nFFT

        H = squeeze(channelResponse(subcarrier,symbol,:,:));
        x = squeeze(txGrid(subcarrier,symbol,:));

        noise = sqrt(noiseVariance/2) * ...
            (randn(cfg.nRx,1) + 1j*randn(cfg.nRx,1));

        rxGrid(subcarrier,symbol,:) = H*x + noise;

    end

end

%% Apply common phase error

phaseRotation = ...
    cfg.residualCfo * (0:cfg.nOFDMSymbols-1) + ...
    cfg.commonPhaseNoiseStd * cumsum(randn(1,cfg.nOFDMSymbols));

rxGrid = rxGrid .* reshape(exp(1j*phaseRotation),1,[],1);

%% Channel estimation

estimatedChannel = estimate_channel(rxGrid,schedule,cfg);

equalizedSymbols = zeros(cfg.nFFT,numDataSymbols,cfg.nStreams);

for symbolIdx = 1:numDataSymbols

    for subcarrier = 1:cfg.nFFT

        H = squeeze(estimatedChannel( ...
            subcarrier,...
            dataSymbols(symbolIdx),...
            :,...
            1:cfg.nStreams));

        if cfg.nStreams == 1
            H = reshape(H,cfg.nRx,1);
        end

        y = reshape( ...
            rxGrid(subcarrier,dataSymbols(symbolIdx),:), ...
            cfg.nRx,1);

        if strcmpi(cfg.equalizer,'ZF')

            W = pinv(H);

        else

            W = (H'*H + noiseVariance*eye(cfg.nStreams)) \ H';

        end

        equalizedSymbols(subcarrier,symbolIdx,:) = W*y;

    end

end

%% Demodulation

if cfg.enableCoding

    llr = qam_llr_maxlog( ...
        equalizedSymbols(:), ...
        cfg.modulation, ...
        noiseVariance);

    rxBits = viterbi_decode_soft( ...
        llr(1:numel(codedBits)), ...
        numInfoBits);

else

    rxBits = qam_demodulate( ...
        equalizedSymbols(:), ...
        cfg.modulation);

end

%% Performance metrics

result = struct();

result.txBits = txBits;
result.rxBits = rxBits;

result.blockError = any(rxBits ~= txBits);

result.hTrue = channelResponse;
result.hEstimate = estimatedChannel;

result.channelNmse = ...
    norm(estimatedChannel(:)-channelResponse(:))^2 / ...
    norm(channelResponse(:))^2;

result.evmRms = ...
    sqrt(mean(abs(equalizedSymbols(:)-dataGrid(:)).^2) / ...
         mean(abs(dataGrid(:)).^2));

result.nDataSymbols = numDataSymbols;

end


function H = generate_channel(cfg)

rho = real(besselj(0,2*pi*cfg.normalizedDoppler));
rho = max(min(rho,0.9999),-0.9999);

taps = ( ...
    randn(cfg.channelLength,cfg.nRx,cfg.nTx) + ...
    1j*randn(cfg.channelLength,cfg.nRx,cfg.nTx)) ...
    / sqrt(2*cfg.channelLength);

H = zeros(cfg.nFFT,cfg.nOFDMSymbols,cfg.nRx,cfg.nTx);

for symbol = 1:cfg.nOFDMSymbols

    if symbol > 1

        innovation = ...
            (randn(size(taps)) + 1j*randn(size(taps))) ...
            / sqrt(2*cfg.channelLength);

        taps = rho*taps + sqrt(1-rho^2)*innovation;

    end

    H(:,symbol,:,:) = fft(taps,cfg.nFFT,1);

end

end