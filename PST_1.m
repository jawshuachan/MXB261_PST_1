classdef PST_1
    methods
        function simulateWalk(obj, P, N)

            % Define starting position
            if P == 1
                xStart = 50;
                yStart = 99;
            else
                xStart = randi([1, 99]);
                yStart = 99;
            end
            
            % Arrays to store the final positions of each particle
            xFinal = zeros(1, N);
            yFinal = zeros(1, N);
        
            % Select bias case
            biases = [
                0.33, 0.33, 0.33; % CASE 1: almost equal probability for all
                0.66, 0.16, 0.16; % CASE 2: higher probability to move south
                0.60, 0.30, 0.10; % CASE 3: higher probability to move south and lower probability to move east
                0.60, 0.10, 0.30; % CASE 4: higher probability to move south and lower probability to move west
            ];
            
            % Define and initialize the grid
            gridSize = 99;
        
            figure;
        
            % Run a simulation for each bias case
            for B = 1:4
                grid = zeros(gridSize, gridSize);
                bias = biases(B, :);
        
                % Run a simulation for each particle
                for i = 1:N
                    % Initialize the particle position
                    x = xStart; 
                    y = yStart;
                    
                    while true
                        % Randomly select movement direction based on bias
                        r = rand;
                        if r <= bias(1)
                            % Move South
                            newX = x;
                            newY = y - 1;
                        elseif r <= sum(bias(1:2))
                            % Move West
                            newX = x - 1;
                            newY = y;
                        else
                            % Move East
                            newX = x + 1;
                            newY = y;
                        end
                        
                        % Apply cyclic boundary conditions
                        newX = mod(newX - 1, gridSize) + 1; % Ensure newX is within [1, gridSize]
                        
                        % Check if the new position is occupied or if the particle has reached the bottom row
                        if newY < 1 || grid(newY, newX) > 0
                            % If reached the bottom row or the position is occupied, stop the particle
                            break;
                        end
            
                        % Update position
                        x = newX;
                        y = newY;
                    end
                    
                    % Store the final position of the particle
                    xFinal(i) = x;
                    yFinal(i) = y;
            
                    % Mark the final position as occupied in the grid
                    grid(y, x) = grid(y, x) + 1;
                end
            
                % Calculate the height of each column from the final positions
                columnHeights = zeros(1, gridSize);
                for col = 1:gridSize
                    % Count how many particles ended up in each column
                    columnHeights(col) = sum(xFinal == col);
                end
            
                % Plot the histograms
                subplot(2,2,B)
                histogram('BinEdges', 0.5:1:gridSize+0.5, 'BinCounts', columnHeights);
                title(['Histogram of Column Heights - Bias Case ', num2str(B)]);
                xlabel('Column Index');
                ylabel('Number of Particles');
                xlim([1 gridSize]);
            end
        end

        function sampleExperimentalData(obj, B)
            
            data = load('sampledata2024.mat');
            sampledata = data.Data0;
            
            % Probability Distribution and CDF function for Data0
            numbins = B;
            
            [counts, edges] = histcounts(sampledata, numbins, 'Normalization', 'probability');
            
            cdf_values = cumsum(counts);
            cdf_values = cdf_values / max(cdf_values);
            
            % Dataset - DataNew
            rng(20);
            u = rand(1, 1000);

            DataNew = interp1(cdf_values, edges(2:end), u, 'linear', 'extrap'); % interpolate random numbers with 
            
            figure;
            
            subplot(1, 2, 1)
            histogram(sampledata, numbins, 'Normalization', 'probability');
            title('Probability Distribution of Data0')
            xlabel('Value')
            ylabel('Probability')
            
            subplot(1, 2, 2)
            histogram(DataNew, numbins, 'Normalization', 'probability');
            title('Probability Distribution of DataNew')
            xlabel('Value')
            ylabel('Probability')

            % Kullback-Leibler Divergence
            pCount = histcounts(sampledata, edges, 'Normalization', 'probability');
            qCount = histcounts(DataNew, edges, 'Normalization', 'probability');

            idx = pCount > 0 & qCount > 0;
            
            P = pCount(idx);
            Q = qCount(idx);

            DK1 = sum(P .* log(P./Q));
            DK2 = sum(Q .* log(Q./P));

            disp(['KL divergence Data0 to DataNew: ', num2str(DK1)]);
            disp(['KL divergence DataNew to Data0: ', num2str(DK2)]);

        end
    end
end