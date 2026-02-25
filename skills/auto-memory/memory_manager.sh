#!/bin/bash
# 🧠 自动记忆管理脚本
# 功能：对话记录、信息提取、记忆搜索、记忆清理

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="/home/administrator/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE_DIR/memory"
CONVERSATION_DIR="$WORKSPACE_DIR/conversations"
LOG_DIR="$WORKSPACE_DIR/logs"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 创建目录
mkdir -p "$MEMORY_DIR" "$CONVERSATION_DIR" "$LOG_DIR"

# 日志函数
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] [$level] $message" | tee -a "$LOG_DIR/memory_manager.log"
}

# 显示帮助
show_help() {
    echo -e "${BLUE}🧠 自动记忆管理脚本${NC}"
    echo -e "用法: $0 [命令] [参数]"
    echo -e ""
    echo -e "命令:"
    echo -e "  start             启动对话记录"
    echo -e "  stop              停止对话记录"
    echo -e "  log <内容>        手动记录对话"
    echo -e "  extract <内容>    提取重要信息"
    echo -e "  search <关键词>   搜索记忆"
    echo -e "  clean             清理过时记忆"
    echo -e "  report            生成记忆报告"
    echo -e "  status            显示系统状态"
    echo -e "  help              显示帮助信息"
    echo -e ""
    echo -e "示例:"
    echo -e "  $0 log \"用户说：明天测试8:30起床提醒\""
    echo -e "  $0 search \"起床提醒\""
    echo -e "  $0 report"
}

