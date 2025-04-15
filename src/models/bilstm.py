#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-09 12:31:26 Wednesday

@author: Nikhil Kapila
"""

import torch.nn.functional as F
from torch import nn


# structure:
#     input
#     Linear 289
#     bilstm 10
#     Linear 19
#     Sigmoid

class bilstm(nn.Module):
    def __init__(self, input_size):
        super(bilstm, self).__init__()
        self.fc1  = nn.Linear(input_size, 289)
        self.lstm = nn.LSTM(input_size=289, hidden_size=300, bidirectional = True)
        self.fc2 = nn.Linear(600, 19)

    """
    Forward pass for BiLSTM

    Parameters:
        x: input instance at time t
        h0: the initial hidden state
        c0: the initial cell state
    """    
    def forward(self, x, h0, c0):
        x = self.fc1(x)
        x = F.relu(x)
        x = x.reshape(x.size(0), 1, -1)
        out, (hn, cn) = self.lstm(x, (h0, c0))
        out = out[:, -1, :]
        out = self.fc2(out)
        return out, h0, c0 
