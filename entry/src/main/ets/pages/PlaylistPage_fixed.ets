import { CommonConstants } from '../common/constants/CommonConstants';
import { SongList } from '../models/DataModels';

@Component
export struct PlaylistPage {
  @State myPlaylists: SongList[] = [];
  @State createdPlaylists: SongList[] = [];
  @State collectedPlaylists: SongList[] = [];

  build() {
    Column() {
      // 头部
      Row() {
        Text('我的歌单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(CommonConstants.TEXT_PRIMARY)
        
        Blank()
        
        Row() {
          Image($r('app.media.ic_public_add_filled'))
            .width(16)
            .height(16)
            .fillColor(Color.White)
            .margin({ right: 4 })
          
          Text('创建歌单')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .backgroundColor(CommonConstants.PRIMARY_COLOR)
        .borderRadius(CommonConstants.BORDER_RADIUS)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.createPlaylist();
        })
      }
      .width('100%')
      .padding(CommonConstants.MARGIN_MEDIUM)
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          // 最近播放
          this.SectionHeader('最近播放')
          this.RecentPlaySection()

          // 创建的歌单
          this.SectionHeader('创建的歌单')
          this.CreatedPlaylistSection()

          // 收藏的歌单
          this.SectionHeader('收藏的歌单')
          this.CollectedPlaylistSection()
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
  }

  @Builder
  SectionHeader(title: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(CommonConstants.TEXT_PRIMARY)
      
      Blank()
      
      Text('查看全部')
        .fontSize(14)
        .fontColor(CommonConstants.TEXT_SECONDARY)
        .onClick(() => {
          // 查看全部逻辑
        })
    }
    .width('100%')
    .padding({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM, top: CommonConstants.MARGIN_SMALL, bottom: CommonConstants.MARGIN_SMALL })
    .margin({ top: CommonConstants.MARGIN_MEDIUM })
  }

  @Builder
  RecentPlaySection() {
    Column() {
      if (this.myPlaylists.length === 0) {
        Text('暂无最近播放记录')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        // TODO: 实现最近播放列表
        Text('最近播放列表')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  @Builder
  CreatedPlaylistSection() {
    Column() {
      if (this.createdPlaylists.length === 0) {
        Text('还没有创建歌单，快去创建一个吧！')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        // TODO: 实现创建的歌单列表
        Text('创建的歌单列表')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  @Builder
  CollectedPlaylistSection() {
    Column() {
      if (this.collectedPlaylists.length === 0) {
        Text('还没有收藏歌单')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        // TODO: 实现收藏的歌单列表
        Text('收藏的歌单列表')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  private createPlaylist() {
    // TODO: 实现创建歌单逻辑
    console.log('创建歌单');
  }
}
