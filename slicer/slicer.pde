// --- 脚本 1: PonySlicer (带边缘裁剪功能) ---

void setup() {
  size(200, 200); 
  noLoop(); 
  
  // --- 配置区域 ---
  // 1. 输入文件路径
    // 2. 输出配置
  String outputFolder = "C:/Users/Admin/Documents/Processing/project/project-pony/output"; // 输出文件夹
  
  String inputFilename = "C:/Users/Admin/Documents/Processing/project/project-pony/data//bianpao-43x5"; 
  String outputPrefix = "/bianpao/bianpao_"; // 输出前缀
  //String inputFilename = "C:/Users/Admin/Documents/Processing/project/project-pony/data//runing-v3-middle（512 x 342）.png"; 
  //String outputPrefix = "/run-v3/run-v3_"; // 输出前缀
  
  //String inputFilename = "C:/Users/Admin/Documents/Processing/project/project-pony/data/running-V4(512x342).png"; 
  //String outputPrefix = "/run-v4/run-v4_"; // 输出前缀
  
  //String inputFilename = "C:/Users/Admin/Documents/Processing/project/project-pony/data/jumping-mid-V4(512x342).png"; 
  //String outputPrefix = "/jump-mid/jump-mid-v4_"; // 输出前缀
  
  //String inputFilename = "C:/Users/Admin/Documents/Processing/project/project-pony/data/jumping-V4(512x342).png"; 
  //String outputPrefix = "/jump-v4/jump-v4_"; // 输出前缀
  
  // 3. 布局参数
  int cols = 5;         // 列数
  int rows = 43;         // 行数
  int totalFrames =215; // 总帧数
  // 4. 【新增】边缘裁剪参数
  // 设置为 10.0 代表：总共切掉 10% 的大小（上下各切 5%，左右各切 5%）
  // 设置为 0.0 代表不裁剪
  float cropPercentage = 10.0; 
  // ----------------
  
  println("开始加载图片: " + inputFilename);
  PImage spriteSheet = loadImage(inputFilename);
  
  if (spriteSheet == null) {
    println("错误：找不到图片，请检查路径！");
    return;
  }
  
  // 计算原始单帧大小
  int frameW = spriteSheet.width / cols;
  int frameH = spriteSheet.height / rows;
  
  println("原始单帧尺寸: " + frameW + " x " + frameH);
  
  // --- 计算裁剪量 (Cut Margin) ---
  // 算出每条边需要向内缩进多少像素
  int marginX = int(frameW * (cropPercentage / 100.0) / 2.0);
  int marginY = int(frameH * (cropPercentage / 100.0) / 2.0);
  
  // 计算裁剪后的新尺寸
  int newWidth = frameW - (marginX * 2);
  int newHeight = frameH - (marginY * 2);
  
  println("裁剪设置: 缩减 " + cropPercentage + "%");
  println(">> X轴每边裁掉: " + marginX + "px");
  println(">> Y轴每边裁掉: " + marginY + "px");
  println(">> 最终输出尺寸: " + newWidth + " x " + newHeight);
  
  int index = 0;
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      if (index < totalFrames) {
        
        // --- 核心修改逻辑 ---
        
        // 1. 计算原始格子的左上角坐标
        int srcX = x * frameW;
        int srcY = y * frameH;
        
        // 2. 加上边距偏移量 (向内缩)
        int finalX = srcX + marginX;
        int finalY = srcY + marginY;
        
        // 3. 抠图 (使用裁剪后的新尺寸)
        // 注意：get() 的参数是 (x, y, w, h)
        PImage frame = spriteSheet.get(finalX, finalY, newWidth, newHeight);
        
        // 4. 构建文件名
        String filename = outputFolder + "/" + outputPrefix + nf(index, 2) + ".png";
        
        // 5. 保存
        // 使用 savePath 确保路径兼容性，或者直接用你的绝对路径
        frame.save(filename); 
        println("已保存: " + filename);
        
        index++;
      }
    }
  }
  
  println("--------------------------------");
  println("切分完成！共 " + index + " 张图片。");
  println("输出路径: " + outputFolder);
  exit(); 
}
