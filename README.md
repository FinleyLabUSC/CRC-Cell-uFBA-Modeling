# Merging Metabolic Modeling and Imaging for Screening Therapeutic Targets in Colorectal Cancer

## Introduction
Cancer-associated fibroblasts (CAFs) play a key role in metabolic reprogramming and are well-established contributors to drug resistance in colorectal cancer (CRC). To exploit this metabolic crosstalk, we integrated a systems biology approach that identified key metabolic targets in a data-driven method and validated them experimentally. This process involved high-throughput computational screening to investigate the effects of enzyme perturbations predicted by a computational model of CRC metabolism to understand system-wide effects efficiently. Our results highlighted hexokinase (HK) as one of the crucial targets, which subsequently became our focus for experimental validation using patient-derived tumor organoids (PDTOs). Through metabolic imaging and viability assays, we found that PDTOs cultured in CAF conditioned media exhibited increased sensitivity to HK inhibition. Our approach emphasizes the critical role of integrating computational and experimental techniques in exploring and exploiting CRC-CAF crosstalk.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [File](#files)
- [Authors](#authors)
- [Acknowledgments](#acknowledgments)

### Files
- ` 📁 enzyme_knockdowns ` : contains all of the code for performing partial enzyme knockdowns for all cell conditions
  - ` 📁 baselineCode ` : contains the code developed by [Wang et al. (2022)](https://www.sciencedirect.com/science/article/pii/S1096717621001774?via%3Dihub), which employs upFBA to predict the network's flux distributions based on the constraints outlined in their study.
  - ` 📁 baselineCode ` : contains the outputted data from `run_upFBA_model.m`. 

