import { HttpUtil } from '../utils/HttpUtil';
import { LoginRequest, RegisterRequest, UserResponse } from '../models/ApiInterfaces';

/**
 * 用户服务类
 */
export class UserService {
  
  /**
   * 用户登录
   */
  static async login(username: string, password: string): Promise<UserResponse | null> {
    try {
      const requestData: Record<string, Object> = {
        'username': username as Object,
        'password': password as Object
      };
      
      const response = await HttpUtil.post<UserResponse>('api/login', requestData);
      if (response.code === 0) {
        return response.data || null;
      } else {
        console.error('登录失败:', response.msg);
        return null;
      }
    } catch (error) {
      console.error('登录请求失败:', error);
      return null;
    }
  }
  
  /**
   * 用户注册
   */
  static async register(username: string, password: string, email?: string): Promise<UserResponse | null> {
    try {
      const requestData: Record<string, Object> = {
        'username': username as Object,
        'password': password as Object
      };
      if (email) {
        requestData['email'] = email as Object;
      }
      
      const response = await HttpUtil.post<UserResponse>('api/register', requestData);
      if (response.code === 0) {
        return response.data || null;
      } else {
        console.error('注册失败:', response.msg);
        return null;
      }
    } catch (error) {
      console.error('注册请求失败:', error);
      return null;
    }
  }
}
