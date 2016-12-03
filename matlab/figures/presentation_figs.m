function [] = presentation_figs( )
% PRESENTATION_FIGS Generates figures for the presentation.
settings = load_settings();

[ Ucell, Dcell, Ccell ] = load_data('imgur');

figure;

figName = 'data_example.eps';
plot_path  = fullfile(settings.fig_dir, figName);
pos = 1;
plot_user_data(Ucell{pos}, Dcell{pos}.*2, Ccell{pos}.*20);
save_as_eps(plot_path, [4.0, 1.3]);

figure;
pos = 6;
figName = 'vote_model_fit_slide.eps';
plot_path  = fullfile(settings.fig_dir, figName);
params = fit_vote_model(@v_and_c, Ucell{pos});
plot_vote_model_fit(@v_and_c, params, Ucell{pos});
% set(gca,'XScale','log'); set(gca,'YScale','log'); 
% xlim_curr = get(gca,'xlim');
% set(gca, 'xlim', [5.0 xlim_curr(2)]);
save_as_eps(plot_path, [3.5, 1.6]);

figure;
pos = 2;
figName = 'up_vs_downvote_fit_slide.eps';
plot_path  = fullfile(settings.doc_dir, figName);
[params_up, params_down] = fit_up_vs_downvote(Ucell{pos}, Dcell{pos});
plot_up_vs_downvote_fit(params_up, params_down, Ucell{pos}, Dcell{pos}, ...
                        'showLegend', false);
save_as_eps(plot_path, [1.8, 1.6]);
 
figure;
pos = 2;
figName = 'votes_vs_comments_fit_slide.eps';
plot_path  = fullfile(settings.doc_dir, figName);
[params_comm] = fit_votes_vs_comments(@comm_vnc, Ucell{pos}, Dcell{pos}, Ccell{pos});
[~, ~, hLeg] = plot_votes_vs_comments_fit(@comm_vnc, params_comm, ...
                                          Ucell{pos}, Dcell{pos}, Ccell{pos});
set(hLeg, 'Location', 'SouthEast');
save_as_eps(plot_path, [1.8, 1.6]);

figure;
pos = 2;
figName = 'tail_forecast_slide.eps';
plot_path  = fullfile(settings.doc_dir, figName);
trainSize = 30;
forecastSize = 100;
Uforecast = tail_forecast(Ucell{pos}(1:trainSize), @v_and_c, forecastSize);
[~, ~, ~, hLeg] = plot_tail_forecast(@v_and_c, ...
                                     Ucell{pos}, Uforecast, trainSize, ...
                                     'timeTicksToForecast', 60);
set(hLeg, 'Location', 'NorthOutside');
set(hLeg, 'orientation', 'horizontal');
save_as_eps(plot_path, [4.3, 1.8]);

end
