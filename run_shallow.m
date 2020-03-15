% @Author: OctaveOliviers
% @Date:   2020-03-05 10:01:18
% @Last Modified by:   OctaveOliviers
% @Last Modified time: 2020-03-15 11:47:36

clear all
clc

% parameters of patterns
dim_patterns = 10 ;
num_patterns = 3 ;

% aprameters of model
% formulation = 'dual' ; feature_map = 'p' ; parameter = [5, 1] ;
% formulation = 'dual' ; feature_map = 'g' ; parameter = 3 ;
% formulation = 'primal' ; feature_map = 'sign' ; parameter = 0 ;
formulation = 'dual' ; feature_map = 'tanh' ; parameter = 0 ;
num_layers	= 1 ;
% hyper-parameters
p_err  = 1e4 ;	% importance of error
p_reg  = 1e1 ;	% importance of regularization
p_drv  = 1e3 ;	% importance of minimizing derivative

% initialize random number generator
rng(10) ;

% create patterns to memorize
patterns = 2*rand( dim_patterns, num_patterns ) - 1 ;
% patterns = -10 : 3 : 10 ;
% patterns = [0.5*randn(dim_patterns, num_patterns)+[0; -5], ...
% 			0.5*randn(dim_patterns, num_patterns)+[0; +5], ...
% 			0.5*randn(dim_patterns, num_patterns)+[-5;  0], ...
% 			0.5*randn(dim_patterns, num_patterns)+[ 5; 0] ] ;
% [X, Y] = meshgrid(-6:3:6, -6:3:6) ; patterns = [X(:)' ; Y(:)'] ;
% build model
model = Memory_Model_Shallow(formulation, feature_map, parameter, p_err, p_drv, p_reg) ;
% train model
model = model.train(patterns) ;
% visualize model
% model.visualize( 10*rand(dim_patterns, 20) - 5 ) ;

[~, err, eigv] = model.energy( patterns ) ;

err
max(eigv, [], 'all')