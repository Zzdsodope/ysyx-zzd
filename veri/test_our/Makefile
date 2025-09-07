# 定义变量
VERILATOR = verilator
VERILATOR_FLAGS = --cc --exe --build -j 0 -Wall
SOURCES = our.v
CPP_SOURCES = sim_main.cpp
TARGET = Vour

# 默认目标
all: $(TARGET)

# 使用 Verilator 编译
$(TARGET): $(SOURCES) $(CPP_SOURCES)
	$(VERILATOR) $(VERILATOR_FLAGS) $(SOURCES) $(CPP_SOURCES) -o $(TARGET)

# 清理生成的文件
clean:
	rm -rf obj_dir
	rm -f $(TARGET)

# 伪目标
.PHONY: all clean
