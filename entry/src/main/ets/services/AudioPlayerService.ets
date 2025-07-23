import media from '@ohos.multimedia.media';
import { BusinessError } from '@kit.BasicServicesKit';
import { Song } from '../models/DataModels';
import { AppConfig } from '../common/AppConfig';

/**
 * 播放状态枚举
 */
export enum PlayState {
  IDLE = 'idle',
  PREPARING = 'preparing',
  PREPARED = 'prepared',
  PLAYING = 'playing',
  PAUSED = 'paused',
  STOPPED = 'stopped',
  ERROR = 'error'
}

/**
 * 音频播放服务
 */
export class AudioPlayerService {
  private static instance: AudioPlayerService;
  private audioPlayer: media.AVPlayer | null = null;
  private currentSong: Song | null = null;
  private playState: PlayState = PlayState.IDLE;
  private duration: number = 0;
  private currentTime: number = 0;
  private seekPending: boolean = false;
  
  // 事件回调
  private onStateChangeCallback?: (state: PlayState) => void;
  private onTimeUpdateCallback?: (currentTime: number, duration: number) => void;
  private onErrorCallback?: (error: string) => void;
  private onCompletedCallback?: () => void;
  
  private constructor() {}
  
  static getInstance(): AudioPlayerService {
    if (!AudioPlayerService.instance) {
      AudioPlayerService.instance = new AudioPlayerService();
    }
    return AudioPlayerService.instance;
  }
  
  /**
   * 初始化播放器
   */
  async initPlayer(): Promise<boolean> {
    try {
      if (this.audioPlayer) {
        await this.release();
      }
      
      this.audioPlayer = await media.createAVPlayer();
      this.setupPlayerCallbacks();
      console.log('音频播放器初始化成功');
      return true;
    } catch (error) {
      console.error('初始化音频播放器失败:', error);
      this.onErrorCallback?.('初始化播放器失败');
      return false;
    }
  }
  
  /**
   * 设置播放器回调
   */
  private setupPlayerCallbacks(): void {
    if (!this.audioPlayer) return;
    
    // 状态变化回调
    this.audioPlayer.on('stateChange', (state: media.AVPlayerState) => {
      console.log('播放器状态变化:', state);
      switch (state) {
        case 'idle':
          this.playState = PlayState.IDLE;
          break;
        case 'initialized':
          // 仅为内部状态，UI层面可忽略
          break;
        case 'prepared':
          this.playState = PlayState.PREPARED;
          break;
        case 'playing':
          this.playState = PlayState.PLAYING;
          break;
        case 'paused':
          this.playState = PlayState.PAUSED;
          break;
        case 'stopped':
          this.playState = PlayState.STOPPED;
          break;
        case 'error':
          this.playState = PlayState.ERROR;
          break;
        default:
          // 处理未预期的状态
          console.warn(`未知的播放器状态: ${state}`);
          break;
      }
      this.onStateChangeCallback?.(this.playState);
    });
    
    // 时间更新回调
    this.audioPlayer.on('timeUpdate', (time: number) => {
      if (!this.seekPending) {
        // 将毫秒转换为秒
        this.currentTime = Math.floor(time / 1000);
        this.onTimeUpdateCallback?.(this.currentTime, this.duration);
      }
    });
    
    // 持续时间变化回调
    this.audioPlayer.on('durationUpdate', (duration: number) => {
      // 将毫秒转换为秒
      this.duration = Math.floor(duration / 1000);
      console.log('音频时长(秒):', this.duration);
      this.onTimeUpdateCallback?.(this.currentTime, this.duration);
    });
    
    // 播放完成回调
    this.audioPlayer.on('endOfStream', () => {
      console.log('播放完成');
      this.onCompletedCallback?.();
    });
    
    // 错误回调
    this.audioPlayer.on('error', (error: BusinessError) => {
      console.error('播放器错误:', error);
      this.playState = PlayState.ERROR;
      this.onErrorCallback?.(`播放错误: ${error.message}`);
    });
  }

