import { Song } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';

@Component
export struct PlayerOptionsMenu {
  @Prop currentSong?: Song;
  
  build() {
    Column() {
      // 标题
      Row() {
        Text('更多选项')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.TEXT_PRIMARY)
        
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(Color.White)
      
      // 选项列表
      Column() {
        // 收藏/取消收藏
        Row() {
          Image($r('app.media.ic_public_favor'))
            .width(24)
            .height(24)
            .fillColor(CommonConstants.TEXT_PRIMARY)
          
          Text('收藏')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.toggleFavorite();
        })
        
        Divider()
          .color('#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 添加到歌单
        Row() {
          Image($r('app.media.ic_playlist_add_icon'))
            .width(24)
            .height(24)
            .fillColor(CommonConstants.TEXT_PRIMARY)
          
          Text('添加到歌单')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.addToPlaylist();
        })
        
        Divider()
          .color('#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 查看专辑
        Row() {
          Image($r('app.media.ic_public_folder'))
            .width(24)
            .height(24)
            .fillColor(CommonConstants.TEXT_PRIMARY)
          
          Text('查看专辑')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.viewAlbum();
        })
        
        Divider()
          .color('#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 歌曲信息
        Row() {
          Image($r('app.media.ic_public_help'))
            .width(24)
            .height(24)
            .fillColor(CommonConstants.TEXT_PRIMARY)
          
          Text('歌曲信息')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.showSongInfo();
        })
        
        Divider()
          .color('#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        // 分享
        Row() {
          Image($r('app.media.ic_public_share_filled'))
            .width(24)
            .height(24)
            .fillColor(CommonConstants.TEXT_PRIMARY)
          
          Text('分享')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
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
          .color('#F0F0F0')
          .margin({ left: 20, right: 20 })
        
        Row() {
          Image($r('app.media.ic_timer_icon'))
            .width(24)
            .height(24)
            .fillColor(CommonConstants.TEXT_PRIMARY)
          
          Text('定时关闭')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .margin({ left: 16 })
          
          Blank()
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .onClick(() => {
          this.setSleepTimer();
        })
      }
      .backgroundColor(Color.White)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
  
  /**
   * 切换收藏状态
   */
  private toggleFavorite(): void {
    // TODO: 实现收藏功能
    console.log('切换收藏状态:', this.currentSong?.name);
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
