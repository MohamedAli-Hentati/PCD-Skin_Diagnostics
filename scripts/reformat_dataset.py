import os
import hashlib
from PIL import Image

def reformat(image_path):
    with open(image_path, 'rb') as file:
        md5 = hashlib.md5(file.read()).hexdigest()
    new_image_path = os.path.join(os.path.dirname(image_path), md5 + os.path.splitext(image_path)[1])
    os.rename(image_path, new_image_path)

for label in os.listdir('../dataset'):
    print(label.capitalize())
    for image_path in os.listdir(f'../dataset/{label}'):
        reformat(f'../dataset/{label}/{image_path}')