  /**
   * 等待播放器达到指定状态
   */
  private waitForState(targetState: 'idle' | 'initialized' | 'prepared', timeout: number = 5000): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!this.audioPlayer) {
        return reject(new Error('播放器未初始化'));
      }

      // 如果当前状态已经是目标状态，直接返回
      if (this.audioPlayer.state === targetState) {
        return resolve();
      }

      const timeoutId = setTimeout(() => {
        this.audioPlayer!.off('stateChange', stateChangeCallback);
        reject(new Error(`等待状态 ${targetState} 超时`));
      }, timeout);

      const stateChangeCallback = (state: media.AVPlayerState) => {
        if (state === targetState) {
          clearTimeout(timeoutId);
          this.audioPlayer!.off('stateChange', stateChangeCallback);
          resolve();
        }
      };

      this.audioPlayer.on('stateChange', stateChangeCallback);
    });
  }
  
  /**
   * 播放歌曲
   */
  async playSong(song: Song): Promise<boolean> {
    try {
      console.log('=== playSong: 开始处理歌曲', { id: song.id, name: song.name });

      if (!this.audioPlayer) {
        console.log('playSong: 播放器未初始化，正在初始化...');
        const initSuccess = await this.initPlayer();
        if (!initSuccess) {
          console.error('playSong: 初始化播放器失败');
          return false;
        }
      }

      // 如果是同一首歌且播放器处于暂停状态，直接恢复播放
      if (this.currentSong?.id === song.id && this.audioPlayer?.state === 'paused') {
        console.log('playSong: 恢复播放同一首歌曲');
        return await this.resume();
      }

      console.log('playSong: 准备播放新歌曲或重新播放，重置播放器...');
      await this.audioPlayer!.reset();
      await this.waitForState('idle');
      console.log('playSong: 播放器已重置到 idle 状态');

      this.currentSong = song;
      this.playState = PlayState.PREPARING;
      this.onStateChangeCallback?.(this.playState);

      const audioUrl = this.buildAudioUrl(song.url || '');
      console.log('playSong: 设置播放器 URL:', audioUrl);
      this.audioPlayer!.url = audioUrl;
      await this.waitForState('initialized');
      console.log('playSong: 播放器已进入 initialized 状态');

      console.log('playSong: 准备播放器...');
      await this.audioPlayer!.prepare();
      await this.waitForState('prepared');
      console.log('playSong: 播放器已进入 prepared 状态');

      console.log('playSong: 开始播放...');
      await this.audioPlayer!.play();
      // 手动触发状态更新回调，确保UI立即显示为播放状态
      this.playState = PlayState.PLAYING;
      this.onStateChangeCallback?.(this.playState);
      console.log('playSong: 成功开始播放歌曲:', song.name);
      return true;
    } catch (error) {
      console.error('playSong: 播放歌曲失败', { song: song.name, error: error });
      this.playState = PlayState.ERROR;
      this.onErrorCallback?.(`播放失败: ${error}`);
      return false;
    }
  }
  
  /**
   * 暂停播放
   */
  async pause(): Promise<boolean> {
    try {
      // 直接检查播放器的原生状态，避免UI状态延迟
      if (this.audioPlayer && this.audioPlayer.state === 'playing') {
        await this.audioPlayer.pause();
        // 手动触发状态更新回调，确保UI立即响应
        this.playState = PlayState.PAUSED;
        this.onStateChangeCallback?.(this.playState);
        return true;
      }
      console.warn(`Pause called when state is not 'playing'. Current AVPlayer state: ${this.audioPlayer?.state}`);
      return false;
    } catch (error) {
      console.error('暂停播放失败:', error);
      this.onErrorCallback?.('暂停播放失败');
      return false;
    }
  }
  
  /**
   * 恢复播放
   */
  async resume(): Promise<boolean> {
    try {
      // 直接检查播放器的原生状态，避免UI状态延迟
      if (this.audioPlayer && this.audioPlayer.state === 'paused') {
        await this.audioPlayer.play();
        // 手动触发状态更新回调，确保UI立即响应
        this.playState = PlayState.PLAYING;
        this.onStateChangeCallback?.(this.playState);
        return true;
      }
      console.warn(`Resume called when state is not 'paused'. Current AVPlayer state: ${this.audioPlayer?.state}`);
      return false;
    } catch (error) {
      console.error('恢复播放失败:', error);
      this.onErrorCallback?.('恢复播放失败');
      return false;
    }
  }
  
  /**
   * 停止播放
   */
  async stop(): Promise<boolean> {
    try {
      if (this.audioPlayer && (this.playState === PlayState.PLAYING || this.playState === PlayState.PAUSED)) {
        await this.audioPlayer.stop();
        return true;
      }
      return false;
    } catch (error) {
      console.error('停止播放失败:', error);
      this.onErrorCallback?.('停止播放失败');
      return false;
    }
  }
  
  /**
   * 跳转到指定时间
   */
  async seekTo(time: number): Promise<boolean> {
    try {
      if (this.audioPlayer && this.playState !== PlayState.IDLE) {
        this.seekPending = true;
        await this.audioPlayer.seek(time * 1000); // 转换为毫秒
        this.currentTime = time;
        setTimeout(() => {
          this.seekPending = false;
        }, 100);
        return true;
      }
      return false;
    } catch (error) {
      console.error('跳转失败:', error);
      this.seekPending = false;
      this.onErrorCallback?.('跳转失败');
      return false;
    }
  }
  
  /**
   * 设置音量
   */
  async setVolume(volume: number): Promise<boolean> {
    try {
      if (this.audioPlayer) {
        await this.audioPlayer.setVolume(Math.max(0, Math.min(1, volume)));
        return true;
      }
      return false;
    } catch (error) {
      console.error('设置音量失败:', error);
      return false;
    }
  }
  
  /**
   * 释放播放器资源
   */
  async release(): Promise<void> {
    try {
      if (this.audioPlayer) {
        await this.audioPlayer.release();
        this.audioPlayer = null;
        this.currentSong = null;
        this.playState = PlayState.IDLE;
        this.duration = 0;
        this.currentTime = 0;
        console.log('播放器资源已释放');
      }
    } catch (error) {
      console.error('释放播放器失败:', error);
    }
  }
  
  /**
   * 构建音频URL
   * 数据库URL: "music/daoxiang.mp3"
   * 最终URL: "http://localhost:3000/music/daoxiang.mp3"
   */
  private buildAudioUrl(url: string): string {
    if (!url) {
      // 返回测试音频URL
      console.warn('音频URL为空，使用测试音频');
      return 'https://music.163.com/song/media/outer/url?id=25906124';
    }
    
    // 使用AppConfig构建音频URL
    const audioUrl = AppConfig.buildAudioUrl(url);
    console.log('URL构建过程:', {
      原始数据库URL: url,
      构建后的完整URL: audioUrl
    });
    
    // 检查音频格式是否支持
    if (!AppConfig.isSupportedAudioFormat(url)) {
      console.warn('不支持的音频格式:', url);
    }
    
    return audioUrl;
  }
  
  /**
   * 验证音频URL是否可访问
   */
  private async validateAudioUrl(url: string): Promise<boolean> {
    try {
      // 这里可以添加URL可访问性检查
      // 目前简单返回true，实际项目中可以发送HEAD请求检查
      return true;
    } catch (error) {
      console.error('音频URL验证失败:', error);
      return false;
    }
  }
  
  // Getter方法
  getCurrentSong(): Song | null {
    return this.currentSong;
  }
  
  getPlayState(): PlayState {
    return this.playState;
  }
  
  getDuration(): number {
    return this.duration;
  }
  
  getCurrentTime(): number {
    return this.currentTime;
  }
  
  isPlaying(): boolean {
    // 直接检查播放器的原生状态，确保UI能获取到最准确的播放状态
    return this.audioPlayer?.state === 'playing';
  }
  
  // 事件监听器设置
  setOnStateChange(callback: (state: PlayState) => void): void {
    this.onStateChangeCallback = callback;
  }
  
  setOnTimeUpdate(callback: (currentTime: number, duration: number) => void): void {
    this.onTimeUpdateCallback = callback;
  }
  
  setOnError(callback: (error: string) => void): void {
    this.onErrorCallback = callback;
  }
  
  setOnCompleted(callback: () => void): void {
    this.onCompletedCallback = callback;
  }
}
