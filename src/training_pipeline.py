#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-15 00:14:19 IST (UTC+05:30) Tuesday 

@author: Tejas Rathi
"""
import pickle
import torch
import argparse
from torch import nn
from skorch import NeuralNetClassifier
from models.convlstm import ConvLSTM

parser = argparse.ArgumentParser()
parser.add_argument('--name')
args = parser.parse_args()

X_train, Y_train = None, None
X_test, Y_test = None, None

if args.name == None:
    print('No argument passed! Skipping execution.')

    print('\nPlease select an argument.'
          '\nAvailable arguments:' \
          '\n1. `load_split_data` : Load the preprocessed data and split train and test set' \
          '\n2. `train_convlstm`: Train ConvLSTM model\
            ')
    
if args.name == 'load_split_data':
    # TODO: Load preprocessed data
    print('Data loaded succesfully.')

    # TODO: create test train split
    X_train, Y_train = None, None
    X_test, Y_test = None, None
    print('Train Test split generated successfully !')
    

if args.name == 'train_convlstm':
    MAX_EPOCHS = 10
    LEARNING_RATE = 0.01

    net = NeuralNetClassifier(
            ConvLSTM(input_size=150),
            max_epochs=MAX_EPOCHS,
            lr=LEARNING_RATE,
            optimizer=torch.optim.Adam,
            criterion=nn.CrossEntropyLoss(),
            device='cuda' if torch.cuda.is_available() else 'cpu',  # GPU support
        )
    
    net.fit(X=X_train, y=Y_train)
    y_pred = net.predict(X_test)

    #TODO: Calculate performance metrics here

    #TODO: Save trained model to use it later in mixture of model architecture
    with open('trained_models/convlstm_model.pkl', 'wb') as f:
        pickle.dump(net, f)