# 启动对话记录
start_recording() {
    log "INFO" "启动对话记录..."
    
    # 检查是否已在运行
    if [ -f "$CONVERSATION_DIR/recording.pid" ]; then
        local pid=$(cat "$CONVERSATION_DIR/recording.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  对话记录已在运行 (PID: $pid)${NC}"
            return 0
        fi
    fi
    
    # 启动记录进程
    nohup python3 "$SCRIPT_DIR/conversation_logger.py" >> "$LOG_DIR/conversation.log" 2>&1 &
    local pid=$!
    echo "$pid" > "$CONVERSATION_DIR/recording.pid"
    
    echo -e "${GREEN}✅ 对话记录已启动 (PID: $pid)${NC}"
    log "SUCCESS" "对话记录启动成功，PID: $pid"
}

# 停止对话记录
stop_recording() {
    log "INFO" "停止对话记录..."
    
    if [ -f "$CONVERSATION_DIR/recording.pid" ]; then
        local pid=$(cat "$CONVERSATION_DIR/recording.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$CONVERSATION_DIR/recording.pid"
            echo -e "${GREEN}✅ 对话记录已停止${NC}"
            log "SUCCESS" "对话记录停止成功"
        else
            echo -e "${YELLOW}⚠️  对话记录进程不存在${NC}"
            rm -f "$CONVERSATION_DIR/recording.pid"
        fi
    else
        echo -e "${YELLOW}⚠️  对话记录未运行${NC}"
    fi
}

# 手动记录对话
log_conversation() {
    local content="$1"
    if [ -z "$content" ]; then
        echo -e "${RED}❌ 错误：请提供对话内容${NC}"
        return 1
    fi
    
    log "INFO" "手动记录对话: $content"
    
    # 创建今日对话文件
    local today=$(date '+%Y-%m-%d')
    local conversation_file="$CONVERSATION_DIR/$today.md"
    
    # 添加对话记录
    local timestamp=$(date '+%H:%M:%S')
    echo -e "\n**[$timestamp]** $content" >> "$conversation_file"
    
    echo -e "${GREEN}✅ 对话已记录到: $conversation_file${NC}"
    log "SUCCESS" "对话记录成功: $content"
}

# 提取重要信息
extract_info() {
    local content="$1"
    if [ -z "$content" ]; then
        echo -e "${RED}❌ 错误：请提供要提取的内容${NC}"
        return 1
    fi
    
    log "INFO" "提取重要信息: $content"
    
    # 检查是否是重要信息
    local important_keywords=("记住" "重要" "保存" "提醒" "计划" "明天" "测试" "验证")
    local is_important=false
    
    for keyword in "${important_keywords[@]}"; do
        if echo "$content" | grep -q "$keyword"; then
            is_important=true
            break
        fi
    done
    
    if [ "$is_important" = true ]; then
        # 保存到记忆文件
        local memory_file="$MEMORY_DIR/important_memories.md"
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        echo -e "\n## 📝 $timestamp" >> "$memory_file"
        echo -e "$content" >> "$memory_file"
        echo -e "---" >> "$memory_file"
        
        echo -e "${GREEN}✅ 重要信息已保存到记忆${NC}"
        log "SUCCESS" "重要信息提取成功: $content"
    else
        echo -e "${YELLOW}⚠️  未检测到重要信息关键词${NC}"
        log "INFO" "未提取重要信息: $content"
    fi
}

# 搜索记忆
search_memory() {
    local keyword="$1"
    if [ -z "$keyword" ]; then
        echo -e "${RED}❌ 错误：请提供搜索关键词${NC}"
        return 1
    fi
    
    log "INFO" "搜索记忆: $keyword"
    
    echo -e "${BLUE}🔍 搜索关键词: $keyword${NC}"
    echo -e "${YELLOW}================================${NC}"
    
    # 搜索对话文件
    local found_count=0
    
    # 搜索今日对话
    local today=$(date '+%Y-%m-%d')
    local conversation_file="$CONVERSATION_DIR/$today.md"
    
    if [ -f "$conversation_file" ]; then
        echo -e "\n📅 今日对话记录:"
        grep -n -i "$keyword" "$conversation_file" | while read -r line; do
            echo -e "   $line"
            found_count=$((found_count + 1))
        done
    fi
    
    # 搜索记忆文件
    local memory_file="$MEMORY_DIR/important_memories.md"
    if [ -f "$memory_file" ]; then
        echo -e "\n🧠 重要记忆:"
        grep -n -i "$keyword" "$memory_file" | while read -r line; do
            echo -e "   $line"
            found_count=$((found_count + 1))
        done
    fi
    
    # 搜索历史记忆文件
    echo -e "\n📚 历史记忆:"
    for file in "$MEMORY_DIR"/*.md; do
        if [ -f "$file" ] && [ "$file" != "$memory_file" ]; then
            local matches=$(grep -c -i "$keyword" "$file" || true)
            if [ "$matches" -gt 0 ]; then
                echo -e "   📄 $(basename "$file"): $matches 条匹配"
                found_count=$((found_count + matches))
            fi
        fi
    done
    
    echo -e "${YELLOW}================================${NC}"
    if [ "$found_count" -gt 0 ]; then
        echo -e "${GREEN}✅ 找到 $found_count 条相关记录${NC}"
        log "SUCCESS" "搜索完成: 找到 $found_count 条记录"
    else
        echo -e "${YELLOW}⚠️  未找到相关记录${NC}"
        log "INFO" "搜索完成: 未找到相关记录"
    fi
}

# 清理过时记忆
clean_memory() {
    log "INFO" "开始清理过时记忆..."
    
    local days_to_keep=30
    local deleted_count=0
    
    echo -e "${BLUE}🧹 清理 $days_to_keep 天前的记忆...${NC}"
    
    # 清理对话记录
    if [ -d "$CONVERSATION_DIR" ]; then
        find "$CONVERSATION_DIR" -name "*.md" -type f -mtime +$days_to_keep | while read -r file; do
            echo -e "   删除: $(basename "$file")"
            rm -f "$file"
            deleted_count=$((deleted_count + 1))
        done
    fi
    
    # 清理日志文件
    if [ -d "$LOG_DIR" ]; then
        find "$LOG_DIR" -name "*.log" -type f -mtime +$days_to_keep | while read -r file; do
            echo -e "   删除: $(basename "$file")"
            rm -f "$file"
            deleted_count=$((deleted_count + 1))
        done
    fi
    
    echo -e "${YELLOW}================================${NC}"
    echo -e "${GREEN}✅ 清理完成，删除了 $deleted_count 个文件${NC}"
    log "SUCCESS" "记忆清理完成，删除了 $deleted_count 个文件"
}

# 生成记忆报告
generate_report() {
    log "INFO" "生成记忆报告..."
    
    local today=$(date '+%Y-%m-%d')
    local report_file="$MEMORY_DIR/report_$today.md"
    
    echo -e "${BLUE}📊 生成记忆报告...${NC}"
    
    # 统计信息
    local conversation_count=0
    local memory_count=0
    local total_files=0
    
    # 统计对话记录
    if [ -d "$CONVERSATION_DIR" ]; then
        conversation_count=$(find "$CONVERSATION_DIR" -name "*.md" -type f | wc -l)
    fi
    
    # 统计记忆文件
    if [ -d "$MEMORY_DIR" ]; then
        memory_count=$(find "$MEMORY_DIR" -name "*.md" -type f | wc -l)
        total_files=$((conversation_count + memory_count))
    fi
    
    # 生成报告
    cat > "$report_file" << EOF
# 🧠 记忆系统报告
📅 报告时间: $(date '+%Y-%m-%d %H:%M:%S')

## 📈 统计信息
- 对话记录文件: $conversation_count 个
- 记忆文件: $memory_count 个
- 总文件数: $total_files 个

## 📅 今日对话
$(if [ -f "$CONVERSATION_DIR/$today.md" ]; then
    echo "今日记录了对话，最后几条记录："
    tail -5 "$CONVERSATION_DIR/$today.md" | sed 's/^/  /'
else
    echo "今日暂无对话记录"
fi)

## 🧠 最近重要记忆
$(if [ -f "$MEMORY_DIR/important_memories.md" ]; then
    echo "最近的重要记忆："
    tail -5 "$MEMORY_DIR/important_memories.md" | sed 's/^/  /'
else
    echo "暂无重要记忆"
fi)

## 📋 系统状态
- 记忆目录: $MEMORY_DIR
- 对话目录: $CONVERSATION_DIR
- 日志目录: $LOG_DIR
- 报告生成时间: $(date)

## 🚀 建议
1. 定期清理过时记忆
2. 检查重要信息是否已保存
3. 验证搜索功能是否正常

---
报告生成: 自动记忆系统
EOF
    
    echo -e "${GREEN}✅ 报告已生成: $report_file${NC}"
    log "SUCCESS" "记忆报告生成成功"
    
    # 显示报告摘要
    echo -e "\n${YELLOW}📋 报告摘要:${NC}"
    echo -e "   对话记录: $conversation_count 个文件"
    echo -e "   记忆文件: $memory_count 个文件"
    echo -e "   总文件数: $total_files 个文件"
}

# 显示系统状态
show_status() {
    log "INFO" "显示系统状态..."
    
    echo -e "${BLUE}📊 自动记忆系统状态${NC}"
    echo -e "${YELLOW}================================${NC}"
    
    # 检查记录进程
    if [ -f "$CONVERSATION_DIR/recording.pid" ]; then
        local pid=$(cat "$CONVERSATION_DIR/recording.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "📝 对话记录: ${GREEN}运行中 (PID: $pid)${NC}"
        else
            echo -e "📝 对话记录: ${RED}进程异常${NC}"
            rm -f "$CONVERSATION_DIR/recording.pid"
        fi
    else
        echo -e "📝 对话记录: ${YELLOW}未运行${NC}"
    fi
    
    # 检查目录
    echo -e "\n📁 目录状态:"
    if [ -d "$MEMORY_DIR" ]; then
        local mem_count=$(find "$MEMORY_DIR" -name "*.md" -type f | wc -l)
        echo -e "   记忆目录: ${GREEN}正常 ($mem_count 个文件)${NC}"
    else
        echo -e "   记忆目录: ${RED}不存在${NC}"
    fi
    
    if [ -d "$CONVERSATION_DIR" ]; then
        local conv_count=$(find "$CONVERSATION_DIR" -name "*.md" -type f | wc -l)
        echo -e "   对话目录: ${GREEN}正常 ($conv_count 个文件)${NC}"
    else
        echo -e "   对话目录: ${RED}不存在${NC}"
    fi
    
    if [ -d "$LOG_DIR" ]; then
        local log_count=$(find "$LOG_DIR" -name "*.log" -type f | wc -l)
        echo -e "   日志目录: ${GREEN}正常 ($log_count 个文件)${NC}"
    else
        echo -e "   日志目录: ${RED}不存在${NC}"
    fi
    
    # 显示今日统计
    local today=$(date '+%Y-%m-%d')
    echo -e "\n📅 今日统计:"
    if [ -f "$CONVERSATION_DIR/$today.md" ]; then
        local today_lines=$(wc -l < "$CONVERSATION_DIR/$today.md")
        echo -e "   今日对话: $today_lines 行"
    else
        echo -e "   今日对话: 暂无记录"
    fi
    
    echo -e "${YELLOW}================================${NC}"
    log "SUCCESS" "系统状态显示完成"
}

# 主函数
main() {
    local command="$1"
    local argument="$2"
    
    case "$command" in
        "start")
            start_recording
            ;;
        "stop")
            stop_recording
            ;;
        "log")
            log_conversation "$argument"
            ;;
        "extract")
            extract_info "$argument"
            ;;
        "search")
            search_memory "$argument"
            ;;
        "clean")
            clean_memory
            ;;
        "report")
            generate_report
            ;;
        "status")
            show_status
            ;;
        "help"|"")
            show_help
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $command${NC}"
            show_help
            return 1
            ;;
    esac
}

# 执行主函数
main "$@"