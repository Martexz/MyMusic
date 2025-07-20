import { Song } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';
import { PlayerManager } from '../managers/PlayerManager';
import router from '@ohos.router';

@Component
export struct SongItem {
  @Prop song: Song;
  @Prop showIndex?: boolean = false;
  @Prop index?: number = 0;

  build() {
    Row() {
      // 序号或封面
      if (this.showIndex === true && this.index !== undefined && this.index > 0) {
        Text(this.index.toString())
          .width(30)
          .fontSize(16)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
      } else {
        Image(this.song.pic || $r('app.media.ic_music_fill'))
          .width(50)
          .height(50)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
      }

      // 歌曲信息
      Column() {
        Text(this.song.name)
          .fontSize(16)
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)

        Text(this.song.singer?.name || '未知歌手')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4 })
          .onClick(() => {
            this.navigateToSinger();
          })
      }
      .layoutWeight(1)
      .margin({ left: CommonConstants.MARGIN_MEDIUM })
      .alignItems(HorizontalAlign.Start)

      // 更多操作按钮
      Image($r('app.media.ic_more_vertical_o_icon'))
        .width(24)
        .height(24)
        .fillColor(CommonConstants.TEXT_SECONDARY)
        .onClick(() => {
          this.showMoreOptions();
        })
    }
    .width('100%')
    .padding(CommonConstants.MARGIN_SMALL)
    .backgroundColor(Color.White)
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .onClick(() => {
      this.playSong();
    })
  }

  private playSong() {
    const playerManager = PlayerManager.getInstance();
    playerManager.playSong(this.song);
  }

  private showMoreOptions() {
    // TODO: 显示更多操作选项（收藏、添加到歌单等）
    console.log('显示更多操作:', this.song.name);
  }

  private navigateToSinger() {
    if (this.song.singer?.id) {
      router.pushUrl({
        url: 'pages/SingerDetailPage',
        params: {
          singerId: this.song.singer.id
        }
      }).catch((error: Error) => {
        console.error('跳转歌手详情页失败:', error.message);
      });
    }
  }
}
