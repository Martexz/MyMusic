import { HttpUtil } from '../utils/HttpUtil';
import { Song, Singer, SongList, Swiper, Comment, Consumer, ApiResponse } from '../models/DataModels';
import { SearchParams, CommentParams, SongResponse, SingerResponse, SongListResponse, CommentResponse, ListSongItem, CollectRequest, CollectStatusResponse, PlaylistOperationRequest, PlaylistSongsResponse, BaseApiResponse } from '../models/ApiInterfaces';

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
   * 获取歌手的所有歌曲
   */
  static async getSongsBySingerId(singerId: number): Promise<Song[]> {
    const queryParams: Record<string, string> = {};
    queryParams.singerId = singerId.toString();
    const response = await HttpUtil.get<Song[]>('api/songs', queryParams);
    return response.data || [];
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
  
  /**
   * 添加收藏
   */
  static async addCollect(consumerId: number, songId?: number, songListId?: number): Promise<boolean> {
    try {
      const requestData: Record<string, Object> = {
        'consumer_id': consumerId as Object
      };
      if (songId !== undefined) {
        requestData['song_id'] = songId as Object;
      }
      if (songListId !== undefined) {
        requestData['song_list_id'] = songListId as Object;
      }
      
      const response = await HttpUtil.post<Object>('api/collects', requestData);
      return response.code === 0;
    } catch (error) {
      console.error('添加收藏失败:', error);
      return false;
    }
  }

  /**
   * 获取用户收藏的歌曲列表
   */
  static async getCollectSongs(consumerId: number): Promise<Song[]> {
    try {
      const queryParams: Record<string, string> = {};
      queryParams.consumer_id = consumerId.toString();
      queryParams.type = 'song';
      
      const response = await HttpUtil.get<Song[]>('api/collects', queryParams);
      return response.data || [];
    } catch (error) {
      console.error('获取收藏歌曲失败:', error);
      return [];
    }
  }

  /**
   * 取消收藏 (别名方法，与removeCollect保持一致)
   */
  static async removeFromCollect(consumerId: number, songId?: number, songListId?: number): Promise<boolean> {
    return MusicService.removeCollect(consumerId, songId, songListId);
  }
  
  /**
   * 取消收藏
   */
  static async removeCollect(consumerId: number, songId?: number, songListId?: number): Promise<boolean> {
    try {
      const requestData: Record<string, Object> = {
        'consumer_id': consumerId as Object
      };
      if (songId !== undefined) {
        requestData['song_id'] = songId as Object;
      }
      if (songListId !== undefined) {
        requestData['song_list_id'] = songListId as Object;
      }
      
      const response = await HttpUtil.delete<Object>('api/collects', requestData);
      return response.code === 0;
    } catch (error) {
      console.error('取消收藏失败:', error);
      return false;
    }
  }
  
  /**
   * 检查收藏状态
   */
  static async checkCollect(consumerId: number, songId?: number, songListId?: number): Promise<boolean> {
    try {
      const queryParams: Record<string, string> = {};
      queryParams.consumer_id = consumerId.toString();
      if (songId !== undefined) {
        queryParams.song_id = songId.toString();
      }
      if (songListId !== undefined) {
        queryParams.song_list_id = songListId.toString();
      }
      
      const response = await HttpUtil.get<CollectStatusResponse>('api/collects/check', queryParams);
      return response.data?.isCollected || false;
    } catch (error) {
      console.error('检查收藏状态失败:', error);
      return false;
    }
  }

  /**
   * 播放音乐
   */
  static async playMusic(song: Song, playlist: Song[], currentIndex: number): Promise<boolean> {
    try {
      // 这里应该调用音乐播放器服务
      // 暂时只是记录日志
      console.log(`正在播放: ${song.name}, 播放列表长度: ${playlist.length}, 当前索引: ${currentIndex}`);
      return true;
    } catch (error) {
      console.error('播放音乐失败:', error);
      return false;
    }
  }

  /**
   * 添加歌曲到歌单
   */
  static async addSongToPlaylist(songListId: number, songId: number): Promise<boolean> {
    try {
      const requestData: PlaylistOperationRequest = {
        songListId: songListId,
        songId: songId
      };
      const response = await HttpUtil.post<BaseApiResponse>('api/listSongs/add', requestData);
      return response.code === 0;
    } catch (error) {
      console.error('添加歌曲到歌单失败:', error);
      return false;
    }
  }

  /**
   * 从歌单中移除歌曲
   */
  static async removeSongFromPlaylist(songListId: number, songId: number): Promise<boolean> {
    try {
      const requestData: PlaylistOperationRequest = {
        songListId: songListId,
        songId: songId
      };
      const response = await HttpUtil.delete<BaseApiResponse>('api/listSongs/remove', requestData);
      return response.code === 0;
    } catch (error) {
      console.error('从歌单移除歌曲失败:', error);
      return false;
    }
  }

  /**
   * 获取用户创建的歌单列表
   */
  static async getUserCreatedPlaylists(userId: number): Promise<SongList[]> {
    try {
      const queryParams: Record<string, string> = {};
      queryParams.userId = userId.toString();
      
      const response = await HttpUtil.get<SongList[]>('api/songLists/created', queryParams);
      return response.data || [];
    } catch (error) {
      console.error('获取用户歌单失败:', error);
      return [];
    }
  }

  /**
   * 获取歌单中的歌曲 (新的API)
   */
  static async getPlaylistSongs(playlistId: number): Promise<PlaylistSongsResponse> {
    try {
      const response = await HttpUtil.get<Song[]>(`api/listSongs/playlist/${playlistId}`);
      if (response.data) {
        const result: PlaylistSongsResponse = { success: true, data: response.data };
        return result;
      } else {
        const result: PlaylistSongsResponse = { success: false, message: '获取歌单歌曲失败' };
        return result;
      }
    } catch (error) {
      console.error('获取歌单歌曲失败:', error);
      const result: PlaylistSongsResponse = { success: false, message: '网络请求失败' };
      return result;
    }
  }
}
