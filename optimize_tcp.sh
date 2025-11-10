#!/bin/bash
# =======================================
# Linux TCP 网络优化脚本
# 作者：ChatGPT (优化版)
# 适用：Debian / Ubuntu
# 功能：开启BBR、TCP Fast Open、网络缓冲优化
# =======================================

set -e

echo "=== 🚀 开始执行 TCP 网络优化 ==="

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 用户运行：sudo bash optimize_tcp.sh"
  exit 1
fi

# 备份配置
SYSCTL_FILE="/etc/sysctl.conf"
BACKUP_FILE="/etc/sysctl.conf.backup.$(date +%Y%m%d%H%M%S)"
cp $SYSCTL_FILE $BACKUP_FILE
echo "✅ 已备份配置文件到: $BACKUP_FILE"

# 写入优化参数
cat <<EOF >> $SYSCTL_FILE

# ========== TCP 网络优化配置 ==========
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3

# 网络缓冲优化
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216

# 其他 TCP 性能优化
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
EOF

# 应用生效
sysctl -p

echo "✅ 参数已写入并生效"

# 检查 BBR 模块
echo "=== 检查 BBR 状态 ==="
if lsmod | grep -q bbr; then
  echo "✅ BBR 模块已加载"
else
  echo "⚠️ 未检测到 BBR 模块，尝试手动加载..."
  modprobe tcp_bbr 2>/dev/null || true
fi

# 验证是否启用
CC=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
FA=$(sysctl net.ipv4.tcp_fastopen | awk '{print $3}')

echo "当前 TCP 拥塞算法：$CC"
echo "当前 Fast Open 状态：$FA"

if [[ "$CC" == "bbr" ]]; then
  echo "✅ BBR 启用成功"
else
  echo "❌ BBR 未启用，请检查内核是否支持（4.9+）"
fi

if [[ "$FA" == "3" ]]; then
  echo "✅ TCP Fast Open 已开启（客户端+服务端）"
else
  echo "⚠️ TCP Fast Open 未正确开启"
fi

echo "=== 🎉 TCP 网络优化完成 ==="
