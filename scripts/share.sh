#!/usr/bin/env bash

#
# 设置：公共变量
#
# SERVICE_NAME  系统服务名称
#
SERVICE_NAME="gpu-power-limit"

#
# 设置：公共路径
#
# PROJECT_ROOTDIR_PATH  项目根目录路径
# PROGRAM_INSTALL_PATH  运行脚本安装路径
# PROFILE_INSTALL_PATH  配置文件安装路径
# SERVICE_INSTALL_PATH  系统服务安装路径
#
PROJECT_ROOTDIR_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRAM_INSTALL_PATH="/usr/local/bin"
PROFILE_INSTALL_PATH="/etc"
SERVICE_INSTALL_PATH="/etc/systemd/system"

#
# 设置：内部函数 - 打印错误日志
#
private_print_error() {
  # 定义内部变量
  local error_message="${1:-}"
  # 打印错误日志
  echo "错误：$error_message" >&2
}

#
# 设置：内部函数 - 抛出异常
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
# 设置：内部函数 - 校验文件是否存在
#
private_check_file_exists() {
  # 定义内部变量
  local file_path="${1:-}"
  # 校验文件是否存在
  [[ -f "$file_path" ]] || private_throw_error "文件 $file_path 不存在！"
}

#
# 设置：外部函数 - 安装系统服务
#
public_install_service() {
  # 定义内部变量
  local program_source="${PROJECT_ROOTDIR_PATH}/bin/${SERVICE_NAME}.sh"
  local profile_source="${PROJECT_ROOTDIR_PATH}/config/${SERVICE_NAME}.conf"
  local service_source="${PROJECT_ROOTDIR_PATH}/services/${SERVICE_NAME}.service"
  # 校验指定文件
  private_check_file_exists "$program_source"
  private_check_file_exists "$service_source"
  # 安装运行脚本
  install -D -o root -g root -m 0755 -- "$program_source" "${PROGRAM_INSTALL_PATH}/${SERVICE_NAME}.sh"
  # 安装配置文件
  # 安装系统服务
  install -D -o root -g root -m 0644 -- "$service_source" "${SERVICE_INSTALL_PATH}/${SERVICE_NAME}.service"
}

#
# 设置：外部函数 - 卸载系统服务
#
public_uninstall_service() {
  # 关闭系统服务
  systemctl disable --now "${SERVICE_NAME}.service"
  # 移除运行脚本
  rm -f -- "${PROGRAM_INSTALL_PATH}/${SERVICE_NAME}.sh"
  # 移除配置文件
  rm -f -- "${PROFILE_INSTALL_PATH}/${SERVICE_NAME}.conf"
  # 移除系统服务
  rm -f -- "${SERVICE_INSTALL_PATH}/${SERVICE_NAME}.service"
}
