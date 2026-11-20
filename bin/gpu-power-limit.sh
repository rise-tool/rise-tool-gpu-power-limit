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
# 设置内部函数 - 校验命令
#
private_check_command() {
  # 定义内部变量
  local command="${1:-}"
  # 校验命令
  command -v "$command" >/dev/null 2>&1 || private_throw_error "找不到 $command 命令！"
}

#
# 设置内部函数：启动应用服务
#
private_start_app() {
  local gpu_ids gpu_id gpu_max_power gpu_target_power
  local gpu_power_limit="${GPU_POWER_LIMIT:-}"

  # 校验百分比
  private_check_env "GPU_POWER_LIMIT" "$gpu_power_limit"

  [[ "$gpu_power_limit" =~ ^([1-9][0-9]?|100)$ ]] ||
    private_throw_error "GPU_POWER_LIMIT 必须是 1～100 的整数百分比！"

  private_check_command "nvidia-smi"
  private_check_command "awk"

  # 查询显卡
  gpu_ids="$(nvidia-smi --query-gpu=uuid --format=csv,noheader)" ||
    private_throw_error "查询 NVIDIA 显卡失败！"

  [[ -n "$gpu_ids" ]] ||
    private_throw_error "没有检测到 NVIDIA 显卡！"

  while IFS= read -r gpu_id; do
    [[ -n "$gpu_id" ]] || continue

    # 查询当前显卡允许的最大功率（W）
    gpu_max_power="$(nvidia-smi -i "$gpu_id" \
      --query-gpu=power.max_limit --format=csv,noheader,nounits)" ||
      private_throw_error "查询 $gpu_id 最大功率失败！"

    # 校验查询结果并计算目标功率，支持最大功率含小数
    gpu_target_power="$(LC_ALL=C awk -v percent="$gpu_power_limit" '
      $1 ~ /^[0-9]+([.][0-9]+)?$/ && $1 > 0 {
        printf "%.2f\n", $1 * percent / 100
        next
      }
      { exit 1 }
    ' <<< "$gpu_max_power")" ||
      private_throw_error "无法读取 $gpu_id 的有效最大功率！"

    # 应用功率上限
    nvidia-smi -i "$gpu_id" -pl "$gpu_target_power" ||
      private_throw_error "设置 $gpu_id 显卡功率失败，请检查是否低于最小功率！"
  done <<< "$gpu_ids"
}

#
# 启动应用服务
#
private_start_app
