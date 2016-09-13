function [ fh_lin, fh_log, x0_fh, lb, ub, typicalX, paramNames, modelName, shiftFit ] = v_and_c()
fh_lin = @model_func;
fh_log = @(x, Y) log10(fh_lin(x, Y) + 1);
x0_fh = @initial_param_est;

% Min and maximum bounds from fitting data.
lb = [0, -15, -14, -30,  0,    0];
ub = [15,  17,   3,  40, 17, +inf];

typicalX = [1, 1, 1, 1, 1, 1];

paramNames = { 'N', 'q', 'p', 'reactionAlpha', 'reactionBeta', 'nstart' };
modelName = 'VnC';
shiftFit = true;

function [ U ] = model_func( x, T )
    N = 10^(x(1));
    q = 10^(x(2));
    p = 10^(x(3));
    reactionAlpha = 10^(x(4));
    reactionBeta = x(5);
    nstart = x(6);
    
    U = zeros(numel(T), 1);
  
    % Compute reaction time probability (reaction modulation).
    % This is the log-logistic PDF.
    % reactionAlpha is the is the scale parameter and corresponds to the
    % median.
    % reactionBeta is the shape parameter and controls the slope of the
    % right tail (this is a heavy-tailed distribution).
    nShare = T - nstart;
    ReactionModulation = (reactionBeta/reactionAlpha) * (nShare./reactionAlpha).^(reactionBeta - 1);
    ReactionModulation = ReactionModulation ./ ...
        (1 + (nShare./reactionAlpha).^(reactionBeta)).^2;
    
    for i = 1:numel(T)
        n = T(i);
        if n <= nstart
            % Initial conditions.
            U(n) = 0;
        else
            % V is the number of users that have already voted.
            V = sum(U(1:n-1));
            if V > N
                V = N;
            end
                        
            reactionModulation = ReactionModulation(n);
            U(n) = ((q*(N - V)*V/N) + p*(N - V))*reactionModulation;
        end;
    end;
end

function [ x0_mat ] = initial_param_est( vol )
    x0_mat = [log10(vol + 1), log10(50), log10(1e-4), log10(1.8), 0.5, 1];
end
end