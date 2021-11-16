import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import gpplot as gpp
import anchors
import core_functions as fns
from poola import core as pool

from config import DATA_FILE, PDNA, CONTROLS, TREATMENTS

# Code based off of SARS-CoV-2-meta-analysis/Sanjana_Re-analysis_v3.ipynb

### QC Functions ###
def qc(pDNA_lfc, lfc_filename):
  gpp.set_aesthetics(palette='Set2')

  #Plot population distributions of log-fold changes
  fns.lfc_dist_plot(pDNA_lfc, initial_id = 'control', res_id = 'treatment', filename = lfc_filename, figsize = (10,4))

  # TODO: Control Name vs. initial id, control, treatment, etc
  # fns.control_dist_plot(pDNA_lfc, initial_id = 'control', res_id = 'treatment', control_name=['dummyguide'], filename = 'control_dist')

  # TODO: Essential / Non-essential
  # roc_auc(pDNA_lfc)

def roc_auc(pDNA_lfc):
  ess_genes, non_ess_genes = fns.get_gene_sets()

  tp_genes = ess_genes.loc[:, 'Gene Symbol'].to_list()
  fp_genes = non_ess_genes.loc[:, 'Gene Symbol'].to_list()

  control_col = [col for col in pDNA_lfc.columns if 'control' in col]

  roc_auc, roc_df = pool.get_roc_aucs(pDNA_lfc, tp_genes, fp_genes, gene_col = 'Gene Symbol', score_col=control_col)

  fig,ax=plt.subplots(figsize=(6,6))
  ax=sns.lineplot(data=roc_df, x='fpr',y='tpr', ci=None, label = 'Control,' + str(round(roc_auc,2)))

  plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
  plt.title('ROC-AUC')
  plt.xlabel('False Positive Rate (non-essential)')
  plt.ylabel('True Positive Rate (essential)')

# Rename arrays to nicer names for output files
def rename(arr):
  return str(arr).replace('[', '').replace(']', '').replace("'", '').replace(',', '_').replace('.fastq', '')

### Main code ###
def process():
  # Load in all count file
  counts = pd.read_csv(DATA_FILE, sep = '\t')

  # Filter out unnecessary columns
  TO_KEEP = ['Gene', 'sgRNA', PDNA] + CONTROLS + TREATMENTS
  counts = counts[TO_KEEP]

  # Rename some columns to more useful names
  counts = counts.rename(columns={'Gene': 'Gene Symbol', 'sgRNA':'Guide', PDNA: 'pDNA'})

  # Rename control columns to contain the suffix "_control"
  for control in CONTROLS:
    counts = counts.rename(columns={ control: control + "_control" })

  # Rename treatment columns to contain the suffix "_treatment"
  for treatment in TREATMENTS:
    counts = counts.rename(columns={ treatment: treatment + "_treatment" })

  # Remove first 2 cols (Guide + Gene) and calculate lognorm on remaining columns
  cols = counts.columns[2:].to_list()
  lognorms = fns.get_lognorm(counts.dropna(), cols = cols)

  #Calculate log-fold change relative to pDNA
  target_cols = list(lognorms.columns[-2:])

  # Calculate lfc
  pDNA_lfc = fns.calculate_lfc(lognorms,target_cols)

  # Quality Control
  qc(pDNA_lfc, rename(CONTROLS) + '_' + rename(TREATMENTS) + '_lfc')

  ## Calculate z-scores of lfc residuals ##

  # Remove Gene column
  lfc_df = pDNA_lfc.copy().drop(['Gene Symbol'], axis = 1)
  lfc_df = lfc_df.dropna()

  # Calculate guide residuals
  guide_residuals_lfcs, all_model_info, model_fit_plots = fns.run_guide_residuals(lfc_df, initial_id = 'control', res_id = 'treatment')

  # Make a mapping of Guides -> Genes from input data
  guide_mapping = pDNA_lfc[['Guide', 'Gene Symbol']]

  # Calculate gene residuals
  gene_residuals = anchors.get_gene_residuals(guide_residuals_lfcs, guide_mapping)
  print(gene_residuals)

  # Write residuals to file in output folder
  gene_residuals.to_csv('output/' + rename(CONTROLS) + '_' + rename(TREATMENTS) + '_residuals.csv')

# Run main function
process()
