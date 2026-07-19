function schedule = make_frame_schedule(nSymbols,nTx,pilotPeriod)

schedule = zeros(1,nSymbols);

for startSymbol = 1:pilotPeriod:nSymbols

    pilotSymbols = startSymbol:min(startSymbol + nTx - 1,nSymbols);

    schedule(pilotSymbols) = 1:numel(pilotSymbols);

end

assert(any(schedule == 0), ...
    'Frame must contain at least one data symbol.');

end