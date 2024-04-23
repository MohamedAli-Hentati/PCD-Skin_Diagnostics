import requests

requests.packages.urllib3.disable_warnings(category=requests.packages.urllib3.exceptions.InsecureRequestWarning)

url = 'https://skindiagnostics.ddns.net/chatbot'
token = str(input('token: '))

while True:
    response = requests.get(url, headers={'token': token, 'message': str(input('Message: '))}, verify=False)
    print(response.text, '\n')
