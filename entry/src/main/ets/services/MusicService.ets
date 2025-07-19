import { HttpUtil } from '../utils/HttpUtil';
import { Song, Singer, SongList, Swiper, Comment, Consumer, ApiResponse } from '../models/DataModels';
import { SearchParams, CommentParams, SongResponse, SingerResponse, SongListResponse, CommentResponse, ListSongItem } from '../models/ApiInterfaces';

/**
 * 音乐API服务类
 */
export class MusicService {
  
  /**
   * 获取轮播图列表
   */
  static async getSwipers(): Promise<Swiper[]> {
    const response = await HttpUtil.get<Swiper[]>('api/swipers');
    return response.data || [];
  }
  
  /**
   * 获取歌曲列表
   */
  static async getSongs(params?: SearchParams): Promise<SongResponse> {
    const queryParams: Record<string, string> = {};
    if (params?.page) queryParams.page = params.page.toString();
    if (params?.pageSize) queryParams.pageSize = params.pageSize.toString();
    if (params?.keyword) queryParams.keyword = params.keyword;
    
    const response = await HttpUtil.get<Song[]>('api/songs', queryParams);
    return {
      songs: response.data || [],
      total: response.total || 0
    };
  }
  
  /**
   * 根据ID获取歌曲详情
   */
  static async getSongById(id: number): Promise<Song | null> {
    const response = await HttpUtil.get<Song>(`api/songs/${id}`);
    return response.data || null;
  }
  
  /**
   * 获取歌手列表
   */
  static async getSingers(params?: SearchParams): Promise<SingerResponse> {
    const queryParams: Record<string, string> = {};
    if (params?.page) queryParams.page = params.page.toString();
    if (params?.pageSize) queryParams.pageSize = params.pageSize.toString();
    if (params?.keyword) queryParams.keyword = params.keyword;
    
    const response = await HttpUtil.get<Singer[]>('api/singers', queryParams);
    return {
      singers: response.data || [],
      total: response.total || 0
    };
  }
  
  /**
   * 根据ID获取歌手详情
   */
  static async getSingerById(id: number): Promise<Singer | null> {
    const response = await HttpUtil.get<Singer>(`api/singers/${id}`);
    return response.data || null;
  }
  
  /**
   * 获取歌单列表
   */
  static async getSongLists(params?: SearchParams): Promise<SongListResponse> {
    const queryParams: Record<string, string> = {};
    if (params?.page) queryParams.page = params.page.toString();
    if (params?.pageSize) queryParams.pageSize = params.pageSize.toString();
    if (params?.keyword) queryParams.keyword = params.keyword;
    
    const response = await HttpUtil.get<SongList[]>('api/songLists', queryParams);
    return {
      songLists: response.data || [],
      total: response.total || 0
    };
  }
  
  /**
   * 根据ID获取歌单详情
   */
  static async getSongListById(id: number): Promise<SongList | null> {
    const response = await HttpUtil.get<SongList>(`api/songLists/${id}`);
    return response.data || null;
  }
  
  /**
   * 获取歌单中的歌曲
   */
  static async getListSongs(songListId: number): Promise<Song[]> {
    const queryParams: Record<string, string> = {};
    queryParams.songListId = songListId.toString();
    const response = await HttpUtil.get<ListSongItem[]>('api/listSongs', queryParams);
    // 提取歌曲数据
    const songs: Song[] = [];
    if (response.data) {
      for (const item of response.data) {
        if (item.song) {
          songs.push(item.song);
        }
      }
    }
    return songs;
  }
  
  /**
   * 获取评论列表
   */
  static async getComments(params: CommentParams): Promise<CommentResponse> {
    const queryParams: Record<string, string> = {};
    if (params.songId) queryParams.songId = params.songId.toString();
    if (params.songListId) queryParams.songListId = params.songListId.toString();
    if (params.page) queryParams.page = params.page.toString();
    if (params.pageSize) queryParams.pageSize = params.pageSize.toString();
    
    const response = await HttpUtil.get<Comment[]>('api/comments', queryParams);
    return {
      comments: response.data || [],
      total: response.total || 0
    };
  }
  
  /**
   * 获取排行榜
   */
  static async getRanks(): Promise<Song[]> {
    const response = await HttpUtil.get<Song[]>('api/ranks');
    return response.data || [];
  }
  
  /**
   * 搜索歌曲
   */
  static async searchSongs(keyword: string, page: number = 1): Promise<SongResponse> {
    return MusicService.getSongs({ keyword, page, pageSize: 20 });
  }
  
  /**
   * 搜索歌手
   */
  static async searchSingers(keyword: string, page: number = 1): Promise<SingerResponse> {
    return MusicService.getSingers({ keyword, page, pageSize: 20 });
  }
  
  /**
   * 搜索歌单
   */
  static async searchSongLists(keyword: string, page: number = 1): Promise<SongListResponse> {
    return MusicService.getSongLists({ keyword, page, pageSize: 20 });
  }
}
