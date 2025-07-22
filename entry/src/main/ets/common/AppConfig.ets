/**
 * 音频配置接口
 */
interface AudioConfig {
  SUPPORTED_FORMATS: string[];
  DEFAULT_QUALITY: string;
  PRELOAD_TIME: number;
  CACHE_SIZE: number;
}

/**
 * 网络配置接口
 */
interface NetworkConfig {
  CONNECT_TIMEOUT: number;
  READ_TIMEOUT: number;
  RETRY_COUNT: number;
  RETRY_INTERVAL: number;
}

/**
 * 应用配置常量
 */
export class AppConfig {
  // 后端服务器地址配置
  static readonly SERVER_BASE_URL = 'http://10.130.3.83:8000';
  static readonly API_BASE_URL = `${AppConfig.SERVER_BASE_URL}/api`;
  
  // 静态文件访问配置 - 对应后端的 public 目录
  static readonly STATIC_BASE_URL = `${AppConfig.SERVER_BASE_URL}`;
  
  // 图片资源配置
  static readonly IMAGE_BASE_URL = `${AppConfig.SERVER_BASE_URL}/images`;
  
  // 音频播放配置
  static readonly AUDIO_CONFIG: AudioConfig = {
    // 支持的音频格式
    SUPPORTED_FORMATS: ['mp3', 'wav', 'aac', 'm4a', 'flac'],
    // 默认音频质量
    DEFAULT_QUALITY: '128k',
    // 预加载时间（秒）
    PRELOAD_TIME: 30,
    // 缓存大小（MB）
    CACHE_SIZE: 100
  };
  
  // 网络请求配置
  static readonly NETWORK_CONFIG: NetworkConfig = {
    // 连接超时时间（毫秒）
    CONNECT_TIMEOUT: 10000,
    // 读取超时时间（毫秒）
    READ_TIMEOUT: 30000,
    // 重试次数
    RETRY_COUNT: 3,
    // 重试间隔（毫秒）
    RETRY_INTERVAL: 1000
  };
  
  /**
   * 构建完整的音频文件URL
   * 数据库格式: "music/daoxiang.mp3"
   * 后端文件: "BackEnd/public/music/daoxiang.mp3"
   * 访问URL: "http://localhost:3000/music/daoxiang.mp3"
   */
  static buildAudioUrl(audioPath: string): string {
    if (!audioPath) {
      return '';
    }
    
    // 如果已经是完整URL，直接返回
    if (audioPath.startsWith('http://') || audioPath.startsWith('https://')) {
      return audioPath;
    }
    
    // 去掉开头的斜杠（如果有的话）
    const cleanPath = audioPath.startsWith('/') ? audioPath.substring(1) : audioPath;
    
    // 构建完整URL - 直接拼接到服务器根路径
    // 因为Express会将public目录作为静态文件根目录
    return `${AppConfig.STATIC_BASE_URL}/${cleanPath}`;
  }
  
  /**
   * 构建API请求URL
   */
  static buildApiUrl(endpoint: string): string {
    const cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return `${AppConfig.API_BASE_URL}/${cleanEndpoint}`;
  }
  
  /**
   * 构建图片URL
   */
  static buildImageUrl(imagePath: string): string {
    if (!imagePath) {
      return '';
    }
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    const cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return `${AppConfig.IMAGE_BASE_URL}/${cleanPath}`;
  }
  
  /**
   * 检查音频格式是否支持
   */
  static isSupportedAudioFormat(filename: string): boolean {
    const extension = filename.split('.').pop()?.toLowerCase();
    return extension ? AppConfig.AUDIO_CONFIG.SUPPORTED_FORMATS.includes(extension) : false;
  }
}
