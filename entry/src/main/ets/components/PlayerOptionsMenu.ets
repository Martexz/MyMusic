import { Song } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';
import { MusicService } from '../services/MusicService';
import { UserManager } from '../managers/UserManager';
import { UserResponse } from '../models/ApiInterfaces';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Component
export struct PlayerOptionsMenu {
  @Prop currentSong?: Song;
  @State isCollected: boolean = false;
  @State currentUser: UserResponse | null = null;
  @State themeMode: ThemeMode = themeManager.themeMode;
  
  private userManager: UserManager = UserManager.getInstance();
  
  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    
    this.currentUser = this.userManager.getCurrentUser();
    this.userManager.addListener(this.onUserChanged.bind(this));
    this.checkCollectStatus();
  }
  
  aboutToDisappear() {
    themeManager.off(this.onThemeChanged);
    this.userManager.removeListener(this.onUserChanged.bind(this));
  }

  private onThemeChanged = (mode: ThemeMode): void => {
    this.themeMode = mode;
  };

  private getBackgroundColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.BACKGROUND_DARK : CommonConstants.BACKGROUND_LIGHT;
  }

  private getTextPrimary(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_PRIMARY : CommonConstants.TEXT_COLOR_LIGHT_PRIMARY;
  }
  
  /**
   * 用户状态变化回调
   */
  private onUserChanged(user: UserResponse | null): void {
    this.currentUser = user;
    this.checkCollectStatus();
  }
  
  build() {
    Column() {
      // 标题
      Row() {
        Text('更多选项')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getTextPrimary())
        
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(this.getBackgroundColor())
      
      // 选项列表
      Column() {
        // 收藏/取消收藏
        Row() {
          Image($r('app.media.ic_public_favor'))
            .width(24)
            .height(24)
            .fillColor(this.isCollected ? '#FF4444' : CommonConstants.TEXT_PRIMARY)
          
          Text(this.isCollected ? '取消收藏' : '收藏')
            .fontSize(16)
            .fontColor(this.getTextPrimary())
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.toggleFavorite();
        })
        
        Divider()
          .color(this.themeMode === 'dark' ? '#2A2A2A' : '#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 添加到歌单
        Row() {
          Image($r('app.media.ic_playlist_add_icon'))
            .width(24)
            .height(24)
            .fillColor(this.getTextPrimary())
          
          Text('添加到歌单')
            .fontSize(16)
            .fontColor(this.getTextPrimary())
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.addToPlaylist();
        })
        
        Divider()
          .color(this.themeMode === 'dark' ? '#2A2A2A' : '#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 查看专辑
        Row() {
          Image($r('app.media.ic_public_folder'))
            .width(24)
            .height(24)
            .fillColor(this.getTextPrimary())
          
          Text('查看专辑')
            .fontSize(16)
            .fontColor(this.getTextPrimary())
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.viewAlbum();
        })
        
        Divider()
          .color(this.themeMode === 'dark' ? '#2A2A2A' : '#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 歌曲信息
        Row() {
          Image($r('app.media.ic_public_help'))
            .width(24)
            .height(24)
            .fillColor(this.getTextPrimary())
          
          Text('歌曲信息')
            .fontSize(16)
            .fontColor(this.getTextPrimary())
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.showSongInfo();
        })
        
        Divider()
          .color(this.themeMode === 'dark' ? '#2A2A2A' : '#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 分享
        Row() {
          Image($r('app.media.ic_public_share_filled'))
            .width(24)
            .height(24)
            .fillColor(this.getTextPrimary())
          
          Text('分享')
            .fontSize(16)
            .fontColor(this.getTextPrimary())
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.shareSong();
        })
        
        // 定时关闭
        Divider()
          .color(this.themeMode === 'dark' ? '#2A2A2A' : '#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        Row() {
          Image($r('app.media.ic_timer_icon'))
            .width(24)
            .height(24)
            .fillColor(this.getTextPrimary())
          
          Text('定时关闭')
            .fontSize(16)
            .fontColor(this.getTextPrimary())
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.setSleepTimer();
        })
      }
      .backgroundColor(this.getBackgroundColor())
    }
    .width('100%')
    .backgroundColor(this.getBackgroundColor())
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
  
  /**
   * 检查收藏状态
   */
  private async checkCollectStatus(): Promise<void> {
    if (this.currentSong?.id && this.currentUser?.id) {
      try {
        this.isCollected = await MusicService.checkCollect(this.currentUser.id, this.currentSong.id);
      } catch (error) {
        console.error('检查收藏状态失败:', error);
        this.isCollected = false;
      }
    } else {
      this.isCollected = false;
    }
  }
  
  /**
   * 切换收藏状态
   */
  private async toggleFavorite(): Promise<void> {
    if (!this.currentSong?.id) {
      console.log('当前没有歌曲');
      return;
    }
    
    if (!this.currentUser?.id) {
      promptAction.showToast({ message: '请先登录' });
      router.pushUrl({ url: 'pages/LoginPage' });
      return;
    }
    
    try {
      let success = false;
      if (this.isCollected) {
        // 取消收藏
        success = await MusicService.removeCollect(this.currentUser.id, this.currentSong.id);
        if (success) {
          this.isCollected = false;
          promptAction.showToast({ message: '取消收藏成功' });
        }
      } else {
        // 添加收藏
        success = await MusicService.addCollect(this.currentUser.id, this.currentSong.id);
        if (success) {
          this.isCollected = true;
          promptAction.showToast({ message: '收藏成功' });
        }
      }
      
      if (!success) {
        promptAction.showToast({ message: '操作失败，请稍后重试' });
      }
    } catch (error) {
      console.error('收藏操作出错:', error);
      promptAction.showToast({ message: '操作失败，请稍后重试' });
    }
  }
  
  /**
   * 添加到歌单
   */
  private addToPlaylist(): void {
    // TODO: 显示歌单选择器
    console.log('添加到歌单:', this.currentSong?.name);
  }
  
  /**
   * 查看专辑
   */
  private viewAlbum(): void {
    // TODO: 跳转到专辑页面
    console.log('查看专辑:', this.currentSong?.name);
  }
  
  /**
   * 显示歌曲信息
   */
  private showSongInfo(): void {
    // TODO: 显示歌曲详细信息
    console.log('显示歌曲信息:', this.currentSong?.name);
  }
  
  /**
   * 分享歌曲
   */
  private shareSong(): void {
    // TODO: 实现分享功能
    console.log('分享歌曲:', this.currentSong?.name);
  }
  
  /**
   * 设置睡眠定时器
   */
  private setSleepTimer(): void {
    // TODO: 设置睡眠定时器
    console.log('设置睡眠定时器');
  }
}
