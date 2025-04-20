= Methodology

== Dataset description
// • Dataset description
// – Source of the data: where the data is collected,
// provide the link if possible; if the data is synthetic
// or self-generated, explain how.
// – Statistics: dataset size, cross validation split, label
// distribution, etc
// – How do you use the data: change the class labels,
// split the dataset to train/valid/test, refining the
// dataset
// – Please use LLMs to help in writing data
// preprocessing code
// a) What was the initial prompt that you used?
// What was the initial output of the LLM?
// Validate the LLM response. How correct,
// relevant and helpful was the LLM? How
// many prompts did you use? If the initial
// prompt did not work, what was wrong with it?

MIMIC-III v1.4 @mimic3ds is a publicly available, de-identified database comprising detailed health-related data from over 40,000 patients admitted to critical care units at the Beth Israel Deaconess Medical Center in Boston, Massachusetts, between 2001 and 2012. 
The MIMIC-III v1.4 database consists of 2,083,180 note events out of which 223,556 are nursing notes from 7,704 distinct patients. We model on these nursing notes which is a huge a corpus of 5,244,541 sentences, 79,988,065 total words and 715,821 unique words.

#figure(
  placement: top,
  scope: "parent",
  image("images/data_prep.png", width: 100%),
  caption: [Data cleaning and preprocessing steps as seen in code.],
) <fig-data-preprocess>

== Dataset Preprocessing and Cleaning 
An overview on our dataset preprocessing and cleaning can be seen in @fig-data-preprocess.
As seen in @fig-data-preprocess, we only use 4 CSV files from the entire MIMIC-III dataset.

\

=== Cohort selection
Our cohort selection approach is same as the one illustrated in the FarSight paper. We do the following: (1) we filter out neonates (age < 15), (2) keep only first ICU admissions for each MIMIC-III subject and discard later admissions, (3) identify and filter out any nursing notes with clerical error attribute, and (4) remove duplicate patient records.

The authors do (1) to maintain consistency in benchmarking with respect to related works, (2) was done because the authors found that for 94% of patients, diagnostic code groups in first admissions overlapped with those in later ones. Furthermore, using only first admissions helps avoid statistical complications that arise from having multiple admissions from same patient, this also helps in decreasing computational requirements without significant loss of information.

=== Text preprocessing
Our text preprocessing steps differs a little bit compared to the FarSight paper. Once the cohort selection has completed, we preprocess the text data in the nursing notes. We do the following: (1) the text is split into individual tokens using NLTK tokens, (2) common stopwords are eliminated using NLTK English stopword corpus, (3) we remove any punctuation marks, (4) text is converted to lowercase, (5) stemming and lemmatization is applied, and (6) tokens appearing in fewer than 10 nursing notes are eliminated.

We deviate from the original paper by omitting medical abbreviation disambiguation. The CARD-2 disambiguation framework used inthe original implementation was not publicly available. While we are unable to directly assess the impact of this omission, we rely on BioCLinicalBERT to implicitly resolve abbreviation disambiguation through its contextualized representations.

=== FarSight Data Aggregation
We apply FarSight's aggregation mechanism to map each nursing note to all ICD-9 diagnostic code groups observed in that patient's admission. This enables detection of disease onset with early symptoms before any formal diagnosis.

=== ICD-9 code grouping
Mapped ICD-9 diagnostic codes into 19 distinct diagonistic groups based on code ranges defined in @tdrdata_icd9_2016. ICD-9 code range of 760-779 corresponding to neonates (age < 15) are not part of our cohort and excluded in this study. Furthermore all reference and supplemental V-codes are grouped into same code group to lower computational complexity to train.

=== BERT embeddings (Clinical Feature Modeling)
We explore two distinct strategies to generate embeddings from BioCLinicalBERT: (1) utilizing [CLS] token representation and implementing mean pooling across all token embeddings. 

We extracted only the final hidden state of the [CLS] token as a 768-dimensional vector representing the entire nursing notes. The [CLS] token is specifically trained during BERT's pretraining to capture sentence-level semantics, i.e. the CLS token gives a summary representation of the entire sequence and is often used for classification tasks in many modeling approaches.

However, given the unstructured and highly variable nature of nursing notes which often contain patient-specific information, we perform a mean pooling across all token embeddings that may offer a more robust representation. This method averages contextual information across the entire sequence, potentially capturing a broader semantic understanding than a single token embedding.

Therefore, we generate two sets of data: one based on [CLS] tokens and the other with mean pooled tokens to perform our downstream task.

== Model description
// – Includes a citation to the original paper
// – Includes link to the original paper’s repo (if
// applicable)
// – Model architecture: layer number/size/type,
// activation function, etc
// – Training objectives: loss function, optimizer,
// weight of each loss term, etc
// – Use LLMs to help with the implementation of the
// model used
// – Others: whether the model is pretrained, Monte
// Carlo simulation for uncertainty analysis, etc

