import { CommonConstants } from '../common/constants/CommonConstants';
import { HomePage } from './HomePage';
import { DiscoverPage } from './DiscoverPage';
import { PlaylistPage } from './PlaylistPage';
import { ProfilePage } from './ProfilePage';
import { MiniPlayer } from '../components/MiniPlayer';
import themeManager, { ThemeMode } from '../common/ThemeManager';

@Component
export struct MainPage {
  @State currentTabIndex: number = CommonConstants.TAB_HOME;
  @State themeMode: ThemeMode = themeManager.themeMode;
  private readonly onThemeChanged = (mode: ThemeMode): void => {
    this.themeMode = mode;
  };
  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
  }

  aboutToDisappear() {
    themeManager.off(this.onThemeChanged);
  }
  private getBackgroundColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.BACKGROUND_DARK : CommonConstants.BACKGROUND_LIGHT;
  }

  private getTabTextColor(isSelected: boolean): string {
    if (isSelected) return CommonConstants.PRIMARY_COLOR;
    return this.themeMode === 'dark'
      ? CommonConstants.TEXT_COLOR_DARK_SECONDARY
      : CommonConstants.TEXT_COLOR_LIGHT_SECONDARY;
  }

  @Builder
  TabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentTabIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 })
        .fillColor(this.themeMode==='dark'?"#ffffff":"#000000")
      Text(title)
        .fontColor(this.getTabTextColor(this.currentTabIndex === targetIndex))
        .fontSize(12)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTabIndex = targetIndex;
    })

  }

  build() {
    Column() {
      // 主内容区
      Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.TabBuilder('首页', CommonConstants.TAB_HOME, $r('app.media.ic_public_app_filled'), $r('app.media.ic_public_app_filled')))

        TabContent() {
          DiscoverPage()
        }
        .tabBar(this.TabBuilder('发现', CommonConstants.TAB_DISCOVER, $r('app.media.ic_public_search_filled'), $r('app.media.ic_public_search_filled')))

        TabContent() {
          PlaylistPage()
        }
        .tabBar(this.TabBuilder('歌单', CommonConstants.TAB_PLAYLIST, $r('app.media.ic_public_music'), $r('app.media.ic_public_music')))

        TabContent() {
          ProfilePage()
        }
        .tabBar(this.TabBuilder('我的', CommonConstants.TAB_PROFILE, $r('app.media.ic_public_contacts_filled'), $r('app.media.ic_public_contacts')))
      }
      .layoutWeight(1)
      .backgroundColor(this.getBackgroundColor())
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })

      // 迷你播放器
      MiniPlayer()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeMode==='dark'?CommonConstants.BACKGROUND_DARK:CommonConstants.BACKGROUND_LIGHT)
  }
}
