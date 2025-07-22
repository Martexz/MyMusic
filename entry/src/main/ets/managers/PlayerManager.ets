import { Song, PlayerState, PlayMode } from '../models/DataModels';
import { AudioPlayerService, PlayState } from '../services/AudioPlayerService';

/**
 * 音乐播放器管理类
 */
export class PlayerManager {
  private static instance: PlayerManager;
  private playerState: PlayerState;
  private listeners: Array<(state: PlayerState) => void> = [];
  private audioService: AudioPlayerService;
  private timeUpdateTimer: number = -1;
  
  private constructor() {
    this.playerState = {
      playlist: [],
      currentIndex: -1,
      isPlaying: false,
      currentTime: 0,
      duration: 0,
      playMode: PlayMode.SEQUENCE
    };
    
    this.audioService = AudioPlayerService.getInstance();
    this.setupAudioServiceCallbacks();
  }
  
  static getInstance(): PlayerManager {
    if (!PlayerManager.instance) {
      PlayerManager.instance = new PlayerManager();
    }
    return PlayerManager.instance;
  }
  
  /**
   * 设置音频服务回调
   */
  private setupAudioServiceCallbacks(): void {
    // 播放状态变化回调
    this.audioService.setOnStateChange((state: PlayState) => {
      this.playerState.isPlaying = (state === PlayState.PLAYING);
      this.notifyListeners();
    });
    
    // 时间更新回调
    this.audioService.setOnTimeUpdate((currentTime: number, duration: number) => {
      this.playerState.currentTime = currentTime;
      this.playerState.duration = duration;
      this.notifyListeners();
    });
    
    // 播放完成回调
    this.audioService.setOnCompleted(() => {
      this.handlePlayCompleted();
    });
    
    // 错误回调
    this.audioService.setOnError((error: string) => {
      console.error('播放错误:', error);
      this.playerState.isPlaying = false;
      this.notifyListeners();
    });
  }
  
  /**
   * 处理播放完成
   */
  private handlePlayCompleted(): void {
    switch (this.playerState.playMode) {
      case PlayMode.SINGLE:
        // 单曲循环，重新播放当前歌曲
        this.playCurrent();
        break;
      case PlayMode.SEQUENCE:
        // 顺序播放，播放下一首
        if (this.playerState.currentIndex < this.playerState.playlist.length - 1) {
          this.next();
        } else {
          // 播放列表结束
          this.playerState.isPlaying = false;
          this.notifyListeners();
        }
        break;
      case PlayMode.LOOP:
        // 列表循环，播放下一首，如果是最后一首则回到第一首
        this.next();
        break;
      case PlayMode.RANDOM:
        // 随机播放下一首
        this.playRandom();
        break;
      default:
        this.next();
        break;
    }
  }
  
  /**
   * 添加状态监听器
   */
  addListener(listener: (state: PlayerState) => void): void {
    this.listeners.push(listener);
  }
  
