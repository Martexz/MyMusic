import { Singer, Song } from '../models/DataModels';
import { MusicService } from '../services/MusicService';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ImageUtil } from '../utils/ImageUtil';
import { SongItem } from '../components/SongItem';
import { PlayerManager } from '../managers/PlayerManager';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import router from '@ohos.router';

@Entry
@Component
struct SingerDetailPage {
  @State singer: Singer | null = null;
  @State songs: Song[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State themeMode: ThemeMode = themeManager.themeMode;
  
  private singerId: number = 0;
  
  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    
    // 获取传递的歌手ID
    const params = router.getParams() as Record<string, Object>;
    if (params && params.singerId) {
      this.singerId = params.singerId as number;
      this.loadSingerData();
    } else {
      this.errorMessage = '歌手信息不存在';
      this.isLoading = false;
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
  
  /**
   * 加载歌手数据
   */
  private async loadSingerData(): Promise<void> {
    try {
      this.isLoading = true;
      
      // 并行获取歌手信息和歌手的歌曲
      const singerData = await MusicService.getSingerById(this.singerId);
      const songsData = await MusicService.getSongsBySingerId(this.singerId);
      
      this.singer = singerData;
      this.songs = songsData;
      
    } catch (error) {
      console.error('加载歌手数据失败:', error);
      this.errorMessage = '加载歌手信息失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_public_arrow_left_filled'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .onClick(() => {
            router.back();
          })
        
        Text('歌手详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getTextPrimary())
          .margin({ left: 16 })
        
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.Transparent)
      
      if (this.isLoading) {
        // 加载中状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(Color.White)
          
          Text('加载中...')
            .fontSize(16)
            .fontColor(Color.White)
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        
      } else if (this.errorMessage) {
        // 错误状态
        Column() {
          Image($r('app.media.ic_public_help'))
            .width(60)
            .height(60)
            .fillColor('#CCFFFFFF')
          
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#CCFFFFFF')
            .margin({ top: 16 })
          
          Button('重试')
            .width(120)
            .height(40)
            .backgroundColor(Color.White)
            .fontColor(CommonConstants.PRIMARY_COLOR)
            .margin({ top: 20 })
            .onClick(() => {
              this.loadSingerData();
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        
      } else if (this.singer) {
        // 内容区域
        Scroll() {
          Column() {
            // 歌手信息区域
            Column() {
              // 歌手头像
              Image(ImageUtil.getSingerAvatarUrl(this.singer.pic || ''))
                .width(150)
                .height(150)
                .borderRadius(75)
                .objectFit(ImageFit.Cover)
                .alt($r('app.media.ic_user_portrait'))
                .shadow({
                  radius: 20,
                  color: '#33000000',
                  offsetY: 10
                })
              
              // 歌手名称
              Text(this.singer.name)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .margin({ top: 20 })
              
              // 歌手信息
              if (this.singer.location || this.singer.birth) {
                Row() {
                  if (this.singer.location) {
                    Text(this.singer.location)
                      .fontSize(14)
                      .fontColor('#CCFFFFFF')
                  }
                  
                  if (this.singer.location && this.singer.birth) {
                    Text(' · ')
                      .fontSize(14)
                      .fontColor('#CCFFFFFF')
                  }
                  
                  if (this.singer.birth) {
                    Text(this.singer.birth)
                      .fontSize(14)
                      .fontColor('#CCFFFFFF')
                  }
                }
                .margin({ top: 8 })
              }
              
              // 歌曲数量
              Text(`${this.songs.length} 首歌曲`)
                .fontSize(14)
                .fontColor('#CCFFFFFF')
                .margin({ top: 8 })
              
              // 歌手简介
              if (this.singer.introduction) {
                Text(this.singer.introduction)
                  .fontSize(14)
                  .fontColor('#CCFFFFFF')
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Center)
                  .margin({ top: 16 })
                  .padding({ left: 20, right: 20 })
              }
              
              // 操作按钮
              Row() {
                Button('播放全部')
                  .width(120)
                  .height(40)
                  .backgroundColor(Color.White)
                  .fontColor(CommonConstants.PRIMARY_COLOR)
                  .onClick(() => {
                    this.playAllSongs();
                  })
                
                Button('收藏歌手')
                  .width(120)
                  .height(40)
                  .backgroundColor(Color.Transparent)
                  .fontColor(Color.White)
                  .border({ width: 1, color: Color.White })
                  .margin({ left: 16 })
                  .onClick(() => {
                    this.followSinger();
                  })
              }
              .margin({ top: 30 })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 20, bottom: 30 })
            .alignItems(HorizontalAlign.Center)
            
            // 歌曲列表
            Column() {
              Row() {
                Text('歌曲列表')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(CommonConstants.TEXT_PRIMARY)
                
                Blank()
                
                Text(`共${this.songs.length}首`)
                  .fontSize(14)
                  .fontColor(CommonConstants.TEXT_SECONDARY)
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              
              if (this.songs.length > 0) {
                ForEach(this.songs, (song: Song, index: number) => {
                  SongItem({ 
                    song: song,
                    showIndex: true,
                    index: index + 1,
                    themeMode: this.themeMode
                  })
                    .margin({ bottom: 8 })
                }, (song: Song) => song.id.toString())
              } else {
                Column() {
                  Image($r('app.media.ic_music_fill'))
                    .width(60)
                    .height(60)
                    .fillColor(CommonConstants.TEXT_SECONDARY)
                  
                  Text('暂无歌曲')
                    .fontSize(16)
                    .fontColor(CommonConstants.TEXT_SECONDARY)
                    .margin({ top: 16 })
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius({ topLeft: 20, topRight: 20 })
          }
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBackgroundColor())
    .backgroundImage($r('app.media.bg4'))
    .backgroundImageSize(ImageSize.Cover)
  }
  
  /**
   * 播放全部歌曲
   */
  private playAllSongs(): void {
    if (this.songs.length > 0) {
      const playerManager = PlayerManager.getInstance();
      // 清空当前播放列表并添加所有歌曲
      playerManager.clearPlaylist();
      playerManager.addSongsToPlaylist(this.songs);
      // 播放第一首歌
      playerManager.playSong(this.songs[0]);
      console.log('开始播放歌手所有歌曲，共', this.songs.length, '首');
    } else {
      console.log('没有可播放的歌曲');
    }
  }
  
  /**
   * 收藏歌手
   */
  private followSinger(): void {
    // TODO: 实现关注歌手功能
    console.log('关注歌手:', this.singer?.name);
    // 这里可以调用API关注/取消关注歌手
    /*
    try {
      const response = await MusicService.followSinger(this.singer.id, !this.isFollowed);
      if (response.success) {
        this.isFollowed = !this.isFollowed;
        console.log(this.isFollowed ? '关注成功' : '取消关注成功');
      }
    } catch (error) {
      console.error('关注操作失败:', error);
    }
    */
  }
}
