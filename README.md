# Merging Metabolic Modeling and Imaging for Screening Therapeutic Targets in Colorectal Cancer

## Table of Contents
- [Introduction](#introduction)
- [Authors](#authors)
- [Prerequisites](#prerequisites)
- [Files](#files)

## Introduction
**Cancer-associated fibroblasts (CAFs)** play a key role in metabolic reprogramming and are well-established contributors to drug resistance in **colorectal cancer (CRC)**. To exploit this metabolic crosstalk, we integrated a **systems biology** approach that identified key metabolic targets in a **data-driven** method and validated them experimentally. This process involved high-throughput computational screening to investigate the effects of enzyme perturbations predicted by a computational model of CRC metabolism to understand **system-wide effects** efficiently. Our results highlighted hexokinase (HK) as one of the crucial targets, which subsequently became our focus for **experimental validation** using **patient-derived tumor organoids (PDTOs)**. Through metabolic imaging and viability assays, we found that PDTOs cultured in CAF conditioned media exhibited increased sensitivity to HK inhibition. Our approach emphasizes the critical role of **integrating computational and experimental techniques** in exploring and exploiting **CRC-CAF crosstalk**.

<div align="center">
  <img src="/images/graphical_abstract.png" alt="summary image" width="500" height=300">
</div>

## Authors
Niki Tavakoli<sup>1+</sup>, Emma J. Fong<sup>2+</sup>, Abigail Coleman<sup>2</sup>, Yu-Kai Huang<sup>2</sup>, Mathias Bigger<sup>2,3</sup>, Michael E. Doche<sup>2</sup>, Seungil Kim<sup>2</sup>, Heinz-Josef Lenz<sup>6</sup>, Nicholas A. Graham<sup>3</sup>, Paul Macklin<sup>4</sup>, Stacey D. Finley<sup>1,3,5,*</sup>, Shannon M. Mumenthaler<sup>1,2,6,\*</sup>   

<sup>1</sup>Alfred E. Mann Department of Biomedical Engineering, University of Southern California, Los Angeles, CA, 90089, USA  
<sup>2</sup>Ellison Institute of Technology, Los Angeles, CA, 90064, USA   
<sup>3</sup>Mork Family Department of Chemical Engineering and Materials Science, University of Southern California, Los Angeles, CA, 90089, USA   
<sup>4</sup>Department of Intelligent Systems Engineering, Indiana University, Bloomington, IN, 46202, USA  
<sup>5</sup>Department of Quantitative and Computational Biology, University of Southern California, Los Angeles, CA, 90089, USA  
<sup>6</sup>Division of Medical Oncology, Norris Comprehensive Cancer Center, University of Southern California, Los Angeles, CA, 90033, USA  
<sup>+</sup>Denotes co-first authors  
<sup>\*</sup>Co-correspondence: sfinley@usc.edu (S.D.F.), smumenthaler@eit.org (S.M.)  





### Files

#### Enzyme Knockdowns 
- ` 📁 enzyme_knockdowns ` : contains all of the code for performing partial enzyme knockdowns for all cell conditions
  - ` 📁 baselineCode ` : contains the code developed by [Wang et al. (2022)](https://www.sciencedirect.com/science/article/pii/S1096717621001774?via%3Dihub), which employs upFBA to predict the network's flux distributions based on the constraints outlined in their study.
  - ` 📁 baselineCode ` : contains the outputted data from `run_upFBA_model.m` in `baselineCode`. 

- `📜 gene_knockdowns.m` : a script that sets up the partial enzyme knockdowns for all cell conditions.
- `📜 main_gene_knockdowns.m` : a script that executes `gene_knockdowns.m`.
---
#### Representation Learning 
- ` 📁 representation_learning ` : contains all of the code for performing representation learning on the the data from `📜 gene_knockdowns.m`.
  - `📜 trainNN.py ` : a script that loads in the data, defines the neural network architecture, specifies the loss function and optimizer, and runs the training loop where the model learns from the training data.
  - `📜 genNN.py ` : a script that generates outputs using the trained neural network.
  - `📜 data_generator.py ` : a script designed to generate / preprocess data.
