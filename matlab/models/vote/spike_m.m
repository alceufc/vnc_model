function [fh_lin, fh_log, x0_fh, lb, ub, typicalX, paramNames, modelName, shiftFit ]  = spike_m()
fh_lin = @model_func;
fh_log = @(x, Y) log10(fh_lin(x, Y) + 1);
x0_fh = @initial_param_est;
lb = [0, -15, 0, -inf, 0];
ub = [inf, inf, inf, 1, +inf];
typicalX = [1, 1, 1, 1, 1];

shiftFit = true;

paramNames = {'N', 'logSb', 'beta*N', 'logNoise', 'nstart'};
paramFactors = [1e3, 1, 1, 1];
modelName = 'Spike-M';

function [ Y ] = model_func( x, T )
    N = x(1) * paramFactors(1);
    Sb = 10^x(2) * paramFactors(2);
    betaN = x(3) * paramFactors(3);
    noise = 10^x(4) * paramFactors(4);
    nstart = x(5);

    Y = zeros(numel(T), 1);
    
    for i = 1:numel(T)
        n = T(i);
        if n < nstart
            % Initial conditions.
            Y(n) = 0;
        elseif n == nstart
            Y(n) = Sb * betaN + noise;
        else
            % D: decay factor.
            D = (betaN / N) * ((n + 1 - nstart):-1:1) .^ (-1.5);
            s = sum(Y(nstart:n) .* D');
            
            V = sum(Y(1:n-1));
            if V > N
                V = N;
            end
            
            Y(n) = (N - V)*s + noise;
        end;
    end;
end

function [ x0 ] = initial_param_est( vol )
    x0 = [(vol + 1) / paramFactors(1), -1, 0.8, -1, 1];
end
end

