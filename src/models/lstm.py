#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-09 12:37:21 Wednesday

@author: Nikhil Kapila
"""

import torch.nn.functional as F
from torch import nn

# structure:
    # input
    # linear 289
    # lstm 300
    # linear 19
    # sigmoid


class lstm(nn.Module):
    def __init__(self, input_size):
        super(lstm, self).__init__()
        self.fc1 = nn.Linear(input_size, 289)
        self.lstm = nn.LSTM(289, 300)
        self.fc2 = nn.Linear(300, 19)

    """
    Forward pass for LSTM

    Parameters:
        x: input instance at time t
        h0: the initial hidden state
        c0: the initial cell state
    """ 
    def forward(self, x, h0, c0):
        x = F.relu(self.fc1(x))
        x = x.reshape(x.size(0), 1, -1)
        out, (hn, cn) = self.lstm(x, (h0, c0))
        out = out[:, -1, :]
        out = self.fc2(out)
        return out, h0, c0
