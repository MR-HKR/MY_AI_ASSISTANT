import requests

url = 'https://www.bbc.com/news'

response = requests.get('https://www.bbc.com/news')

with open('html.txt','w') as f:
    f.write(response.text)
    