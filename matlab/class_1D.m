% Created  by OctaveOliviers
%          on 2020-10-14 10:28:07
%
% Modified on 2020-10-14 12:00:37

clear
clc
rng(10)

% add the folders to the Matlab path
addpath( './models/' )
addpath( './util/' )

alpha = 0.2 ;

% create data set
dim = 1 ;
num = 20 ;
%
mu_1 = -10 + 0.5*randn ;
std_1 = 1.5 ;
class_1 = mu_1 + std_1 * randn( dim, num ) ;
%
mu_2 = 3 + 0.5*randn ;
std_2 = 1 ;
class_2 = mu_2 + std_2 * randn( dim, num ) ;
%
mu_3 = 10 + 0.5*randn ;
std_3 = 0.5 ;
class_3 = mu_3 + std_3 * randn( dim, num ) ;
%
% lab = [ ones(1, size(class_1, 2)) ; -ones(1, size(class_2, 2)) ] ;

% (hyper-)parameters of the layer
space           = 'dual' ;          % space to train layer
hp_equi         = 1e2 ;             % importance of equilibrium objective
hp_stab         = 1e1 ;             % importance of local stability objective
hp_reg          = 1e0 ;            % importance of regularization
feat_map        = 'rbf' ;           % chosen feature map or kernel function
feat_map_param  = 4 ;               % parameter of feature map or kernel function
% build model
model = CLSSVM() ;
% add a layer
model = model.add_layer( space, dim, hp_equi, hp_stab, hp_reg, feat_map, feat_map_param, alpha ) ;

% train model
%model = model.train( [ class_1 , class_2 ] ) ;
%model = model.train( [ class_1 , class_2 , class_3 ] ) ;
% train model only on mean of each class
%model = model.train( [ mu_1 , mu_2 ] ) ;
model = model.train( [ mu_1 , mu_2 , mu_3 ] ) ;

% visualize trained model
plot_decision(model, class_1, class_2, class_3, mu_1, mu_2, mu_3, alpha) ;
plot_convergence(model, class_1, class_2, class_3, mu_1, alpha) ;


%function plot_decision(model, class_1, class_2, mu_1, mu_2)
function plot_decision(model, class_1, class_2, class_3, mu_1, mu_2, mu_3, alpha)

    figure('position', [800, 500, 400, 300])
    set(gca,'TickLabelInterpreter','latex')
    hold on
    box on
    
    % colors
    orange      = [230, 135, 28]/255 ;
    KUL_blue    = [0.11,0.55,0.69] ;
    green       = [58, 148, 22]/255 ;
    red         = [194, 52, 52]/255 ;
    grey        = 0.5 * [1 1 1] ;
    purple      = [103, 78, 167]/255 ;
    
    % parameters of the plot
    prec = .1 ;
    wdw = 20 ;
    x_min = -wdw + floor( min( [ class_1(1,:), class_2(1,:), class_3(1,:) ] )) ;
    x_max =  wdw + ceil(  max( [ class_1(1,:), class_2(1,:), class_3(1,:) ] )) ;
    x = x_min:prec:x_max ;
    
    %x_end = simulate_alpha(model, x, alpha) ;
    f = model.simulate_one_step(x) ;
    [~, ~, x_end] = model.simulate( x ) ;
    
    plot(zeros(size(x)), x, 'color', grey)
    plot(x, zeros(size(x)), 'color', grey)
    plot(x, x, 'color', [0,0,0])
    plot(x,f, 'color', KUL_blue)
        
    dist2class1 = vecnorm(x_end-mu_1, 2, 1) ;
    dist2class2 = vecnorm(x_end-mu_2, 2, 1) ;
    dist2class3 = vecnorm(x_end-mu_3, 2, 1) ;
    min_dist = min(dist2class1, min(dist2class2, dist2class3)) ;
    
    bin_class1 = (dist2class1 == min_dist) ;
    bin_class2 = (dist2class2 == min_dist) ;
    bin_class3 = (dist2class3 == min_dist) ;
    
    for p = 1:length(x)
        c = (bin_class1(p)*orange + bin_class2(p)*green + + bin_class3(p)*purple)/(bin_class1(p)+bin_class2(p)+bin_class3(p)) ;
        scatter(x(p), x(p), 15, 'filled', 'MarkerFaceColor', c, 'MarkerFaceAlpha', .8)
    end
    
    % class 1 patterns to memorize
    %l_patterns_c1 = plot(class_1(1, :), class_1(2, :), 'x', 'MarkerSize', 10, 'color', orange, 'LineWidth', 2) ;
    plot(mu_1, mu_1, '.', 'MarkerSize', 20, 'color', red, 'LineWidth', 2) ;
    % class 2 patterns to memorize
    %l_patterns_c2 = plot(class_2(1, :), class_2(2, :), '+', 'MarkerSize', 10, 'color', green, 'LineWidth', 2) ;
    plot(mu_2, mu_2, '.', 'MarkerSize', 20, 'color', red, 'LineWidth', 2) ;
    % class 3 patterns to memorize
    %l_patterns_c3 = plot(class_3(1, :), class_3(2, :), '*', 'MarkerSize', 10, 'color', purple, 'LineWidth', 2) ;
    plot(mu_3, mu_3, '.', 'MarkerSize', 20, 'color', red, 'LineWidth', 2) ;
    
    % simulate from one point
    %move = cell2mat(simulate_alpha(model, -2, alpha)) ;
    %plot(move(1,:), move(2,:), 'r-', 'linewidth', 1)
    %
    %move = cell2mat(simulate_alpha(model, [10;-20], alpha)) ;
    %plot(move(1,:), move(2,:), 'r-', 'linewidth', 1)
    %
    %move = cell2mat(simulate_alpha(model, [4;-11], alpha)) ;
    %plot(move(1,:), move(2,:), 'r-', 'linewidth', 1)
    
    
    hold off
    set(gca,'FontSize',12)
    xlabel('$x^{(k)}$', 'interpreter', 'latex', 'fontsize', 14)
    ylabel('$x^{(k+1)}$', 'interpreter', 'latex', 'fontsize', 14)
    xlim([x_min, x_max])
    %ylim([y_min, y_max])
