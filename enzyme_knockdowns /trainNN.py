'''
train a neural network for representation learning

simulations should be formated in a numpy array where the size of the
first dimension is the number of simulations

TRAINING METHODS
----------------
- triplet loss
	- need to load labels
		labels is a 1d array the corresponding to the simulations
		each simulation is labeled based on which group it corresponds to
		these would be the NN outputs if doing classification
		should NOT be one-hot-encoded. Simply number labels from 0 to nGroups-1
	- set training = 'triplet'
	- does NOT require distortion in DataGenerator(...)

- NT-Xent loss (from SimCLR)
	- does NOT require labels for DataGenerator(...)
	- requires distortion for DataGenerator(...)
		the default of 0.01 is probably sufficient
	set training = 'simclr'


NEURAL NETWORK TYPES
-------------------------
- for a basic multi-layer-perceptron, params = {..., 'structure': 'ffn', ...}
- for 1-dimensional convolutional network, params = {..., 'structure': 'c1d', ...}
- for 2-dimensional convolutional network, params = {..., 'structure': 'c2d', ...}

PARAMS
------
- cnnFilters
	- number of elements is the number of convolutional layers
	- the integer value of each element is the number of features extracted in each conv layer
- kernelSize is the size of the conv kernel
- fullyConnected
	- number of elements is the number of layers in the mlp
	- the integer value of each element is the number of neurons in each layer
	- the final element is the projection layer. If visualizing the representations, use 2 or 3
- hiddenActivation
	- activation function for the conv layers and mlp layers
- outputActivation
	- activation for the final projection layers. Leaves as linear
- droupout
	- probability of randomly turning off a neuron connection during each training step
- learning_rate
	- the learning rate
- patience
	- number of epochs without improvement before stopping early
	- leaving this higher generally leads to a better training, but it takes longer
- batchNorm
	- True or False on using batchNormalization

'''

from genNN import createTrainedModel
from data_generator import DataGenerator
import os
import gc
import numpy as np
import sys

saveFld = 'results/4groups_10kepochs_simCLR' #name of folder that it will save in. 
# n_nn = sys.argv[2]
n_nn = 1

sims_list = [] # to temporarily store individual arrays
labels_list = [] # to temporarily store individual label arrays

z = 0
for i in ['wt', 'kras']:
	for j in ['caf', 'crc']:
		for k in ['20', '40', '60', '80', '100']:
			s = np.loadtxt('allData/'+i+'_'+j+'_'+k+'.csv', delimiter=',')
			
			# Debugging information:
			print(f"Labels for file {i+'_'+j+'_'+k}: {s.shape[0]}")
			
			label_array = np.full((s.shape[0],), z)
			labels_list.append(label_array)
			sims_list.append(s)
		z += 1


sims = np.vstack(sims_list)
labels = np.concatenate(labels_list)

# Debugging information:
print(f"Total shape of sims: {sims.shape}")
print(f"Total shape of labels: {labels.shape}")

# Check mismatch
if sims.shape[0] != labels.shape[0]:
	exit('wrong number of labels')


training = 'simclr'
input_shape = sims[0].shape
batchSize = sims.shape[0]
data = DataGenerator(sims, batchSize, training, distortion=0.01, labels=labels)

params = {'input_shape': input_shape,
		  'structure': 'ffn', 
		  'fullyConnected': [64,2],
		  'hiddenActivation': 'selu', # 'linear'
		  'outputActivation': 'linear',
		  'dropout': 0.0,
		  'learning_rate': 1e-3,
		  'epochs': 10000,
		  'patience': 10000,
		  'batchNorm': False,
		  'training': training}

print()
print('training')
print()
projector, loss = createTrainedModel(params, data)

os.system('mkdir -p ' + saveFld + '/projector')
os.system('mkdir -p ' + saveFld + '/loss')
projector.save(saveFld + '/projector/model_'+str(n_nn))
np.savetxt(saveFld + '/loss/loss_'+str(n_nn)+'.csv', loss, delimiter=',')
