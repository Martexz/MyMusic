/**
 * 歌曲数据模型
 */
export interface Song {
  id: number;
  name: string;
  url?: string;
  pic?: string;
  lyric?: string;
  singerId: number;
  singer?: Singer;
  introduction?: string;
  createTime?: string;
  updateTime?: string;
}

/**
 * 歌手数据模型
 */
export interface Singer {
  id: number;
  name: string;
  sex?: number;
  pic?: string;
  birth?: string;
  location?: string;
  introduction?: string;
}

/**
 * 歌单数据模型
 */
export interface SongList {
  id: number;
  title: string;
  pic?: string;
  introduction?: string;
  style?: string;
}

/**
 * 轮播图数据模型
 */
export interface Swiper {
  id: number;
  pic: string;
  url?: string;
}

/**
 * 评论数据模型
 */
export interface Comment {
  id: number;
  userId: number;
  songId?: number;
  songListId?: number;
  content: string;
  createTime: string;
  consumer?: Consumer;
}

/**
 * 用户数据模型
 */
export interface Consumer {
  id: number;
  username: string;
  password?: string;
  sex?: number;
  phoneNum?: string;
  email?: string;
  birth?: string;
  introduction?: string;
  location?: string;
  avatar?: string;
}

/**
 * 播放器状态模型
 */
export interface PlayerState {
  currentSong?: Song;
  playlist: Song[];
  currentIndex: number;
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  playMode: PlayMode;
}

/**
 * 播放模式枚举
 */
export enum PlayMode {
  SEQUENCE = 0,  // 顺序播放
  LOOP = 1,      // 列表循环
  SINGLE = 2,    // 单曲循环
  RANDOM = 3     // 随机播放
}

/**
 * 通用API响应模型
 */
export interface ApiResponse<T> {
  code: number;
  data?: T;
  msg?: string;
  total?: number;
  page?: number;
  pageSize?: number;
}
