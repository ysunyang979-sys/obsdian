import os
import sys
import shutil
import re
import datetime

vault_path = r"F:\Tools\obsidian\cangku\first"
hexo_source_posts = r"F:\Tools\hexo_blog\source\_posts\study"

os.makedirs(hexo_source_posts, exist_ok=True)

# 需要同步到博客的目录或文件
sync_folders = ["02-词语", "03-知识点", "01-错题"]

synced_count = 0

for folder in sync_folders:
    src_dir = os.path.join(vault_path, folder)
    if not os.path.exists(src_dir):
        continue
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith(".md"):
                src_file = os.path.join(root, file)
                rel_path = os.path.relpath(src_file, vault_path)
                dest_file = os.path.join(hexo_source_posts, file)
                
                with open(src_file, "r", encoding="utf-8") as f:
                    content = f.read()
                
                title = os.path.splitext(file)[0].lstrip("# ").strip()
                now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                
                # 如果没有 Frontmatter，自动补齐 Hexo 所需元数据
                if not content.startswith("---"):
                    frontmatter = f"---\ntitle: {title}\ndate: {now_str}\ncategories:\n  - 学习笔记\n  - {folder}\ntags:\n  - 学习\n  - 公考\n---\n\n"
                    content = frontmatter + content
                
                with open(dest_file, "w", encoding="utf-8") as f:
                    f.write(content)
                synced_count += 1
                print(f"  📄 同步到博客: {file}")

# 同步根目录下的精选笔记（例如 Day 1）
for file in os.listdir(vault_path):
    if file.endswith(".md") and not file.startswith("00-") and not file.startswith("README"):
        src_file = os.path.join(vault_path, file)
        dest_file = os.path.join(hexo_source_posts, file.replace("# ", ""))
        with open(src_file, "r", encoding="utf-8") as f:
            content = f.read()
        title = os.path.splitext(file)[0].lstrip("# ").strip()
        now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if not content.startswith("---"):
            frontmatter = f"---\ntitle: {title}\ndate: {now_str}\ncategories:\n  - 学习笔记\ntags:\n  - 言语理解\n---\n\n"
            content = frontmatter + content
        with open(dest_file, "w", encoding="utf-8") as f:
            f.write(content)
        synced_count += 1
        print(f"  📄 同步到博客: {file}")

print(f"\n🎉 共同步 {synced_count} 篇笔记到 Hexo 博客目录！")
