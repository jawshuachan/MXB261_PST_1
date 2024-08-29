pst1 = PST_1;

% PART 1

simulations = [
    struct('P', 1, 'N', 100);    % Figure 1
    struct('P', 1, 'N', 200);    % Figure 2
    struct('P', rand, 'N', 100); % Figure 3
    struct('P', rand, 'N', 200); % Figure 4
];

for i = 1:4
    P = simulations(i).P;
    N = simulations(i).N;
    pst1.simulateWalk(P, N);
end


% PART 2

bins = [ 20, 10, 40 ];

for j = 1:3
    pst1.sampleExperimentalData(bins(j));
end
