import { Song, PlayerState } from '../models/DataModels';
import { PlayerManager } from '../managers/PlayerManager';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ImageUtil } from '../utils/ImageUtil';
import { PlaylistDialog } from '../components/PlaylistDialog';
import { PlayerOptionsMenu } from '../components/PlayerOptionsMenu';
import router from '@ohos.router';

@Entry
@Component
struct PlayerPage {
  @State private playerState: PlayerState = {
    playlist: [],
    currentIndex: -1,
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    playMode: 0
  };
  @State private showOptions: boolean = false;
  
  private playerManager: PlayerManager = PlayerManager.getInstance();
  private playlistDialogController: CustomDialogController = new CustomDialogController({
    builder: PlaylistDialog(),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  });
  
  aboutToAppear() {
    // 监听播放器状态变化
    this.playerManager.addListener((state: PlayerState) => {
      this.playerState = state;
    });
    
    // 获取当前播放器状态
    this.playerState = this.playerManager.getPlayerState();
  }
  
  aboutToDisappear() {
    // 移除监听器
    this.playerManager.removeListener((state: PlayerState) => {
      this.playerState = state;
    });
  }
  
  /**
   * 格式化时间 - 将秒数转换为 mm:ss 格式
   */
  private formatTime(seconds: number): string {
    // 确保seconds是有效数字
    if (!seconds || isNaN(seconds) || seconds < 0) {
      return '00:00';
    }
    
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    
    // 限制最大显示时间为99:59
    const displayMins = Math.min(mins, 99);
    
    return `${displayMins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  
  /**
   * 获取当前歌曲
   */
  private getCurrentSong(): Song | undefined {
    if (this.playerState.currentIndex >= 0 && this.playerState.playlist.length > 0) {
      return this.playerState.playlist[this.playerState.currentIndex];
    }
    return undefined;
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_public_arrow_left_filled'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        
        Blank()
        
        Text('正在播放')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
        
        Blank()
        
        Image($r('app.media.ic_public_more_filled'))
          .width(24)
          .height(24)
          .onClick(() => {
            this.showOptions = true;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.Transparent)
      
      Scroll() {
        Column() {
          // 歌曲封面
          Column() {
            if (this.getCurrentSong()) {
              Image(ImageUtil.getSongCoverUrl(this.getCurrentSong()!.pic || ''))
                .width(280)
                .height(280)
                .borderRadius(20)
                .objectFit(ImageFit.Cover)
                .alt($r('app.media.bg_default'))
                .shadow({
                  radius: 20,
                  color: '#33000000',
                  offsetY: 10
                })
            } else {
              Image($r('app.media.bg_default'))
                .width(280)
                .height(280)
                .borderRadius(20)
                .objectFit(ImageFit.Cover)
            }
          }
          .margin({ top: 40, bottom: 40 })
          
          // 歌曲信息
          Column() {
            Text(this.getCurrentSong()?.name || '未知歌曲')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            
            Text(this.getCurrentSong()?.singer?.name || '未知歌手')
              .fontSize(16)
              .fontColor('#CCFFFFFF')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
              .onClick(() => {
                this.navigateToSinger();
              })
          }
          .width('100%')
          .padding({ left: 32, right: 32 })
          .margin({ bottom: 40 })
          
          // 进度条
          Column() {
            Slider({
              value: this.playerState.currentTime,
              min: 0,
              max: this.playerState.duration,
              step: 1
            })
              .width('100%')
              .trackColor('#33FFFFFF')
              .selectedColor(Color.White)
              .blockColor(Color.White)
              .onChange(async (value: number) => {
                await this.playerManager.seekTo(value);
              })
            
            Row() {
              Text(this.formatTime(this.playerState.currentTime))
                .fontSize(12)
                .fontColor('#CCFFFFFF')
              
              Blank()
              
              Text(this.formatTime(this.playerState.duration))
                .fontSize(12)
                .fontColor('#CCFFFFFF')
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .width('100%')
          .padding({ left: 32, right: 32 })
          .margin({ bottom: 40 })
          
          // 控制按钮
          Row() {
            // 播放模式
            Image(this.getPlayModeIcon())
              .width(24)
              .height(24)
              .onClick(() => {
                this.playerManager.togglePlayMode();
              })
            
            Blank()
            
            // 上一首
            Image($r('app.media.ic_public_play_last'))
              .width(32)
              .height(32)
              .onClick(async () => {
                await this.playerManager.previous();
              })
            
            Blank()
            
            // 播放/暂停
            Image(this.playerState.isPlaying ? $r('app.media.ic_public_pause') : $r('app.media.ic_play_fill'))
              .width(56)
              .height(56)
              .borderRadius(28)
              .backgroundColor('#FFFFFF')
              .padding(12)
              .onClick(async () => {
                await this.playerManager.togglePlay();
              })
            
            Blank()
            
            // 下一首
            Image($r('app.media.ic_public_play_next'))
              .width(32)
              .height(32)
              .onClick(async () => {
                await this.playerManager.next();
              })
            
            Blank()
            
            // 播放列表
            Image($r('app.media.ic_playqueue'))
              .width(24)
              .height(24)
              .onClick(() => {
                this.playlistDialogController.open();
              })
          }
          .width('100%')
          .padding({ left: 32, right: 32 })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FF2D3436')
    .backgroundImage($r('app.media.bg4'))
    .backgroundImageSize(ImageSize.Cover)
    .bindSheet(this.showOptions, this.OptionsMenuBuilder(), {
      height: '50%',
      backgroundColor: Color.Transparent,
      onDisappear: () => {
        this.showOptions = false;
      }
    })
  }
  
  @Builder
  OptionsMenuBuilder() {
    PlayerOptionsMenu({ currentSong: this.getCurrentSong() })
  }
  
  /**
   * 获取播放模式图标
   */
  private getPlayModeIcon(): Resource {
    switch (this.playerState.playMode) {
      case 0: // SEQUENCE
        return $r('app.media.ic_public_order_play');
      case 1: // LOOP
        return $r('app.media.ic_public_list_cycle');
      case 2: // SINGLE
        return $r('app.media.ic_public_single_cycle');
      case 3: // RANDOM
        return $r('app.media.ic_public_random');
      default:
        return $r('app.media.ic_public_order_play');
    }
  }
  
  /**
   * 跳转到歌手详情页
   */
  private navigateToSinger(): void {
    const currentSong = this.getCurrentSong();
    if (currentSong?.singer?.id) {
      router.pushUrl({
        url: 'pages/SingerDetailPage',
        params: {
          singerId: currentSong.singer.id
        }
      }).catch((error: Error) => {
        console.error('跳转歌手详情页失败:', error.message);
      });
    }
  }
}
