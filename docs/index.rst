MetaDataset: A Dataset of Datasets for Evaluating Distribution Shifts and Training Conflicts
====================================================================================================

.. raw:: html
   
   <i class="fa fa-github"></i> View on and Install via <a
   href="https://anonymous.4open.science/r/MetaDataset-Distribution-Shift-E613/">anonymous GitHub.</a> 
   A public Github repo will be created after the peer review. 
   <br /> <br />

Abstract
----------------
*Understanding the performance of machine learning model across diverse data distributions is critically important for reliable applications. Motivated by this, there is a growing focus on curating benchmark datasets that capture distribution shifts. While valuable, the existing benchmarks are limited in that many of them only contain a small number of shifts and they lack systematic annotation about what is different across different shifts. We present MetaDataset---a collection of 12,868 sets of natural images across 410 classes---to address this challenge. We leverage the natural heterogeneity of Visual Genome and its annotations to construct MetaDataset. The key construction idea is to cluster images using its metadata, which provides context for each image (e.g. cats with cars or cats in bathroom) that represent distinct data distributions. MetaDataset has two important benefits: first it contains orders of magnitude more natural data shifts than previously available. Second, it provides explicit explanations of what is unique about each of its data sets and a distance score that measures the amount of distribution shift between any two of its data sets. We demonstrate the utility of MetaDataset in benchmarking several recent proposals for training models to be robust to data shifts. We find that the simple empirical risk minimization performs the best when shifts are moderate and no method had a systematic advantage for large shifts. We also show how MetaDataset can help to visualize conflicts between data subsets during model training.*


What is :samp:`MetaDataset`?
----------------
The :samp:`MetaDataset` is a collection of subsets of data together with an annotation graph that explains the similarity/distance between two subsets (edge weight) as well as what is unique about each subset (node metadata). For each class, say “cat”, we have many subsets of cats, and we can think of each subset as a node in the graph. Each subset corresponds to “cat” in a different context: e.g. “cat with sink” or “cat with fence”. The context of each subset is the node metadata. The “cat with sink” subset is more similar to “cat with faucet” subset because there are many images that contain both sink and faucet. This similarity is the weight of the node; higher weight means the contexts of the two nodes tend to co-occur in the same data. 


How can we use :samp:`MetaDataset`?
----------------
It is a flexible framework to generate a large number of real-world distribution shifts that are well-annotated and controlled. For each class of interest, say ``cats'', we can use the meta-graph of cats to identify a collection of cats nodes for training (e.g. cats with bathroom related contexts) and a collection of cats nodes for out-of-domain evaluation (e.g. cats in outdoor contexts). Our meta-graph tells us exactly what is different between the train and test domains (e.g. bathroom vs. outdoor contexts), and it also specifies the similarity between the two contexts via graph distance. That makes it easy to carefully modulate the amount of distribution shift. For example, if we use cats-in-living-room as the test set, then this is an smaller distribution shift.  


- `Code <https://github.com/MadryLab/robust_representations>`_  for
  "Learning Perceptually-Aligned Representations via Adversarial Robustness"
  [EIS+19]_ 
- `Code <https://github.com/MadryLab/robustness_applications>`_ for
  "Image Synthesis with a Single (Robust) Classifier" [STE+19]_
- `Code <https://github.com/MadryLab/BREEDS-Benchmarks>`_ for
  "BREEDS: Benchmarks for Subpopulation Shift" [STM20]_

We demonstrate how to use the library in a set of walkthroughs and our API
reference. Functionality provided by the library includes:

- Training and evaluating standard and robust models for a variety of
  datasets/architectures using a :doc:`CLI interface
  <example_usage/cli_usage>`. The library also provides support for adding
  :ref:`custom datasets <using-custom-datasets>` and :ref:`model architectures
  <using-custom-archs>`.

.. code-block:: bash

   python -m robustness.main --dataset cifar --data /path/to/cifar \
      --adv-train 0 --arch resnet18 --out-dir /logs/checkpoints/dir/

- Performing :doc:`input manipulation
  <example_usage/input_space_manipulation>` using robust (or standard)
  models---this includes making adversarial examples, inverting representations,
  feature visualization, etc. The library offers a variety of optimization
  options (e.g. choice between real/estimated gradients, Fourier/pixel basis,
  custom loss functions etc.), and is easily extendable.

