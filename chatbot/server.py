import time, json, pickle, socket, threading, firebase_admin, requests
from copy import deepcopy
from firebase_admin import auth
from flask import Flask, request
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from torch import bfloat16
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig, ConversationalPipeline, Conversation, TextIteratorStreamer, pipeline

class ConversationsManager:
    def __init__(self, model: AutoModelForCausalLM, tokenizer: AutoTokenizer, persistance_filename: str = 'persistance.bin'):
        self.model = model
        self.tokenizer = tokenizer
        self.filename = persistance_filename
        try:
            file = open(self.filename, 'rb')
            self.data = pickle.load(file)
        except:
            self.data = {}
    def __del__(self):
        file = open(self.filename, 'wb')
        pickle.dump(self.data, file)
    def user_has_conversation(self, uid: str) -> bool:
        return uid in self.data.keys()
    def create_conversation(self, uid: str) -> Conversation | None:
        if not self.user_has_conversation(uid):
            self.data[uid] = {
                'conversation': Conversation(conversation_id=uid),
                'created': int(time.time())
            }
            return self.data[uid]['conversation']
        else:
            return None
    def add_message(self, uid: str, message: str) -> bool:
        if self.user_has_conversation(uid) and len(self.data[uid]['conversation'].messages) > 0 and self.data[uid]['conversation'].messages[-1]['role'] == 'assistant':
            self.data[uid]['conversation'].add_message({'role': 'user', 'content': message})
            return True
        else:
            return False
    def get_conversation(self, uid: str) -> Conversation | None:
        if self.user_has_conversation(uid):
            return self.data[uid]['conversation']
        else:
            return self.create_conversation(uid)
    def delete_conversation(self, uid: str) -> bool:
        if self.user_has_conversation(uid):
            del self.data[uid]
            return True
        else:
            return False
    def generate_response(self, uid: str, age: str = 'Not set', gender: str = 'Not set', skin_tone: str = 'Not set', skin_type: str = 'Not set') -> TextIteratorStreamer | None:
        if self.user_has_conversation(uid):
            conversation = self.get_conversation(uid)
            if len(conversation.messages) == 0 or conversation.messages[-1]['role'] == 'user':
                system_message = f'''
                You are a assistant that helps users with there skin concerns.
                You are not allowed to talk about anything other than dermatology/skin related topics.
                You can use the following information to help the user if needed, Please note that some of the below information may not always be set:

                Age: {age}
                Gender: {gender}
                Skin tone: {skin_tone}
                Skin type: {skin_type}
            
                You are allowed to mention this personal information only if the user alludes to it or if it will help provide more information to the user about there issue.
                '''
                message = {'role': 'system', 'content': system_message}
                conversation_copy = deepcopy(conversation)
                conversation_copy.messages.insert(0, message)
                streamer = TextIteratorStreamer(self.tokenizer, skip_prompt=True)
                chatbot = pipeline(
                    task='conversational',
                    model=self.model,
                    tokenizer=self.tokenizer,
                    device_map='auto',
                    framework='pt',
                    streamer=streamer
                )
                def generation(self, conversation_copy):
                    conversation_copy = chatbot(
                            conversation_copy,
                            max_new_tokens=1024,
                            eos_token_id=[
                                self.tokenizer.eos_token_id,
                                self.tokenizer.convert_tokens_to_ids("<|eot_id|>")
                            ],
                            do_sample=True,
                            temperature=0.6,
                            top_p=0.9,
                        )
                    conversation_copy.messages.pop(0)
                    self.data[uid]['conversation'] = conversation_copy
                thread = threading.Thread(target=generation, args=[self, conversation_copy])
                thread.start()
                return streamer
            else:
                return None
        else:
            return None

def main():

    # Define the model name/path and HF token
    model_name = 'meta-llama/Meta-Llama-3-8B-Instruct'
    access_token = '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'

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
        token=access_token,
        quantization_config=bnb_config,
        torch_dtype=bfloat16,
        device_map='auto',
        trust_remote_code=True
    )

    # Load the tokenizer
    tokenizer = AutoTokenizer.from_pretrained(
        pretrained_model_name_or_path=model_name,
        token=access_token
    )

    # Create the conversations manager
    manager = ConversationsManager(model, tokenizer)

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
    ddns_updater = threading.Thread(target=ddns_update_loop, daemon=True)
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
        default_limits=['1/minute']
    )

    def error_html(header: str, message: str, code: int) -> str:
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
    def root():
        return error_html('Not Found', 'The requested URL was not found on the server.', 404), 404

    @server.route('/<path>')
    def other(path):
        return error_html('Not Found', 'The requested URL was not found on the server.', 404), 404

    @server.route('/chatbot/generateResponse', methods=['GET'])
    @limiter.limit('20/minute;1/second')
    def generate_response():
        try:
            token = request.headers['token']
            uid = verify_token(token)
            if uid == None:
                return error_html('Unauthorized Access', 'Provided token is unauthorized.'), 400
            else:
                age = request.headers.get('age', 'Not set')
                gender = request.headers.get('gender', 'Not set')
                skin_tone = request.headers.get('skin-tone', 'Not set')
                skin_type = request.headers.get('skin-type', 'Not set')
                streamer = manager.generate_response(uid, age, gender, skin_tone, skin_type)
                if streamer == None:
                    return error_html('Bad Request', 'Cannot generate text.', 400), 400
                else:
                    def generator():
                        for text in streamer:
                            text = text.replace('<|eot_id|>', '')
                            yield text
                    return generator(), 200
        except:
            return error_html('Bad Request', 'Incoming request is not formatted correctly.', 400), 400
    
    @server.route('/chatbot/addMessage', methods=['POST'])
    @limiter.limit('5/second')
    def add_message():
        try:
            token = request.headers['token']
            uid = verify_token(token)
            if uid == None:
                return error_html('Unauthorized Access', 'Provided token is unauthorized.'), 400
            else:
                message = request.headers['message']
                if manager.add_message(uid, message):
                    return 'success', 200
                else:
                    error_html('Bad Request', 'Cannot add message.'), 400
        except:
            return error_html('Bad Request', 'Incoming request is not formatted correctly.', 400), 400

    @server.route('/chatbot/getConversation', methods=['GET'])
    @limiter.limit('5/second')
    def get_conversation():
        try:
            token = request.headers['token']
            uid = verify_token(token)
            if uid == None:
                return error_html('Unauthorized Access', 'Provided token is unauthorized.', 400), 400
            else:
                conversation = manager.get_conversation(uid)
                return conversation.messages, 200
        except:
            return error_html('Bad Request', 'Incoming request is not formatted correctly.', 400), 400
        
    @server.route('/chatbot/deleteConversation', methods=['DELETE'])
    @limiter.limit('5/second')
    def delete_conversation():
        try:
            token = request.headers['token']
            uid = verify_token(token)
            if uid == None:
                return error_html('Unauthorized Access', 'Provided token is unauthorized.', 400), 400
            else:
                if manager.delete_conversation(uid):
                    return 'success', 200
                else:
                    return error_html('Bad Request', 'User does not have a conversation.', 400), 400
        except:
            return error_html('Bad Request', 'Incoming request is not formatted correctly.', 400), 400

    # Run the server
    print('Starting inference server on port 443, please ensure that this port is open to the internet.')
    ssl_context = ('certificate.pem', 'key.pem')
    host = socket.gethostbyname(socket.gethostname())
    server.run(debug=False, use_reloader=False, host=host, port=443, ssl_context=ssl_context)

if __name__ == '__main__':
    main()