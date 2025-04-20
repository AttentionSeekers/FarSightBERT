= Discussion
// Make an assessment of whether the paper is
// reproducible or not.
// • Explain why it is not reproducible if your results are kind of negative.
// • Describe ’What was easy’ and ’What was difficult’
// during reproduction.
// • Make suggestions to the author or other reproducers
// on how to improve the reproducibility.

The reproduction of FarSight paper's yielded valuable insights into both strengths of original approach and limitations of newer embedding techniques.

== Reproducibility Assessment
While we had no access to source code, it was possible to reproduce FarSight's aggregation mechanism and extend it to our niche use-cases.

=== What Was Easy
The FarSight aggregation mechanism was easy to reproduce and implementing it required minimal interpretation, the pre-processing steps were well-documented, neural architecture to implement was clear, evaluation metrics were fairly standard and well-defined.

== What Was Difficult
There were a few things that were difficult to comprehend. The paper did not specify a exact threshold to convert probabilities into binary predictions. Hence, we just used $0.5$ which could have swayed our results.
The detailed hyperparameter settings could have helped reduce significant tuning times and made benchmarking much easier. In the pre-processing steps, it was not possible to do abbreviation disambiguation as we could not find the framework used for it which could have again swayed our results.