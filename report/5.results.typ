= Results
// Report results for all experiments that you run:
// – specific numbers (accuracy, AUC, RMSE, etc)
// – figures (loss shrinkage, outputs from GAN,
// annotation or label of sample pictures, etc)
// • Comparison with the hypothesis and results from the
// original paper.
// • Explain why the results may be the same or different.
// • Additional Extensions or Ablations
// – Use LLMs to help brainstorm at least one
// new extension - new dataset, new loss function,
// removing a part of the model (ablation study), etc.
// a) What extensions did the LLM come up with?
// How valid are they?
// b) What were your insights and analysis on
// making prompts effective for brainstorming?
// – Use LLMs to help implement your planned
// extension(s) and validate them. Include results and
// a discussion

#figure(
  placement: top,
  scope: "parent",
  caption: [Performance metrics across classifiers],
  text(size: 11pt)[
    #table(
      columns: 7,
      align: horizon,
      inset: 9pt,
      table.header(
        [*Data Model*], [*Classifier*], [*ACC*], [*MCC*], [*F1*], [*AUPRC*], [*AUROC*]
      ),

      table.cell(rowspan: 4)[*NMF-TW with SC* \ (from the paper)], [*MLP*],[],[],[],[],[],
                                              [*LSTM*],[],[],[],[],[],
                                              [*BiLSTM*],[],[],[],[],[],
                                              [*ConvNet*],[],[],[],[],[],
      table.cell(rowspan: 4)[*BERT [CLS] Token*], [*MLP*],[],[],[],[],[],
                                              [*LSTM*],[],[],[],[],[],
                                              [*BiLSTM*],[],[],[],[],[],
                                              [*ConvNet*],[],[],[],[],[],
      table.cell(rowspan: 4)[*BERT Mean Pooling*], [*MLP*],[],[],[],[],[],
                                              [*LSTM*],[],[],[],[],[],
                                              [*BiLSTM*],[],[],[],[],[],
                                              [*ConvNet*],[],[],[],[],[],


    ),
  ],
)<farsight-results>



