import http from '@ohos.net.http';
import { ApiResponse } from '../models/DataModels';
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
}
