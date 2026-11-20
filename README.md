# rise-tool-gpu-power-limit

GPU 运行功率限制工具

## Install

```bash
#
# 安装系统服务
#
sudo bash scripts/install.sh
```

## Usage

```bash
#
# 启动系统服务并设置开机自启
#
sudo systemctl enable --now gpu-power-limit.service
```

## Uninstall

```bash
#
# 卸载系统服务
#
sudo bash scripts/uninstall.sh
```