  /**
   * 移除状态监听器
   */
  removeListener(listener: (state: PlayerState) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }
  
  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    const currentState = JSON.parse(JSON.stringify(this.playerState)) as PlayerState;
    this.listeners.forEach(listener => listener(currentState));
  }
  
  /**
   * 获取当前播放状态
   */
  getPlayerState(): PlayerState {
    return JSON.parse(JSON.stringify(this.playerState)) as PlayerState;
  }
  
  /**
   * 设置播放列表
   */
  setPlaylist(songs: Song[], startIndex: number = 0): void {
    this.playerState.playlist = songs;
    this.playerState.currentIndex = startIndex;
    this.playerState.currentSong = songs[startIndex];
    this.notifyListeners();
  }
  
  /**
   * 播放指定歌曲
   */
  async playSong(song: Song, playlist?: Song[]): Promise<void> {
    if (playlist) {
      this.setPlaylist(playlist);
      const index = playlist.findIndex(s => s.id === song.id);
      this.playerState.currentIndex = index >= 0 ? index : 0;
    } else {
      // 如果当前播放列表中没有这首歌，添加到播放列表
      const existingIndex = this.playerState.playlist.findIndex(s => s.id === song.id);
      if (existingIndex >= 0) {
        this.playerState.currentIndex = existingIndex;
      } else {
        this.playerState.playlist.push(song);
        this.playerState.currentIndex = this.playerState.playlist.length - 1;
      }
    }
    
    this.playerState.currentSong = song;
    this.notifyListeners();
    
    // 使用音频服务播放歌曲
    await this.audioService.playSong(song);
  }
  
  /**
   * 播放当前歌曲
   */
  async playCurrent(): Promise<void> {
    if (this.playerState.currentIndex >= 0 && this.playerState.playlist.length > 0) {
      const currentSong = this.playerState.playlist[this.playerState.currentIndex];
      await this.audioService.playSong(currentSong);
    }
  }
  
  /**
   * 播放/暂停
   */
  async togglePlay(): Promise<void> {
    if (this.audioService.isPlaying()) {
      await this.audioService.pause();
    } else {
      if (this.audioService.getCurrentSong()) {
        await this.audioService.resume();
      } else {
        // 如果没有当前歌曲，播放播放列表中的第一首
        await this.playCurrent();
      }
    }
  }
  
  /**
   * 下一首
   */
  async next(): Promise<void> {
    if (this.playerState.playlist.length === 0) return;
    
    let nextIndex: number;
    
    switch (this.playerState.playMode) {
      case PlayMode.SEQUENCE:
        nextIndex = (this.playerState.currentIndex + 1) % this.playerState.playlist.length;
        break;
      case PlayMode.LOOP:
        nextIndex = (this.playerState.currentIndex + 1) % this.playerState.playlist.length;
        break;
      case PlayMode.SINGLE:
        nextIndex = this.playerState.currentIndex;
        break;
      case PlayMode.RANDOM:
        nextIndex = Math.floor(Math.random() * this.playerState.playlist.length);
        break;
      default:
        nextIndex = (this.playerState.currentIndex + 1) % this.playerState.playlist.length;
    }
    
    this.playerState.currentIndex = nextIndex;
    this.playerState.currentSong = this.playerState.playlist[nextIndex];
    this.notifyListeners();
    
    // 播放下一首歌曲
    await this.audioService.playSong(this.playerState.playlist[nextIndex]);
  }
  
  /**
   * 上一首
   */
  async previous(): Promise<void> {
    if (this.playerState.playlist.length === 0) return;
    
    let prevIndex: number;
    
    switch (this.playerState.playMode) {
      case PlayMode.RANDOM:
        prevIndex = Math.floor(Math.random() * this.playerState.playlist.length);
        break;
      default:
        prevIndex = this.playerState.currentIndex - 1;
        if (prevIndex < 0) {
          prevIndex = this.playerState.playlist.length - 1;
        }
    }
    
    this.playerState.currentIndex = prevIndex;
    this.playerState.currentSong = this.playerState.playlist[prevIndex];
    this.notifyListeners();
    
    // 播放上一首歌曲
    await this.audioService.playSong(this.playerState.playlist[prevIndex]);
  }
  
  /**
   * 随机播放
   */
  async playRandom(): Promise<void> {
    if (this.playerState.playlist.length === 0) return;
    
    const randomIndex = Math.floor(Math.random() * this.playerState.playlist.length);
    this.playerState.currentIndex = randomIndex;
    this.playerState.currentSong = this.playerState.playlist[randomIndex];
    this.notifyListeners();
    
    await this.audioService.playSong(this.playerState.playlist[randomIndex]);
  }
  
  /**
   * 切换播放模式
   */
  togglePlayMode(): void {
    const modes = [PlayMode.SEQUENCE, PlayMode.LOOP, PlayMode.SINGLE, PlayMode.RANDOM];
    const currentIndex = modes.indexOf(this.playerState.playMode);
    const nextIndex = (currentIndex + 1) % modes.length;
    this.playerState.playMode = modes[nextIndex];
    this.notifyListeners();
  }
  
  /**
   * 更新播放进度
   */
  updateProgress(currentTime: number, duration: number): void {
    this.playerState.currentTime = currentTime;
    this.playerState.duration = duration;
    this.notifyListeners();
  }
  
    /**
   * 跳转到指定时间
   */
  async seekTo(time: number): Promise<void> {
    await this.audioService.seekTo(time);
  }
  
  /**
   * 设置音量
   */
  async setVolume(volume: number): Promise<void> {
    await this.audioService.setVolume(volume);
  }
  
  /**
   * 停止播放
   */
  async stop(): Promise<void> {
    await this.audioService.stop();
    this.playerState.isPlaying = false;
    this.notifyListeners();
  }
  
  /**
   * 释放播放器资源
   */
  async release(): Promise<void> {
    if (this.timeUpdateTimer !== -1) {
      clearInterval(this.timeUpdateTimer);
      this.timeUpdateTimer = -1;
    }
    await this.audioService.release();
  }
  
  /**
   * 从播放列表中删除歌曲
   */
  removeSongFromPlaylist(index: number): void {
    if (index < 0 || index >= this.playerState.playlist.length) {
      return;
    }
    
    // 如果删除的是当前播放的歌曲
    if (index === this.playerState.currentIndex) {
      // 如果播放列表只有一首歌
      if (this.playerState.playlist.length === 1) {
        this.clearPlaylist();
        return;
      }
      
      // 播放下一首歌
      if (index < this.playerState.playlist.length - 1) {
        this.playerState.currentSong = this.playerState.playlist[index + 1];
      } else {
        this.playerState.currentIndex = 0;
        this.playerState.currentSong = this.playerState.playlist[0];
      }
    } else if (index < this.playerState.currentIndex) {
      // 如果删除的歌曲在当前播放歌曲之前，需要调整当前索引
      this.playerState.currentIndex--;
    }
    
    // 删除歌曲
    this.playerState.playlist.splice(index, 1);
    this.notifyListeners();
  }
  
  /**
   * 清空播放列表
   */
  clearPlaylist(): void {
    this.playerState.playlist = [];
    this.playerState.currentIndex = -1;
    this.playerState.currentSong = undefined;
    this.playerState.isPlaying = false;
    this.playerState.currentTime = 0;
    this.playerState.duration = 0;
    this.notifyListeners();
  }
  
  /**
   * 添加歌曲到播放列表
   */
  addToPlaylist(song: Song): void {
    // 检查歌曲是否已存在
    const existingIndex = this.playerState.playlist.findIndex(s => s.id === song.id);
    if (existingIndex === -1) {
      this.playerState.playlist.push(song);
      this.notifyListeners();
    }
  }
  
  /**
   * 批量添加歌曲到播放列表
   */
  addSongsToPlaylist(songs: Song[]): void {
    songs.forEach(song => {
      const existingIndex = this.playerState.playlist.findIndex(s => s.id === song.id);
      if (existingIndex === -1) {
        this.playerState.playlist.push(song);
      }
    });
    this.notifyListeners();
  }
  /**
   * 播放歌单
   */
  static async playPlaylist(songs: Song[], startIndex: number = 0): Promise<void> {
    const instance = PlayerManager.getInstance();
    instance.setPlaylist(songs, startIndex);
    if (songs.length > 0 && startIndex < songs.length) {
      await instance.playSong(songs[startIndex], songs);
    }
  }
}
