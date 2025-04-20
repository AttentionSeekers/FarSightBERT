= Appendix


We mainly used LLMs in the initial phase to get a high-level understanding of the paper. For coding and report-writing, we mainly constricted our LLM usage to boilerplate code (such as understanding Pandas or PyTorch training loops), and Typst document formatting.

\

 #table(
      columns: 3,
      align: horizon,
      inset: 9pt,
      table.header(
        [*Prompt*], [*Description*], [*Validation*]
      ),
      [Please analyze this paper and give it's key contributions and points.], [Used mainly during literature review and exploration phase.], [The LLM was mostly correct but there were cases when it hallucinated.],

      [How to optimize .apply methods on a pandas dataframe?], [Used during data preprocessing pipeline], [The LLM was very accurate in its response.],

      [How to use sentence-transformers and how does it compare to HuggingFace lib?], [Used during data preprocessing pipeline], [The LLM was very accurate in its response.],

      [Write a PyTorch training loop.], [Used during MoE training pipeline.], [The LLM was very accurate in its response.],

      [How to make a table span 2 columns in Typst?], [Report writing.], [Major hallucination unless context is given.],

    )