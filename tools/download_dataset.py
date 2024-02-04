import os
import requests
import threading

def download(name, label, url):
    connection = requests.get(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:71.0) Gecko/20100101 Firefox/71.0'})
    if connection.status_code != 200:
        file = open('bad_urls.txt', 'w+')
        file.writeline(url)
    else:
        if not os.path.exists('dataset/{}'.format(label)):
            os.makedirs('dataset/{}'.format(label))
        file = open('dataset/{}/{}.png'.format(label, name), 'wb')
        file.write(connection.content)
    file.close()
    connection.close()

file = open('fitzpatrick17k.csv')
lines = file.readlines()
file.close()

threads = []
max_threads = 12
line_number = 1
images_downloaded = 0
for line in lines[1:]:
    data = line[:-1].split(',')
    name = data[0]
    label = data[3]
    url = data[7]
    if url == '' or name == '' or label == '':
        file = open('bad_lines.txt', 'w+')
        file.writeline(line_number)
        file.close()
    else:
        if len(threads) == max_threads:
            threads.pop(0).join()
            images_downloaded += 1
            print('Images downloaded: {}/{}'.format(images_downloaded, len(lines) - 1))
        thread = threading.Thread(target=download, args=(name, label, url, ))
        threads.append(thread)
        thread.start()
        
while len(threads) != 0:
    threads.pop(0).join()
    images_downloaded += 1
    print('Images downloaded: {}/{}'.format(images_downloaded, len(lines) - 1))
