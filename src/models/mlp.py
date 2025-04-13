#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-09 12:35:53 Wednesday

@author: Nikhil Kapila
"""

import torch.functional as F
from torch import nn

# structure:
    # input
    # linear 19
    # linear 75
    # sigmoid


class mlp(nn.Module):
    def __init__(self, input_size):
        super(mlp, self).__init__()
        self.fc1 = nn.Linear(in_features=input_size, out_features=75)
        self.fc2 = nn.Linear(in_features=75, out_features=19)

    def forward(self):
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return x
