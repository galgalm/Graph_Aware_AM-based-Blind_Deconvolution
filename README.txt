================================================================================
BLIND DECONVOLUTION ON GRAPHS - SIMULATION CODE
================================================================================

This repository contains the MATLAB implementation for the paper:
"Graph-Aware Alternating Minimization for Blind Deconvolution of Sparse Graph Signals"

Author: Dr. Gal Morgenstern & Prof. Tirza Routtenberg 
Date: January 2026

================================================================================
OVERVIEW
================================================================================

This code implements a non-convex, graph-aware alternating minimization (AM) 
framework for blind deconvolution of graph signals and filters. The framework 
compares multiple sparse recovery methods including:

  - AM_MGFOC_Delta_1: AM with Multi-GFOC (confidence parameter δ=1)
  - AM_MGFOC_Delta_s: AM with Multi-GFOC (confidence parameter δ=s)
  - AM_GBNB: AM with Graph-Based Branch and Bound
  - AM_GBNB_GFOC: AM with GBNB + GFOC correction
  - AM_OMP: AM with Orthogonal Matching Pursuit
  - AM_OMP_GFOC: AM with OMP + GFOC correction
  - AM_L1: AM with ℓ₁ constraint (CVX)
  - AM_L1_GFOC: AM with ℓ₁ constraint + GFOC correction
  - PR_Inv: Invertible filter method [1]

[1]] Ye and G. Mateos, “Blind deconvolution on graphs: Exact and stable recovery,”
 IEEE Transactions on Signal Processing, 2024.

================================================================================
REQUIREMENTS
================================================================================

Software Requirements:
  - MATLAB R2020b or later
  - CVX: MATLAB Software for Disciplined Convex Programming
    (Download from: http://cvxr.com/cvx/)

================================================================================
QUICK START
================================================================================

1. Install CVX and add it to your MATLAB path

2. Run all simulations:
   >> run_simulations

3. Generate plots:
   >> cd PlotFunctions
   >> Main_Plot

4. View saved results in the 'Results/' folder
   View generated figures in the 'avg_figures/' folder

================================================================================
DIRECTORY STRUCTURE
================================================================================

Root Directory:
  run_simulations.m      - Main script to run all simulation configurations
  run_master.m           - Master function that runs trials and saves results
  run_slave.m            - Slave function that runs a single trial

auxiliary/
  call_config.m          - Configuration generator for simulation parameters
  generate_data.m        - Generates graph signals and observations
  evaluate_results.m     - Evaluates performance metrics (F-score, MSE, runtime)
  normalize_X_H.m        - Normalizes signals and filters

blind_deconvolution/
  Alternating_H_X.m      - Main AM framework implementation
  Blind_Invertible.m     - Invertible filter baseline method (PR_Inv)
  khatri_rao.m           - Khatri-Rao product utility

sparse_recovery/
  M_GFOC_Delta.m        - Multi-support GFOC with confidence parameter
  GFOC.m                - Graph-First-Order Correction
  OMP.m                 - Orthogonal Matching Pursuit
  BNB_GB.m              - Graph-Based Branch and Bound
  
Underlying Graphs/
  brain_data_processed.mat    - Real brain connectivity graph data
  brain_data_66.mat           - Raw brain data (66 nodes)
  BrainGraphsConstruction.m   - Processes brain graph data
  simulate_sensor_graph.m     - Generates sensor network graphs
  simulate_SBM_graph.m        - Generates stochastic block model graphs
  generateSBM.m              - SBM utility function

PlotFunctions/
  Main_Plot.m           - Main plotting script
  PlotAveragedRs.m      - Plots averaged results across graph types
  PlotR.m               - Plots individual result files
  ParseConfigName.m     - Parses configuration names from filenames
  ExportLegendOnly.m    - Exports figure legends separately

Results/
  Contains .mat files with simulation results
  Naming convention: graph_[TYPE]_support_[SUPPORT]_Xaxis_[PARAM]_A.mat

avg_figures/
  Contains generated plots averaging results across multiple graph types

figures/
  legend_two_lines.eps  - Legend for final paper figures

================================================================================
SIMULATION CONFIGURATION
================================================================================

Graph Types:
  - 'squared': 8×8 2D grid graph (64 nodes)
  - 'erdus-reyni': Erdős-Rényi random graph (64 nodes, p=0.06)
  - 'sensor': Random geometric sensor network (64 nodes, radius=1.7)
  - 'brain': Real brain connectivity graph (66 nodes)

Support Types:
  - 'rand': 4 randomly selected nodes
  - 'rand-pairs': 2 randomly selected neighbor-node pairs (4 nodes total)

X-Axis Variables (Varying Parameters):
  - 'filter-degree': Filter degree ∈ {1, 2, 3, 4, 5}
  - 'maxeigenvalue': Maximum eigenvalue ∈ {1, 3, 6, 9, 12}

Fixed Parameters:
  - Signal sparsity: 4 nodes
  - SNR: 50 dB
  - Trials per configuration: 10
  - AM tolerance: 1e-4
  - AM max iterations: 10
=======================================
CITATION
================================================================================

If you use this code, please cite:

To be added later. 

================================================================================
VERSION HISTORY
================================================================================

v1.0 (January 2026) - Initial release for IEEE Signal Processing Letters submission

================================================================================

