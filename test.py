import os
import torch
from PIL import Image
from torchvision import models, transforms
from torchvision.transforms.functional import equalize

model = torch.load('models/mobilenet_v2_test.pth')
model.to('cpu')
model.eval()
norm_mean = [0.6286657, 0.46822867, 0.41442943]
norm_std = [0.21822813, 0.19549523, 0.20002359]

os.chdir('dataset')
path = input('Input an image path or a path to change directory: ')
while True:
    if os.path.isfile(path):
        image = Image.open(path).convert('RGB')
        transform = transforms.Compose([transforms.Resize((224,224)), transforms.ToTensor(), transforms.Normalize(norm_mean, norm_std)])
        input_tensor = transform(image).unsqueeze(0)
        output_tensor = model.forward(input_tensor)
        print(output_tensor)
    elif os.path.isdir(path):
        os.chdir(path)
    else:
        break
    path = input('Input an image path or a path to change directory: ')
