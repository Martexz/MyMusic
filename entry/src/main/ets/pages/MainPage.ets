import { CommonConstants } from '../common/constants/CommonConstants';
import { HomePage } from './HomePage';
import { DiscoverPage } from './DiscoverPage';
import { PlaylistPage } from './PlaylistPage';
import { ProfilePage } from './ProfilePage';
import { MiniPlayer } from '../components/MiniPlayer';

@Component
export struct MainPage {
  @State currentTabIndex: number = CommonConstants.TAB_HOME;

  @Builder
  TabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentTabIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 })
      Text(title)
        .fontColor(this.currentTabIndex === targetIndex ? CommonConstants.PRIMARY_COLOR : CommonConstants.TEXT_SECONDARY)
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
      .barBackgroundColor(Color.White)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })

      // 迷你播放器
      MiniPlayer()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
  }
}
