================================================================================
GRAPH-AWARE AM BLIND DECONVOLUTION - SIMULATION CODE
================================================================================

This repository contains the MATLAB implementation for the paper:
"Graph-Aware Alternating Minimization for Blind Deconvolution of Graph Filters
and Signals"

Authors: Gal Morgenstern and Tirza Routtenberg
Date: January 2026

================================================================================
OVERVIEW
================================================================================

The code implements a non-convex, graph-aware alternating minimization (AM)
framework for blind deconvolution of graph filters and sparse graph signals.
The implementation compares several sparse recovery methods, including:

  - AM_MGFOC_Delta_1_GBNB_OMP: AM with Multi-GFOC, delta = 1
  - AM_MGFOC_Delta_s_GBNB_OMP: AM with Multi-GFOC, delta = s
  - AM_GBNB: AM with Graph-Based Branch and Bound
  - AM_GBNB_GFOC: AM with GBNB + GFOC correction
  - AM_OMP: AM with Orthogonal Matching Pursuit
  - AM_OMP_GFOC: AM with OMP + GFOC correction
  - AM_L1: AM with l1 constraint (CVX)
  - AM_L1_GFOC: AM with l1 constraint + GFOC correction
  - PR_Inv: Invertible filter baseline [1]

[1] Ye and G. Mateos, "Blind deconvolution on graphs: Exact and stable
recovery," IEEE Transactions on Signal Processing, 2024.

================================================================================
REQUIREMENTS
================================================================================

Software requirements:
  - MATLAB R2020b or later
  - CVX: MATLAB Software for Disciplined Convex Programming
    Download from: http://cvxr.com/cvx/

Before running the simulations, install CVX and add it to the MATLAB path.

================================================================================
QUICK START
================================================================================

1. Run the configured simulations from the repository root:

   >> run_simulations

   Important:
   Existing matching files in Results/ are updated, not overwritten. New trials
   are merged with previous trials using a weighted average. To start from a
   clean run, move, rename, or remove the relevant files from Results/ before
   running the simulations.

2. To repeat the full simulation matrix serially until manually stopped:

   >> run_serial_until_stopped

   Stop the loop with Ctrl-C. Results are saved after each completed
   configuration.

3. Generate averaged plots:

   >> cd PlotFunctions
   >> Main_Plot

   The selected graph types, support types, and x-axis variable can be changed
   inside PlotFunctions/Main_Plot.m.


4. View saved results and figures:

   - Results/      stores .mat result files
   - figures/      stores individual plots
   - avg_figures/  stores plots averaged across selected graph/support settings

================================================================================
DIRECTORY STRUCTURE
================================================================================

Root directory:
  run_simulations.m             Main script for the public simulation matrix
  run_serial_until_stopped.m    Repeats run_simulations until manually stopped
  run_master.m                  Runs all trials for one configuration
  run_slave.m                   Runs one simulation trial
  citation.bib                  BibTeX citation entries for this code

auxiliary/
  call_config.m                 Builds simulation configurations
  generate_data.m               Generates graph filters, signals, and data
  evaluate_results.m            Evaluates F-score, MSE(X), MSE(H), and runtime
  normalize_X_H.m               Normalizes signal and filter estimates

blind_deconvolution/
  Alternating_H_X.m             Main AM framework implementation
  Blind_Invertible.m            Invertible filter baseline method (PR_Inv)
  khatri_rao.m                  Khatri-Rao product utility

sparse_recovery/
  M_GFOC_Delta.m                Multi-support GFOC with confidence parameter
  GFOC.m                        Graph-First-Order Correction
  OMP.m                         Orthogonal Matching Pursuit
  BNB_GB.m                      Graph-Based Branch and Bound

Underlying Graphs/
  brain_data_processed.mat      Processed brain connectivity graph data
  brain_data_66.mat             Raw brain data
  BrainGraphsConstruction.m     Processes the brain graph data
  simulate_sensor_graph.m       Generates sensor network graphs
  simulate_SBM_graph.m          Generates stochastic block model graphs
  generateSBM.m                 SBM utility function

