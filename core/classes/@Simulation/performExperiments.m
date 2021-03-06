
% performExperiments - Perform the experiments
%   This method test in turn each algorithm on every dataset, and collect 
%   the results, i.e., performance measures, training times, and trained
%   algorithms.

% License to use and modify this code is granted freely without warranty to all, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
% Programmed and Copyright by Simone Scardapane:
% simone.scardapane@uniroma1.it

function obj = performExperiments(obj)

N_algo = length(obj.algorithms);
N_datasets = length(obj.datasets);

% Compute all possible combinations of algorithms, datasets and runs
experiments = combvec(1:obj.nRuns, 1:N_datasets, 1:N_algo);
N_experiments = size(experiments, 2);

% Results are saved in three linear cell arrays (due to the parfor)
perfMeasures_linear = cell(N_experiments, 1);
trainingTime_linear = cell(N_experiments, 1);
trainedAlgo_linear = cell(N_experiments, 1);

fprintf('\n');
fprintf('--------------------------------------------------\n');
fprintf('--- TRAINING PHASE -------------------------------\n');
fprintf('--------------------------------------------------\n');

log = SimulationLogger.getInstance();

% Initialize progress bars (only in the non-parallelized case)
if(~(log.flags.parallelized))
    statusbar(0, 'Processing %d of %d (%.1f%%)...', 0, 0, 0);
end

if(~(log.flags.parallelized))

    for i = 1:N_experiments

        % Train and test
        log.setAdditionalParameter('current_iteration', i);
        sb = statusbar(0, 'Processing %d of %d (%.1f%%)...', i, N_experiments, (i)*100/N_experiments);
        [perfMeasures_linear{i}, trainingTime_linear{i}, trainedAlgo_linear{i}] = ...
                obj.performSingleExperiment(experiments(:, i));

    end
    
else
    
    parfor i=1:N_experiments
        
        % Train and test
        log.setAdditionalParameter('current_iteration', i);
        [perfMeasures_linear{i}, trainingTime_linear{i}, trainedAlgo_linear{i}] = ...
                obj.performSingleExperiment(experiments(:, i));
            
    end
    
end

% Now we need to reconstruct the reshaped cell arrays
obj.trainedAlgo = cell(N_datasets, N_algo, obj.nRuns);
obj.trainingTimes = cell(N_datasets, N_algo);
obj.performanceMeasures = cell(N_datasets, N_algo);
for i=1:N_experiments
    obj.trainedAlgo{experiments(2,i), experiments(3,i), experiments(1,i)} = trainedAlgo_linear(i);
    if(isempty(obj.trainingTimes{experiments(2,i), experiments(3,i)}))
        obj.trainingTimes{experiments(2,i), experiments(3,i)} = trainingTime_linear{i};
    else
        obj.trainingTimes{experiments(2,i), experiments(3,i)} = ...
            obj.trainingTimes{experiments(2,i), experiments(3,i)}.append(trainingTime_linear{i});
    end
    if(isempty(obj.performanceMeasures{experiments(2,i), experiments(3,i)}))
        obj.performanceMeasures{experiments(2,i), experiments(3,i)} = perfMeasures_linear{i};
    else
        tmp = obj.performanceMeasures{experiments(2,i), experiments(3,i)};
        for j = 1:length(obj.performanceMeasures{experiments(2,i), experiments(3,i)})
            tmp{j} = tmp{j}.append(perfMeasures_linear{i}{j});
        end
        obj.performanceMeasures{experiments(2,i), experiments(3,i)} = tmp;
    end
end

fprintf('\n');

end