#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-09 12:35:44 Wednesday

@author: Nikhil Kapila
"""

import torch
import torch.functional as F
from torch import nn

# structure:
    # input
    # linear 289
    # conv3d 19
    # linear 289
    # lstm 300
    # linear 19
    # sigmoid


class conv_lstm(nn.Module):
    def __init__(self, input_size):
        super(conv_lstm, self).__init__()
        self.fc1 = nn.Linear(input_size, 289)
        self.conv1 = nn.Conv2d(1, 19, kernel_size=3)
        self.fc2 = nn.Linear(19 * 225, 289)
        self.lstm = nn.LSTM(289, 300)
        self.fc3 = nn.Linear(300, 19)

    """
    Forward pass for ConvLSTM

    Parameters:
        x: input instance at time t
        h0: the initial hidden state
        c0: the initial cell state
    """ 

    def forward(self, x, h0, c0):
      x = F.relu(self.fc1(x))
      x = x.view(-1, 1, int(289**0.5), int(289**0.5))
      x = F.relu(self.conv1(x))
      x = torch.flatten(x, 1)
      x = F.relu(self.fc2(x))
      x = x.reshape(x.size(0), 1, -1)
      out, (hn, cn) = self.lstm(x, (h0, c0))
      out = out.squeeze()
      out = self.fc3(out)
      return out, h0, c0