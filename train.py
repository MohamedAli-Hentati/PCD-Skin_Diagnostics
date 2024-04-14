# python libraries
import datetime
import itertools
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from tqdm import tqdm

# pytorch libraries
import torch
import torchvision
import torchvision.transforms.v2 as transforms
from torch import optim, nn
from torch.autograd import Variable
from torch.utils.data import DataLoader, Dataset
from torchvision import models

# sklearn libraries
from sklearn.metrics import confusion_matrix

# define the device
device = torch.device('cuda')

# this is a multiplier for various variables
multiplier = 0.125

# get the current time
startup_time = datetime.datetime.now().strftime('%Y-%m-%d-%H-%M')

# define a pytorch dataloader for our dataset
class CustomDataset(Dataset):
    def __init__(self, dataframe, static_transform=None, transform=None):
        self.images = []
        self.labels = []
        self.transform = transform
        self.static_transform = static_transform
        for index in range(len(dataframe)):
            image = torchvision.io.read_image(dataframe['path'][index], torchvision.io.ImageReadMode.RGB)
            label = torch.tensor(int(dataframe['label_id'][index]))
            image = Variable(image).to(device)
            label = Variable(label).to(device)
            if self.static_transform:
                image = self.static_transform(image)
            self.images.append(image)
            self.labels.append(label)
    def __len__(self):
        return len(self.images)
    def __getitem__(self, index):
        if self.transform:
            return self.transform(self.images[index]), self.labels[index]
        else:
            return self.images[index], self.labels[index]

# this class is used during training process to calculate the loss and accuracy
class AverageMeter(object):
    def __init__(self):
        self.reset()
    def reset(self):
        self.val = 0
        self.avg = 0
        self.sum = 0
        self.count = 0
    def update(self, val, n=1):
        self.val = val
        self.sum += val * n
        self.count += n
        self.avg = self.sum / self.count

# computing the mean and standard deviation of the three channels on the whole dataset, we should normalize the image from 0-255 to 0-1
def compute_images_std_mean(paths):
    images = []
    print('Computing mean and standard deviation on the whole dataset...')
    for path in tqdm(paths):
        image = torchvision.io.read_image(path, torchvision.io.ImageReadMode.RGB)
        image = transforms.Resize((224, 224))(image)
        images.append(image)
    images = torch.stack(images, axis=3)
    images = images.to(torch.float32) / 255
    return torch.std_mean(images, dim=(1, 2, 3))

def initialize_model(num_classes, feature_extract=False):
    model = models.mobilenet_v3_large(weights=torchvision.models.MobileNet_V3_Large_Weights.IMAGENET1K_V2)
    if feature_extract:
        for param in model.parameters():
            param.requires_grad = False
    num_ftrs = model.classifier[3].in_features
    model.classifier[3] = nn.Linear(num_ftrs, num_classes)
    input_size = 224
    return model, input_size

def train(train_loader, model, criterion, optimizer, epoch):
    model.train()
    train_loss = AverageMeter()
    train_acc = AverageMeter()
    for i, data in enumerate(train_loader):
        images, labels = data
        N = images.size(0)
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        prediction = outputs.max(1, keepdim=True)[1]
        train_acc.update(prediction.eq(labels.view_as(prediction)).sum().item() / N)
        train_loss.update(loss.item())
    print('------------------------------------------------------------------------------------------------------------------')
    print(f'[epoch {epoch}], [train loss {train_loss.avg}], [train acc {train_acc.avg}]')
    print('------------------------------------------------------------------------------------------------------------------')
    return train_loss.avg, train_acc.avg

def validate(val_loader, model, criterion, epoch):
    model.eval()
    val_loss = AverageMeter()
    val_acc = AverageMeter()
    with torch.no_grad():
        for i, data in enumerate(val_loader):
            images, labels = data
            N = images.size(0)
            outputs = model(images)
            prediction = outputs.max(1, keepdim=True)[1]
            val_acc.update(prediction.eq(labels.view_as(prediction)).sum().item() / N)
            val_loss.update(criterion(outputs, labels).item())
    print('------------------------------------------------------------------------------------------------------------------')
    print(f'[epoch {epoch}], [val loss {val_loss.avg}], [val acc {val_acc.avg}]')
    print('------------------------------------------------------------------------------------------------------------------')
    return val_loss.avg, val_acc.avg

