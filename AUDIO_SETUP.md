# 音乐播放功能配置说明

## 后端音乐文件播放集成

### 1. 配置说明

#### 后端服务器配置
在 `AppConfig.ets` 中配置后端服务器地址：
```typescript
static readonly SERVER_BASE_URL = 'http://localhost:3000';
static readonly AUDIO_BASE_URL = `${AppConfig.SERVER_BASE_URL}/audio`;
```

# 音乐播放功能配置说明

## 后端音乐文件播放集成

### 1. 你的项目配置

#### 数据库URL格式
```sql
-- 你的数据库中的URL字段格式
url: "music/daoxiang.mp3"
```

#### 后端文件结构
```
BackEnd/
├── public/
│   ├── music/
│   │   ├── daoxiang.mp3
│   │   ├── qilixiang.mp3
│   │   └── ...
│   └── images/
└── api/
```

#### Express.js后端配置
```javascript
// 在你的后端主文件中应该有类似这样的配置
app.use(express.static('public'));

// 这样配置后，访问路径将是：
// http://localhost:3000/music/daoxiang.mp3
```

### 2. 前端配置更新

#### AppConfig.ets 已更新为：
```typescript
export class AppConfig {
  static readonly SERVER_BASE_URL = 'http://localhost:3000';
  static readonly STATIC_BASE_URL = `${AppConfig.SERVER_BASE_URL}`;
  
  static buildAudioUrl(audioPath: string): string {
    // 数据库: "music/daoxiang.mp3"
    // 返回: "http://localhost:3000/music/daoxiang.mp3"
    return `${AppConfig.STATIC_BASE_URL}/${audioPath}`;
  }
}
```

### 3. URL转换过程

#### 完整的URL构建流程：
```
数据库存储: "music/daoxiang.mp3"
        ↓
AppConfig处理: "http://localhost:3000/music/daoxiang.mp3"
        ↓
实际文件路径: "BackEnd/public/music/daoxiang.mp3"
        ↓
Express访问: GET http://localhost:3000/music/daoxiang.mp3
```

### 4. 后端Express配置验证

确保你的后端有以下配置：

```javascript
const express = require('express');
const app = express();

// 静态文件服务 - 将public目录设为静态文件根目录
app.use(express.static('public'));

// 或者如果你的public目录在其他位置：
// app.use(express.static(path.join(__dirname, 'public')));

app.listen(3000, () => {
  console.log('服务器运行在 http://localhost:3000');
});
```

### 5. 测试音频文件访问

#### 直接在浏览器中测试：
```
http://localhost:3000/music/daoxiang.mp3
```

如果能正常访问并播放，说明配置正确。

### 6. 调试和验证

#### 前端日志输出：
```typescript
console.log('URL构建过程:', {
  原始数据库URL: "music/daoxiang.mp3",
  构建后的完整URL: "http://localhost:3000/music/daoxiang.mp3"
});
```

#### 后端日志验证：
```javascript
// 在Express中添加日志中间件
app.use('/music', (req, res, next) => {
  console.log('音频文件请求:', req.path);
  next();
});
```

### 4. 后端服务器配置

#### Express.js 示例配置
```javascript
// 静态文件服务
app.use('/audio', express.static(path.join(__dirname, 'audio')));

// 音频文件路由
app.get('/audio/:folder/:filename', (req, res) => {
  const { folder, filename } = req.params;
  const filePath = path.join(__dirname, 'audio', folder, filename);
  
  if (fs.existsSync(filePath)) {
    res.sendFile(filePath);
  } else {
    res.status(404).send('音频文件不存在');
  }
});
```

#### Nginx 配置示例
```nginx
server {
    listen 3000;
    server_name localhost;
    
    # 音频文件服务
    location /audio/ {
        alias /path/to/audio/files/;
        expires 1d;
        add_header Cache-Control "public, immutable";
    }
    
    # API代理
    location /api/ {
        proxy_pass http://localhost:3001;
    }
}
```

### 5. 支持的音频格式

#### 当前支持格式
- MP3 (.mp3)
- WAV (.wav)
- AAC (.aac)
- M4A (.m4a)
- FLAC (.flac)

#### 推荐配置
- **音质**: 128kbps - 320kbps
- **采样率**: 44.1kHz
- **声道**: 立体声
- **编码**: CBR (恒定比特率)

### 6. 缓存机制

#### 缓存策略
- **自动缓存**: 播放时自动下载到本地
- **缓存大小**: 默认100MB，可在AppConfig中调整
- **清理策略**: 超出限制时清空所有缓存

#### 缓存目录
```
/data/storage/el2/base/cache/audio_cache/
├── song_123.mp3
├── song_124.wav
└── ...
```

### 7. 网络权限配置

#### 必需权限
```json5
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET",
      "reason": "需要网络权限来播放在线音乐"
    },
    {
      "name": "ohos.permission.GET_NETWORK_INFO",
      "reason": "需要网络状态权限来检查网络连接"
    }
  ]
}
```

### 8. 错误处理

#### 常见错误及解决方案

1. **音频文件不存在**
   - 检查后端文件路径
   - 验证数据库URL字段

2. **网络连接失败**
   - 检查服务器地址配置
   - 确认网络权限

3. **音频格式不支持**
   - 转换为支持的格式
   - 检查文件完整性

### 9. 调试和日志

#### 播放日志示例
```typescript
console.log('准备播放音频:', {
  songName: song.name,
  songId: song.id,
  originalUrl: song.url,
  finalUrl: audioUrl
});
```

#### 调试步骤
1. 检查控制台日志
2. 验证音频URL可访问性
3. 测试后端服务器响应
4. 检查网络连接状态

### 10. 性能优化建议

#### 后端优化
- 使用CDN加速音频文件分发
- 启用Gzip压缩
- 设置合适的缓存头

#### 前端优化
- 预加载下一首歌曲
- 使用适当的音频质量
- 合理控制缓存大小

### 11. 示例完整配置

#### 开发环境
```typescript
// AppConfig.ets
export class AppConfig {
  static readonly SERVER_BASE_URL = 'http://192.168.1.100:3000'; // 开发服务器
  static readonly AUDIO_BASE_URL = `${AppConfig.SERVER_BASE_URL}/audio`;
}
```

#### 生产环境
```typescript
// AppConfig.ets
export class AppConfig {
  static readonly SERVER_BASE_URL = 'https://api.mymusic.com'; // 生产服务器
  static readonly AUDIO_BASE_URL = `${AppConfig.SERVER_BASE_URL}/audio`;
}
```
