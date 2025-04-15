#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-09 12:36:50 Wednesday

@author: Nikhil Kapila
"""

import torch
import torch.nn.functional as F
from torch import nn

# structure:
#     input
#     linear 289
#     conv3d 19
#     linear 19
#     sigmoid


class ConvNet(nn.Module):
    def __init__(self, input_size):
        super(ConvNet, self).__init__()
        self.fc1 = nn.Linear(in_features=input_size, out_features=289)
        self.conv1 = nn.Conv2d(1, 19, kernel_size=3)
        self.fc2 = nn.Linear(in_features=19 * 225, out_features=19)

    def forward(self, x):
        x = F.relu(self.fc1(x))
        # reshape the output of fc1 for convolution
        x = x.reshape(-1, 1, int(289**0.5), int(289**0.5))
        x = F.relu(self.conv1(x))
        # flatten to be pass through fully connected layer fc2
        x = torch.flatten(x, 1)
        x = self.fc2(x)
        return x