The referred FarSight paper @farsight-orig discusses various models viz. MLP, ConvNet, LSTM, Bi-LSTM, Conv-LSTM, Seg-GRU and evaluate their performance on unstructured clinical nursing notes. In this paper, we chose top 3 performing models from original paper i.e. Conv-LSTM, Bi-LSTM and ConvNet and simple MLP architecture. Conv-LSTM  have consistently highest performance as seen for multiple metrics and on various type of embeddings viz. Doc2Vec, NMF-BoW, NMF-TW etc.. followed by ConvNet and Bi-LSTM. All these architecture models are discussed below:

== Bi-LSTM
LSTM (Long Short-Term Memory) is a type of Recurrent Neural Network (RNN) designed to address the vanishing gradient problem commonly observed in traditional RNNs. 

The LSTM architecture includes a gating mechanism that regulates the flow of information through the network. These gates include:

- *Forget Gate (f):* Decides which information to discard from the previous cell state.
- *Input Gate (i):* Determines which new information to update in the cell state.
- *Cell State (c):* Maintains the memory of the network, updated by the forget and input gates.
- *Output Gate (o):* Controls the output of the current cell state.

The LSTM model processes the input sequence step-by-step, maintaining a current cell state c#sub[t] and a hidden state h#sub[t] at each time step. These states are influenced by the previous cell state c#sub[t-1] and hidden state h#sub[t-1], allowing the model to retain semantic meaning over long sequences. This capability is particularly important for clinical notes, where the meaning of terms is often influenced by preceding terms. However, the LSTM outputs only considers the past inputs for generating output.

Bi-LSTM (Bidirectional Long Short-Term Memory) extends the capabilities of LSTM by processing the input sequence in both forward and backward directions. This allows the model to capture context from both past and future terms, which is particularly beneficial for understanding the semantic meaning of terms in nursing notes.

The Bi-LSTM architecture consists of two LSTM layers:

- *Forward LSTM:* Processes the input sequence from the beginning to the end, capturing past dependencies.
- *Backward LSTM:* Processes the input sequence in reverse, capturing future dependencies.

The outputs from both the forward and backward LSTMs are concatenated at each time step to form a comprehensive representation of the input sequence. 
// This bidirectional approach enables the model to better understand the context of terms, as their meaning often depends on both preceding and succeeding terms.

In the context of clinical nursing notes, where the semantic meaning of terms is influenced by their surrounding context, Bi-LSTM provides a significant advantage over unidirectional LSTMs. By leveraging information from both directions, Bi-LSTM improves the model's ability to make accurate predictions based on the input data.

In our implementation, we have fixed the architecture as shared in @farsight-orig. A schematic overview of the architecture is presented in the accompanying image. The Bi-LSTM model is configured with the following specifications:

- *Number of Layers:* 1
- *Hidden State Size:* 150
- *Embedding Layer:* A fully connected layer is placed before the Bi-LSTM module to reduce the dimensionality of BERT's 768-dimensional contextualized embeddings to 289 while retaining maximum semantic information.
- *Output Layer:* Another fully connected layer is added after the Bi-LSTM module to process the output.

== ConvNet, Convolutional Neural Network
CNN has proven to be an efficient architecture to process image data. CNN utilizes convolving filters (kernels) to extract meaningful features from input data. We extend these capabilities of CNN to textual modality. Each filter is responsible for extracting one feature; multiple filters can be combined to fetch multiple features. 

Under the hood, the input is a 768-dimensional vector derived from BERT embeddings. A convolution operation involving a filter is applied to a window of h terms to produce a new feature. This features are applied to every possible window of terms in embeddings.

The ConvNet architecture used in this study is configured as follows:

- *Input Layer:* Accepts 768-dimensional BERT embeddings and transforms it 289-dimensional while retaining maximum semantic information.
- *Convolutional Layer:* Applies 19 filters of size 3 with stride 1
- *Activation Function:* ReLU is applied after the convolutional layer.
- *Output Layer:* Output feature map is flattened and passed through a fully connected layer to produce the final probabilities across 19 target classes.

This architecture is particularly effective for capturing local dependencies in textual data, making it well-suited for analyzing clinical nursing notes. The ConvNet model complements the Bi-LSTM by focusing on local patterns, while the Bi-LSTM captures long-term dependencies.

== Conv-LSTM
As described in ConvNet, convolutional layer extracts high level features from given BERT embeddings of clinical nursing notes. But it cannot capture long term dependencies in nursing notes. The idea for this architecture is to capture the capabilities of Convolution and LSTM. The hybrid architecture is efficient in capturing high level features as well as retains long term dependencies.

The ConvLSTM architecture used in this study is configured as follows:
- *Input Layer:*  Accepts 768-dimensional BERT embeddings and transforms it 289-dimensional while retaining maximum semantic information.
- *Convolutional Layer:* Applies 19 filters of kernel size 3 on (17 x 17) size input with stride 1 and extracts 19 feature maps
- *Intermediate Linear Layer:* Accepts 19 flattened feature maps and transforms those to 289-dimensional latent space.
- *LSTM:* LSTM module with 1 layer, 300-dimension hidden tensors
- *Output Layer:* Output from LSTM module is passed through a fully connected layer to produce the final probabilities across 19 target classes.