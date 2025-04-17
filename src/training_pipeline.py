#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-15 00:14:19 IST (UTC+05:30) Tuesday 

@author: Tejas Rathi
"""
import torch
from torch import nn
import pickle
import numpy as np
# optuna 
import optuna
from optuna.integration import SkorchPruningCallback
# skorch
from skorch import NeuralNetClassifier
from skorch.callbacks import ProgressBar
from skorch.dataset import ValidSplit
from skorch.callbacks import EpochScoring
# sklearn and metrics
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

class TrainingPipeline:    
    def __init__(self):
        self.X_train = None
        self.X_test = None
        self.y_train = None 
        self.y_test = None
        self.best_params = None
        self.data_loaded = False
        self.batch_size = 128
        self.max_epochs = 10
        self.device = 'mps' if torch.backends.mps.is_available() else ('cuda' if torch.cuda.is_available() else 'cpu')
        self.study = None
        self.test_run_optuna = None

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
        print('Train/Test split completed.')
        self.data_loaded = True
    
    def train_model(self, model, args):
        callbacks = []
        max_epochs, learning_rate, batch_size = \
            args['max_epochs'], args['learning_rate'], args['batch_size']
                    
        training_acc_callback = EpochScoring(self.calculate_acc,
                                             name='train_acc',  
                                             on_train=True, 
                                             lower_is_better=False)


        val_acc_callback = EpochScoring(self.calculate_acc,
                                             name='valid_acc',
                                             on_train=False,
                                             lower_is_better=False)

        callbacks.append(training_acc_callback)
        callbacks.append(val_acc_callback)
        callbacks.append(ProgressBar())

        print(f'Using device: {self.device}')
        
        net = NeuralNetClassifier(
                model,
                max_epochs=max_epochs,
                batch_size=batch_size,
                lr=learning_rate,
                callbacks=callbacks,
                train_split=ValidSplit(5),
                optimizer=torch.optim.Adam,
                criterion=nn.BCEWithLogitsLoss,
                device=self.device
            )

        net.fit(X=self.X_train, y=self.y_train) 

        # Save trained model to use it later in mixture of model architecture
        net.save_params(f_params=f'trained_models/{type(model).__name__}.pkl')

    def calculate_acc(self, net, ds, y):
        y_true = np.stack([y.cpu().numpy() for _,y in ds]).astype(int)
        y_pred = net.predict(ds)

        per_class_acc = []

        for i in range(y_true.shape[1]): #19
            per_class_acc.append(
                accuracy_score(y_true[:, i], y_pred[:, i])
            )

        return np.mean(per_class_acc)

    # TODO(@trathi9): Why was this added?
    def eval_model(self):
        pass

    def create_optuna_objective(self, model):
        def objective(trial):

            print(f'-- Trial number {trial.number} --')
            if self.test_run_optuna is True:
                # -- for testing purposes --
                learning_rate = trial.suggest_categorical('learning_rate', [1e-5])#, 1e-1) 
            else:
                learning_rate = trial.suggest_loguniform('learning_rate', 1e-5, 1e-1)
            # -- fixing at 128 --
            # batch_size = trial.suggest_categorical('batch_size', [32, 64, 128, 256])
            # -- fixing at 10 --
            # max_epochs = trial.suggest_int('max_epochs', 10, 50)
            
            # Create callbacks including pruning
            callbacks = [
                EpochScoring(self.calculate_acc, name='train_acc', on_train=True, lower_is_better=False),
                EpochScoring(self.calculate_acc, name='valid_acc', on_train=False, lower_is_better=False),
                ProgressBar(),
                # SkorchPruningCallback(trial, 'valid_acc')
            ]

            net = NeuralNetClassifier(
                model,
                max_epochs=self.max_epochs,
                batch_size=self.batch_size,
                lr=learning_rate,
                callbacks=callbacks,
                train_split=ValidSplit(5),
                optimizer=torch.optim.Adam,
                criterion=nn.BCEWithLogitsLoss,
                device=self.device
            )
            net.fit(X=self.X_train, y=self.y_train)

            train_acc = net.history[-1, 'train_acc']
            valid_acc = net.history[-1, 'valid_acc']
            # we define a multi objective --> 
            # MAX VALID_ACC BUT LOW GAP IN ACCURACIES == GENERALIZATION
            generalization_gap = abs(train_acc-valid_acc)

            return valid_acc, generalization_gap
            
        return objective

    def optimize_hyperparameters(self, model_class, n_trials=100):
        if self.data_loaded is False:
            self.load_data()

        sampler = optuna.samplers.TPESampler(
            n_startup_trials=5, #
            n_ei_candidates=12,
            seed=42
            )

        self.study = optuna.create_study(
                    directions=['maximize', 'minimize'], # max valid, low generalization gap
                    sampler=sampler
                )
        
        objective = self.create_optuna_objective(model_class)
        print(f'Using device: {self.device}.')
        self.study.optimize(objective, n_trials=n_trials, show_progress_bar=True)

        # best trial
        print('Best trial:')
        best = self.select_best_trial(self.study)
        return self.study, best

    def select_best_trial(self, study):
        if not study.trials:
            raise ValueError("No trials have completed for this study.")

        trials = [
            trial for trial in study.trials if trial.state == optuna.trial.TrialState.COMPLETE
            ]

        sorted_trials = sorted(trials, key=lambda x: (x.values[0],-x.values[1]), reverse=True)
        bestfrom5 = sorted_trials[0]

        print("\nBest trial")
        print(f' - Validation accuracy: {bestfrom5.values[0]}')
        print(f' - Generalization gap: {bestfrom5.values[1]}')
        print(f'Parameters:')
        for k, v in bestfrom5.params.items():
            print(f'{k}: {v}')
        return bestfrom5.params
        
    def train_model_using_optuna_hp(self, model, best_params=None):
        if best_params is None:
            best_params = {
                'max_epochs': 10,
                'learning_rate': 0.001,
                'batch_size': 128,
                'device': self.device
            }

        # Call the existing train_model method with optimized parameters
        self.train_model(model, best_params)