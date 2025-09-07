# 自动检测 Verilog 和 C++ 文件
VERI_SRCS := $(wildcard *.v)
CPP_SRCS := $(wildcard *.cpp)

# 检测模块名（假设模块名与第一个 .v 文件名一致）
VERI_MODULE := $(basename $(notdir $(firstword $(VERI_SRCS))))
TOP_MODULE := V$(subst -,_,$(subst .,_,$(VERI_MODULE)))

# 默认目标
all: $(TOP_MODULE)

# Verilator 编译规则
$(TOP_MODULE): $(VERI_SRCS) $(CPP_SRCS)
	verilator --cc --trace --exe --build -j 0 -Wall $(CPP_SRCS) $(VERI_SRCS)

# 清理生成的文件
clean:
	rm -rf obj_dir $(TOP_MODULE)

# 打印模块名和文件列表（调试用）
print:
	@echo "Verilog Sources: $(VERI_SRCS)"
	@echo "C++ Sources: $(CPP_SRCS)"
	@echo "Top Module: $(TOP_MODULE)"
