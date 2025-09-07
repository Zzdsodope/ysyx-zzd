#!/bin/bash

# 检查并添加 kernel.core_pattern 配置
if ! grep -qi 'kernel.core_pattern' /etc/sysctl.conf; then
    echo "kernel.core_pattern=core.%p.%u.%s.%e.%t" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

# 设置 ulimit
ulimit -c unlimited

# 检查配置是否生效
echo "Current core_pattern: $(cat /proc/sys/kernel/core_pattern)"
echo "Current ulimit -c: $(ulimit -c)"
