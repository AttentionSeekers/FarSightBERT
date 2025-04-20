#figure(
  placement: top,
  scope: "parent",
  image("images/moe_model.png", width: 75%),
  caption: [A hetrogeneous MoE model architecture. Input data is processed in parallel by multiple expert networks. The gating network assigns dynamic weights to each expert's output which are then combined via weighted summation to produce the final prediction. Pretrained models are frozen, and only gating network is fine-tuned to learn which expert contributes most to the output.],
) <fig-moe-model>


= Training

== Computational implementation
//  Computational Implementation
// – Report at least 3 types of requirements such as
// type of hardware, average runtime for each epoch,
// total number of trials, GPU hrs used, and training
// epochs.

All code is written in a Python 3.10 environment. Data preprocessing and cleaning pipeline was done locally using Pandas, training and modeling architecture were written in PyTorch 2.6.0 and the sentence-transformers library was used to extract BERT embeddings from BioCLinicalBERT.

Our experiments were conducted on an Apple M1 Pro and CPU hardware configurations. Despite using consumer grade computing resources, we achieved reasonable training efficiency with an average runtime of approximately 50-60 seconds per epoch resulting in a total training time of around 6.5 minutes per model.

The extraction of FP32 embeddings for both CLS token and mean pooling methods took approximately 1.5 hours each on an Apple M1 Pro.

== Training details
// • Includes Training Details
// – Loss functions
// – Please use LLMs to help write code for the training
// loop.
// a) What was the initial prompt that you used?
// What was the initial output of the LLM?
// Validate the LLM response. How correct,
// relevant and helpful was the LLM? How
// many prompts did you use? If the initial
// prompt did not work, what was wrong with
// it?(In appendix)
// Below are the details of training pipeline:
- *Dataset:* Two datasets are generated as seen in @bert-embeddings. We use BioCLinicalBERT to generate datasets based on [CLS] tokens and mean pooled tokens.

- *Train-Test Set*: The preprocessed dataset is split into training and testing sets. 80% of the records are allocated to the training set, while the remaining 20% are used for testing. This split ensures that the model is trained on a majority of the data while retaining a portion for evaluating its performance.

- *Hyperparameter Tuning*: We initially implemented a multi-objective Bayesian optimization approach that focused on increasing validation accuracy and decreasing the generalization gap. However, given that such optimization requires numerous trials and our primary focus was on comparing embedding methodologies rather than hyperparameter optimization, we maintained fixed hyperparameters across experiments. Following the original paper, we used a batch size of 128, 8 epochs and a learning rate of 1e-3.

- *Optimizer:* Adam optimizer is used to train the model. Adam (Adaptive Moment Estimation) automatically adjusts the learning rate for each parameter based on estimates of the first (mean) and second (variance) moments of the gradients. This enables faster and more stable convergence, especially in high-dimensional spaces. Compared to traditional optimizers like SGD, Adam is robust, more computationally efficient, and generally converges faster on large and complex datasets.

- *Random State:* The ensure the reproducability of experiments, random state is set for all the training and experiments.

- *Loss Function:* The task of ICD-9 code prediction is multi-label classification problem, i.e. each clinical record can have multiple labels. In this setting, each label is treated as an independent binary classification task. To accomodate this, the model uses Binary Cross Entropy with Logits Loss (BCEwithLogitsLoss) which computes the binary cross-entropy loss independently for each class and averages the result across all classes and samples. The loss is calculated as shown in Equation @loss.

$ "BCEWithLogitsLoss" = \
  -frac(1, N * C)
  sum_(i=1)^N sum_(c=1)^C [
    w_c * (
      y_{i,c} * log(sigma(z_{i,c})) \ 
      + (1 - y_{i,c}) * log(1 - sigma(z_{i,c}))
      )
  ] $ <loss>

  *Variables:*
    - $N$: Number of samples in the batch.
    - $C$: Number of classes.
    - $z_i,c$: Raw logit (unnormalized output) for class $c$ in sample $i$.
    - $y_{i,c} in {0, 1}$: Ground truth label for class $c$ in sample $i$.
    - $sigma(z_{i,c})$: Sigmoid function applied to logit $z_{i,c}$.
    - $w_c$: Optional weight for class $c$ (e.g., `pos_weight` to handle class imbalance).


