#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-19 16:47:42 IST (UTC+05:30) Saturday 

@author: 
"""

from torch import nn
import torch

class MoE(nn.Module):
    def __init__(self, experts:dict, input_dim:int, hidden_dim:int):
        super().__init__()
        self.device = 'mps' if torch.backends.mps.is_available() else ('cuda' if torch.cuda.is_available() else 'cpu')
        # self.expert_list = experts
        # self.experts = nn.ModuleList([
        #     e.to(self.device).eval().requires_grad_(False) for e in experts
        #     ])
        
        self.expert_names = list(experts.keys())

        self.experts = nn.ModuleDict({
            name: e.to(self.device).eval().requires_grad_(False)
            for name, e in experts.items()
            })

        self.gating_network = nn.Sequential(
            nn.Linear(in_features=input_dim, out_features=hidden_dim),
            nn.ReLU(),
            nn.Linear(in_features=hidden_dim, out_features=len(experts))
        ).to(self.device)


    def forward(self, x):
        gate_logits = self.gating_network(x)
        expert_weights = torch.softmax(gate_logits, dim=1)  # n * number of experts
        
        expert_outputs = []
        with torch.no_grad():
            for name in self.expert_names:
                expert_outputs.append(self.experts[name](x))

        o = torch.stack(expert_outputs, dim=0)   # number of experts * n * output_size
        w = expert_weights.T.unsqueeze(dim=-1)
        out = torch.sum(o * w, dim=0)

        mean_w = expert_weights.mean(dim=0) # mean over batch
        w_dict = {name: mean_w[i].item() for i,name in enumerate(self.expert_names)}
        return out, expert_weights, w_dict
