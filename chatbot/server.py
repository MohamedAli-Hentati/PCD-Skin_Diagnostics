import time, json, pickle, socket, threading, firebase_admin, requests
from firebase_admin import auth
from flask import Flask, request
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from torch import bfloat16
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, ConversationalPipeline, Conversation, pipeline

class ConversationsManager:
    def __init__(self, chatbot: ConversationalPipeline, filename: str = 'persistance.bin'):
        self.chatbot = chatbot
        self.filename = filename
        try:
            with open(self.filename, 'rb') as file:
                self.data = pickle.load(file)
        except:
            self.data = {}
    def __del__(self):
        with open(self.filename, 'wb') as file:
            pickle.dump(self.data, file)
    def user_has_conversation(self, uid: str) -> bool:
        return uid in self.data.keys()
    def create_conversation(self, uid: str, first_message: str) -> None:
        if not self.user_has_conversation(uid):
            new_conversation = Conversation(first_message, conversation_id=uid)
            self.data[uid] = {
                'conversation': new_conversation,
                'created': int(time.time())
            }
    def add_message(self, uid: str, message: str) -> None:
        if self.user_has_conversation(uid):
            self.data[uid]['conversation'].add_message({'role': 'user', 'content': message})
        else:
            self.create_conversation(uid, message)
    def get_conversation(self, uid: str) -> Conversation | None:
        if self.user_has_conversation(uid):
            return self.data[uid]['conversation']
        else:
            return None
    def delete_conversation(self, uid: str) -> None:
        if self.user_has_conversation(uid):
            del self.data[uid]
    def generate_response(self, uid: str) -> str | None:
        if self.user_has_conversation(uid) and self.get_conversation(uid).messages[-1]['role'] == 'user':
            self.data[uid]['conversation'] = self.chatbot(self.data[uid]['conversation'])
            return self.data[uid]['conversation'].messages[-1]['content']
        else:
            return None

def main():

    # Define the model name/path
    model_name = 'mistralai/Mistral-7B-Instruct-v0.2'

    # Quantization configuration
    bnb_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_quant_type='nf4',
        bnb_4bit_use_double_quant=True,
    )

    # Load the model
    print(f'Loading {model_name}...')
    model = AutoModelForCausalLM.from_pretrained(
        pretrained_model_name_or_path=model_name,
        quantization_config=bnb_config,
        torch_dtype=bfloat16,
        device_map='auto',
        trust_remote_code=True,
    )

    # Load the tokenizer
    tokenizer = AutoTokenizer.from_pretrained(
        pretrained_model_name_or_path=model_name
    )

    # Create a conversational pipeline
    pipe = pipeline(
        task='conversational',
        model=model,
        tokenizer=tokenizer,
        device_map='auto',
        framework='pt'
    )

    # Create the conversations manager
    manager = ConversationsManager(pipe)

    # Function that keeps the DDNS updated
    def ddns_update_loop():
        file = open('ddns-config.json', 'r')
        ddns_config = json.load(file)
        email = ddns_config['email']
        password = ddns_config['password']
        hostname = ddns_config['hostname']
        current_ip = None
        while True:
            try:
                ip = requests.get('https://api.ipify.org').text
                if ip != current_ip:
                    url = f'https://{email}:{password}@dynupdate.no-ip.com/nic/update?hostname={hostname}&myip={ip}'
                    requests.get(url)
                    current_ip = ip
                    print(f' * DDNS updated to {ip}')
            except:
                print(' * Failed to update DDNS')
                pass
            time.sleep(30)

    # Start the DDNS update function in a separate thread
    ddns_updater = threading.Thread(target=ddns_update_loop)
    ddns_updater.daemon = True
    ddns_updater.start()

    # Firebase configuration
    credential = firebase_admin.credentials.Certificate('firebase-config.json')
    firebase_admin.initialize_app(credential)

    # Function that verifies a token against the Firebase Auth API and returns the user's id if it's valid
    def verify_token(token):
        try:
            decoded_token = auth.verify_id_token(token)
            uid = decoded_token['uid']
            return uid
        except:
            return None

    # Flask configuration
    server = Flask(__name__)
    limiter = Limiter(
        key_func=get_remote_address,
        app=server,
        storage_uri='memory://',
        default_limits=['5/minute']
    )

    def error(header: str, message: str, code: int) -> str:
        html = f'''
            <!doctype html>
            <html lang=en>
            <title>{code} {header}</title>
            <h1>{header}</h1>
            <p>{message}</p>
            </html>
        '''
        return html

    @server.route('/')
    @limiter.limit('5/minute')
    def root():
        return error('Not Found', 'The requested URL was not found on the server.', 404), 404

    @server.route('/<path>')
    @limiter.limit('5/minute')
    def other(path):
        return error('Not Found', 'The requested URL was not found on the server.', 404), 404

    @server.route('/chatbot', methods=['GET', 'DELETE'])
    @limiter.limit('20/minute')
    def chatbot():
        try:
            token = request.headers['token']
            uid = verify_token(token)
            if uid == None:
                return error('Unauthorized Access', 'Provided token is unauthorized.'), 400
            if request.method == 'GET':
                message = request.headers['message']
                manager.add_message(uid, message)
                response = manager.generate_response(uid)
                return response, 200
            elif request.method == 'DELETE':
                uid = request.headers['uid']
                manager.delete_conversation(uid)
        except:
            return error('Bad Request', 'Incoming request is not formatted correctly.', 400), 400

    # Run the server
    print('Starting inference server on port 443, please ensure that this port is open to the internet.')
    ssl_context = ('certificate.pem', 'key.pem')
    host = socket.gethostbyname(socket.gethostname())
    server.run(debug=False, use_reloader=False, host=host, port=443, ssl_context=ssl_context)

if __name__ == '__main__':
    main()