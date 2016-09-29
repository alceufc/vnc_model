function [  ] = plot_user_data( U, D, C, varargin )

MINUTES_IN_HOUR = 60;

% Parse optional arguments.
parser = inputParser;
addParamValue(parser, 'tickLen', 20, @isnumeric);

parse(parser, varargin{:});
tickLen = parser.Results.tickLen;

T = 1:numel(U);
Thour = T * tickLen / MINUTES_IN_HOUR;

plot(Thour, U, '-b', 'LineWidth', 1.1);
hold on;
plot(Thour, D, '-r', 'LineWidth', 1.1);
plot(Thour, C, '-g', 'LineWidth', 1.1);
hold off;

xlabel('Time after submission (h)');
ylims = ylim;
set(gca, 'Ylim', [-1, ylims(2)]);

hLeg = legend('Up-votes', 'Down-votes', 'Comments');
set(hLeg, 'Box', 'off');
set(hLeg, 'Color', 'none');
box on;