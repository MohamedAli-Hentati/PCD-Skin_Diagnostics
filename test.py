import os
import pandas as pd
import random as r
import torch
import torchvision
import torchvision.transforms.v2 as transforms

def compute_images_std_mean(paths):
    images = []
    print('Computing mean and standard deviation on the whole dataset...')
    for path in paths:
        image = torchvision.io.read_image(path, torchvision.io.ImageReadMode.RGB)
        image = transforms.Resize((224, 224))(image)
        images.append(image)
    images = torch.stack(images, axis=3)
    images = images.to(torch.float32) / 255
    return torch.std_mean(images, dim=(1, 2, 3))

train_dataframe = pd.read_csv('./train.csv')
validation_dataframe = pd.read_csv('./validation.csv')
images_paths = list(train_dataframe['path']) + list(validation_dataframe['path'])
norm_std, norm_mean = compute_images_std_mean(images_paths)
print(f'norm_std = {norm_std.tolist()}\nnorm_mean = {norm_mean.tolist()}')
model = torch.load(f"models/{input('Enter model filename: ')}")
model.to('cpu')
model.eval()
input_size = 224

label_counts = validation_dataframe['label'].value_counts()
labels = label_counts.index.tolist()
abbreviations = []
for name in labels:
    abbreviation = ''
    words = name.split()
    for word in words:
        abbreviation += word[0]
    if abbreviation in abbreviations:
        abbreviation.capitalize()
    if abbreviation in abbreviations:
        abbreviation = words[0][0:2] + abbreviation[1:]
    if abbreviation in abbreviations:
        abbreviation.capitalize()
    abbreviations.append(abbreviation)

label = input('Choose a label to test: ')
while label in os.listdir('./dataset'):
    filenames = os.listdir(f'./dataset/{label}')
    r.shuffle(filenames)
    for filename in filenames[:5]:
        print(f'./dataset/{label}/{filename}:')
        image = torchvision.io.read_image(f'./dataset/{label}/{filename}', torchvision.io.ImageReadMode.RGB)
        transform = transforms.Compose([transforms.Resize((input_size, input_size)),
                                        transforms.ToDtype(torch.float32, scale=True),
                                        transforms.Normalize(norm_mean, norm_std)])
        input_tensor = transform(image)
        output_tensor = torch.nn.functional.softmax(model(input_tensor.unsqueeze(0)), dim=1)
        output_tensor = torch.squeeze(output_tensor)
        probabilities = [f'{round(output * 100, 2)}% ' for output in output_tensor.tolist()]
        for i in range(max(list(validation_dataframe['label_id'])) + 1):
            print(f'{abbreviations[i]}:\t{probabilities[i]}')
    label = input('Choose a label to test: ')