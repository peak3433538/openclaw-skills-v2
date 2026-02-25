#!/bin/bash
# 🧪 自动记忆系统测试脚本
# 功能：测试所有记忆系统功能

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="/home/administrator/.openclaw/workspace"
TEST_DIR="$WORKSPACE_DIR/tests/auto-memory"
LOG_FILE="$TEST_DIR/test_$(date +%Y%m%d_%H%M%S).log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 创建测试目录
mkdir -p "$TEST_DIR"

# 日志函数
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"
    
    echo -e "$log_entry" | tee -a "$LOG_FILE"
}

# 测试开始
echo -e "${BLUE}🧪 开始自动记忆系统测试${NC}"
echo -e "${YELLOW}================================${NC}"
log "INFO" "自动记忆系统测试开始"

# 测试1：检查文件存在性
echo -e "\n1. ${BLUE}检查核心文件...${NC}"
test_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "   ✅ $description: ${GREEN}存在${NC}"
        log "SUCCESS" "$description 文件存在"
        return 0
    else
        echo -e "   ❌ $description: ${RED}不存在${NC}"
        log "ERROR" "$description 文件不存在"
        return 1
    fi
}

test_file "$SCRIPT_DIR/SKILL.md" "技能说明文档"
test_file "$SCRIPT_DIR/memory_manager.sh" "记忆管理脚本"
test_file "$SCRIPT_DIR/conversation_logger.py" "对话记录器"
test_file "$SCRIPT_DIR/config.json" "配置文件"

# 测试2：检查脚本权限
echo -e "\n2. ${BLUE}检查脚本权限...${NC}"
test_permission() {
    local file="$1"
    local description="$2"
    
    if [ -x "$file" ]; then
        echo -e "   ✅ $description: ${GREEN}可执行${NC}"
        log "SUCCESS" "$description 可执行"
        return 0
    else
        echo -e "   ❌ $description: ${RED}不可执行${NC}"
        log "WARNING" "$description 不可执行"
        return 1
    fi
}

# 设置执行权限
chmod +x "$SCRIPT_DIR/memory_manager.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/conversation_logger.py" 2>/dev/null || true

test_permission "$SCRIPT_DIR/memory_manager.sh" "记忆管理脚本"
test_permission "$SCRIPT_DIR/conversation_logger.py" "对话记录器"

# 测试3：测试记忆管理功能
echo -e "\n3. ${BLUE}测试记忆管理功能...${NC}"

# 测试状态显示
echo -e "   📊 测试状态显示..."
if "$SCRIPT_DIR/memory_manager.sh" status >/dev/null 2>&1; then
    echo -e "   ✅ 状态显示: ${GREEN}正常${NC}"
    log "SUCCESS" "状态显示功能正常"
else
    echo -e "   ❌ 状态显示: ${RED}失败${NC}"
    log "ERROR" "状态显示功能失败"
fi

# 测试对话记录
echo -e "   📝 测试对话记录..."
test_message="测试对话记录功能 - $(date '+%H:%M:%S')"
if "$SCRIPT_DIR/memory_manager.sh" log "$test_message" >/dev/null 2>&1; then
    echo -e "   ✅ 对话记录: ${GREEN}正常${NC}"
    log "SUCCESS" "对话记录功能正常"
else
    echo -e "   ❌ 对话记录: ${RED}失败${NC}"
    log "ERROR" "对话记录功能失败"
fi

# 测试重要信息提取
echo -e "   🧠 测试重要信息提取..."
important_message="记住明天要测试8:30起床提醒功能"
if "$SCRIPT_DIR/memory_manager.sh" extract "$important_message" >/dev/null 2>&1; then
    echo -e "   ✅ 信息提取: ${GREEN}正常${NC}"
    log "SUCCESS" "重要信息提取功能正常"
else
    echo -e "   ❌ 信息提取: ${RED}失败${NC}"
    log "ERROR" "重要信息提取功能失败"
fi

# 测试记忆搜索
echo -e "   🔍 测试记忆搜索..."
if "$SCRIPT_DIR/memory_manager.sh" search "测试" >/dev/null 2>&1; then
    echo -e "   ✅ 记忆搜索: ${GREEN}正常${NC}"
    log "SUCCESS" "记忆搜索功能正常"
else
    echo -e "   ❌ 记忆搜索: ${RED}失败${NC}"
    log "ERROR" "记忆搜索功能失败"
fi

# 测试4：测试Python对话记录器
echo -e "\n4. ${BLUE}测试Python对话记录器...${NC}"
if python3 "$SCRIPT_DIR/conversation_logger.py" --help >/dev/null 2>&1; then
    echo -e "   ✅ Python记录器: ${GREEN}可运行${NC}"
    log "SUCCESS" "Python对话记录器可运行"
else
    echo -e "   ❌ Python记录器: ${RED}运行失败${NC}"
    log "ERROR" "Python对话记录器运行失败"
