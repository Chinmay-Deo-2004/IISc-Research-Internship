%% Run the complete experimental suite.
% This script executes both the pilot-density and Doppler studies, saves the results, and generates publication-quality figures.

clear;
clc;
close all;

addpath('src');
addpath('experiments');

cfg = research_config();

% Run experiments
pilotStudy = run_pilot_density_study(cfg);
dopplerStudy = run_doppler_estimator_study(cfg);

% Save all simulation results
save(fullfile('results','full_research_suite.mat'), ...
    'cfg','pilotStudy','dopplerStudy');

legendLabels = compose('Pilot period = %d',pilotStudy.pilotPeriods);

%% BER versus SNR

figure('Color','w');

semilogy(pilotStudy.snrDb, ...
         max(pilotStudy.ber,1e-7), ...
         '-o','LineWidth',1.3);

grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('Pilot-density study: BER');
legend(legendLabels,'Location','southwest');

exportgraphics(gcf, ...
    fullfile('results','suite_ber_vs_snr.png'), ...
    'Resolution',200);

%% BLER versus SNR

figure('Color','w');

semilogy(pilotStudy.snrDb, ...
         max(pilotStudy.bler,1e-7), ...
         '-o','LineWidth',1.3);

grid on;
xlabel('SNR (dB)');
ylabel('BLER');
title('Pilot-density study: BLER');
legend(legendLabels,'Location','southwest');

exportgraphics(gcf, ...
    fullfile('results','suite_bler_vs_snr.png'), ...
    'Resolution',200);

%% RMS EVM versus SNR

figure('Color','w');

semilogy(pilotStudy.snrDb, ...
         max(pilotStudy.evmRms,1e-7), ...
         '-o','LineWidth',1.3);

grid on;
xlabel('SNR (dB)');
ylabel('RMS EVM');
title('Pilot-density study: EVM');
legend(legendLabels,'Location','southwest');

exportgraphics(gcf, ...
    fullfile('results','suite_evm_vs_snr.png'), ...
    'Resolution',200);

%% Channel-estimation NMSE versus SNR

figure('Color','w');

semilogy(pilotStudy.snrDb, ...
         max(pilotStudy.nmse,1e-7), ...
         '-o','LineWidth',1.3);

grid on;
xlabel('SNR (dB)');
ylabel('Channel-estimation NMSE');
title('Pilot-density study: NMSE');
legend(legendLabels,'Location','southwest');

exportgraphics(gcf, ...
    fullfile('results','suite_nmse_vs_snr.png'), ...
    'Resolution',200);

%% Goodput versus SNR

figure('Color','w');

plot(pilotStudy.snrDb, ...
     pilotStudy.throughput, ...
     '-o','LineWidth',1.3);

grid on;
ylim([0 1]);

xlabel('SNR (dB)');
ylabel('Normalized goodput');
title('normalized payload-symbol efficiency (pre-FEC)');
legend(legendLabels,'Location','southeast');

exportgraphics(gcf, ...
    fullfile('results','suite_goodput_vs_snr.png'), ...
    'Resolution',200);

%% Doppler robustness comparison

figure('Color','w');

semilogy(dopplerStudy.dopplers, ...
         max(dopplerStudy.nmse,1e-7), ...
         '-o','LineWidth',1.3);

grid on;
xlabel('Normalized Doppler');
ylabel('Channel-estimation NMSE');
title('Estimator robustness to Doppler');
legend(dopplerStudy.estimators,'Location','northwest');

exportgraphics(gcf, ...
    fullfile('results','doppler_estimator_nmse.png'), ...
    'Resolution',200);