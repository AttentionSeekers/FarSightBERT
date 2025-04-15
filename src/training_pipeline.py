#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-15 00:14:19 IST (UTC+05:30) Tuesday 

@author: Tejas Rathi
"""
import pickle
import torch
import numpy as np
from torch import nn
from skorch import NeuralNetClassifier
from models.convlstm import ConvLSTM
from models.convnet import ConvNet
from skorch.dataset import ValidSplit
from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, roc_auc_score, average_precision_score, accuracy_score
from skorch.callbacks import ProgressBar
from skorch.callbacks import EpochScoring

class TrainingPipeline:    
    def __init__(self):
        self.X_train = None
        self.X_test = None
        self.y_train = None 
        self.y_test = None
        self.device ='cuda' if torch.cuda.is_available() else 'cpu' # GPU support

    def load_data(self):
        # Load preprocessed data
        with open("data/X.pkl", "rb") as f:
            X = pickle.load(f)

        with open("data/y.pkl", "rb") as f:
            y = pickle.load(f)
        print('Data loaded successfully.')

        # create test train split
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

        self.X_train = torch.tensor(X_train, dtype=torch.float32).to(self.device)
        self.y_train = torch.tensor(y_train, dtype=torch.float32).to(self.device)
        self.X_test = torch.tensor(X_test, dtype=torch.float32).to(self.device)
        self.y_test = torch.tensor(y_test, dtype=torch.float32).to(self.device)

        print('Train Test split generated successfully !')
    
    def train_model(self, model, args):
        max_epochs, learning_rate, batch_size = args['max_epochs'], args['learning_rate'], args['batch_size']

        def train_acc_scoring(net, batch, y):
            if hasattr(batch, 'indices'):  # when using ValSplit(.1)
                train_actual = np.array([batch.dataset.X[batch.indices]])
            else:  # when using the full dataset without valsplit
                train_actual = np.array(batch.dataset.X)
                # train_actual = np.array([X.dataset.targets[idx] for idx in X.indices])
            train_preds = net.predict(batch)
            
            return accuracy_score(train_actual, train_preds)
        
        training_acc_callback = EpochScoring(train_acc_scoring, name='train_acc',  on_train=True, lower_is_better=False)
        
        net = NeuralNetClassifier(
                model,
                max_epochs=max_epochs,
                batch_size=batch_size,
                train_split=ValidSplit(5),
                lr=learning_rate,
                callbacks=[training_acc_callback, ProgressBar()],
                optimizer=torch.optim.Adam,
                criterion=nn.BCEWithLogitsLoss(),
                device=self.device
            )

        net.fit(X=self.X_train, y=self.y_train) 

        # Save trained model to use it later in mixture of model architecture
        with open(f'trained_models/{type(model).__name__}.pkl', 'wb') as f:
            pickle.dump(net, f)

    def eval_model(self):
        pass