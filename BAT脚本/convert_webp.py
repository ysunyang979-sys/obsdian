import os
import sys
import re
from PIL import Image

def convert_images_to_webp(vault_path, quality=80):
    vault_path = os.path.abspath(vault_path)
    print(f"正在扫描笔记库: {vault_path}")
    
    valid_exts = ('.png', '.jpg', '.jpeg')
    converted_map = {}
    
    # 1. 查找并转换所有图片文件为 webp
    for root, dirs, files in os.walk(vault_path):
        if '.git' in root or '.obsidian' in root or '.trash' in root:
            continue
        for file in files:
            name, ext = os.path.splitext(file)
            ext_lower = ext.lower()
            if ext_lower in valid_exts:
                img_path = os.path.join(root, file)
                webp_name = f"{name}.webp"
                webp_path = os.path.join(root, webp_name)
                
                try:
                    with Image.open(img_path) as img:
                        # 处理 RGBA 模式
                        if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
                            img.save(webp_path, "WEBP", quality=quality, method=6)
                        else:
                            img.convert("RGB").save(webp_path, "WEBP", quality=quality, method=6)
                    
                    orig_size = os.path.getsize(img_path) / 1024
                    webp_size = os.path.getsize(webp_path) / 1024
                    saved = (1 - webp_size / orig_size) * 100 if orig_size > 0 else 0
                    print(f"✅ 转换: {file} ({orig_size:.1f} KB) -> {webp_name} ({webp_size:.1f} KB, 节省 {saved:.1f}%)")
                    
                    converted_map[file] = webp_name
                    # 删除原图
                    os.remove(img_path)
                except Exception as e:
                    print(f"❌ 转换失败 {file}: {e}")

    if not converted_map:
        print("未发现需要转换的 PNG/JPG 图片（库内已全是 WebP 格式或暂无图片）。")
        return

    # 2. 批量替换所有 Markdown 笔记中的图片引用
    print("\n正在更新 Markdown 笔记中的图片引用链接...")
    updated_files = 0
    for root, dirs, files in os.walk(vault_path):
        if '.git' in root or '.obsidian' in root or '.trash' in root:
            continue
        for file in files:
            if file.endswith('.md'):
                md_path = os.path.join(root, file)
                try:
                    with open(md_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    modified = False
                    for old_name, new_name in converted_map.items():
                        if old_name in content:
                            content = content.replace(old_name, new_name)
                            modified = True
                    
                    if modified:
                        with open(md_path, 'w', encoding='utf-8') as f:
                            f.write(content)
                        updated_files += 1
                        print(f"  📝 已更新引用: {file}")
                except Exception as e:
                    print(f"  ❌ 更新失败 {file}: {e}")

    print(f"\n🎉 全部处理完成！共转换 {len(converted_map)} 张图片，更新了 {updated_files} 篇笔记。")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        v_path = sys.argv[1]
    else:
        v_path = r"F:\Tools\obsidian\cangku\first"
    convert_images_to_webp(v_path)
