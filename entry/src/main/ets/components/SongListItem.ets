import { SongList } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ImageUtil } from '../utils/ImageUtil';

@Component
export struct SongListItem {
  @Prop songList: SongList;

  build() {
    Column() {
      // 歌单封面
      Image(this.songList.pic ? ImageUtil.getSongListCoverUrl(this.songList.pic) : $r('app.media.ic_public_music'))
        .width('100%')
        .aspectRatio(1)
        .borderRadius(CommonConstants.BORDER_RADIUS)
        .objectFit(ImageFit.Cover)
        .alt($r('app.media.ic_public_music'))
        .onError(() => {
          console.log('歌单图片加载失败:', this.songList.pic);
        })

      // 歌单信息
      Column() {
        Text(this.songList.title)
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({ top: CommonConstants.MARGIN_SMALL })

        if (this.songList.introduction) {
          Text(this.songList.introduction)
            .fontSize(12)
            .fontColor(CommonConstants.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(CommonConstants.MARGIN_SMALL)
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .onClick(() => {
      this.openSongList();
    })
  }

  private openSongList() {
    // TODO: 跳转到歌单详情页面
    console.log('打开歌单:', this.songList.title);
  }
}
