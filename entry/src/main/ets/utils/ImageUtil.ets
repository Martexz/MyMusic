/**
 * 图片资源工具类
 */
export class ImageUtil {
  
  /**
   * 获取图片资源
   * @param imagePath 图片路径
   * @param baseUrl 服务器基础URL
   * @returns 完整的图片URL或本地资源路径
   */
  static getImageUrl(imagePath: string, baseUrl: string = ''): string {
    if (!imagePath) {
      return '';
    }
    
    // 如果是完整的URL，直接返回
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // 如果是相对路径，拼接服务器地址
    if (imagePath.startsWith('/')) {
      return baseUrl + imagePath;
    }
    
    // 默认拼接
    return baseUrl + '/' + imagePath;
  }
  
  /**
   * 获取轮播图URL
   * @param pic 图片路径
   * @returns 完整的图片URL
   */
  static getSwiperImageUrl(pic: string): string {
    // 从CommonConstants导入BASE_URL
    const baseUrl = 'http://10.130.3.83:8000';
    return ImageUtil.getImageUrl(pic, baseUrl);
  }
  
  /**
   * 获取歌曲封面URL
   * @param pic 图片路径  
   * @returns 完整的图片URL
   */
  static getSongCoverUrl(pic: string): string {
    const baseUrl = 'http://10.130.3.83:8000';
    return ImageUtil.getImageUrl(pic, baseUrl);
  }
  
  /**
   * 获取歌手头像URL
   * @param pic 图片路径
   * @returns 完整的图片URL
   */
  static getSingerAvatarUrl(pic: string): string {
    const baseUrl = 'http://10.130.3.83:8000';
    return ImageUtil.getImageUrl(pic, baseUrl);
  }

  /**
   * 获取歌单封面URL
   * @param pic 图片路径
   * @returns 完整的图片URL
   */
  static getSongListCoverUrl(pic: string): string {
    const baseUrl = 'http://10.130.3.83:8000';
    return ImageUtil.getImageUrl(pic, baseUrl);
  }
}
