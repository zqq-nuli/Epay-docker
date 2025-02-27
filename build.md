针对使用 Nuitka 打包深度学习项目耗时过长的问题，以下是分步解决方案：

---

### **1. 启用并行编译加速**
Nuitka 默认使用单线程编译，可通过 `--jobs` 参数启用多核并行编译：
```bash
nuitka --standalone --enable-plugin=pyqt5 --jobs=8 main.py
```
- 将 `--jobs=8` 改为你的 CPU 核心数（如 4/6/8）。
- **效果**：编译时间可减少 30%-50%。

---

### **2. 利用缓存复用中间结果**
添加 `--enable-plugin=nuitka-plugin-enable-cache` 启用缓存：
```bash
nuitka --standalone --enable-plugin=pyqt5 --enable-plugin=nuitka-plugin-enable-cache main.py
```
- **原理**：首次编译后，后续编译会跳过未更改的代码。
- **注意**：修改代码或依赖后需清理缓存（删除生成的 `.build` 文件夹）。

---

### **3. 精简深度学习依赖**
深度学习库（如 PyTorch/TensorFlow）包含大量冗余文件，需手动裁剪：

#### **示例：优化 PyTorch 依赖**
```python
# 在代码中显式导入所需模块，避免动态导入
import torch.nn as nn
import torch.optim  # 避免 from torch import *
```
```bash
# 打包时排除未使用的模块
nuitka --standalone --enable-plugin=pyqt5 --include-package=torch.nn --nofollow-import-to=torch.testing main.py
```
- **关键参数**：
  - `--include-package`：仅包含必要子模块。
  - `--nofollow-import-to`：排除测试、示例等无用模块。
- **手动裁剪**：在虚拟环境中删除 `torch/lib` 下未用的 CUDA 版本（如仅保留 `libcublas.so.11`）。

---

### **4. 分阶段打包（先目录后单文件）**
直接生成单文件 (`--onefile`) 效率低，建议分两步：
```bash
# 第一阶段：生成目录结构（快速调试）
nuitka --standalone --enable-plugin=pyqt5 main.py

# 第二阶段：将目录压缩为单文件（可选）
cd main.dist && zip -9 -r ../app.zip . && cat /usr/local/bin/zip2exe.py app.zip > app.exe
```
- **优势**：调试阶段使用目录形式，发布时再生成单文件。

---

### **5. 使用虚拟环境隔离依赖**
创建纯净的虚拟环境避免打包无关库：
```bash
python -m venv myenv && source myenv/bin/activate
pip install -r requirements.txt  # 仅安装必要依赖
nuitka --standalone --enable-plugin=pyqt5 main.py
```

---

### **6. 针对 OpenCV 和 PyQt5 优化**
#### **OpenCV 精简**
```bash
# 删除 opencv_python 中未用的 *.so 文件
rm venv/lib/python3.8/site-packages/cv2/data/*.xml  # 保留实际用到的模型文件
```
#### **PyQt5 优化**
```bash
# 删除未用的 Qt 组件
rm -r venv/lib/python3.8/site-packages/PyQt5/Qt/translations/qt_*.qm
```

---

### **7. 替换依赖项为轻量版本**
- 将 `opencv-python` 替换为无 GUI 支持的 `opencv-python-headless`：
  ```bash
  pip uninstall opencv-python && pip install opencv-python-headless
  ```

---

### **8. 终极方案：升级硬件**
- 使用 SSD 硬盘（机械硬盘打包速度可能慢 5-10 倍）。
- 增加内存至 16GB 以上避免交换。

---

### **完整优化命令示例**
```bash
nuitka --standalone \
       --enable-plugin=pyqt5 \
       --jobs=8 \
       --enable-plugin=nuitka-plugin-enable-cache \
       --include-package=torch.nn \
       --nofollow-import-to=torch.testing \
       --nofollow-import-to=torch.distributed \
       main.py
```

---

通过上述步骤，预计可将打包时间从数小时缩短至 10-30 分钟。如果问题仍未解决，建议提供 `nuitka --version` 和完整的打包命令进一步诊断。
