#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-09 12:31:26 Wednesday

@author: Nikhil Kapila
"""

import torch
from torch import nn

# structure:
#     input
#     Linear 289
#     bilstm 10
#     Linear 19
#     Sigmoid

class bilstm(nn.Module):
    def __init__(self):
        super(bilstm, self).__init__()

    def forward(self):
        pass