# 测试数据示例

## 数据库示例数据

```sql
-- 确保你的数据库中有这样的数据结构
INSERT INTO songs (id, name, url, singer_id, pic) VALUES 
(1, '稻香', 'music/daoxiang.mp3', 1, 'images/daoxiang.jpg'),
(2, '七里香', 'music/qilixiang.mp3', 1, 'images/qilixiang.jpg'),
(3, '青花瓷', 'music/qinghuaci.mp3', 1, 'images/qinghuaci.jpg');
```

## 后端文件结构检查

确保你的文件结构如下：
```
BackEnd/
├── public/
│   ├── music/
│   │   ├── daoxiang.mp3      ✓ 存在
│   │   ├── qilixiang.mp3     ✓ 存在
│   │   └── qinghuaci.mp3     ✓ 存在
│   └── images/
│       ├── daoxiang.jpg      ✓ 存在
│       ├── qilixiang.jpg     ✓ 存在
│       └── qinghuaci.jpg     ✓ 存在
├── app.js                    # 你的Express服务器文件
└── package.json
```

## Express服务器配置验证

确保你的Express服务器配置正确：

```javascript
const express = require('express');
const path = require('path');
const app = express();

// 静态文件服务
app.use(express.static(path.join(__dirname, 'public')));

// API路由
app.use('/api', require('./routes/api'));

// 启动服务器
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`服务器运行在 http://localhost:${PORT}`);
  console.log(`音频文件测试: http://localhost:${PORT}/music/daoxiang.mp3`);
});
```

## 测试步骤

1. **启动后端服务器**
   ```bash
   cd BackEnd
   npm start
   ```

2. **测试音频文件访问**
   在浏览器中访问：
   ```
   http://localhost:3000/music/daoxiang.mp3
   ```
   
3. **检查前端配置**
   - 确保AppConfig.ets中的SERVER_BASE_URL正确
   - 查看控制台日志确认URL构建正确

4. **运行HarmonyOS应用**
   - 构建并运行应用
   - 点击歌曲进行播放测试
   - 查看日志输出
