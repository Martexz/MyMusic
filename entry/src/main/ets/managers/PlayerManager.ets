import { Song, PlayerState, PlayMode } from '../models/DataModels';

/**
 * 音乐播放器管理类
 */
export class PlayerManager {
  private static instance: PlayerManager;
  private playerState: PlayerState;
  private listeners: Array<(state: PlayerState) => void> = [];
  
  private constructor() {
    this.playerState = {
      playlist: [],
      currentIndex: -1,
      isPlaying: false,
      currentTime: 0,
      duration: 0,
      playMode: PlayMode.SEQUENCE
    };
  }
  
  static getInstance(): PlayerManager {
    if (!PlayerManager.instance) {
      PlayerManager.instance = new PlayerManager();
    }
    return PlayerManager.instance;
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
  playSong(song: Song, playlist?: Song[]): void {
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
    this.playerState.isPlaying = true;
    this.notifyListeners();
  }
  
  /**
   * 播放/暂停
   */
  togglePlay(): void {
    this.playerState.isPlaying = !this.playerState.isPlaying;
    this.notifyListeners();
  }
  
  /**
   * 下一首
   */
  next(): void {
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
  }
  
  /**
   * 上一首
   */
  previous(): void {
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
   * 跳转到指定位置
   */
  seekTo(position: number): void {
    this.playerState.currentTime = position;
    this.notifyListeners();
  }
}
