# VnC Model

Matlab implementation of the VnC-Model which is described in the following paper:

>**Vote-and-Comment: Modeling the Coevolution of User Interactions in Social Voting Web Sites**

> Alceu Ferraz Costa, Agma Juci Machado Traina, Caetano Traina Jr., and Christos Faloutsos

> IEEE International Conference on Data Mining (ICDM), 2016

## How to Use

First, we need to load some data to use in the examples below. Also we will
include into Matlab path variable all the subfolders of the repository:
```matlab
addpath(genpath('.'));
[ Ucell, Dcell, Ccell ] = load_data('imgur');
```

### Fitting an up-vote time-series

To fit an up-vote time-series, we use the `fit_vote_model` function, passing
as input argument a handle to the `v_and_c` function and the time-series that
we want to fit (in this case, `Ucell{1}`):
```matlab
params = fit_vote_model(@v_and_c, Ucell{1});
```

Now we can use the `plot_vote_model_fit` to compare the fit to the data:
```matlab
plot_vote_model_fit(@v_and_c, params, Ucell{1});
```

The result should be similar to the following figure:

![Up-votes time-series fit](./doc/vote_model_fit.png?raw=true "Up-vote time-series fit" )


### Fitting an up-vote vs. down-vote curve

To fit the the up-vote vs. down-vote curve of a submission we can use the
`fit_up_vs_downvote` function.
The `fit_up_vs_downvote` function ensures that the parameters that control the
reaction times in VnC are the same for the up-vote and down-vote time-series
(see the Section IV-B of the paper).
```matlab
[params_up, params_down] = fit_up_vs_downvote(Ucell{1}, Dcell{1});
```

To plot the fitted up-vote vs. down-vote trajectory we use the function
`plot_up_vs_downvote_fit`:
```matlab
plot_up_vs_downvote_fit(params_up, params_down, Ucell{1}, Dcell{1});
```

![Up-vote vs. down-vote time-series fit](./doc/up_vs_downvote_fit.png?raw=true "Up-vote vs. down-vote time-series fit" )

### Fitting an comments vs. votes curve

To fit the the votes vs. comments curve of a submission we use the
`fit_votes_vs_comments` function:
```matlab
[params_comm] = fit_votes_vs_comments(@comm_vnc, Ucell{1}, Dcell{1}, Ccell{1});
```

And now we plot the resulting curve using the `plot_votes_vs_comments_fit`
function:
```matlab
plot_votes_vs_comments_fit(@comm_vnc, params_comm, Ucell{1}, Dcell{1}, Ccell{1});
```

![Votes vs. comments fit](./doc/votes_vs_comments_fit.png?raw=true "Votes vs. comments fit" )

### Forecasting


### Batch Fitting
