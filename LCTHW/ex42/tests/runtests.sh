#!/bin/bash

#echo "Running unit tests:"

#SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
#cd "$SCRIPT_DIR"
#./*.out

echo "Running unit tests:"

# 获取脚本所在的目录
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 切换到脚本所在的目录
cd "$SCRIPT_DIR"

# 执行所有 .out 文件
for file in *.out; do
    if [ -x "$file" ]; then
        echo "Executing $file"
        ./"$file"
    else
        echo "$file is not executable"
    fi
done

for i in tests/*_tests
do
    if test -f $i
    then
        if $VALGRIND ./$i 2>> tests/tests.log
        then
            echo $i PASS
        else
            echo "ERROR in test $i: here's tests/tests.log"
            echo "------"
            tail tests/tests.log
            exit 1
        fi
    fi
done

echo ""
