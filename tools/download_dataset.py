import os
import csv
import requests
from concurrent.futures import ThreadPoolExecutor

# Define the number of threads (max 12)
NUM_THREADS = 12

# Define the output directory
OUTPUT_DIR = '../dataset'

# Create the output directory if it doesn't exist
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

def download_image(label, url, filename, extension):
    try:
        # Create a folder for the label if it doesn't exist
        label_dir = os.path.join(OUTPUT_DIR, label)
        if not os.path.exists(label_dir):
            os.makedirs(label_dir)

        # Check if the url is empty
        if url == '':
            print('Error downloading: URL is null')
            return

        # Get the image's full path
        image_path = os.path.join(label_dir, filename + extension)

        # Check if the file already exists
        if os.path.exists(image_path):
            return

        # Get the image content
        response = requests.get(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:71.0) Gecko/20100101 Firefox/71.0'})
        if response.status_code == 200:
            # Save the image
            with open(image_path, 'wb') as f:
                f.write(response.content)
        else:
            print(f'Error downloading {url}: (Status code: {response.status_code})')
    except Exception as e:
        print(f'Error downloading {url}: {e}')

def download_dataset(csv_file):
    with open(csv_file, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        rows = list(reader)

    with ThreadPoolExecutor(max_workers=NUM_THREADS) as executor:
        for row in rows:
            label = row['label']
            url = row['url']
            filename = row['md5hash']
            extension = '.jpg'
            executor.submit(download_image, label, url, filename, extension)
   
download_dataset('../fitzpatrick17k.csv')