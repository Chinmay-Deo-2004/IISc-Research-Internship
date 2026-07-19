function cfg = research_config()

cfg.nFFT = 64;
cfg.cpLength = 16;

cfg.nTx = 2;
cfg.nRx = 2;
cfg.nStreams = 2;

cfg.nOFDMSymbols = 80;

cfg.channelLength = 8;
cfg.estimatedChannelLength = 8;

cfg.modulation = 'QPSK';
cfg.equalizer = 'MMSE';
cfg.estimator = 'DFTLinear';

cfg.enableCoding = true;

cfg.commonPhaseNoiseStd = 0;
cfg.residualCfo = 0;
cfg.normalizedDoppler = 0.02;

cfg.snrDb = 0:3:27;
cfg.pilotPeriods = [6 10 16 24];

cfg.framesPerPoint = 100;
cfg.randomSeed = 20260715;

assert(cfg.nStreams <= cfg.nTx && cfg.nStreams <= cfg.nRx, ...
    'Number of spatial streams exceeds available antennas.');

assert(cfg.cpLength >= cfg.channelLength - 1, ...
    'Cyclic prefix must be at least the channel delay spread.');

end