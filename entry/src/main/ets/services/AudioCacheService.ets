import fs from '@ohos.file.fs';
import { AppConfig } from '../common/AppConfig';
import request from '@ohos.request';

/**
 * 音频缓存管理服务
 */
export class AudioCacheService {
  private static instance: AudioCacheService;
  private cacheDir: string = '';
  private downloadTasks: Map<string, request.DownloadTask> = new Map();
  
  private constructor() {
    this.initCacheDir();
  }
  
  static getInstance(): AudioCacheService {
    if (!AudioCacheService.instance) {
      AudioCacheService.instance = new AudioCacheService();
    }
    return AudioCacheService.instance;
  }
  
  /**
   * 初始化缓存目录
   */
  private async initCacheDir(): Promise<void> {
    try {
      // 获取应用缓存目录
      const context = globalThis.abilityContext;
      this.cacheDir = `${context.cacheDir}/audio_cache`;
      
      // 创建缓存目录
      if (!fs.accessSync(this.cacheDir)) {
        fs.mkdirSync(this.cacheDir, true);
        console.log('创建音频缓存目录:', this.cacheDir);
      }
    } catch (error) {
      console.error('初始化缓存目录失败:', error);
    }
  }
  
  /**
   * 获取歌曲的缓存文件路径
   */
  getCachedFilePath(songId: number, url: string): string {
    const extension = this.getFileExtension(url);
    return `${this.cacheDir}/song_${songId}.${extension}`;
  }
  
  /**
   * 检查歌曲是否已缓存
   */
  isCached(songId: number, url: string): boolean {
    const filePath = this.getCachedFilePath(songId, url);
    try {
      return fs.accessSync(filePath);
    } catch {
      return false;
    }
  }
  
  /**
   * 预缓存歌曲
   */
  async preCache(songId: number, url: string): Promise<string | null> {
    try {
      // 检查是否已缓存
      if (this.isCached(songId, url)) {
        const cachedPath = this.getCachedFilePath(songId, url);
        console.log('歌曲已缓存:', cachedPath);
        return cachedPath;
      }
      
      // 构建完整URL
      const fullUrl = AppConfig.buildAudioUrl(url);
      const localPath = this.getCachedFilePath(songId, url);
      
      console.log('开始缓存音频:', {
        songId,
        url: fullUrl,
        localPath
      });
      
      // 创建下载任务
      const downloadConfig: request.DownloadConfig = {
        url: fullUrl,
        filePath: localPath,
        enableMetered: true,
        enableRoaming: true,
        description: `缓存歌曲 ${songId}`,
        networkType: request.NETWORK_WIFI | request.NETWORK_MOBILE,
        title: `音频缓存 ${songId}`
      };
      
      const downloadTask = await request.downloadFile(globalThis.abilityContext, downloadConfig);
      this.downloadTasks.set(songId.toString(), downloadTask);
      
      return new Promise((resolve, reject) => {
        downloadTask.on('complete', () => {
          console.log('音频缓存完成:', localPath);
          this.downloadTasks.delete(songId.toString());
          resolve(localPath);
        });
        
        downloadTask.on('fail', (error: number) => {
          console.error('音频缓存失败:', error);
          this.downloadTasks.delete(songId.toString());
          // 删除可能的部分下载文件
          try {
            if (fs.accessSync(localPath)) {
              fs.unlinkSync(localPath);
            }
          } catch (e) {
            console.error('删除部分下载文件失败:', e);
          }
          reject(new Error(`下载失败: ${error}`));
        });
        
        downloadTask.on('progress', (receivedSize: number, totalSize: number) => {
          const progress = Math.round((receivedSize / totalSize) * 100);
          console.log(`缓存进度 ${songId}: ${progress}%`);
        });
      });
    } catch (error) {
      console.error('预缓存失败:', error);
      return null;
    }
  }
  
  /**
   * 获取文件扩展名
   */
  private getFileExtension(url: string): string {
    const parts = url.split('.');
    return parts.length > 1 ? parts.pop() || 'mp3' : 'mp3';
  }
  
  /**
   * 清理缓存
   */
  async clearCache(): Promise<void> {
    try {
      // 取消所有下载任务
      for (const [songId, task] of this.downloadTasks) {
        await task.delete();
        this.downloadTasks.delete(songId);
      }
      
      // 删除缓存文件
      if (fs.accessSync(this.cacheDir)) {
        const files = fs.listFileSync(this.cacheDir);
        for (const file of files) {
          const filePath = `${this.cacheDir}/${file}`;
          fs.unlinkSync(filePath);
        }
        console.log('缓存清理完成');
      }
    } catch (error) {
      console.error('清理缓存失败:', error);
    }
  }
  
  /**
   * 获取缓存大小
   */
  async getCacheSize(): Promise<number> {
    try {
      let totalSize = 0;
      if (fs.accessSync(this.cacheDir)) {
        const files = fs.listFileSync(this.cacheDir);
        for (const file of files) {
          const filePath = `${this.cacheDir}/${file}`;
          const stat = fs.statSync(filePath);
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (error) {
      console.error('获取缓存大小失败:', error);
      return 0;
    }
  }
  
  /**
   * 检查缓存空间并清理
   */
  async checkAndCleanCache(): Promise<void> {
    try {
      const currentSize = await this.getCacheSize();
      const maxSize = AppConfig.AUDIO_CONFIG.CACHE_SIZE * 1024 * 1024; // 转换为字节
      
      if (currentSize > maxSize) {
        console.log('缓存超出限制，开始清理...');
        // 简单策略：清理所有缓存
        await this.clearCache();
      }
    } catch (error) {
      console.error('检查缓存空间失败:', error);
    }
  }
}
