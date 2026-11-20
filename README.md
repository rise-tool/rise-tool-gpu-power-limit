# rise-tool-gpu-power-limit

GPU 运行功率限制工具

## Install

```bash
#
# 安装系统服务
#
sudo bash scripts/install.sh

#
# 加载服务定义
#
sudo systemctl daemon-reload
```

## Usage

```bash
#
# 启动系统服务并设置开机自启
#
sudo systemctl enable --now gpu-power-limit.service

#
# 修改配置参数
#
sudo nano /etc/gpu-power-limit.conf

#
# 重启服务
#
sudo systemctl reset-failed gpu-power-limit.service
sudo systemctl restart gpu-power-limit.service
```

## Uninstall

```bash
#
# 卸载系统服务
#
sudo bash scripts/uninstall.sh

#
# 加载服务定义
#
sudo systemctl daemon-reload
```
