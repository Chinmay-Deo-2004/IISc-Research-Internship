function study = run_doppler_estimator_study(cfg)
% Evaluate channel estimation performance under different Doppler conditions.
% Two estimators are compared:
%   1. LS interpolation
%   2. DFT delay-truncated interpolation

dopplerValues = [0 0.005 0.02 0.05];
estimators = {'LSLinear','DFTLinear'};
snr = 15;

numEstimators = numel(estimators);
numCases = numel(dopplerValues);

study = struct();
study.dopplers = dopplerValues;
study.estimators = estimators;
study.ber  = zeros(numEstimators,numCases);
study.bler = zeros(numEstimators,numCases);
study.nmse = zeros(numEstimators,numCases);

for estIdx = 1:numEstimators

    for dopplerIdx = 1:numCases

        simCfg = cfg;
        simCfg.estimator = estimators{estIdx};
        simCfg.normalizedDoppler = dopplerValues(dopplerIdx);
        simCfg.pilotPeriod = 10;

        totalBitErrors = 0;
        totalBits = 0;
        totalBlockErrors = 0;
        totalNmse = 0;

        for frame = 1:cfg.framesPerPoint

            result = simulate_mimo_ofdm_link(simCfg,snr);

            totalBitErrors = totalBitErrors + nnz(result.txBits ~= result.rxBits);
            totalBits = totalBits + numel(result.txBits);
            totalBlockErrors = totalBlockErrors + result.blockError;
            totalNmse = totalNmse + result.channelNmse;

        end

        study.ber(estIdx,dopplerIdx) = totalBitErrors / totalBits;
        study.bler(estIdx,dopplerIdx) = totalBlockErrors / cfg.framesPerPoint;
        study.nmse(estIdx,dopplerIdx) = totalNmse / cfg.framesPerPoint;

    end

end

end