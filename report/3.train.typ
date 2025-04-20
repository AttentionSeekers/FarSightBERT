#figure(
  placement: top,
  scope: "parent",
  image("images/moe_model.png", width: 75%),
  caption: [A hetrogeneous MoE model architecture.Input data is processed in parallel by multiple expert networks. The gating network assigns dynamic weights to each expert's output which are then combined via weighted summation to produce the final prediction. Pretrained models are frozen, and only gating network is fine-tuned to learn which expert contributes most to the output.],
) <fig-moe-model>


= Training

== Computational implementation
//  Computational Implementation
// – Report at least 3 types of requirements such as
// type of hardware, average runtime for each epoch,
// total number of trials, GPU hrs used, and training
// epochs.

We initially implemented a multi-objective Bayesian optimization approach that focused on increasing validation accuracy and decreasing the generalization gap. However, given that such optimization requires numerous trials and our primary focus was on comparing embedding methodologies rather than hyperparameter optimization, we maintained fixed hyperparameters across experiments. Following the original paper, we used a batch size of 128, 8 epochs and a learning rate of 1e-3.

All code was written in a Python 3.10 environment. Data preprocessing and cleaning pipeline was done locally using Pandas, training and modeling architecture were written in PyTorch 2.6.0 and the sentence-transformers library was used to extract BERT embeddings from BioCLinicalBERT.

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

