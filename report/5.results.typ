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

      table.cell(rowspan: 4)[*NMF-TW with SC* \ (from the paper with \ FarSight Aggregation \  mechanism)], 
                                              [*MLP*],[79.61%],[57.53%],[71.75%],[67.03%],[78.56%],
                                              [*ConvNet*],[81.92%],[61.99%],[74.66%],[69.83%],[80.77%],
                                              [*ConvLSTM*],[83.43%],[64.59%],[76.02%],[71.70%],[81.92%],
                                              [*BiLSTM*],[80.96%],[59.98%],[73.18%],[68.60%],[79.61%],
        table.cell(rowspan: 5)[*BioClinicalBERT \ [CLS] Token*], 
                                              [*MLP*],[77.30%], [20.62%], [70.01%], [59.66%], [71.38%],
                                              [*ConvNet*],[78.20%], [25.00%], [71.43%], [62.45%], [74.24%],
                                              [*ConvLSTM*],[77.82%], [23.72%], [71.75%], [61.49%], [73.54%],
                                              [*BiLSTM*],[77.95%], [25.07%], [71.65%], [62.07%], [73.93%],
                                              [*MoE*],[78.43%], [25.38%], [71.89%], [63.24%], [75.21%],
        table.cell(rowspan: 5)[*BioClinicalBERT \ Mean Pooling*], 
                                              [*MLP*],[77.99%], [23.21%], [71.10%], [61.50%], [73.66%],
                                              [*ConvNet*],[78.42%], [25.76%], [71.78%], [63.61%], [75.39%],
                                              [*ConvLSTM*],[78.66%], [25.93%], [72.05%], [63.65%], [75.77%],
                                              [*BiLSTM*],[79.14%], [29.09%], [72.27%], [65.08%], [76.75%],
                                              [*MoE*],[79.3%], [29.12%], [72.44%], [65.67%], [77.33%],
    ),
  ],
)<farsight-results>



