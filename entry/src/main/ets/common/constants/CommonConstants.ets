/**
 * 通用常量定义
 */
export class CommonConstants {
  // 服务器配置
  // 开发环境 - 本地服务器
  static readonly BASE_URL: string = 'http://10.130.114.227:8000/';
  
  // 生产环境配置示例 (根据需要修改)
  // static readonly BASE_URL: string = 'http://your-server-domain.com/';
  
  // 如果后端运行在不同端口，请修改上面的URL，例如：
  // static readonly BASE_URL: string = 'http://localhost:8080/';
  
  // 页面路由
  static readonly MAIN_PAGE: string = 'pages/MainPage';
  static readonly PLAYER_PAGE: string = 'pages/PlayerPage';
  static readonly SEARCH_PAGE: string = 'pages/SearchPage';
  static readonly PROFILE_PAGE: string = 'pages/ProfilePage';
  
  // 底部导航标签
  static readonly TAB_HOME: number = 0;
  static readonly TAB_DISCOVER: number = 1;
  static readonly TAB_PLAYLIST: number = 2;
  static readonly TAB_PROFILE: number = 3;
  
  // 颜色定义
  static readonly PRIMARY_COLOR: string = '#FF6B35';
  static readonly BACKGROUND_COLOR: string = '#F8F9FA';
  static readonly TEXT_PRIMARY: string = '#212529';
  static readonly TEXT_SECONDARY: string = '#6C757D';
  
  // 尺寸定义
  static readonly BORDER_RADIUS: number = 12;
  static readonly MARGIN_SMALL: number = 8;
  static readonly MARGIN_MEDIUM: number = 16;
  static readonly MARGIN_LARGE: number = 24;
  
  // 播放状态
  static readonly PLAY_STATE_PLAYING: number = 1;
  static readonly PLAY_STATE_PAUSED: number = 0;
  static readonly PLAY_STATE_STOPPED: number = -1;
}
