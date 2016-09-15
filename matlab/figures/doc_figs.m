function [] = doc_figs( )
% DOC_FIGS Generates figures for the documentation.
settings = load_settings();

[ Ucell, Dcell, Ccell ] = load_data('imgur');

figure;
figName = 'vote_model_fit.png';
plot_path  = fullfile(settings.doc_dir, figName);
params = fit_vote_model(@v_and_c, Ucell{1});
plot_vote_model_fit(@v_and_c, params, Ucell{1});
save_as_png(plot_path, [5.0, 2.3]);

figure;
figName = 'up_vs_downvote_fit.png';
plot_path  = fullfile(settings.doc_dir, figName);
[params_up, params_down] = fit_up_vs_downvote(Ucell{1}, Dcell{1});
plot_up_vs_downvote_fit(params_up, params_down, Ucell{1}, Dcell{1});
save_as_png(plot_path, [5.0, 2.3]);

figure;
figName = 'votes_vs_comments_fit.png';
plot_path  = fullfile(settings.doc_dir, figName);
[params_comm] = fit_votes_vs_comments(@comm_vnc, Ucell{1}, Dcell{1}, Ccell{1});
plot_votes_vs_comments_fit(@comm_vnc, params_comm, Ucell{1}, Dcell{1}, Ccell{1});
save_as_png(plot_path, [5.0, 2.3]);

figure;
figName = 'tail_forecast.png';
plot_path  = fullfile(settings.doc_dir, figName);
trainSize = 30;
forecastSize = 100;
Uforecast = tail_forecast(Ucell{1}(1:trainSize), @v_and_c, forecastSize);
plot_tail_forecast(@v_and_c, Ucell{1}, Uforecast, trainSize);
save_as_png(plot_path, [5.0, 2.3]);

end