.. code-block:: python
   
   import torch as ch
   from robustness.datasets import CIFAR
   from robustness.model_utils import make_and_restore_model

   ds = CIFAR('/path/to/cifar')
   model, _ = make_and_restore_model(arch='resnet50', dataset=ds, 
                resume_path='/path/to/model', state_dict_path='model')
   model.eval()
   attack_kwargs = {
      'constraint': 'inf', # L-inf PGD 
      'eps': 0.05, # Epsilon constraint (L-inf norm)
      'step_size': 0.01, # Learning rate for PGD
      'iterations': 100, # Number of PGD steps
      'targeted': True # Targeted attack
      'custom_loss': None # Use default cross-entropy loss
   }

   _, test_loader = ds.make_loaders(workers=0, batch_size=10)
   im, label = next(iter(test_loader))
   target_label = (label + ch.randint_like(label, high=9)) % 10
   adv_out, adv_im = model(im, target_label, make_adv, **attack_kwargs)

- Importing :samp:`robustness` as a package, which allows for easy training of
  neural networks with support for custom loss functions, logging, data loading,
  and more! A good introduction can be found in our two-part walkthrough
  (:doc:`Part 1 <example_usage/training_lib_part_1>`, :doc:`Part 2
  <example_usage/training_lib_part_2>`).

.. code-block:: python

   from robustness import model_utils, datasets, train, defaults
   from robustness.datasets import CIFAR

   # We use cox (http://github.com/MadryLab/cox) to log, store and analyze 
   # results. Read more at https//cox.readthedocs.io.
   from cox.utils import Parameters
   import cox.store

   # Hard-coded dataset, architecture, batch size, workers
   ds = CIFAR('/path/to/cifar')
   m, _ = model_utils.make_and_restore_model(arch='resnet50', dataset=ds)
   train_loader, val_loader = ds.make_loaders(batch_size=128, workers=8)

   # Create a cox store for logging
   out_store = cox.store.Store(OUT_DIR)

   # Hard-coded base parameters
   train_kwargs = {
       'out_dir': "train_out",
       'adv_train': 1,
       'constraint': '2',
       'eps': 0.5,
       'attack_lr': 1.5,
       'attack_steps': 20
   }
   train_args = Parameters(train_kwargs)

   # Fill whatever parameters are missing from the defaults
   train_args = defaults.check_and_fill_args(train_args,
                           defaults.TRAINING_ARGS, CIFAR)
   train_args = defaults.check_and_fill_args(train_args,
                           defaults.PGD_ARGS, CIFAR)

   # Train a model
   train.train_model(train_args, m, (train_loader, val_loader), store=out_store)

Citation
--------
If you use this library in your research, cite it as
follows:

.. code-block:: bibtex
   
   @misc{robustness,
      title={Robustness (Python Library)},
      author={Logan Engstrom and Andrew Ilyas and Shibani Santurkar and Dimitris Tsipras},
      year={2019},
      url={https://github.com/MadryLab/robustness}
   }

*(Have you used the package and found it useful? Let us know!)*. 

Walkthroughs
------------

.. toctree::
   example_usage/cli_usage
   example_usage/input_space_manipulation
   example_usage/training_lib_part_1
   example_usage/training_lib_part_2
   example_usage/custom_imagenet
   example_usage/breeds_datasets
   example_usage/changelog

API Reference
-------------

We provide an API reference where we discuss the role of each module and
provide extensive documentation.

.. toctree::
   api


Contributors
-------------
- `Andrew Ilyas <https://twitter.com/andrew_ilyas>`_
- `Logan Engstrom <https://twitter.com/logan_engstrom>`_
- `Shibani Santurkar <https://twitter.com/ShibaniSan>`_
- `Dimitris Tsipras <https://twitter.com/tsiprasd>`_

.. [EIS+19] Engstrom L., Ilyas A., Santurkar S., Tsipras D., Tran B., Madry A. (2019). Learning Perceptually-Aligned Representations via Adversarial Robustness. arXiv, arXiv:1906.00945 

.. [STE+19] Santurkar S., Tsipras D., Tran B., Ilyas A., Engstrom L., Madry A. (2019). Image Synthesis with a Single (Robust) Classifier. arXiv, arXiv:1906.09453

.. [STM20] Santurkar S., Tsipras D., Madry A. (2020). : BREEDS: Benchmarks for Subpopulation Shift. arXiv, arXiv:2008.04859