%     xticks([])
%     yticks([])
    axis equal
    %title( "2D classification", 'interpreter', 'latex', 'fontsize', 14 )
    %legend( [l_patterns_c1, l_patterns_c2, hlines(1)], {'Class 1', 'Class 2', 'Streamlines'}, 'location', 'southwest','interpreter', 'latex', 'fontsize', 12) ;
end


function plot_convergence(model, class_1, class_2, class_3, mu_1, alpha)

    figure('position', [800, 100, 400, 300])
    set(gca,'TickLabelInterpreter','latex')
    hold on
    box on
    
    % colors
    orange      = [230, 135, 28]/255 ;
    KUL_blue    = [0.11,0.55,0.69] ;
    green       = [58, 148, 22]/255 ;
    red         = [194, 52, 52]/255 ;
    grey        = 0.5 * [1 1 1] ;
    
    % parameters of the plot
    prec = .1 ;
    wdw = 10 ;
    x_min = -wdw + floor( min( [ class_1(1,:), class_2(1,:), class_3(1,:) ] )) ;
    x_max =  wdw + ceil(  max( [ class_1(1,:), class_2(1,:), class_3(1,:) ] )) ;
    data = x_min:prec:x_max ;
    
    num_steps = 500 ;
    data_old = data ;
    data_d2class1 = zeros(size(data,2), num_steps) ;
    data_d2class2 = zeros(size(data,2), num_steps) ;
    for n = 1:num_steps
        data_new = model.simulate_one_step(data_old) ;
        %data_new = simulate_alpha_one_step(model, data_old, alpha) ;
        % store step
        data_d2class1(:,n) = vecnorm(data_new-mu_1, 2, 1) ;
        %data_d2class2(:,n) = vecnorm(data_new-mu_2) ;
        % 
        data_old = data_new ;
    end
    
    plot(1:num_steps, data_d2class1, 'color', orange)
    %plot(1:num_steps, data_d2class2, 'color', green)

    hold off
    set(gca,'FontSize',12)
    ylim([-0.5 , max([data_d2class1, data_d2class2], [], 'all')+0.5])
    xlabel('num steps', 'interpreter', 'latex', 'fontsize', 14)
    ylabel('distance', 'interpreter', 'latex', 'fontsize', 14)
    %title( "2D classification", 'interpreter', 'latex', 'fontsize', 14 )
end