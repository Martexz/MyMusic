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
  
  /**
   * 播放
   */
  play(): void {
    this.playerState.isPlaying = true;
    this.notifyListeners();
  }
  
  /**
   * 暂停
   */
  pause(): void {
    this.playerState.isPlaying = false;
    this.notifyListeners();
  }
  
  /**
   * 停止播放
   */
  stop(): void {
    this.playerState.isPlaying = false;
    this.playerState.currentTime = 0;
    this.notifyListeners();
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
   * 设置播放速度
   */
  setPlaybackSpeed(speed: number): void {
    // TODO: 实现播放速度设置
    console.log('设置播放速度:', speed);
  }
  
  /**
   * 设置音量
   */
  setVolume(volume: number): void {
    // TODO: 实现音量设置
    console.log('设置音量:', volume);
  }
}
