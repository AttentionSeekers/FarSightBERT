#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-09 12:38:54 Wednesday

@author: Nikhil Kapila
"""

import torch
from torch import nn

# Seg-GRU Architecture Implementation
    # Stage 1:
        # multiple parallel inputs of shape (M × N/20)
        # this is a HYPERPARAM
        # each input is processed through its own branch before concatenation
            #   1. Fully connected layer with N + N/20 neurons
            #   2. Fully connected layer with 20 neurons
        
    # Stage 1 hyperparam
    # - M is the number of parallel inputs
    # - N is a hyperparameter that determines network size
    # - Each parallel input has shape (N/20)
    # VERY similar parallelization to multihead att :)

    # Stage 2:
        # concatenate from stage 1
        # gru 400
        # dropout 0.1
        # linear 200
        # dropout 0.1
        # linear 100
        # dropout 0.1
        # linear 50
        # dropout 0.1
        # linear 19
        # batch norm
        # sigmoid


class seggru(nn.Module):
    def __init__(self):
        super(seggru, self).__init__()

    def forward(self):
        pass