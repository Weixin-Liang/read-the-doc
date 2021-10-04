Getting Started: Download MetaDataset
===============================================


Download MetaDataset Github Repo
------------------------------------
.. raw:: html
   
   <i class="fa fa-github"></i> Download via <a
   href="https://anonymous.4open.science/r/MetaDataset-Distribution-Shift-E613/">anonymous GitHub.</a> 
   A public Github repo will be created after the peer review. 
   <br /> <br />


Downlaod Base Dataset: Visual Genome
------------------------------------
We leverage the natural heterogeneity of Visual Genome and its annotations to construct MetaDataset. We use the pre-processed and cleaned version of Visual Genome by `Hudson and Manning <https://arxiv.org/pdf/1902.09506.pdfL>`_. Download the base dataset as follows: 


- Download image files (~20GB) from: https://nlp.stanford.edu/data/gqa/images.zip

.. code-block:: bash

   wget -c https://nlp.stanford.edu/data/gqa/images.zip


- *[Optional]* Download the annotations provided the base dataset (scene graphs): https://nlp.stanford.edu/data/gqa/sceneGraphs.zip  

.. code-block:: bash

   wget -c https://nlp.stanford.edu/data/gqa/sceneGraphs.zip  


Extract the files. After this step, the base dataset file structure should look like this:

.. code-block:: 

    /your_path/
        allImages/
            images/
                <ID>.jpg
                ...
        sceneGraphs/
            train_sceneGraphs.json
            val_sceneGraphs.json


Generate MetaDataset
------------------------------------
The image IDs for each subset are provided as a Python Dictionary in ``generate_dataset/meta_data/full-candidate-subsets.pkl`` in the Github repo. The Python scpript ``generate_dataset/meta_data/create_metadataset.py`` provides the code for generating the MetaDataset. 

- Specify the following arguments defined in ``generate_dataset/meta_data/Constants.py`` . 

    - The base dataset folder: ``IMAGE_DATA_FOLDER=/your_path/allImages/images/``

    - The destination folder (to be created): ``PYTORCH_DATASET_FOLDER=/data/MetaDataset``

    - Only generate MetaDataset for selected classes. ``ONLY_SELECTED_CLASSES = True``. Change to False to generate the whole meta-dataset; However, that would be very large. 

    - If ``ONLY_SELECTED_CLASSES`` is True, we only generate MetaDataset for the following classes, as specified in the file. 
    
    .. code-block:: python

        SELECTED_CLASSES = [
            'cat', 'dog',
            'bus', 'truck',
            'elephant', 'horse',
            'bowl', 'cup',
            ]
    
    - If ``ONLY_SELECTED_CLASSES`` is False, this argument would be ignored. 

- Run the scpript to generate MetaDataset including the meta-graph for each class. 

.. code-block:: bash

   python create_metadataset.py


The ``meta-graphs`` folder contains the generated meta-graph for each class. 
The ``subsets`` folder contains the image subsets, organized by the subject class. The file structure should look like this:

.. code-block:: 

    generate_dataset/
        meta-graphs/
            cat_graph.jpg
            dog_graph.jpg
            ...
        subsets/
            cat/
                cat(sink)/
                    <ID>.jpg
                    ...
                cat(faucet)/
                    <ID>.jpg
                    ...
            truck/
                truck(airplane)/
                    <ID>.jpg
                    ...

