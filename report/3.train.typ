#figure(
  placement: auto,
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