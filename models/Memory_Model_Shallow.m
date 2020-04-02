% Created  by OctaveOliviers
%          on 2020-03-28 15:17:46
%
% Modified on 2020-03-29 19:33:04

classdef Memory_Model_Shallow < Memory_Model

    properties      
        % model architecture
        space       % 'primal' or 'dual'
        phi         % feature map as string
        theta       % parameter of feature map
        num_lay     % number of layers
        % model hyper-parameters
        p_err       % importance of minimizing error
        p_drv       % importance of minimizing derivative
        p_reg       % importance of regularization
        % model parameters
        L_e         % dual Lagrange parameters for error
        L_d         % dual Lagrange parameters for derivative
    end

    methods
        % constructor
        function obj = Memory_Model_Shallow(phi, theta, p_err, p_drv, p_reg)
            % superclass constructor
            obj@Memory_Model() ;
            
            % subclass specific variables
            obj.num_lay = 1 ;
            % architecture
            obj.phi     = phi ;     % string
            obj.theta   = theta ;   % float
            % hyper-parameters
            obj.p_err   = p_err ;   % float
            obj.p_drv   = p_drv ;   % float
            obj.p_reg   = p_reg ;   % float
            % model information
            obj.name    = 'Shallow network' ;
        end
    end
end