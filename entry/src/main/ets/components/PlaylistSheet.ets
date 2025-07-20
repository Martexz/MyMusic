import { Song, PlayerState } from '../models/DataModels';
import { PlayerManager } from '../managers/PlayerManager';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ImageUtil } from '../utils/ImageUtil';

@Component
export struct PlaylistSheet {
  @State playerState: PlayerState = {
    playlist: [],
    currentIndex: -1,
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    playMode: 0
  };
  
  private playerManager: PlayerManager = PlayerManager.getInstance();
  
  aboutToAppear() {
    // 获取当前播放器状态
    this.playerState = this.playerManager.getPlayerState();
    
    // 监听播放器状态变化
    this.playerManager.addListener((state: PlayerState) => {
      this.playerState = state;
    });
  }
  
  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('播放列表')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(CommonConstants.TEXT_PRIMARY)
        
        Blank()
        
        Text(`${this.playerState.playlist.length}首`)
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
        
        Image($r('app.media.ic_public_delete'))
          .width(20)
          .height(20)
          .fillColor(CommonConstants.TEXT_SECONDARY)
          .margin({ left: 16 })
          .onClick(() => {
            this.clearPlaylist();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(Color.White)
      
      // 播放列表
      List() {
        ForEach(this.playerState.playlist, (song: Song, index: number) => {
          ListItem() {
            Row() {
              // 播放状态指示器
              if (index === this.playerState.currentIndex && this.playerState.isPlaying) {
                Image($r('app.media.ic_public_play_norm'))
                  .width(16)
                  .height(16)
                  .fillColor(CommonConstants.PRIMARY_COLOR)
              } else if (index === this.playerState.currentIndex) {
                Image($r('app.media.ic_public_pause'))
                  .width(16)
                  .height(16)
                  .fillColor(CommonConstants.PRIMARY_COLOR)
              } else {
                Text((index + 1).toString())
                  .fontSize(14)
                  .fontColor(CommonConstants.TEXT_SECONDARY)
                  .width(16)
                  .textAlign(TextAlign.Center)
              }
              
              // 歌曲信息
              Column() {
                Text(song.name)
                  .fontSize(16)
                  .fontColor(index === this.playerState.currentIndex ? 
                    CommonConstants.PRIMARY_COLOR : CommonConstants.TEXT_PRIMARY)
                  .fontWeight(index === this.playerState.currentIndex ? 
                    FontWeight.Medium : FontWeight.Normal)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .alignSelf(ItemAlign.Start)
                
                Text(song.singer?.name || '未知歌手')
                  .fontSize(14)
                  .fontColor(CommonConstants.TEXT_SECONDARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)
              
              // 删除按钮
              Image($r('app.media.ic_public_cancel'))
                .width(20)
                .height(20)
                .fillColor(CommonConstants.TEXT_SECONDARY)
                .onClick(() => {
                  this.removeSong(index);
                })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 12, bottom: 12 })
            .backgroundColor(Color.White)
            .onClick(() => {
              this.playSongAtIndex(index);
            })
          }
        }, (song: Song, index: number) => `${song.id}_${index}`)
      }
      .layoutWeight(1)
      .backgroundColor('#F8F8F8')
      .divider({
        strokeWidth: 1,
        color: '#F0F0F0',
        startMargin: 48,
        endMargin: 20
      })
    }
    .width('100%')
    .height('60%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
  
  /**
   * 播放指定位置的歌曲
   */
  private playSongAtIndex(index: number): void {
    if (index >= 0 && index < this.playerState.playlist.length) {
      const song = this.playerState.playlist[index];
      this.playerManager.playSong(song, this.playerState.playlist);
    }
  }
  
  /**
   * 删除指定位置的歌曲
   */
  private removeSong(index: number): void {
    this.playerManager.removeSongFromPlaylist(index);
  }
  
  /**
   * 清空播放列表
   */
  private clearPlaylist(): void {
    this.playerManager.clearPlaylist();
  }
}
