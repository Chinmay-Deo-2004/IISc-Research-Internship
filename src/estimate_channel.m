function hEst = estimate_channel(rxGrid,schedule,c)

[nFFT,nSymbols,nRx] = size(rxGrid);

hEst = zeros(nFFT,nSymbols,nRx,c.nTx);

symbolIndex = 1:nSymbols;

for txIdx = 1:c.nTx

    pilotSymbols = find(schedule == txIdx);

    for rxIdx = 1:nRx

        pilotEstimates = squeeze(rxGrid(:,pilotSymbols,rxIdx));

        % Apply delay-domain truncation before interpolation.
        if strcmpi(c.estimator,'DFTLinear')

            for pilotIdx = 1:numel(pilotSymbols)

                impulseResponse = ifft(pilotEstimates(:,pilotIdx),nFFT);
                impulseResponse(c.estimatedChannelLength+1:end) = 0;

                pilotEstimates(:,pilotIdx) = fft(impulseResponse,nFFT);

            end

        end

        % Linearly interpolate the channel estimate across OFDM symbols.
        for subcarrierIdx = 1:nFFT

            hEst(subcarrierIdx,:,rxIdx,txIdx) = ...
                interp1(pilotSymbols, ...
                        pilotEstimates(subcarrierIdx,:), ...
                        symbolIndex, ...
                        'linear','extrap');

        end

    end

end

end