import http from '@ohos.net.http';
import { ApiResponse, CreateSongListDto, Song, SongList } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';

/**
 * HTTP请求工具类
 */
export class HttpUtil {
  /**
   * 通用GET请求
   */
  static async get<T>(url: string, params?: Record<string, string>): Promise<ApiResponse<T>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      
      // 构建URL参数
      let fullUrl = CommonConstants.BASE_URL + url;
      if (params) {
        const queryString = Object.keys(params)
          .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
          .join('&');
        fullUrl += `?${queryString}`;
      }
      
      httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }, (err, data) => {
        if (!err) {
          try {
            const result = JSON.parse(data.result.toString()) as ApiResponse<T>;
            resolve(result);
          } catch (parseError) {
            reject(parseError);
          }
        } else {
          reject(err);
        }
        httpRequest.destroy();
      });
    });
  }
  
  /**
   * 通用POST请求
   */
  static async post<T>(url: string, data?: Record<string, Object>): Promise<ApiResponse<T>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      
      httpRequest.request(CommonConstants.BASE_URL + url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: data ? JSON.stringify(data) : undefined
      }, (err, response) => {
        if (!err) {
          try {
            const result = JSON.parse(response.result.toString()) as ApiResponse<T>;
            resolve(result);
          } catch (parseError) {
            reject(parseError);
          }
        } else {
          reject(err);
        }
        httpRequest.destroy();
      });
    });
  }
  
    /**
   * 通用PUT请求
   */
  static async put<T>(url: string, data?: Record<string, Object>): Promise<ApiResponse<T>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      
      httpRequest.request(CommonConstants.BASE_URL + url, {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: data ? JSON.stringify(data) : undefined
      }, (err, response) => {
        if (!err) {
          try {
            const result = JSON.parse(response.result.toString()) as ApiResponse<T>;
            resolve(result);
          } catch (parseError) {
            reject(parseError);
          }
        } else {
          reject(err);
        }
        httpRequest.destroy();
      });
    });
  }
  
  /**
   * 通用DELETE请求
   */
  static async delete<T>(url: string, data?: Record<string, Object>): Promise<ApiResponse<T>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      
      httpRequest.request(CommonConstants.BASE_URL + url, {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: data ? JSON.stringify(data) : undefined
      }, (err, response) => {
        if (!err) {
          try {
            const result = JSON.parse(response.result.toString()) as ApiResponse<T>;
            resolve(result);
          } catch (parseError) {
            reject(parseError);
          }
        } else {
          reject(err);
        }
        httpRequest.destroy();
      });
    });
  }

  /**
   * 创建歌单
   */
  static async createSongList(data: CreateSongListDto): Promise<ApiResponse<SongList>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      httpRequest.request(CommonConstants.BASE_URL + 'api/songLists/create', {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(data)
      }, (err, response) => {
        if (!err) {
          try {
            const result = JSON.parse(response.result.toString()) as ApiResponse<SongList>;
            resolve(result);
          } catch (parseError) {
            reject(parseError);
          }
        } else {
          reject(err);
        }
        httpRequest.destroy();
      });
    });
  }


  static async getCreatedSongLists(userId: number): Promise<SongList[]> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      const url = `${CommonConstants.BASE_URL}api/songLists/created?userId=${encodeURIComponent(userId.toString())}`;

      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }, (err, data) => {
        if (!err) {
          try {
            const result = JSON.parse(data.result.toString()) as ApiResponse<SongList[]>;
            if (result.code === 0 && result.data) {
              resolve(result.data);
            } else {
              console.error('getCreatedSongLists API error:', result.msg);
              resolve([]);
            }
          } catch (parseError) {
            reject(parseError);
          }
        } else {
          reject(err);
        }
        httpRequest.destroy();
      });
    });
  }

}
