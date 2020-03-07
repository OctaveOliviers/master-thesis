% @Author: OctaveOliviers
% @Date:   2020-03-04 22:56:29
% @Last Modified by:   OctaveOliviers
% @Last Modified time: 2020-03-05 15:26:15

% compute kernel matrix 
%       m = phi(x)^T * phi(y) 
% for data in X and Y

function m = phiTphi(X, Y, fun, param) 
    % X, Y      data matrix with observations in columns
    % fun 		feature map
    % param 	parameter of feature map

    % extract useful variables
    num_x = size(X, 2) ;
    num_y = size(Y, 2) ;
    
    m = zeros(num_x, num_y) ;
    
    fun = lower(fun);
    switch fun
        case { 'rbf', 'gauss', 'gaus' }
            sig = param ;
            for i = 1:num_x
                for j = 1:num_y
                    x = X(:, i) ;
                    y = Y(:, j) ;
                    m(i, j) = exp(-(x-y)'*(x-y)/(2*sig^2)) ;
                end
            end 
    end
end