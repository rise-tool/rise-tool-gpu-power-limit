#!/usr/bin/env bash

#
# 开启严格模式
#
set -euo pipefail

#
# 设置内部函数：启动应用服务
#
private_start_app() {
  for ((GPU_INDEX = 0; GPU_INDEX <= GPU_TOTAL; GPU_INDEX += 1)); do
    nvidia-smi -i ${GPU_INDEX} -pl ${POWER_LIMIT}
  done
}

#
# 启动应用服务
#
private_start_app