# this function prints and plots the confusion matrix. normalization can be applied by setting `normalize=True`.
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

if __name__ == "__main__":
    train_dataframe = pd.read_csv('./train.csv')
    validation_dataframe = pd.read_csv('./validation.csv')

    images_paths = list(train_dataframe['path']) + list(validation_dataframe['path'])
    norm_std, norm_mean = compute_images_std_mean(images_paths)
    print(f'norm_std = {norm_std}\nnorm_mean = {norm_mean}')

    num_classes = max(list(validation_dataframe['label_id'])) + 1

    # initialize the model for this run
    model, input_size = initialize_model(num_classes, feature_extract=False)
    # put the model on the device
    model = model.to(device)
    # training transformations
    train_static_transform = transforms.Compose([transforms.Resize((input_size, input_size)),
                                                 transforms.ToDtype(torch.float32, scale=True),
                                                 transforms.Normalize(norm_mean, norm_std)])
    train_transform = transforms.Compose([transforms.TrivialAugmentWide()])
    # validation transformations
    validation_static_transform = transforms.Compose([transforms.Resize((input_size, input_size)),
                                                      transforms.ToDtype(torch.float32, scale=True),
                                                      transforms.Normalize(norm_mean, norm_std)])
    validation_transform = None
    # define the training set
    training_set = CustomDataset(train_dataframe, static_transform=train_static_transform, transform=train_transform)
    train_loader = DataLoader(training_set, batch_size=int(32 * multiplier), shuffle=True, num_workers=0)
    # same for the validation set:
    validation_set = CustomDataset(validation_dataframe, static_transform=validation_static_transform, transform=validation_transform)
    val_loader = DataLoader(validation_set, batch_size=int(32 * multiplier), shuffle=False, num_workers=0)
    # we use Adam optimizer, use cross entropy loss as our loss function
    optimizer = optim.Adam(model.parameters(), lr=1e-4 * multiplier, weight_decay=1e-5 * multiplier)
    criterion = nn.CrossEntropyLoss().to(device)

    epoch_num = 250
    best_val_acc = 0
    total_loss_train, total_acc_train = [], []
    total_loss_val, total_acc_val = [], []

    for epoch in range(1, epoch_num + 1):
        loss_train, acc_train = train(train_loader, model, criterion, optimizer, epoch)
        loss_val, acc_val = validate(val_loader, model, criterion, epoch)
        total_loss_train.append(loss_train)
        total_acc_train.append(acc_train)
        total_loss_val.append(loss_val)
        total_acc_val.append(acc_val)
        if acc_val > best_val_acc:
            best_val_acc = acc_val
            if best_val_acc > 0.87:
                torch.save(model, f'models/model_{startup_time}_{int(best_val_acc * 100)}.pth')
            print('******************************************************************************************************************')
            print(f'best record: [epoch {epoch}], [val loss {loss_val}], [val acc {acc_val}]')
            print('******************************************************************************************************************')

    fig = plt.figure(num = 2)
    fig1 = fig.add_subplot(2, 1, 1)
    fig2 = fig.add_subplot(2, 1, 2)
    fig1.plot(total_loss_train, label = 'training loss')
    fig1.plot(total_acc_train, label = 'training accuracy')
    fig2.plot(total_loss_val, label = 'validation loss')
    fig2.plot(total_acc_val, label = 'validation accuracy')
    plt.legend()
    plt.show()

    # best model evaluation
    if best_val_acc > 0.87:
        model = torch.load(f'models/model-{startup_time}_{int(best_val_acc * 100)}.pth')
        model.eval()
        y_label = []
        y_predict = []
        with torch.no_grad():
            for i, data in enumerate(val_loader):
                images, labels = data
                N = images.size(0)
                images = Variable(images).to(device)
                outputs = model(images)
                prediction = outputs.max(1, keepdim=True)[1]
                y_label.extend(labels.cpu().numpy())
                y_predict.extend(np.squeeze(prediction.cpu().numpy().T))

        # compute the confusion matrix
        confusion_mtx = confusion_matrix(y_label, y_predict)
        # plot the confusion matrix
        label_counts = validation_dataframe['label'].value_counts()
        labels = label_counts.index.tolist()
        plot_labels = []
        for name in labels:
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