import torch
import torchvision
from torch.utils.mobile_optimizer import optimize_for_mobile

model = torch.load('models/mobilenet_v2_test.pth')
model = model.to('cpu')
model.eval()
example = torch.rand(1, 3, 224, 224)
traced_script_module = torch.jit.trace(model, example)