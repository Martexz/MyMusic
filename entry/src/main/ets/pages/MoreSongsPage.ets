import router from '@ohos.router';
import { CommonConstants } from '../common/constants/CommonConstants';
import { MusicService } from '../services/MusicService';
import { Song } from '../models/DataModels';
import { SongItem } from '../components/SongItem';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import { MiniPlayer } from '../components/MiniPlayer';

const MINI_PLAYER_HEIGHT = 64; // MiniPlayer高度，按实际调整

@Entry
@Component
export struct MoreSongsPage {
  @State songs: Song[] = [];
  @State loading: boolean = false;
  @State noMoreData: boolean = false;
  @State currentPage: number = 1;
  @State themeMode: ThemeMode = themeManager.themeMode;
  @State scrollOffsetY: number = 0;
  private readonly pageSize: number = 20;

  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    this.loadSongs(1);
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

  private getTextColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_PRIMARY : CommonConstants.TEXT_PRIMARY;
  }

  private async loadSongs(page: number) {
    if (this.loading) return;
    this.loading = true;
    try {
      const data = await MusicService.getSongs({ page, pageSize: this.pageSize });
      if (page === 1) {
        this.songs = data.songs;
      } else {
        this.songs = [...this.songs, ...data.songs];
      }
      this.noMoreData = data.songs.length < this.pageSize;
      this.currentPage = page;
    } catch (error) {
      console.error('加载歌曲失败:', error);
    } finally {
      this.loading = false;
    }
  }

  private checkIfScrollToBottom() {
    if (!this.loading && !this.noMoreData) {
      this.loadSongs(this.currentPage + 1);
    }
  }

  build() {
    // 外层Column，内容区+MiniPlayer
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_public_arrow_left_filled'))
          .width(24)
          .height(24)
          .fillColor(this.themeMode==='dark'?"#ffffff":"#000000")
          .onClick(() => {
            router.back();
          })

        Blank().width('auto').flexGrow(1)

        Text('推荐歌单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextColor())
          .alignSelf(ItemAlign.Center)
          .flexGrow(2)
          .textAlign(TextAlign.Center)

        Blank().width('auto').flexGrow(1)
      }
      .height(56)
      .width('100%')
      .backgroundColor(this.getBackgroundColor())
      .alignItems(VerticalAlign.Center)
      .padding({
        left: 16,
        right: 16,
      })

      // 歌单列表内容区
      Scroll() {
        Column() {
          ForEach(this.songs, (song: Song, index: number) => {
            SongItem({ song: song, showIndex: true, index: index + 1, themeMode: this.themeMode })
              .margin({ bottom: CommonConstants.MARGIN_SMALL })
              .width('100%')
          })

          if (this.loading) {
            LoadingProgress()
              .width(40)
              .height(40)
              .color(this.getTextColor())
              .alignSelf(ItemAlign.Center)
          }

          if (!this.loading && this.noMoreData) {
            Row() {
              Blank().layoutWeight(1)
              Text('没有更多歌曲了')
                .fontSize(14)
                .fontColor(this.getTextColor())
                .textAlign(TextAlign.Center)
                .padding({
                  top: CommonConstants.MARGIN_MEDIUM,
                  bottom: CommonConstants.MARGIN_MEDIUM
                })
              Blank().layoutWeight(1)
            }
            .width('100%')
          }
        }
        .justifyContent(FlexAlign.Start)
        .padding({
          left: CommonConstants.MARGIN_MEDIUM,
          right: CommonConstants.MARGIN_MEDIUM
        })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .align(Alignment.Top)
      .scrollable(ScrollDirection.Vertical)
      .onScroll((xOffset: number, yOffset: number) => {
        this.scrollOffsetY = yOffset;
        this.checkIfScrollToBottom();
      })
      .width('100%')
      .layoutWeight(1) // 让内容区自动填满剩余空间

      // MiniPlayer 固定在底部
      MiniPlayer()
        .width('100%')
        .height(MINI_PLAYER_HEIGHT)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBackgroundColor())
  }
}