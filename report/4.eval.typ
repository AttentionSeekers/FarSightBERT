= Evaluation Metrics
// Evaluation//// • Please use LLMs to help identify and write code forte// metrics and evaluations. c// a) What was the initial prompt that you used?aluations.
// a) What was the initial prompt that you used?
// What was the initial output of the LLM?
// Validate the LLM response. How correct,
// relevant au use? If the initial prompt did
// not work, what was wrong with it?(In appendix)
// 
It is crucial to select appropriate metric to access the performance of model. The choice of metric depends heavily on the nature of problem and characterstics of dataset (e.g., balanced vs imbalanced). Since our ICD-9 dataset is imbalanced in nature, we followed the approach in the FarSight paper and selected various standard classification evaluation metrics suited for multil-label and imbalanced datasets.

- *Accuracy:* Measures the proportion of correctly predicted labels out of the total labels. 
However, for imbalanced datasets, accuracy can be misleading as it does not account for the distribution of classes.

- *Matthews Correlation Coefficient (MCC):* A balanced measure that takes into account true and false positives and negatives. It is especially useful for imbalanced datasets as it provides a single score that evaluates the quality of binary classifications. The MCC value ranges from -1 to +1, 
  - +1 indicates a perfect prediction
  - 0 indicates no better than random prediction 
  - -1 indicates total disagreement between prediction and observation.

- *F1 Score:* Harmonic mean of precision and recall. It is particularly useful for imbalanced datasets as it balances the trade-off between precision and recall. The F1 score ranges from 0 to 1, where 1 indicates perfect precision and recall. In our multilabel settings for this problem, weighted F1 is used to balance the impact of rare and frequent code groups.

- *Area Under the Precision-Recall Curve (AUPRC):* Evaluates the trade-off between precision and recall across different thresholds. It is a more informative measure than AUROC for imbalanced as it emphasizes on model's ability to identify true positives without being diverted by majority of true negatives.
  
- *Area Under the Receiver Operating Characteristic Curve (AUROC):* Represents model's ability to discriminate between different classes by plotting true positive rate against false positive rate. This metric provides measure of ranking positive instances over negative ones by the classifier. A higher AUROC score (closer to 1) indicates stronger class separability.

All these above metrics evaluates the model from a different perspective, hence ensuring that model is accurate, as well as robust, reliable and affective across all diagnostic code groups - including minor classes. 