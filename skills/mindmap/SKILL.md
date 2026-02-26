# Mind Map Skill

Create and manage mind maps.

## Tools

### Generate Mind Map from Text

```bash
# Generate a simple mind map
mindmap generate "主题: 项目管理\n子主题1: 需求分析\n子主题2: 设计\n子主题3: 开发\n子主题4: 测试"
```

### Using Python

```python
from docx import Document
from pptx import Presentation

# Create a simple text-based mind map
def create_mindmap(topic, branches):
    """Create a simple mind map document"""
    content = f"""# {topic}

## 中心主题
{topic}

## 分支主题
"""
    for i, branch in enumerate(branches, 1):
        content += f"\n### {i}. {branch}\n"
        content += f"- {branch}的子要点1\n"
        content += f"- {branch}的子要点2\n"
    
    return content
```

## Popular Mind Map Tools

| Tool | Platform | Description |
|------|----------|-------------|
| XMind | Windows/Mac/Linux | Professional mind mapping |
| MindNode | macOS/iOS | Simple and beautiful |
| iThoughts | iOS/Android | Cross-platform |
| GitMind | Web/Windows/Mac | Free online mind map |
| Miro | Web | Collaborative whiteboard |

## Create Mind Map in Word

```python
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

doc = Document()
doc.add_heading('Mind Map: 主题名称', 0)

# Center topic
p = doc.add_paragraph()
p.add_run('中心主题').bold = True
p.alignment = WD_ALIGN_PARAGRAPH.CENTER

# Add branches
for i, branch in enumerate(['分支1', '分支2', '分支3'], 1):
    doc.add_heading(f'{i}. {branch}', level=2)
    doc.add_paragraph(f'- 子要点1')
    doc.add_paragraph(f'- 子要点2')

doc.save('mindmap.docx')
```

## Quick Start

1. Define your central topic
2. Identify main branches (3-7 recommended)
3. Add sub-points to each branch
4. Use colors or icons for visual distinction
5. Keep it simple and readable

