/**
 * 通用工具类
 */
export class Utils {
  
  /**
   * 格式化时间（秒转为 mm:ss 格式）
   */
  static formatTime(seconds: number): string {
    if (!seconds || seconds < 0) {
      return '00:00';
    }
    
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    
    const formattedMinutes = minutes.toString().padStart(2, '0');
    const formattedSeconds = remainingSeconds.toString().padStart(2, '0');
    
    return `${formattedMinutes}:${formattedSeconds}`;
  }
  
  /**
   * 格式化文件大小
   */
  static formatFileSize(bytes: number): string {
    if (!bytes || bytes === 0) return '0 B';
    
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    
    return `${Math.round(bytes / Math.pow(1024, i) * 100) / 100} ${sizes[i]}`;
  }
  
  /**
   * 格式化数字（添加千分符）
   */
  static formatNumber(num: number): string {
    if (!num) return '0';
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }
  
  /**
   * 检查字符串是否为空
   */
  static isEmpty(str?: string): boolean {
    return !str || str.trim().length === 0;
  }
  
  /**
   * 防抖函数
   */
  static debounce<T extends (...args: any[]) => any>(
    func: T,
    wait: number
  ): (...args: Parameters<T>) => void {
    let timeout: number | undefined;
    
    return (...args: Parameters<T>) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => func(...args), wait);
    };
  }
  
  /**
   * 节流函数
   */
  static throttle<T extends (...args: any[]) => any>(
    func: T,
    limit: number
  ): (...args: Parameters<T>) => void {
    let inThrottle: boolean = false;
    
    return (...args: Parameters<T>) => {
      if (!inThrottle) {
        func(...args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  }
  
  /**
   * 生成随机ID
   */
  static generateRandomId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }
}
