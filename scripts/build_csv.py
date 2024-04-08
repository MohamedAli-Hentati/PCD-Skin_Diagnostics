import os
import random as r
import pandas as pd

MAX_LABELS = 12

os.chdir('../dataset/')

train_csv_dict = {'filename': [], 'label': [], 'label_id': [], 'path': []}
validation_csv_dict = {'filename': [], 'label': [], 'label_id': [], 'path': []}

label_size = []
for label in os.listdir(os.curdir):
    label_size.append((len(os.listdir(label)), label))
labels = [data[1] for data in sorted(label_size, reverse=True)]
labels = labels[:MAX_LABELS]

label_id = 0
for label in labels:
    path = f'{os.path.curdir}/{label}'
    files = os.listdir(path)
    r.shuffle(files)
    split_point = int(len(files) * 0.75)
    train_files = files[:split_point]
    validation_files = files[split_point:]
    for filename in train_files:
        train_csv_dict['filename'].append(filename)
        train_csv_dict['label'].append(label)
        train_csv_dict['label_id'].append(label_id)
        train_csv_dict['path'].append(f'./dataset/{label}/{filename}')
    for filename in validation_files:
        validation_csv_dict['filename'].append(filename)
        validation_csv_dict['label'].append(label)
        validation_csv_dict['label_id'].append(label_id)
        validation_csv_dict['path'].append(f'./dataset/{label}/{filename}')
    label_id += 1

os.chdir('..')

train_df = pd.DataFrame.from_dict(train_csv_dict)
validation_df = pd.DataFrame.from_dict(validation_csv_dict)
train_df.to_csv("train.csv")
validation_df.to_csv("validation.csv")