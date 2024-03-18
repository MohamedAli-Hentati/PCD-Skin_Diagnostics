import os
import random as r
import pandas as pd

min_picture_number = 200
os.chdir('../dataset/')

pathology_id = 0
train_csv_dict = {'md5': [], 'pathology': [], 'pathology_id': [], 'path': []}
val_csv_dict = {'md5': [], 'pathology': [], 'pathology_id': [], 'path': []}
for pathology in os.listdir():
    path = os.path.curdir + '/' + pathology
    if len(os.listdir(path)) > min_picture_number:
        for md5 in os.listdir(path):
            if r.randint(0, 4) == 2:
                val_csv_dict['md5'].append(md5)
                val_csv_dict['pathology'].append(pathology)
                val_csv_dict['pathology_id'].append(pathology_id)
                val_csv_dict['path'].append('./dataset/' + pathology + '/' + md5)
            else:
                train_csv_dict['md5'].append(md5)
                train_csv_dict['pathology'].append(pathology)
                train_csv_dict['pathology_id'].append(pathology_id)
                train_csv_dict['path'].append('./dataset/' + pathology + '/' + md5)
        pathology_id += 1

os.chdir('..')
train_df = pd.DataFrame.from_dict(train_csv_dict)
val_df = pd.DataFrame.from_dict(val_csv_dict)
train_df.to_csv("train.csv")
val_df.to_csv("val.csv")
