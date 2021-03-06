# -*- coding: utf-8 -*-
# @Created by: OctaveOliviers
# @Created on: 2021-01-28 12:13:39
# @Last Modified by: OctaveOliviers
# @Last Modified on: 2021-04-01 11:09:12


# import libraries
import torch
import torch.nn as nn
from modules.layer import *
from itertools import chain
from tqdm import trange
import numbers


class CLSSVM(nn.Module):
    """
    docstring for CLSSVM
    """

    def __init__(
            self,
            device:str='cpu'
    ):
        """
        explain
        """
        super(CLSSVM, self).__init__()

        # model layers
        self.layers = []
        # model optimizer
        self.opt = None    
        # model parameters
        self.parameters = []
        # model targets for each layer
        self.targets = []
        # model input data
        self.data_in = None
        # training device
        self.device = device

    def __str__(self) -> str:
        """
        explain
        """
        return f"C-LS-SVM with {len(self.layers)} layers"

    def add_layer(
            self,
            **kwargs
    ) -> None:
        """
        explain
        """
        # assert that the dimensions match
        assert (len(self.layers)==0 or kwargs['dim_in']==self.layers[-1].dim_out), \
            f"The input dimension is not correct. It should be {self.layers[-1].dim_out} to match the output of the previous layer."

        if kwargs['space']=='primal':
            layer = LayerPrimal(**kwargs)
        elif kwargs['space']=='dual':
            layer = LayerDual(**kwargs)
        else:
            raise ValueError('Did not understand the space of the layer')
        # store new layer
        self.layers.append(layer)

    def forward(
            self,
            x:torch.Tensor
    ) -> torch.Tensor:
        """
        explain
        """
        x = self.layers[0].forward(x, targets=self.targets[-1])
        for i, layer in enumerate(self.layers[1:]):
            x = layer.forward(x, targets=self.targets[i])
        return x

    def loss(
            self,
            x:torch.Tensor,
            y:torch.Tensor
    ) -> numbers.Real:
        """
        explain
        """
        # initialize loss
        l = 0
        # sum losses of each layer
        l += self.layers[0].loss(x,self.targets[0])
        for i, layer in enumerate(self.layers[1:]):
            l += layer.loss(self.targets[i], self.targets[i+1])
        return l


    def custom_train(
            self,
            x:torch.Tensor,
            y:torch.Tensor,
            max_iter:int=10**3
    ) -> None:
        """
        explain
        """
        # # ensure inputs are torch.tensor objects
        # x = torch.Tensor(x)
        # y = torch.Tensor(y)

        # assert that x and the first layer have the same dimension
        assert self.layers[0].dim_in==x.shape[1], \
            f"The input dimension of the first layer ({self.layers[0].dim_in}) does not match the dimension of the data in 'x' ({x.shape[1]})."
            # assert that y and the last layer have the same dimension
        assert self.layers[-1].dim_out==y.shape[1], \
            f"The output dimension of the last layer ({self.layers[-1].dim_out}) does not match the dimension of the data in 'y' ({y.shape[1]})."

        # initialize the parameters in each layer and build targets
        for layer in self.layers:
            # build layer targets
            self.targets.append(nn.Parameter(nn.init.normal_(torch.Tensor(x.shape[0],layer.dim_out).to(self.device)), requires_grad=True))
            # initialize parameters
            layer.init_parameters(x.shape[0], device=self.device)
            # update model parameters
            self.parameters = chain(self.parameters, layer.parameters())
        # set target of last layer to y
        self.targets[-1] = y

        # update optimizer
        self.opt = torch.optim.Adam(chain(self.parameters, iter(self.targets[:-1])), lr=0.001)

        print(f"First loss value = {self.loss(x,y)}")

        # start training
        for _ in trange(max_iter):
            self.opt.zero_grad()
            loss = self.loss(x,y)
            loss.backward()
            self.opt.step()

        print(f"Final loss value = {self.loss(x,y)}")

        # self.layers[0].data = x
        # for i, layer in enumerate(self.layers[1:]):
        #     layer.data = self.targets[i]
