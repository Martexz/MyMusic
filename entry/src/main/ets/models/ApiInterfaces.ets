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
