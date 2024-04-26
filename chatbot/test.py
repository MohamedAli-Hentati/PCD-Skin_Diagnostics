import requests

requests.packages.urllib3.disable_warnings(category=requests.packages.urllib3.exceptions.InsecureRequestWarning)

url = 'https://skindiagnostics.ddns.net/chatbot/getConversation'
token = str(input('token: '))

response = requests.get(url, headers={'token': token}, verify=False)
print(response.text, '\n')

