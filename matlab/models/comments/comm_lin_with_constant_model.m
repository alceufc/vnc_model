function [fh_lin, x0_fh, lb, ub, paramNames, modelName] = comm_lin_with_constant_model()
%y(n) = a*x(n)

fh_lin = @model_func;
x0_fh = @initial_param_est;
lb = [0, 0];
ub = [inf, inf];
paramNames = {'a', 'b'};
modelName = 'a x(n) + b';

function [ U ] = model_func( x, T )
    a = x(1);
    b = x(2);
    U = a * T + b;
end

function [ x0 ] = initial_param_est( )
    x0 = [1, 1];
end
end

