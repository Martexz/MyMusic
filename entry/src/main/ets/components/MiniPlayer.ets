import { PlayerManager } from '../managers/PlayerManager';
import { PlayerState, PlayMode } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ImageUtil } from '../utils/ImageUtil';
import router from '@ohos.router';
import themeManager from '../common/ThemeManager';
import { ThemeMode } from '../common/ThemeManager';

@Component
export struct MiniPlayer {
  @State playerState: PlayerState = {
    playlist: [],
    currentIndex: -1,
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    playMode: PlayMode.SEQUENCE
  };

  @State themeMode: ThemeMode = themeManager.themeMode;
  private playerManager: PlayerManager = PlayerManager.getInstance();

  aboutToAppear() {
    // 监听播放器状态变化
    this.playerManager.addListener((state: PlayerState) => {
      this.playerState = state;
    });
    this.themeMode = themeManager.themeMode;
    themeManager.on(this.onThemeChanged);
    
    // 获取初始状态
    this.playerState = this.playerManager.getPlayerState();
  }

  aboutToDisappear() {
    themeManager.off(this.onThemeChanged);
    // 移除监听器
    this.playerManager.removeListener((state: PlayerState) => {
      this.playerState = state;
    });
  }
  private onThemeChanged = (mode: ThemeMode): void => {
    this.themeMode = mode;
  }

  build() {
    Column() {
      Row() {
        if (this.playerState.currentSong) {
          // 歌曲封面
          Image(ImageUtil.getSongCoverUrl(this.playerState.currentSong.pic || ''))
            .width(50)
            .height(50)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
            .alt($r('app.media.ic_music_fill'))
            .onClick(() => {
              this.openPlayerPage();
            })

          // 歌曲信息
          Column() {
            Text(this.playerState.currentSong.name)
              .fontSize(14)
              .fontColor(this.getTextPrimaryColor())
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .alignSelf(ItemAlign.Start)

            Text(this.playerState.currentSong.singer?.name || '未知歌手')
              .fontSize(12)
              .fontColor(this.getTextSecondaryColor())
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .alignSelf(ItemAlign.Start)
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .margin({ left: CommonConstants.MARGIN_MEDIUM })
          .alignItems(HorizontalAlign.Start)
          .onClick(() => {
            this.openPlayerPage();
          })

          // 播放控制按钮
          Row() {
            Image($r('app.media.ic_public_play_last'))
              .width(24)
              .height(24)
              .fillColor(this.getTextPrimaryColor())
              .onClick(() => {
                this.playerManager.previous();
              })

            Image(this.playerState.isPlaying ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play_norm'))
              .width(32)
              .height(32)
              .fillColor(CommonConstants.PRIMARY_COLOR)
              .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
              .onClick(() => {
                this.playerManager.togglePlay();
              })

            Image($r('app.media.ic_public_play_next'))
              .width(24)
              .height(24)
              .fillColor(this.getTextPrimaryColor())
              .onClick(() => {
                this.playerManager.next();
              })
          }

          // 播放列表按钮
          Image($r('app.media.ic_public_view_list_filled'))
            .width(24)
            .height(24)
            .fillColor(this.getTextSecondaryColor())
            .margin({ left: CommonConstants.MARGIN_MEDIUM })
            .onClick(() => {
              this.showPlaylist();
            })
        } else {
          // 没有歌曲时的占位内容
          Image($r('app.media.ic_music_fill'))
            .width(50)
            .height(50)
            .borderRadius(8)
            .fillColor(this.getTextSecondaryColor())

          Column() {
            Text('暂无播放')
              .fontSize(14)
              .fontColor(this.getTextSecondaryColor())
              .alignSelf(ItemAlign.Start)

            Text('点击歌曲开始播放')
              .fontSize(12)
              .fontColor(this.getTextSecondaryColor())
              .alignSelf(ItemAlign.Start)
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .margin({ left: CommonConstants.MARGIN_MEDIUM })
          .alignItems(HorizontalAlign.Start)

          // 播放按钮（禁用状态）
          Image($r('app.media.ic_public_play_norm'))
            .width(32)
            .height(32)
            .fillColor(this.getTextSecondaryColor())
            .opacity(0.5)
        }
      }
      .width('100%')
      .height(60)
      .padding({ 
        left: CommonConstants.MARGIN_MEDIUM, 
        right: CommonConstants.MARGIN_MEDIUM,
        top: CommonConstants.MARGIN_SMALL,
        bottom: CommonConstants.MARGIN_SMALL
      })
      .backgroundColor(this.getBackgroundColor())

      if (this.playerState.currentSong && this.playerState.duration > 0) {
        Progress({
          value: this.playerState.currentTime,
          total: this.playerState.duration
        })
          .width('100%')
          .height(2)
          .color(CommonConstants.PRIMARY_COLOR)
          .backgroundColor(this.themeMode === 'dark' ? '#333333' : '#F0F0F0')
      }
    }
    .backgroundColor(this.getBackgroundColor())
    .border({
      width: { top: 1 },
      color: this.themeMode === 'dark' ? '#333333' : '#F0F0F0'
    })
  }

  private openPlayerPage() {
    // 跳转到播放器页面
    router.pushUrl({
      url: 'pages/PlayerPage'
    }).catch((error: Error) => {
      console.error('跳转播放器页面失败:', error.message);
    });
  }

  private showPlaylist() {
    // TODO: 显示播放列表
    console.log('显示播放列表');
  }

  private getBackgroundColor(): string {
    return this.themeMode === 'dark' ?  "#ff535050":"#ffffff" ;
  }

  private getTextPrimaryColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_PRIMARY : CommonConstants.TEXT_COLOR_LIGHT_PRIMARY;
  }

  private getTextSecondaryColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_SECONDARY : CommonConstants.TEXT_COLOR_LIGHT_SECONDARY;
  }
}
