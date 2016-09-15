function [ hFit, hData, hLeg ] = plot_votes_vs_comments_fit( model, params, U, D, C )
% PLOT_VOTES_VS_COMMENTS_FIT Compares the data to the fitted votes vs.
% comments curve.

% Plot the data.
Vcum = cumsum(U + D);
Ccum = cumsum(C);
hData = scatter(Vcum, Ccum, ...
                'o', 'filled', ...
                'MarkerEdgeColor', [0.1, 0.1, 0.1], ...
                'MarkerFaceColor', [0.1, 0.1, 0.1]);
set(hData, 'SizeData', 7);
hold on;

box on;
set(gca, 'xscale', 'log');
set(gca, 'yscale', 'log');
set(gca, 'xlim', [min(Vcum)/2, max(Vcum)*2]);
set(gca, 'ylim', [min(Ccum)/2, max(Ccum)*2]);

% Add ticks.
xLims = get(gca, 'xlim');
xLims = xLims + 1;
minExpX = ceil(log10(xLims(1)));
maxExpX = floor(log10(xLims(2)));
xTicks = 10.^(minExpX:maxExpX);
set(gca, 'XTick', xTicks);

yLims = get(gca, 'ylim');
yLims = yLims + 1;
minExpY = ceil(log10(yLims(1)));
maxExpY = floor(log10(yLims(2)));
yTicks = 10.^(minExpY:maxExpY);
set(gca, 'yTick', yTicks);

% Plot the fitted curve.
[fh, ~, ~, ~, ~, modelName] = model();
CcumFit = fh(params, Vcum);
hFit = plot(Vcum, CcumFit, '-b', 'LineWidth', 1.3);

hLeg = legend('Data', modelName);
set(hLeg, 'Location', 'Northwest');
set(hLeg, 'Box', 'off');
set(hLeg, 'Color', 'none');

end