= Evaluation Metrics
// Evaluation//// • Please use LLMs to help identify and write code forte// metrics and evaluations. c// a) What was the initial prompt that you used?aluations.
// a) What was the initial prompt that you used?
// What was the initial output of the LLM?
// Validate the LLM response. How correct,
// relevant au use? If the initial prompt did
// not work, what was wrong with it?(In appendix)
It is crucial to select appropriate metric to access the performance of model. The choice of metric depends heavily on the nature of problem and characterstics of dataset e.g. balanced vs imbalanced etc.. Since the ICD-9 dataset is imbalanced in nature, we selected various standard classification evaluation metrics which are suited for multil-label and imbalanced dataset.
- *Accuracy:* Accuracy measures the proportion of correctly predicted labels out of the total labels. 
However, for imbalanced datasets, accuracy can be misleading as it does not account for the distribution of classes.
- *Matthews Correlation Coefficient (MCC):* MCC is a balanced measure that takes into account true and false positives and negatives. It is especially useful for imbalanced datasets as it provides a single score that evaluates the quality of binary classifications. The MCC value ranges from -1 to +1, 
  - +1 indicates a perfect prediction
  - 0 indicates no better than random prediction 
  - 1 indicates total disagreement between prediction and observation.
  - *F1 Score:* F1 score is the harmonic mean of precision and recall. It is particularly useful for imbalanced datasets as it balances the trade-off between precision and recall. The F1 score ranges from 0 to 1, where:
    - 1 indicates perfect precision and recall.
    - 0 indicates the worst possible performance.
  In multi-label settings for this problem, weighted F1 is used to balance the impact of rare and frequent code groups.
  - *Area Under the Precision-Recall Curve (AUPRC):* AUPRC is a performance metric that evaluates the trade-off between precision and recall across different thresholds. It provides a more informative measure than AUROC when datasets are skewed in nature. It emphasizes on models ability to identify true positives without being diverted by majority of true negatives.
- - *Area Under the Receiver Operating Characteristic Curve (AUROC):* AUROC represents model's ability to discriminate between different classes by plotting true positive rate against false positive rate. This metric provides measure of ranking positive instances over negative ones by the classifier. A higher AUROC score (closer to 1) indicates stronger class separability.

All these above metrics evaluates the model from a different perspective, hence ensuring that model is accurate, as well as robust, reliable and affective across all diagnostic code groups - including minor classes. 