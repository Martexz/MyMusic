import { CommonConstants } from '../common/constants/CommonConstants';
import { Song } from '../models/DataModels';
import { UserManager } from '../managers/UserManager';
import { MusicService } from '../services/MusicService';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ImageUtil } from '../utils/ImageUtil';

@Entry
@Component
struct MyFavoritesPage {
  @State favoriteSongs: Song[] = [];
  @State isLoading: boolean = true;
  @State isEmpty: boolean = false;
  @State isLogin: boolean = false;
  @State themeMode: ThemeMode = themeManager.themeMode;
  
  private userManager: UserManager = UserManager.getInstance();

  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    this.checkLoginAndLoadFavorites();
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

  private checkLoginAndLoadFavorites() {
    const currentUser = this.userManager.getCurrentUser();
    if (currentUser) {
      this.isLogin = true;
      this.loadFavorites();
    } else {
      this.isLogin = false;
      this.isLoading = false;
    }
  }

  private async loadFavorites() {
    try {
      this.isLoading = true;
      const currentUser = this.userManager.getCurrentUser();
      if (currentUser) {
        // 获取用户收藏的歌曲
        const favorites = await MusicService.getCollectSongs(currentUser.id);
        this.favoriteSongs = favorites || [];
        this.isEmpty = this.favoriteSongs.length === 0;
      }
    } catch (error) {
      console.error('加载收藏歌曲失败:', error);
      promptAction.showToast({ message: '加载收藏歌曲失败' });
      this.favoriteSongs = [];
      this.isEmpty = true;
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopNavigationBar()
      
      if (!this.isLogin) {
        // 未登录状态
        this.NotLoginSection()
      } else if (this.isLoading) {
        // 加载中状态
        this.LoadingSection()
      } else if (this.isEmpty) {
        // 空状态
        this.EmptySection()
      } else {
        // 收藏列表
        this.FavoriteListSection()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBackgroundColor())
  }

  @Builder
  TopNavigationBar() {
    Row() {
      Image($r('app.media.ic_public_back'))
        .width(24)
        .height(24)
        .fillColor(CommonConstants.TEXT_PRIMARY)
        .onClick(() => {
          router.back();
        })

      Text('我的收藏')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getTextPrimary())
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 右侧操作按钮
      if (this.favoriteSongs.length > 0) {
        Image($r('app.media.ic_public_arrow_right'))
          .width(24)
          .height(24)
          .fillColor(CommonConstants.TEXT_PRIMARY)
          .onClick(() => {
            this.playAllFavorites();
          })
      } else {
        Text('')
          .width(24)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }

  @Builder
  NotLoginSection() {
    Column() {
      Image($r('app.media.ic_public_favor_filled'))
        .width(80)
        .height(80)
        .fillColor('#CCCCCC')
        .margin({ bottom: 20 })

      Text('登录后查看收藏')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ bottom: 8 })

      Text('登录账号，收藏你喜欢的音乐')
        .fontSize(14)
        .fontColor(CommonConstants.TEXT_SECONDARY)
        .margin({ bottom: 30 })

      Button('立即登录')
        .type(ButtonType.Normal)
        .backgroundColor(CommonConstants.PRIMARY_COLOR)
        .fontColor(Color.White)
        .borderRadius(CommonConstants.BORDER_RADIUS)
        .width(120)
        .onClick(() => {
          router.pushUrl({ url: 'pages/LoginPage' });
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(CommonConstants.MARGIN_LARGE)
  }

  @Builder
  LoadingSection() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(CommonConstants.PRIMARY_COLOR)

      Text('正在加载...')
        .fontSize(16)
        .fontColor(CommonConstants.TEXT_SECONDARY)
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  EmptySection() {
    Column() {
      Image($r('app.media.ic_public_favor_filled'))
        .width(80)
        .height(80)
        .fillColor('#CCCCCC')
        .margin({ bottom: 20 })

      Text('暂无收藏')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ bottom: 8 })

      Text('快去收藏你喜欢的音乐吧')
        .fontSize(14)
        .fontColor(CommonConstants.TEXT_SECONDARY)
        .margin({ bottom: 30 })

      Button('去发现音乐')
        .type(ButtonType.Normal)
        .backgroundColor(CommonConstants.PRIMARY_COLOR)
        .fontColor(Color.White)
        .borderRadius(CommonConstants.BORDER_RADIUS)
        .width(120)
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(CommonConstants.MARGIN_LARGE)
  }

  @Builder
  FavoriteListSection() {
    Column() {
      // 列表头部信息
      Row() {
        Text(`共${this.favoriteSongs.length}首歌曲`)
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin({ left: 16 })

        Blank()

        Button('播放全部')
          .type(ButtonType.Normal)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .fontColor(Color.White)
          .borderRadius(16)
          .fontSize(12)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .margin({ right: 16 })
          .onClick(() => {
            this.playAllFavorites();
          })
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)

      Divider()
        .color('#F0F0F0')

      // 歌曲列表
      List() {
        ForEach(this.favoriteSongs, (song: Song, index: number) => {
          ListItem() {
            this.SongItem(song, index)
          }
          .onClick(() => {
            this.playSong(song, index);
          })
        })
      }
      .layoutWeight(1)
      .backgroundColor(Color.White)
      .divider({ strokeWidth: 1, color: '#F0F0F0', startMargin: 60, endMargin: 16 })
    }
    .layoutWeight(1)
  }

  @Builder
  SongItem(song: Song, index: number) {
    Row() {
      // 序号
      Text((index + 1).toString())
        .fontSize(14)
        .fontColor(this.getTextSecondary())
        .width(30)
        .textAlign(TextAlign.Center)

      // 歌曲封面
      Image(song.pic ? ImageUtil.getSongCoverUrl(song.pic) : $r('app.media.ic_music_fill'))
        .width(40)
        .height(40)
        .borderRadius(4)
        .margin({ left: 8, right: 12 })
        .alt($r('app.media.ic_music_fill'))
        .onError(() => {
          console.log('歌曲图片加载失败:', song.pic);
        })

      // 歌曲信息
      Column() {
        Text(song.name)
          .fontSize(16)
          .fontColor(this.getTextPrimary())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)

        Text(song.singer?.name || '未知歌手')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 操作按钮
      Row() {
        // 取消收藏按钮
        Image($r('app.media.ic_public_favor_filled'))
          .width(20)
          .height(20)
          .fillColor(CommonConstants.PRIMARY_COLOR)
          .margin({ right: 12 })
          .onClick(() => {
            this.toggleFavorite(song, index);
          })

        // 更多操作按钮
        Image($r('app.media.ic_more_vertical_o_icon'))
          .width(20)
          .height(20)
          .fillColor(CommonConstants.TEXT_SECONDARY)
          .onClick(() => {
            this.showMoreOptions(song);
          })
      }
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  private async playSong(song: Song, index: number) {
    try {
      // 播放选中的歌曲，并将收藏列表作为播放列表
      await MusicService.playMusic(song, this.favoriteSongs, index);
      promptAction.showToast({ message: `正在播放: ${song.name}` });
    } catch (error) {
      console.error('播放歌曲失败:', error);
      promptAction.showToast({ message: '播放失败' });
    }
  }

  private async playAllFavorites() {
    if (this.favoriteSongs.length === 0) return;
    
    try {
      // 播放收藏列表的第一首歌曲
      await MusicService.playMusic(this.favoriteSongs[0], this.favoriteSongs, 0);
      promptAction.showToast({ message: '开始播放收藏列表' });
    } catch (error) {
      console.error('播放收藏列表失败:', error);
      promptAction.showToast({ message: '播放失败' });
    }
  }

  private async toggleFavorite(song: Song, index: number) {
    try {
      const currentUser = this.userManager.getCurrentUser();
      if (!currentUser) {
        promptAction.showToast({ message: '请先登录' });
        return;
      }

      // 取消收藏
      const success = await MusicService.removeFromCollect(currentUser.id, song.id);
      if (success) {
        // 从列表中移除
        this.favoriteSongs.splice(index, 1);
        this.isEmpty = this.favoriteSongs.length === 0;
        promptAction.showToast({ message: '已取消收藏' });
      } else {
        promptAction.showToast({ message: '取消收藏失败' });
      }
    } catch (error) {
      console.error('取消收藏失败:', error);
      promptAction.showToast({ message: '取消收藏失败' });
    }
  }

  private showMoreOptions(song: Song) {
    // 显示更多操作选项
    promptAction.showToast({ message: '更多操作功能待实现' });
  }
}
