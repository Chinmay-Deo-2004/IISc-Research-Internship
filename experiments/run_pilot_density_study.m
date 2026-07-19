function study = run_pilot_density_study(cfg)

rng(cfg.randomSeed,'twister');

numPilotConfigs = numel(cfg.pilotPeriods);
numSnrPoints = numel(cfg.snrDb);

study = struct();
study.snrDb = cfg.snrDb;
study.pilotPeriods = cfg.pilotPeriods;
study.ber = zeros(numPilotConfigs,numSnrPoints);
study.bler = zeros(numPilotConfigs,numSnrPoints);
study.berLower = zeros(numPilotConfigs,numSnrPoints);
study.berUpper = zeros(numPilotConfigs,numSnrPoints);
study.evmRms = zeros(numPilotConfigs,numSnrPoints);
study.nmse = zeros(numPilotConfigs,numSnrPoints);
study.throughput = zeros(numPilotConfigs,numSnrPoints);

for pilotIdx = 1:numPilotConfigs

    simCfg = cfg;
    simCfg.pilotPeriod = cfg.pilotPeriods(pilotIdx);

    for snrIdx = 1:numSnrPoints

        totalBitErrors = 0;
        totalBits = 0;
        totalBlockErrors = 0;
        totalEvm = 0;
        totalNmse = 0;
        totalUsefulSymbols = 0;

        for frame = 1:cfg.framesPerPoint

            result = simulate_mimo_ofdm_link(simCfg,cfg.snrDb(snrIdx));

            totalBitErrors = totalBitErrors + nnz(result.rxBits ~= result.txBits);
            totalBits = totalBits + numel(result.txBits);
            totalBlockErrors = totalBlockErrors + result.blockError;

            totalEvm = totalEvm + result.evmRms^2;
            totalNmse = totalNmse + result.channelNmse;
            totalUsefulSymbols = totalUsefulSymbols + result.nDataSymbols;

        end

        study.ber(pilotIdx,snrIdx) = totalBitErrors / totalBits;
        study.bler(pilotIdx,snrIdx) = totalBlockErrors / cfg.framesPerPoint;

        [study.berLower(pilotIdx,snrIdx), ...
         study.berUpper(pilotIdx,snrIdx)] = ...
            wilson_interval(totalBitErrors,totalBits);

        study.evmRms(pilotIdx,snrIdx) = ...
            sqrt(totalEvm / cfg.framesPerPoint);

        study.nmse(pilotIdx,snrIdx) = ...
            totalNmse / cfg.framesPerPoint;

        study.throughput(pilotIdx,snrIdx) = ...
            (1 - study.ber(pilotIdx,snrIdx)) * ...
            totalUsefulSymbols / ...
            (cfg.framesPerPoint * simCfg.nOFDMSymbols);

        fprintf(['Pilot Period = %d, SNR = %2d dB | ' ...
                 'BER = %.3e, EVM = %.3f, NMSE = %.3e, ' ...
                 'Efficiency = %.3f\n'], ...
                 simCfg.pilotPeriod, ...
                 cfg.snrDb(snrIdx), ...
                 study.ber(pilotIdx,snrIdx), ...
                 study.evmRms(pilotIdx,snrIdx), ...
                 study.nmse(pilotIdx,snrIdx), ...
                 study.throughput(pilotIdx,snrIdx));

    end

end

end