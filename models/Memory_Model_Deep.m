% @Author: OctaveOliviers
% @Date:   2020-03-05 19:26:18
% @Last Modified by:   OctaveOliviers
% @Last Modified time: 2020-03-15 15:41:37

classdef Memory_Model_Deep < Memory_Model
	
	properties
		models		% cell of shallow models in each layer
		max_iter	% maximum number of iterations during training
		alpha		% learning rate for gradient descent in hidden states
	end

	methods
		% constructor
		function obj = Memory_Model_Deep(num_lay, space, phi, theta, p_err, p_drv, p_reg)
			% check correctness of inputs
			assert( length(space) == num_lay , 'Number of spaces does not match number of layers' ) ;
			assert( length(phi)   == num_lay , 'Number of feature maps does not match number of layers' ) ;
			assert( length(theta) == num_lay , 'Number of feature parameters does not match number of layers' ) ;

			% superclass constructor
			obj 			= obj@Memory_Model(space, phi, theta, p_err, p_drv, p_reg) ;
			% subclass specific variables
			obj.num_lay		= num_lay ;
			obj.models		= cell(num_lay, 1) ;
			obj.max_iter	= 20 ;
			obj.alpha		= 0.3 ;
			% shallow model for each step of the action
			for l = 1:num_lay
				obj.models{l} = Memory_Model_Shallow(space{l}, phi{l}, theta{l}, p_err, p_drv, p_reg) ;
			end
		end


		% train model for objective p_err/2*Tr(E^TE) + p_drv/2*Tr(J^TJ) + p_reg/2*Tr(W^TW)
		function obj = train(obj, X, varargin)
			% X 		patterns to memorize
			% varargin	contains Y to map patterns X to (for stacked architectures)
			
			% extract useful parameters
			[N, P] 			= size(X) ;
			obj.patterns 	= repmat( X, 1, 1, obj.num_lay+1 ) ;

			for i = 1:obj.max_iter
				% hidden representations of patterns
				H = obj.patterns ;

				% train each layer
				for l = 1:obj.num_lay
					obj.models{ l } = obj.models{ l }.train( H(:, :, l), H(:, :, l+1) ) ;
				end

				% update hidden layers
				for l = obj.num_lay-1:-1:1

					assert( strcmp(obj.models{l}.phi, 'sign'), 'deep target only for sign(x) yet' )

					switch obj.space{ l }
						case {'primal', 'p'}
							L_e_l 	= obj.models{ l }.L_e ; 
							% F_lp1	= jac( H(:, :, l), obj.phi{l+1}, obj.theta{l+1} ) ;
							% W_lp1	= obj.models{ l+1 }.W ;
							% L_e_lp1	= obj.models{ l+1 }.L_e ;
							% L_d_lp1	= obj.models{ l+1 }.L_d ;

							% grad 	= L_e_l - F_lp1'*W_lp1*L_e_lp1 ;
							% for p = 1:P
							% 	A = L_d_lp1(:, (p-1)*N+1:p*N)' * W_lp1 ;

							% 	H = hess() ;
							% end

							grad = L_e_l ;
							r = max(vecnorm(grad)) ;

							H(:, :, l+1) = H(:, :, l+1) - obj.alpha * grad ;

						case {'dual', 'd'}
							warning( 'target prop has not yet been implemented for dual formulation' ) ;
					end

				end

				% check for convergence
				if ( r < 1e-5 )
					break
				end

			end

		    disp("model trained")
		end


		% compute value of Lagrangian
		function L = lagrangian(obj)
			L = obj.p_err/2 * ;
		end


		% simulate model over one step
		function F = simulate_one_step(obj, X)
			% x		matrix with start positions to simulate from as columns

			F = X ;
			for l = 1:obj.num_lay
				F = obj.models{ l }.simulate_one_step( F ) ;
			end
		end
	end
end