function [] = gen_presentation_data( )
% PRESENTATION_FIGS Generates data for the presentation figures.
settings = load_settings();

warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(settings.pres_data_dir);
warning('on', 'MATLAB:MKDIR:DirectoryExists');

if false
%-------------------------------------------------------------------------
fileName = 'data_example.dat';
[ Ucell, Dcell, Ccell ] = load_data('imgur');
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 1;
save_data_file(filePath, ...
               [Ucell{pos}, Dcell{pos}.*2, Ccell{pos}.*20], ...
               {'Up-votes', 'Down-votes', 'Comments'}, ...
               'addTimestampCol', true);

%-------------------------------------------------------------------------
fileName = 'upvotes_fit_example.dat';
[ Ucell, Dcell, Ccell ] = load_data('imgur');
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
fh = v_and_c();
params = fit_vote_model(@v_and_c, U);
T = 1:numel(U);
Ufit = fh(params, T);
save_data_file(filePath, ...
               [U, Ufit], ...
               {'Up-votes', 'VnC'}, ...
               'addTimestampCol', true);

%-------------------------------------------------------------------------
fileName = 'up_vs_down_fit_example.dat';
[ Ucell, Dcell, Ccell ] = load_data('imgur');
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
D = Dcell{pos};
fh = v_and_c();
[params_up, params_down] = fit_up_vs_downvote(Ucell{pos}, Dcell{pos});

T = 1:numel(U);
Ufit = fh(params_up, T);
Dfit = fh(params_down, T);

save_data_file(filePath, ...
               [cumsum(U), cumsum(D), cumsum(Ufit), cumsum(Dfit)], ...
               {'Up-data', 'Down-data', 'Up-VnC', 'Down-VnC'}, ...
               'addTimestampCol', false);

           
%-------------------------------------------------------------------------
fileName = 'votes_vs_comm_fit_example.dat';
[ Ucell, Dcell, Ccell ] = load_data('imgur');
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
D = Dcell{pos};
C = Ccell{pos};
Vcum = cumsum(U + D);
Ccum = cumsum(C);

[vnc_params] = fit_votes_vs_comments(@comm_vnc, U, D, C);
[lin_params] = fit_votes_vs_comments(@comm_lin_model, U, D, C);

fhVnc = comm_vnc();
CcumVncFit = fhVnc(vnc_params, Vcum);

fhLin = comm_lin_model();
CcumLinFit = fhLin(lin_params, Vcum);

save_data_file(filePath, ...
               [Vcum, Ccum, CcumVncFit, CcumLinFit], ...
               {'Votes', 'Data', 'VnC', 'Linear'}, ...
               'addTimestampCol', false);

%-------------------------------------------------------------------------
fileName = 'tail_decay.dat';
[ Ucell, ~, ~ ] = load_data('reddit');
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
T = 1:numel(U);
modelList = {@v_and_c, @bass_model, @si_model, @spike_m};
modelNames = {'VnC', 'Bass', 'SI', 'Spike-M'};

Data = zeros(numel(U), 1 + numel(modelList));
Data(:, 1) = U;
for modelPos = 1:numel(modelList)
    model = modelList{modelPos};
    fh = model();
    params = fit_vote_model(model, U);
    Ufit = fh(params, T);
    Data(:, modelPos + 1) = Ufit;
end;

save_data_file(filePath, Data, ...
               ['Data', modelNames], ...
               'addTimestampCol', true);
           
%-------------------------------------------------------------------------
datasetNames = {'reddit', 'imgur', 'digg'};
fh = v_and_c();
for datasetPos = 1:numel(datasetNames)
    datasetName = datasetNames{datasetPos};
    fileName = sprintf('upvotes_fit_%s.dat', datasetName);
    filePath  = fullfile(settings.pres_data_dir, fileName);
    
    [Ucell, ~, ~] = load_data(datasetName);
    Usum = cellfun(@sum, Ucell);
    [~,IX] = sort(Usum, 'descend');
    U = Ucell{IX(1)};
    params = fit_vote_model(@v_and_c, U);
    T = 1:numel(U);
    Ufit = fh(params, T);
    save_data_file(filePath, ...
                   [U, Ufit], ...
                   {'Up-votes', 'VnC'}, ...
                   'addTimestampCol', true);
end;

%-------------------------------------------------------------------------
datasetNames = {'reddit', 'imgur'};
fh = v_and_c();
for datasetPos = 1:numel(datasetNames)
    datasetName = datasetNames{datasetPos};
    fileName = sprintf('up_vs_down_fit_%s.dat', datasetName);
    filePath  = fullfile(settings.pres_data_dir, fileName);
    
    [Ucell, Dcell, ~] = load_data(datasetName);
    Usum = cellfun(@sum, Ucell);
    [~,IX] = sort(Usum, 'descend');
    U = Ucell{IX(1)};
    D = Dcell{IX(1)};
    
    [params_up, params_down] = fit_up_vs_downvote(U, D);
    T = 1:numel(U);
    Ufit = fh(params_up, T);
    Dfit = fh(params_down, T);
    save_data_file(filePath, ...
                   [cumsum(U), cumsum(D), cumsum(Ufit), cumsum(Dfit)], ...
                   {'Up-data', 'Down-data', 'Up-VnC', 'Down-VnC'}, ...
                   'addTimestampCol', false);
end;

%-------------------------------------------------------------------------
datasetNames = {'reddit', 'imgur'};
fh = v_and_c();
for datasetPos = 1:numel(datasetNames)
    datasetName = datasetNames{datasetPos};
    fileName = sprintf('votes_vs_comm_fit_%s.dat', datasetName);
    filePath  = fullfile(settings.pres_data_dir, fileName);
    
    [Ucell, Dcell, Ccell] = load_data(datasetName);
    Usum = cellfun(@sum, Ucell);
    [~,IX] = sort(Usum, 'descend');
    U = Ucell{IX(1)};
    D = Dcell{IX(1)};
    C = Ccell{IX(1)};
    Vcum = cumsum(U + D);
    Ccum = cumsum(C);

    [vnc_params] = fit_votes_vs_comments(@comm_vnc, U, D, C);
    [lin_params] = fit_votes_vs_comments(@comm_lin_model, U, D, C);

    fhVnc = comm_vnc();
    CcumVncFit = fhVnc(vnc_params, Vcum);

    fhLin = comm_lin_model();
    CcumLinFit = fhLin(lin_params, Vcum);

    save_data_file(filePath, ...
                   [Vcum, Ccum, CcumVncFit, CcumLinFit], ...
                   {'Votes', 'Data', 'VnC', 'Linear'}, ...
                   'addTimestampCol', false);
end;

%-------------------------------------------------------------------------
fileName = 'forecast_example.dat';
[Ucell, ~, ~] = load_data('reddit');
filePath  = fullfile(settings.pres_data_dir, fileName);
pos = 2;
U = Ucell{pos};
trainSize = 30;
forecastSize = 100;
Uforecast = tail_forecast(U(1:trainSize), @v_and_c, forecastSize);
save_data_file(filePath, ...
               [U, Uforecast], ...
               {'Up-votes', 'VnC'}, ...
               'addTimestampCol', true);
           
end; % end if false

end