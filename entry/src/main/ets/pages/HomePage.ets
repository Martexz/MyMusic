import { CommonConstants } from '../common/constants/CommonConstants';
import { MusicService } from '../services/MusicService';
import { Swiper, Song, SongList } from '../models/DataModels';
import { SwiperComponent } from '../components/SwiperComponent';
import { SongItem } from '../components/SongItem';
import { SongListItem } from '../components/SongListItem';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import router from '@ohos.router';

@Component
export struct HomePage {
  @State swipers: Swiper[] = [];
  @State recommendSongs: Song[] = [];
  @State recommendSongLists: SongList[] = [];
  @State loading: boolean = true;
  @State themeMode: ThemeMode = themeManager.themeMode;

  // 监听主题变化
  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    this.loadData();
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

  private getTextPrimaryColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_PRIMARY : CommonConstants.TEXT_PRIMARY;
  }

  private getTextSecondaryColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_SECONDARY : CommonConstants.TEXT_SECONDARY;
  }

  private getLoadingColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.PRIMARY_COLOR : CommonConstants.PRIMARY_COLOR;
  }

  private async loadData() {
    try {
      this.loading = true;
      
      // 并行加载数据
      const swipersPromise = MusicService.getSwipers();
      const songsPromise = MusicService.getSongs({ page: 1, pageSize: 10 });
      const songListsPromise = MusicService.getSongLists({ page: 1, pageSize: 6 });
      
      const swipersData = await swipersPromise;
      const songsData = await songsPromise;
      const songListsData = await songListsPromise;
      
      this.swipers = swipersData;
      this.recommendSongs = songsData.songs;
      this.recommendSongLists = songListsData.songLists;
      
    } catch (error) {
      console.error('加载首页数据失败:', error);
    } finally {
      this.loading = false;
    }
  }

  build() {
    if (this.loading) {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(this.getLoadingColor())
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getBackgroundColor())
    } else {
      Scroll() {
        Column() {
          // 轮播图
          if (this.swipers.length > 0) {
            SwiperComponent({ swipers: this.swipers })
              .margin({ bottom: CommonConstants.MARGIN_LARGE })
          }

          // 推荐歌曲
          Column() {
            Row() {
              Text('推荐歌曲')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getTextPrimaryColor())

              Blank()
              
              Text('更多')
                .fontSize(14)
                .fontColor(this.getTextSecondaryColor())
                .onClick(() => {
                  // 跳转到更多歌曲页面
                  router.pushUrl({ url: 'pages/MoreSongsPage' });
                })
            }
            .width('100%')
            .margin({ bottom: CommonConstants.MARGIN_MEDIUM })

            Column() {
              ForEach(this.recommendSongs, (song: Song, index: number) => {
                SongItem({ 
                  song: song,
                  showIndex: true,
                  index: index + 1,
                  themeMode: this.themeMode
                })
                  .margin({ bottom: CommonConstants.MARGIN_SMALL })
              })
            }
          }
          .padding({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
          .margin({ bottom: CommonConstants.MARGIN_LARGE })

          // 推荐歌单
          Column() {
            Row() {
              Text('推荐歌单')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getTextPrimaryColor())

              Blank()
              
              Text('更多')
                .fontSize(14)
                .fontColor(this.getTextSecondaryColor())
                .onClick(() => {
                  // 跳转到更多歌单页面
                })
            }
            .width('100%')
            .margin({ bottom: CommonConstants.MARGIN_MEDIUM })

            Grid() {
              ForEach(this.recommendSongLists, (songList: SongList) => {
                GridItem() {
                  SongListItem({ songList: songList, themeMode: this.themeMode })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(CommonConstants.MARGIN_MEDIUM)
            .rowsGap(CommonConstants.MARGIN_MEDIUM)
          }
          .padding({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
          .margin({ bottom: CommonConstants.MARGIN_LARGE })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .backgroundColor(this.getBackgroundColor())
    }
  }
}
