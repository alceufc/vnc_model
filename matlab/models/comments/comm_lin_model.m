function [fh_lin, x0_fh, lb, ub, paramNames, modelName] = comm_lin_model()
%y(n) = a*x(n)

fh_lin = @model_func;
x0_fh = @initial_param_est;
lb = [0];
ub = [inf];
paramNames = {'a'};
modelName = 'a x(n)';

function [ U ] = model_func( x, T )
    a = x(1);
    U = a * T;
end

function [ x0 ] = initial_param_est( )
    x0 = [1];
end
end

