# -*- coding: utf-8 -*
import re
import os
from shutil import move

toppaths = [r'./bazel-bin/tensorflow/dumpbin/libs/tensorflow/core/common_runtime',
           r'./bazel-bin/tensorflow/dumpbin/libs/tensorflow/core/kernels',
           r'./bazel-bin/tensorflow/dumpbin/libs/tensorflow/core/ops']
file_type = '.txt'
pattern = re.compile(r'\?GLOBAL_LOAD__.*')
set_tf_global_load = set()

for toppath in toppaths:
    paths = os.walk(toppath)
    for root,dirs,files in paths:
        for file in files:
            if file_type in file:
                path = os.path.join(root,file) #带路径的文件名            
                print(path)
                with open(path, "r", encoding='utf-8') as f:
                    for line in f.readlines():
                        result = pattern.search(line)
                        if result:
                            set_tf_global_load.add('#pragma comment(linker, "/include:{}")'.format(result.group()))

results = r'./bazel-bin/tensorflow/dumpbin/tf_global_load.h'
results_tmp = results+'.tmp'

# 打开要写入结果的文件
with open(results_tmp, "w+", encoding='utf-8') as f:
    list_data = list(set_tf_global_load)
    list_data.sort()
    for data in list_data:
        f.write(data+'\n')

move(results_tmp, results)