fi

# 测试5：生成测试报告
echo -e "\n5. ${BLUE}生成测试报告...${NC}"
if "$SCRIPT_DIR/memory_manager.sh" report >/dev/null 2>&1; then
    echo -e "   ✅ 报告生成: ${GREEN}正常${NC}"
    log "SUCCESS" "报告生成功能正常"
    
    # 检查报告文件
    today=$(date '+%Y-%m-%d')
    report_file="$WORKSPACE_DIR/memory/report_$today.md"
    if [ -f "$report_file" ]; then
        echo -e "   📄 报告文件: ${GREEN}$report_file${NC}"
        log "INFO" "测试报告已生成: $report_file"
    fi
else
    echo -e "   ❌ 报告生成: ${RED}失败${NC}"
    log "ERROR" "报告生成功能失败"
fi

# 测试6：清理功能测试
echo -e "\n6. ${BLUE}测试清理功能...${NC}"
echo -e "   🧹 测试清理功能（模拟）..."
if "$SCRIPT_DIR/memory_manager.sh" clean >/dev/null 2>&1; then
    echo -e "   ✅ 清理功能: ${GREEN}正常${NC}"
    log "SUCCESS" "清理功能正常"
else
    echo -e "   ❌ 清理功能: ${RED}失败${NC}"
    log "ERROR" "清理功能失败"
fi

# 测试7：目录结构检查
echo -e "\n7. ${BLUE}检查目录结构...${NC}"
check_dir() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        local file_count=$(find "$dir" -type f | wc -l)
        echo -e "   ✅ $description: ${GREEN}存在 ($file_count 个文件)${NC}"
        log "INFO" "$description 目录存在，包含 $file_count 个文件"
        return 0
    else
        echo -e "   ❌ $description: ${RED}不存在${NC}"
        log "ERROR" "$description 目录不存在"
        return 1
    fi
}

check_dir "$WORKSPACE_DIR/memory" "记忆目录"
check_dir "$WORKSPACE_DIR/conversations" "对话目录"
check_dir "$WORKSPACE_DIR/logs" "日志目录"
check_dir "$TEST_DIR" "测试目录"

# 测试总结
echo -e "\n${YELLOW}================================${NC}"
echo -e "${BLUE}📊 测试总结${NC}"

# 统计测试结果
total_tests=0
passed_tests=0
failed_tests=0

# 从日志统计
if [ -f "$LOG_FILE" ]; then
    total_tests=$(grep -c "测试" "$LOG_FILE" || true)
    passed_tests=$(grep -c "SUCCESS" "$LOG_FILE" || true)
    failed_tests=$(grep -c "ERROR" "$LOG_FILE" || true)
fi

echo -e "   总测试数: $total_tests"
echo -e "   通过测试: ${GREEN}$passed_tests${NC}"
echo -e "   失败测试: ${RED}$failed_tests${NC}"

if [ "$failed_tests" -eq 0 ]; then
    echo -e "\n${GREEN}🎉 所有测试通过！自动记忆系统功能正常。${NC}"
    log "SUCCESS" "所有测试通过，自动记忆系统功能正常"
else
    echo -e "\n${YELLOW}⚠️  部分测试失败，请检查日志文件。${NC}"
    log "WARNING" "部分测试失败，请检查日志"
fi

echo -e "\n${BLUE}📋 测试日志文件:${NC} $LOG_FILE"
echo -e "${BLUE}📁 测试目录:${NC} $TEST_DIR"

# 显示测试文件内容
echo -e "\n${YELLOW}📝 测试生成的对话记录:${NC}"
today=$(date '+%Y-%m-%d')
conversation_file="$WORKSPACE_DIR/conversations/$today.md"
if [ -f "$conversation_file" ]; then
    tail -5 "$conversation_file" | sed 's/^/   /'
else
    echo -e "   暂无对话记录"
fi

echo -e "\n${YELLOW}🧠 测试生成的重要记忆:${NC}"
memory_file="$WORKSPACE_DIR/memory/important_memories.md"
if [ -f "$memory_file" ]; then
    tail -5 "$memory_file" | sed 's/^/   /'
else
    echo -e "   暂无重要记忆"
fi

echo -e "\n${GREEN}✅ 自动记忆系统测试完成${NC}"
log "INFO" "自动记忆系统测试完成"

# 建议
echo -e "\n${BLUE}💡 使用建议:${NC}"
echo -e "   1. 启动对话记录: ./memory_manager.sh start"
echo -e "   2. 记录对话: ./memory_manager.sh log \"对话内容\""
echo -e "   3. 搜索记忆: ./memory_manager.sh search \"关键词\""
echo -e "   4. 生成报告: ./memory_manager.sh report"
echo -e "   5. 查看状态: ./memory_manager.sh status"

exit $failed_tests