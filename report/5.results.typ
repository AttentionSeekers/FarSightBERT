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
// 

It is interesting to see that both [CLS] token and mean pooled embeddings from BioCLinicalBERT show lower performance compared to static embeddings of NMF-TW with SC from FarSight's paper. Furthermore, CLS token slightly underperforms mean pooling on most metrics and mean pooling shows modest improvements in MCC scores and AUROC

Below are some important inferences: 
- *Domain-specific representation matters:* Referring @farsight-results, it is inevitable that domain-adapted NMF-TW with SC outperforms the pre trained BioClinicalBERT embeddings, even though BioClinicalBERT is specifically pre-trained on all MIMIC notes. This suggests that NMF-TW with SC model captured rich information in the informally-written nursing notes needed for classifier to learn and generalize; better compared to BioClinicalBERT @bio_clinicalbert.

- *FarSight aggregation provides crucial advantage: * The results @farsight-results confirms the hypothesis and core promise mentioned in @farsight-orig that Farsight aggregation mechanism substantially provides capability to model to detect the diseases at on-set from the unstructured clinical notes.

- *MCC divergence:* The most dramatic difference observed in original paper @farsight-orig and @farsight-results is, huge divergence in MCC scores i.e. 64.59% for best NMF-TW model vs 29.12% for best BioClinicalBERT model. This indicates the NMF-TW approach is particularly strong at handling the class imbalance in the ICD-9 dataset.

- *Mean v/s CLS embeddings:* For BioClinicalBERT, it is observed that models trained on Mean embeddings consitently outperforms models trained on Mean Embeddings. This indicates that averaging all token provides more comprehensive and complete clinical information then relying on CLS token alone.

- *The transfer learning trade-off*: A compute vs accuracy trade-off arises from our result. While contextual embeddings do not beat static embeddings by marginal percentages, it is important to take note of the compute requirements as well. While NMF-TW with SC significantly outperforms BioClinicalBERT embeddings, the computational considerations are noteworthy. NMF-TW requires substantial upfront computation to generate topic models on the specific corpus, but enables efficient subsequent neural network training. In contrast, BioClinicalBERT leverages pre-trained weights but demands significant compute resources to generate contextual embeddings for each nursing note. This trade-off is particularly relevant in resource-constrained clinical settings. The superior performance of NMF-TW (and others) may justify its computational investment, but scenarios requiring rapid deployment might benefit from transfer learning despite lower accuracy. The optimal approach ultimately depends on accuracy requirements, available computational resources, and deployment constraints.

- *MoE outperforms individual models:* It is observed that Mixture of Experts model consistently outperforms individual neural architectures when trained on both CLS token and Mean pooling embeddings. This suggests that different experts are successfully specializing in different aspects of the prediction task. The expert usage plots @expert-usage-cls and @expert-usage-moe show clear specialization patterns, with distinct experts being consistently activated for different input patterns throughout training.
  - For MoE on Mean embeddings, BiSLTM is specialist for $~60%$ of ICD-9 classification task followed by ConvLSTM and ConvNet. Mean embeddings provide better representation of clinical information and BiLSTM considers both past and future dependencies, thus combining the best of both.
  - For MoE on CLS embeddings, ConvNet is specialist for $~50%$ of ICD-9 classification task followed by BiLSTM and ConvLSTM. CLS embeddings provide summarized representation of clinical note and ConvNet's ability to capture local patterns proves most effective.
\
The results demonstrate that despite the general success of transformer models like BERT in NLP tasks, specialized approaches like NMF topic modeling with the FarSight aggregation mechanism can significantly outperform them for specific clinical prediction tasks, particularly when dealing with imbalanced data.

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

#figure(
  placement: top,
  scope: "parent",
  grid(
    columns: 2,
      [
        #figure(
          image("../plots/moe-cls-usage/expert_usage_all_epochs.png", width: 75%),
          caption: [Expert usage across epochs w/ models trained on CLS embeddings]
        ) <expert-usage-cls>
      ],
      [
        #figure(
          image("../plots/moe-mean-usage/expert_usage_all_epochs.png", width: 75%),
          caption: [Expert usage across epochs w/ models trained on Mean embeddings]
        ) <expert-usage-moe>
      ]
  )
)

