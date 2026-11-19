#!/usr/bin/env bash

#
# 开启严格模式
#
set -euo pipefail

#
# 设置内部函数 - 打印错误日志
#
private_print_error() {
  # 定义内部变量
  local error_message="${1:-}"
  # 打印错误日志
  echo "错误：$error_message" >&2
}

#
# 设置内部函数 - 抛出异常
#
private_throw_error() {
  # 定义内部变量
  local error_message="${1:-}"
  # 打印错误日志
  private_print_error "$error_message"
  # 退出脚本
  exit 1
}

#
# 设置内部函数 - 校验环境变量
#
private_check_env() {
  # 定义内部变量
  local env_key="${1:-}"
  local env_value="${2:-}"
  # 校验环境变量
  [ -n "$env_value" ] || private_throw_error "环境变量 $env_key 不能为空！"
}

#
# 设置内部函数：启动应用服务
#
private_start_app() {
  # 定义内部变量
  local gpu_ids="$(nvidia-smi --query-gpu=uuid --format=csv,noheader)"
  local gpu_power_limit="${GPU_POWER_LIMIT:-}"
  # 校验环境变量
  private_check_env "GPU_POWER_LIMIT" "$gpu_power_limit"
  # 判断显卡数量
  [[ -n "$gpu_ids" ]] || private_throw_error "没有检测到 NVIDIA 显卡！"
  # 设置显卡功率
  while IFS= read -r gpu_id; do
    # 跳过无效显卡
    [[ -n "$gpu_id" ]] || continue
    # 设置显卡功率
    nvidia-smi -i "$gpu_id" -pl "$gpu_power_limit"
  done <<< "$gpu_ids"
}

#
# 启动应用服务
#
private_start_app
