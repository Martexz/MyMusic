import { PlayerManager } from '../managers/PlayerManager';
import { PlayerState, PlayMode } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';

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

  private playerManager: PlayerManager = PlayerManager.getInstance();

  aboutToAppear() {
    // 监听播放器状态变化
    this.playerManager.addListener((state: PlayerState) => {
      this.playerState = state;
    });
    
    // 获取初始状态
    this.playerState = this.playerManager.getPlayerState();
  }

  aboutToDisappear() {
    // 移除监听器
    this.playerManager.removeListener((state: PlayerState) => {
      this.playerState = state;
    });
  }

  build() {
    Row() {
      if (this.playerState.currentSong) {
        // 歌曲封面
        Image(this.playerState.currentSong.pic || $r('app.media.ic_music_fill'))
          .width(50)
          .height(50)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            this.openPlayerPage();
          })

        // 歌曲信息
        Column() {
          Text(this.playerState.currentSong.name)
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .alignSelf(ItemAlign.Start)

          Text(this.playerState.currentSong.singer?.name || '未知歌手')
            .fontSize(12)
            .fontColor(CommonConstants.TEXT_SECONDARY)
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
            .fillColor(CommonConstants.TEXT_PRIMARY)
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
            .fillColor(CommonConstants.TEXT_PRIMARY)
            .onClick(() => {
              this.playerManager.next();
            })
        }

        // 播放列表按钮
        Image($r('app.media.ic_public_view_list_filled'))
          .width(24)
          .height(24)
          .fillColor(CommonConstants.TEXT_SECONDARY)
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
          .fillColor(CommonConstants.TEXT_SECONDARY)

        Column() {
          Text('暂无播放')
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_SECONDARY)
            .alignSelf(ItemAlign.Start)

          Text('点击歌曲开始播放')
            .fontSize(12)
            .fontColor(CommonConstants.TEXT_SECONDARY)
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
          .fillColor(CommonConstants.TEXT_SECONDARY)
          .opacity(0.5)
      }
    }
    .width('100%')
    .height(70)
    .padding({ 
      left: CommonConstants.MARGIN_MEDIUM, 
      right: CommonConstants.MARGIN_MEDIUM,
      top: CommonConstants.MARGIN_SMALL,
      bottom: CommonConstants.MARGIN_SMALL
    })
    .backgroundColor(Color.White)
    .border({
      width: { top: 1 },
      color: '#F0F0F0'
    })
  }

  private openPlayerPage() {
    // TODO: 跳转到播放器页面
    console.log('打开播放器页面');
  }

  private showPlaylist() {
    // TODO: 显示播放列表
    console.log('显示播放列表');
  }
}