PlotFunctions/
  Main_Plot.m                   Main averaged-plot script
  plot_sensor_supp.m            Sensor-only supplemental plotting script
  PlotAveragedRs.m              Averages compatible result files and plots them
  PlotR.m                       Plots one result structure
  ParseConfigName.m             Parses configuration names from filenames
  ExportLegendOnly.m            Exports standalone legends
  GetSolverStyle.m              Shared solver color/marker styling

Results/
  Contains .mat files with simulation results.
  Naming convention:
  graph_[TYPE]_support_[SUPPORT]_Xaxis_[PARAM]_A.mat

figures/
  Contains individual plots generated from single result files.

avg_figures/
  Contains plots averaged across selected graph/support settings.

================================================================================
SIMULATION CONFIGURATION
================================================================================

Graph types:
  - 'squared': 8 x 8 two-dimensional grid graph, 64 nodes
  - 'erdus-reyni': Erdos-Renyi random graph, 64 nodes, p = 0.06
  - 'sensor': random geometric sensor network, 64 nodes by default
  - 'brain': real brain connectivity graph, 66 nodes

Support types:
  - 'rand': randomly selected support nodes
  - 'rand-pairs': randomly selected neighboring-node pairs

X-axis variables:
  - 'filter-degree': filter degree
  - 'maxeigenvalue': graph max eigenvalue
  - 'graph-size': number of graph nodes
  - 'noise-snr': signal-to-noise ratio
  - 'sparsity': signal sparsity

Default fixed parameters:
  - Signal sparsity: 4 nodes
  - SNR: 50 dB
  - Trials per configuration: 10
  - AM tolerance: 1e-4
  - AM max iterations: 10

Previous results:
  The filter-degree and graph-max-eigenvalue sweeps were run for all graph
  types and both support models.

  The graph-size, sparsity, and noise-SNR sweeps were run for the sensor graph.
  The noise-SNR and sparsity sweeps are not intrinsically limited to sensor
  graphs and can be enabled for other graph models by editing
  run_simulations.m.

  Graph-size sweeps have additional limitations. Brain graphs have fixed size
  in the provided data. For random graph-size studies, stochastic block model
  graphs may be preferable to Erdos-Renyi graphs when the goal is to preserve
  sparse graph structure across graph sizes.

  The graph-size and sparsity sweeps were tested only on a subset of the
  methods. Other methods can be enabled, but runtime may become long,
  especially for MGFOC with larger gamma values.

================================================================================
METRICS
================================================================================

The saved and plotted metrics are:

  - F-score: support recovery quality
  - MSE(X): signal estimation error
  - MSE(H): filter estimation error
  - Runtime: elapsed runtime of the recovery method

Older internal result structures may use names such as MSE_X and MSE_H. In
figures and text, we use the display labels MSE(X) and MSE(H).

================================================================================
RUNTIME AND AVERAGING
================================================================================

The full simulation matrix can take a long time because each configuration
runs multiple trials and several recovery methods, including CVX-based
baselines.

run_master.m averages the trials within each completed configuration and saves
the result to Results/. If a matching result file already exists, the new
trials are merged with the existing file using a weighted average based on the
number of trials. This allows repeated runs to accumulate additional trials.

PlotAveragedRs.m averages compatible result files across selected graph and
support settings before plotting. Compatibility requires matching x-axis
values, metric names, and solver names.

================================================================================
GRAPH CONSTRUCTION
================================================================================

Brain graphs:
  The brain graphs are obtained by binarizing anatomical connectivity matrices.
  An edge is placed wherever the connectivity reaches a threshold set to the
  smallest per-node maximum connectivity, min(max(W)), so that no node is left
  isolated.

Sensor graphs:
  The sensor graphs are random geometric graphs. Nodes are placed at uniformly
  random planar positions and connected whenever their pairwise distance falls
  below a threshold. To enforce a maximum-degree budget, edges incident to
  over-connected nodes are greedily removed while preserving connectivity. The
  construction is repeated until the graph is connected and every node meets
  the degree bound.

Stochastic block model graphs:
  SBM utilities are included for experiments where community structure or
  sparsity-preserving graph-size scaling is desired.

================================================================================
CITATION
================================================================================

If you use this code, please cite the accompanying paper and the software
repository. BibTeX entries are provided in citation.bib.

================================================================================
VERSION HISTORY
================================================================================

v1.0 (January 2026) - Initial public release for the IEEE Signal Processing
Letters submission

================================================================================
