function [ hFit, hData, hLeg ] = plot_up_vs_downvote_fit( params_up, params_down, U, D )
% PLOT_UP_VS_DOWNVOTE_FIT Compares the data to the fitted up-vote vs.
% down-vote curve.
%
%  Input arguments:
%
%     params_up: estimated parameters for the up-vote time-series. Use 
%     FIT_UP_VS_DOWNVOTE to estimate params_up and params_down.
%
%     params_down: estimated parameters for the down-vote time-series. Use 
%     FIT_UP_VS_DOWNVOTE to estimate params_up and params_down.
%
%     U: array with the up-vote time-series (data).
%
%     D: array with the down-vote time-series (data).
%
%  Optional input arguments:
%     tickLen: number of minutes between two time ticks (defaults to
%     20 min).
%

model = @v_and_c;
[fh, ~, ~, ~, ~, ~, ~, modelName] = model();

% Plot data.
hData = scatter(cumsum(U), cumsum(D), ...
                'o', 'filled', ...
                'MarkerEdgeColor', [0.1, 0.1, 0.1], ...
                'MarkerFaceColor', [0.1, 0.1, 0.1]);
set(hData, 'SizeData', 7);
hold on;

% Plot fitted curve.
T = 1:numel(U);
Ufit = fh(params_up, T);
Dfit = fh(params_down, T);
hFit = plot(cumsum(Ufit), cumsum(Dfit), '-b', 'LineWidth', 1.3);
box on;

maxX = max(sum(Ufit), sum(U));
set(gca, 'Xlim', [0, maxX * 1.1]);
maxY = max(sum(D), sum(D));
set(gca, 'Ylim', [0, maxY * 1.1]);
ylabel('Down-votes');
xlabel('Up-votes');

hLeg = legend('Data', modelName);
set(hLeg, 'Location', 'Northwest');
set(hLeg, 'Box', 'off');
set(hLeg, 'Color', 'none');

end