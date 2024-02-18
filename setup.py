import subprocess

subprocess.call(["pip", "install", "-r", "requirements.txt"])
subprocess.call(["pip", "install", "torch", "torchvision", "torchaudio", "--index-url", "https://download.pytorch.org/whl/cu121"])
