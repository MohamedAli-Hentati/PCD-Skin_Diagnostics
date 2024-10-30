import torch
from torch.utils.mobile_optimizer import optimize_for_mobile

filename= input('Enter model filename: ')
model = torch.load(f'../models/{filename}')
model = model.to('cpu')
model.eval()
example = torch.rand(1, 3, 224, 224)
traced_script_module = torch.jit.script(model, example)
traced_script_module_optimized = optimize_for_mobile(traced_script_module)
traced_script_module_optimized._save_for_lite_interpreter('../app/android/app/src/main/assets/model.ptl')