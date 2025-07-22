import { Song, Singer, SongList, Comment } from './DataModels';

/**
 * 搜索参数接口
 */
export interface SearchParams {
  page?: number;
  pageSize?: number;
  keyword?: string;
}

/**
 * 评论参数接口
 */
export interface CommentParams {
  songId?: number;
  songListId?: number;
  page?: number;
  pageSize?: number;
}

/**
 * 歌单歌曲关联项接口
 */
export interface ListSongItem {
  song: Song;
}

/**
 * 歌曲响应接口
 */
export interface SongResponse {
  songs: Song[];
  total: number;
}

/**
 * 歌手响应接口
 */
export interface SingerResponse {
  singers: Singer[];
  total: number;
}

/**
 * 歌单响应接口
 */
export interface SongListResponse {
  songLists: SongList[];
  total: number;
}

/**
 * 评论响应接口
 */
export interface CommentResponse {
  comments: Comment[];
  total: number;
}

/**
 * 收藏请求接口
 */
export interface CollectRequest {
  consumer_id: number;
  song_id?: number;
  song_list_id?: number;
}

/**
 * 收藏状态响应接口
 */
export interface CollectStatusResponse {
  isCollected: boolean;
}

/**
 * 登录请求接口
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 注册请求接口
 */
export interface RegisterRequest {
  username: string;
  password: string;
  email?: string;
}

/**
 * 更新用户信息请求接口
 */
export interface UpdateUserRequest {
  id: number;
  username?: string;
  email?: string;
  introduction?: string;
  avator?: string;
  gender?: number;
  phone_num?: string;
  birth?: string;
  location?: string;
}

/**
 * 用户响应接口
 */
export interface UserResponse {
  id: number;
  username: string;
  email?: string;
  gender?: number;
  phone_num?: string;
  birth?: string;
  introduction?: string;
  location?: string;
  avator?: string;
}

/**
 * 歌单操作请求接口
 */
export interface PlaylistOperationRequest extends Record<string, Object> {
  songListId: number;
  songId: number;
}

/**
 * 歌单歌曲响应接口
 */
export interface PlaylistSongsResponse {
  success: boolean;
  data?: Song[];
  message?: string;
}

/**
 * 基础API响应接口
 */
export interface BaseApiResponse {
  code: number;
  message?: string;
  data?: Record<string, Object>;
}
