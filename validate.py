# python libraries
import itertools
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from tqdm import tqdm

# pytorch libraries
import torch
import torchvision
import torchvision.transforms.v2 as transforms
from torch.autograd import Variable
from torch.utils.data import DataLoader, Dataset

# sklearn libraries
from sklearn.metrics import confusion_matrix

class CustomDataset(Dataset):
    def __init__(self, dataframe, transform=None):
        self.dataframe = dataframe
        self.transform = transform
    def __len__(self):
        return len(self.dataframe)
    def __getitem__(self, index):
        data = torchvision.io.read_image(self.dataframe['path'][index], torchvision.io.ImageReadMode.RGB)
        label = torch.tensor(int(self.dataframe['label_id'][index]))
        if self.transform:
            data = self.transform(data)
        return data, label

def compute_images_std_mean(paths):
    images = []
    print('Computing mean and standard deviation of whole dataset...')
    for path in tqdm(paths):
        image = torchvision.io.read_image(path, torchvision.io.ImageReadMode.RGB)
        image = transforms.Resize((224, 224))(image)
        images.append(image)
    images = torch.stack(images, axis=3)
    images = images.to(torch.float32) / 255
    return torch.std_mean(images, dim=(1, 2, 3))

def plot_confusion_matrix(cm, classes, normalize=False, title='Confusion matrix', cmap=plt.cm.Blues):

    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(classes))
    plt.xticks(tick_marks, classes, rotation=45)
    plt.yticks(tick_marks, classes)

    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]

    thresh = cm.max() / 2.
    for i, j in itertools.product(range(cm.shape[0]), range(cm.shape[1])):
        plt.text(j, i, cm[i, j],
                 horizontalalignment="center",
                 color="white" if cm[i, j] > thresh else "black")

    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.show()

if __name__ == '__main__':
    device = torch.device('cuda')
    train_dataframe = pd.read_csv('./train.csv')
    validation_dataframe = pd.read_csv('./validation.csv')
    images_paths = list(train_dataframe['path']) + list(validation_dataframe['path'])
    norm_std, norm_mean = compute_images_std_mean(images_paths)
    model = torch.load(f"models/{input('Enter model filename: ')}")
    input_size = 224
    validation_transform = transforms.Compose([transforms.Resize((input_size, input_size)),
                                            transforms.ToDtype(torch.float32, scale=True),
                                            transforms.Normalize(norm_mean, norm_std)])
    validation_set = CustomDataset(validation_dataframe, transform=validation_transform)
    validation_loader = DataLoader(validation_set, batch_size=32, shuffle=False, num_workers=0)

    model = model.to(device)
    model.eval()
    y_label = []
    y_predict = []
    with torch.no_grad():
        for i, data in enumerate(validation_loader):
            images, labels = data
            N = images.size(0)
            images = Variable(images).to(device)
            outputs = model(images)
            prediction = outputs.max(1, keepdim=True)[1]
            y_label.extend(labels.cpu().numpy())
            y_predict.extend(np.squeeze(prediction.cpu().numpy().T))

    confusion_mtx = confusion_matrix(y_label, y_predict)
    class_names = list(set(list(validation_dataframe['label'])))
    plot_labels = []
    for name in class_names:
        abbreviation = ''
        words = name.split()
        for word in words:
            abbreviation += word[0]
        if abbreviation in plot_labels:
            abbreviation.capitalize()
        if abbreviation in plot_labels:
            abbreviation = words[0][0:2] + abbreviation[1:]
        if abbreviation in plot_labels:
            abbreviation.capitalize()
        plot_labels.append(abbreviation)
    plot_confusion_matrix(confusion_mtx, plot_labels)