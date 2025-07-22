import { Singer } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ImageUtil } from '../utils/ImageUtil';

@Component
export struct SingerItem {
  @Prop singer: Singer;

  build() {
    Row() {
      // 歌手头像
      Image(this.singer.pic ? ImageUtil.getSingerAvatarUrl(this.singer.pic) : $r('app.media.ic_user_portrait'))
      .width(50)
      .height(50)
      .borderRadius(25)
      .objectFit(ImageFit.Cover)
      .alt($r('app.media.ic_user_portrait'))
      .onError(() => {
        console.log('歌手头像加载失败:', this.singer.pic);
      })

      // 歌手信息
      Column() {
        Text(this.singer.name)
          .fontSize(16)
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)

        if (this.singer.introduction) {
          Text(this.singer.introduction)
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .alignSelf(ItemAlign.Start)
            .margin({ top: 4 })
        }
      }
      .layoutWeight(1)
      .margin({ left: CommonConstants.MARGIN_MEDIUM })
      .alignItems(HorizontalAlign.Start)

      // 关注按钮
      Button('关注')
        .type(ButtonType.Normal)
        .backgroundColor(CommonConstants.PRIMARY_COLOR)
        .fontColor(Color.White)
        .borderRadius(CommonConstants.BORDER_RADIUS)
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          this.followSinger();
        })
    }
    .width('100%')
    .padding(CommonConstants.MARGIN_SMALL)
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .onClick(() => {
      this.openSingerDetail();
    })
  }

  private followSinger() {
    // TODO: 实现关注歌手功能
    console.log('关注歌手:', this.singer.name);
  }

  private openSingerDetail() {
    // TODO: 跳转到歌手详情页面
    console.log('打开歌手详情:', this.singer.name);
  }
}
