import { UserResponse } from '../models/ApiInterfaces';
import preferences from '@ohos.data.preferences';

/**
 * 用户状态管理器
 */
export class UserManager {
  private static instance: UserManager;
  private currentUser: UserResponse | null = null;
  private listeners: ((user: UserResponse | null) => void)[] = [];
  private preferencesStore: preferences.Preferences | null = null;
  
  private constructor() {
    this.initPreferences();
  }
  
  static getInstance(): UserManager {
    if (!UserManager.instance) {
      UserManager.instance = new UserManager();
    }
    return UserManager.instance;
  }
  
  /**
   * 初始化首选项存储
   */
  private async initPreferences(): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(getContext(), 'user_prefs');
      await this.loadUserFromStorage();
    } catch (error) {
      console.error('初始化用户首选项失败:', error);
    }
  }
  
  /**
   * 从本地存储加载用户信息
   */
  private async loadUserFromStorage(): Promise<void> {
    try {
      if (this.preferencesStore) {
        const userJson = await this.preferencesStore.get('current_user', '');
        if (userJson && typeof userJson === 'string' && userJson !== '') {
          this.currentUser = JSON.parse(userJson) as UserResponse;
          this.notifyListeners();
        }
      }
    } catch (error) {
      console.error('从本地存储加载用户信息失败:', error);
    }
  }
  
  /**
   * 保存用户信息到本地存储
   */
  private async saveUserToStorage(): Promise<void> {
    try {
      if (this.preferencesStore) {
        const userJson = this.currentUser ? JSON.stringify(this.currentUser) : '';
        await this.preferencesStore.put('current_user', userJson);
        await this.preferencesStore.flush();
      }
    } catch (error) {
      console.error('保存用户信息到本地存储失败:', error);
    }
  }
  
  /**
   * 设置当前用户
   */
  setCurrentUser(user: UserResponse | null): void {
    this.currentUser = user;
    this.saveUserToStorage();
    this.notifyListeners();
  }
  
  /**
   * 获取当前用户
   */
  getCurrentUser(): UserResponse | null {
    return this.currentUser;
  }
  
  /**
   * 检查是否已登录
   */
  isLoggedIn(): boolean {
    return this.currentUser !== null;
  }
  
  /**
   * 退出登录
   */
  logout(): void {
    this.setCurrentUser(null);
  }
  
  /**
   * 添加状态监听器
   */
  addListener(listener: (user: UserResponse | null) => void): void {
    this.listeners.push(listener);
  }
  
  /**
   * 移除状态监听器
   */
  removeListener(listener: (user: UserResponse | null) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }
  
  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    this.listeners.forEach(listener => {
      try {
        listener(this.currentUser);
      } catch (error) {
        console.error('通知用户状态监听器失败:', error);
      }
    });
  }
}
