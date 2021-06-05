#!/bin/bash
conda activate py37
make html && git add . && git commit -m "update" && git push
Running Sphinx v2.2.0