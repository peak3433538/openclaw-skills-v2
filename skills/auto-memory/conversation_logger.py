#!/usr/bin/env python3
# 📝 对话记录器
# 功能：实时记录对话内容，自动保存到文件

import os
import sys
import time
import json
from datetime import datetime
from pathlib import Path

class ConversationLogger:
    def __init__(self):
        # 配置路径
        self.workspace_dir = Path("/home/administrator/.openclaw/workspace")
        self.conversation_dir = self.workspace_dir / "conversations"
        self.log_dir = self.workspace_dir / "logs"
        self.config_file = Path(__file__).parent / "config.json"
        
        # 创建目录
        self.conversation_dir.mkdir(exist_ok=True)
        self.log_dir.mkdir(exist_ok=True)
        
        # 加载配置
        self.config = self.load_config()
        
        # 日志文件
        self.log_file = self.log_dir / "conversation.log"
        
        # 重要关键词
        self.important_keywords = [
            "记住", "重要", "保存", "提醒", "计划",
            "明天", "测试", "验证", "执行", "完成",
            "兆龙互连", "起床提醒", "飞书", "cron"
        ]
        
    def load_config(self):
        """加载配置文件"""
        default_config = {
            "auto_save": True,
            "save_interval": 60,  # 秒
            "max_file_size": 1024 * 1024,  # 1MB
            "important_keywords": self.important_keywords,
            "log_level": "INFO"
        }
        
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                    default_config.update(user_config)
            except Exception as e:
                self.log_error(f"加载配置文件失败: {e}")
        
        return default_config
    
    def log_message(self, level, message):
        """记录日志"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"[{timestamp}] [{level}] {message}\n"
        
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_entry)
        
        # 控制台输出
        if level in ["ERROR", "WARNING"]:
            print(f"\033[91m{log_entry.strip()}\033[0m")
        elif level == "INFO":
            print(f"\033[94m{log_entry.strip()}\033[0m")
        else:
            print(log_entry.strip())
    
    def log_error(self, message):
        """记录错误"""
        self.log_message("ERROR", message)
    
    def log_info(self, message):
        """记录信息"""
        self.log_message("INFO", message)
    
    def log_success(self, message):
        """记录成功"""
        self.log_message("SUCCESS", message)
    
    def save_conversation(self, content, speaker="用户", is_important=False):
        """保存对话内容"""
        try:
            # 获取今日日期
            today = datetime.now().strftime('%Y-%m-%d')
            conversation_file = self.conversation_dir / f"{today}.md"
            
            # 时间戳
            timestamp = datetime.now().strftime('%H:%M:%S')
            
            # 格式化内容
            if is_important:
                prefix = "🔴"
            else:
                prefix = "💬"
            
            # 对话条目
            entry = f"\n**{prefix} [{timestamp}] {speaker}:** {content}\n"
            
            # 追加到文件
            with open(conversation_file, 'a', encoding='utf-8') as f:
                f.write(entry)
            
            # 如果是重要信息，也保存到记忆文件
            if is_important:
                self.save_to_memory(content, speaker)
            
            self.log_info(f"对话已保存: {speaker} - {content[:50]}...")
            return True
            
        except Exception as e:
            self.log_error(f"保存对话失败: {e}")
            return False
    
    def save_to_memory(self, content, speaker):
        """保存重要信息到记忆文件"""
        try:
            memory_file = self.workspace_dir / "memory" / "important_memories.md"
            memory_file.parent.mkdir(exist_ok=True)
            
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            memory_entry = f"""
## 🧠 重要记忆 - {timestamp}

**发言者**: {speaker}
**内容**: {content}

**提取时间**: {timestamp}
**关键词**: {self.extract_keywords(content)}

---
"""
            
            with open(memory_file, 'a', encoding='utf-8') as f:
                f.write(memory_entry)
            
            self.log_success(f"重要信息已保存到记忆: {content[:50]}...")
            
        except Exception as e:
            self.log_error(f"保存到记忆失败: {e}")
    
    def extract_keywords(self, content):
        """提取关键词"""
        found_keywords = []
        for keyword in self.important_keywords:
            if keyword in content:
                found_keywords.append(keyword)
        
        return ", ".join(found_keywords) if found_keywords else "无"
    
    def check_importance(self, content):
        """检查内容是否重要"""
        content_lower = content.lower()
        
        # 检查关键词
        for keyword in self.important_keywords:
            if keyword in content_lower:
                return True
        
        # 检查指令性语言
        instruction_words = ["需要", "要求", "必须", "应该", "要", "请"]
        for word in instruction_words:
            if word in content_lower:
                return True
        
        return False
    
    def monitor_stdin(self):
        """监控标准输入（模拟对话输入）"""
        self.log_info("开始监控对话输入...")
        print("\033[92m对话记录器已启动，输入 'exit' 退出\033[0m")
        
        buffer = []
        last_save_time = time.time()
        
        while True:
            try:
                # 读取输入
                line = input().strip()
                
                if line.lower() == 'exit':
                    self.log_info("收到退出指令")
                    break
                
                if line:
                    # 检查重要性
                    is_important = self.check_importance(line)
                    
                    # 保存对话
                    self.save_conversation(line, "用户", is_important)
                    
                    # 添加到缓冲区
                    buffer.append({
                        "timestamp": datetime.now().isoformat(),
                        "content": line,
                        "important": is_important
                    })
                
                # 定期保存缓冲区
                current_time = time.time()
                if current_time - last_save_time > self.config["save_interval"] and buffer:
                    self.save_buffer(buffer)
                    buffer = []
                    last_save_time = current_time
                    
            except KeyboardInterrupt:
                self.log_info("收到中断信号")
                break
            except EOFError:
                self.log_info("输入结束")
                break
            except Exception as e:
                self.log_error(f"处理输入时出错: {e}")
        
        # 保存剩余缓冲区
        if buffer:
            self.save_buffer(buffer)
        
        self.log_info("对话记录器已停止")
    
    def save_buffer(self, buffer):
        """保存缓冲区内容到JSON文件"""
        try:
            today = datetime.now().strftime('%Y-%m-%d')
            json_file = self.conversation_dir / f"{today}.json"
            
            # 读取现有数据
            existing_data = []
            if json_file.exists():
                with open(json_file, 'r', encoding='utf-8') as f:
                    existing_data = json.load(f)
            
            # 合并数据
            existing_data.extend(buffer)
            
            # 保存到文件
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(existing_data, f, ensure_ascii=False, indent=2)
            
            self.log_info(f"缓冲区已保存到JSON文件: {len(buffer)} 条记录")
            
        except Exception as e:
            self.log_error(f"保存缓冲区失败: {e}")
    
    def run(self):
        """主运行函数"""
        self.log_info("对话记录器启动")
        print("\033[1;36m" + "="*50 + "\033[0m")
        print("\033[1;36m      🧠 自动记忆系统 - 对话记录器     \033[0m")
        print("\033[1;36m" + "="*50 + "\033[0m")
        
        try:
            self.monitor_stdin()
        except Exception as e:
            self.log_error(f"运行出错: {e}")
            return 1
        
        return 0

def main():
    """主函数"""
    logger = ConversationLogger()
    return logger.run()

if __name__ == "__main__":
    sys.exit(main())