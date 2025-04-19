#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-19 16:47:42 IST (UTC+05:30) Saturday 

@author: 
"""

from torch import nn
import torch

class MoE(nn.Module):
    def __init__(self, experts, input_dim, hidden_dim):
        super().__init__()
        self.experts = experts
        self.gating_network = nn.Sequential(
            nn.Linear(in_features=input_dim, out_features=hidden_dim),
            nn.ReLU(),
            nn.Linear(in_features=hidden_dim, out_features=len(experts))
        )
        self.device = 'mps' if torch.backends.mps.is_available() else ('cuda' if torch.cuda.is_available() else 'cpu')


    def forward(self, x):
        gate_logits = self.gating_network(x)
        expert_weights = torch.softmax(gate_logits, dim=1)  # n * number of experts
        expert_outputs = []                                 

        for expert in self.experts:
            expert.eval()
            with torch.no_grad():
                out = expert(x)
                expert_outputs.append(out)

        o = torch.stack(expert_outputs, dim=0)   # number of experts * n * output_size
        w = expert_weights.T.unsqueeze(dim=-1)

        return torch.sum(o * w, dim=0)
