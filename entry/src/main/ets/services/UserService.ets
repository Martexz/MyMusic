import { HttpUtil } from '../utils/HttpUtil';
import { LoginRequest, RegisterRequest, UpdateUserRequest, UserResponse } from '../models/ApiInterfaces';

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
  
  /**
   * 更新用户信息
   */
  static async updateUserInfo(userInfo: UpdateUserRequest): Promise<UserResponse | null> {
    try {
      const requestData: Record<string, Object> = {
        'id': userInfo.id as Object
      };
      
      if (userInfo.username !== undefined) {
        requestData['username'] = userInfo.username as Object;
      }
      if (userInfo.email !== undefined) {
        requestData['email'] = userInfo.email as Object;
      }
      if (userInfo.introduction !== undefined) {
        requestData['introduction'] = userInfo.introduction as Object;
      }
      if (userInfo.avator !== undefined) {
        requestData['avator'] = userInfo.avator as Object;
      }
      if (userInfo.gender !== undefined) {
        requestData['gender'] = userInfo.gender as Object;
      }
      if (userInfo.phone_num !== undefined) {
        requestData['phone_num'] = userInfo.phone_num as Object;
      }
      if (userInfo.birth !== undefined) {
        requestData['birth'] = userInfo.birth as Object;
      }
      if (userInfo.location !== undefined) {
        requestData['location'] = userInfo.location as Object;
      }
      
      const response = await HttpUtil.put<UserResponse>(`api/users/${userInfo.id}`, requestData);
      if (response.code === 0) {
        return response.data || null;
      } else {
        console.error('更新用户信息失败:', response.msg);
        return null;
      }
    } catch (error) {
      console.error('更新用户信息请求失败:', error);
      return null;
    }
  }
}
