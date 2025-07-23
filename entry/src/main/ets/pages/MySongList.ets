import { router } from '@kit.ArkUI';
import { SongListParams, Song } from '../models/DataModels';
import { MusicService } from '../services/MusicService';
import { SongItem } from '../components/SongItem';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import promptAction from '@ohos.promptAction';
import { CommonConstants } from '../common/constants/CommonConstants';
import { UserManager } from '../managers/UserManager';
import { PlayerManager } from '../managers/PlayerManager';

interface PlaylistInfo {
  id: number;
  name: string;
  cover_image?: string;
  description?: string;
  song_count?: number;
}

@Entry
@Component
export struct MySongList {
  @State songListId: number = -1;
  @State songListName: string = '';
  @State creatorName: string = '';
  @State songs: Song[] = [];
  @State isLoading: boolean = true;
  @State themeMode: ThemeMode = themeManager.themeMode;

  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    
    const params = router.getParams() as SongListParams;
    if (params) {
      this.songListId = params.id ?? -1;
      this.songListName = params.title ?? '';
      this.creatorName = params.username ?? '';
      
      if (this.songListId !== -1) {
        this.loadSongListSongs();
      }
    }
  }

  aboutToDisappear() {
    themeManager.off(this.onThemeChanged);
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

  private getTextSecondary(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_SECONDARY : CommonConstants.TEXT_COLOR_LIGHT_SECONDARY;
  }

  private async loadSongListSongs() {
    try {
      this.isLoading = true;
      const result = await MusicService.getPlaylistSongs(this.songListId);
      if (result.success && result.data) {
        this.songs = result.data;
      } else {
        console.error('加载歌单歌曲失败:', result.message);
        this.songs = [];
        promptAction.showToast({ message: result.message || '加载歌单歌曲失败' });
      }
    } catch (error) {
      console.error('加载歌单歌曲失败:', error);
      this.songs = [];
      promptAction.showToast({ message: '加载歌单歌曲失败' });
    } finally {
      this.isLoading = false;
    }
  }

  private async playAllSongs() {
    if (this.songs.length > 0) {
      try {
        PlayerManager.playPlaylist(this.songs, 0);
        promptAction.showToast({ message: '开始播放歌单' });
      } catch (error) {
        console.error('播放失败:', error);
        promptAction.showToast({ message: '播放失败' });
      }
    }
  }

  private playSong(song: Song, index: number) {
    try {
      PlayerManager.playPlaylist(this.songs, index);
    } catch (error) {
      console.error('播放失败:', error);
      promptAction.showToast({ message: '播放失败' });
    }
  }



  build() {
    Column() {
      // 播放页整体
      Column() {
        // 歌单头部区域
        Column() {
          // 简介区域
          Row({ space: 8 }) {
            Row() {
              Image($r('app.media.bg_default'))
                .width('80%')
                .opacity(0.8)
                .fillColor('#ff5186')
            }
            .width(100)
            .aspectRatio(1)
            .borderRadius(8)
            .backgroundColor(Color.White)
            .justifyContent(FlexAlign.Center)

            Column({ space: 12 }) {
              Text(this.songListName)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .fontSize(20)

              Text(`歌单创建人：${this.creatorName}`)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .fontSize(14)


              Blank()
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }

          // 操作按钮区域
          Row() {
            Button() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_public_share_filled'))
                  .width(20)
                  .fillColor('#ec5c87')
                Text('分享')
                  .fontColor(Color.White)
                  .fontSize(12)
              }
              .width(100)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ff353333')
            }
            .clip(true)

            Button() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_public_message'))
                  .width(20)
                  .fillColor('#ec5c87')
                Text('评论')
                  .fontColor(Color.White)
                  .fontSize(12)
              }
              .width(100)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ff353333')
            }
            .clip(true)

            Button() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_public_favor'))
                  .width(20)
                  .fillColor('#ec5c87')
                Text('收藏')
                  .fontColor(Color.White)
                  .fontSize(12)
              }
              .width(100)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ff353333')
            }
            .clip(true)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .height('30%')
        .justifyContent(FlexAlign.SpaceAround)
        .radialGradient({
          center: ['80%', '-10%'],
          radius: '100%',
          colors: [['#ff865d13', 0.0], [Color.Transparent, 1.0]]
        })
        .padding(16)

        // 歌单播放列表区域
        Column() {
          // 播放全部按钮
          Row({ space: 8 }) {
            Row({ space: 8 }) {
              Image($r("app.media.ic_public_play_norm"))
                .width(16)
                .fillColor('#ff5186')
              Text(`播放全部 (${this.songs.length})`)
                .fontColor('#333333')
                .fontSize(14)
            }
            .onClick(() => {
              this.playAllSongs();
            })
          }
          .width('100%')
          .padding(16)
          .border({
            width: { bottom: 1 },
            color: '#12ec5c87'
          })

          // 歌曲列表
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color(CommonConstants.PRIMARY_COLOR)
              
              Text('加载中...')
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_SECONDARY)
                .margin({ top: 16 })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else if (this.songs.length === 0) {
            Column() {
              Image($r('app.media.ic_public_music'))
                .width(60)
                .height(60)
                .fillColor(CommonConstants.TEXT_SECONDARY)
              
              Text('歌单中暂无歌曲')
                .fontSize(16)
                .fontColor(CommonConstants.TEXT_PRIMARY)
                .margin({ top: 16 })
              
              Text('快去添加一些喜欢的歌曲吧')
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_SECONDARY)
                .margin({ top: 8 })
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            List({ space: 8 }) {
              ForEach(this.songs, (song: Song, index: number) => {
                ListItem() {
                  SongItem({ 
                    song: song,
                    showIndex: true,
                    index: index + 1,
                    themeMode: this.themeMode
                  })
                }
                .onClick(() => {
                  this.playSong(song, index);
                })
              })
            }
            .layoutWeight(1)
            .padding({ left: 16, right: 16, bottom: 16 })
          }
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 12, topRight: 12 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBackgroundColor())
  }
}