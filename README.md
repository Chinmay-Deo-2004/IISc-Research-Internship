# Research MIMO-OFDM PHY simulator

A reproducible study on pilot density and channel estimation for time-varying spatial-multiplexing MIMO-OFDM.

Run ```run_research_study``` in MATLAB. Results are written to results/pilot_density_study.mat.

Implemented: configurable MIMO, QPSK/16-QAM/64-QAM, full-band orthogonal pilots, time-varying Rayleigh tapped-delay channel, LS/DFT channel estimation with linear time interpolation, ZF/MMSE detection, rate-1/2 convolutional coding with soft Viterbi decoding, BER/EVM/NMSE/goodput metrics, Wilson confidence bounds, and repeatable experiment seeds.

Use ```run_full_research_suite``` for the Doppler/estimator comparison. 