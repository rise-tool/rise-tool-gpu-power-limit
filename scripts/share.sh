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
# SERVICE_INSTALL_PATH  系统服务安装路径
#
PROJECT_ROOTDIR_PATH="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRAM_INSTALL_PATH="/usr/local/bin"
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
# 设置：内部函数 - 拷贝文件
#
private_copy_file() {
  # 定义内部变量
  local file_origin_path="${1:-}"
  local file_target_path="${2:-}"
  # 拷贝文件
  copy "$file_origin_path" "$file_target_path"
}

#
# 设置：内部函数 - 删除文件
#
private_delete_file() {
  # 定义内部变量
  local file_path = "${1:-}"
  # 校验文件是否存在
  private_check_file_exists "$file_path"
  # 删除文件
  rm -rf "$file_path"
}

#
# 设置：外部函数 - 安装系统服务
#
public_install_service() {
  # 安装运行脚本
  private_copy_file "${PROJECT_ROOTDIR_PATH}/bin/${SERVICE_NAME}.sh" "$PROGRAM_INSTALL_PATH"
  # 安装系统服务
  private_copy_file "${PROJECT_ROOTDIR_PATH}/services/${SERVICE_NAME}.service" "$SERVICE_INSTALL_PATH"
}

#
# 设置：外部函数 - 启动系统服务
#
public_start_service() {
  # 启动系统服务
  systemctl start "${SERVICE_NAME}.service"
  # 添加开机自启
  systemctl enable "${SERVICE_NAME}.service"
  # 查看服务状态
  systemctl status "${SERVICE_NAME}.service"
}

#
# 设置：外部函数 - 关闭系统服务
#
public_close_service() {
  # 关闭系统服务
  systemctl stop "${SERVICE_NAME}.service"
  # 移除开机自启
  systemctl disable "${SERVICE_NAME}.service"
}

#
# 设置：外部函数 - 重启系统服务
#
public_rerun_service() {
  # 重启系统服务
  systemctl restart "${SERVICE_NAME}.service"
}

#
# 设置：外部函数 - 卸载系统服务
#
public_uninstall_service() {
  # 关闭系统服务
  public_close_service
  # 移除运行脚本
  private_delete_file "${PROGRAM_INSTALL_PATH}/${SERVICE_NAME}.sh"
  # 移除系统服务
  private_delete_file "${SERVICE_INSTALL_PATH}/${SERVICE_NAME}.service"
}
