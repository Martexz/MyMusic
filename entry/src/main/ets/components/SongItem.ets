import { Song } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';
import { PlayerManager } from '../managers/PlayerManager';
import { AddToPlaylistDialog } from './AddToPlaylistDialog';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ImageUtil } from '../utils/ImageUtil';

@Component
export struct SongItem {
  @Prop song: Song;
  @Prop showIndex?: boolean = false;
  @Prop index?: number = 0;
  @State showMoreMenu: boolean = false;

  private addToPlaylistDialogController: CustomDialogController = new CustomDialogController({
    builder: AddToPlaylistDialog(),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  });

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
        Image(this.song.pic ? ImageUtil.getSongCoverUrl(this.song.pic) : $r('app.media.ic_music_fill'))
          .width(50)
          .height(50)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .alt($r('app.media.ic_music_fill'))
          .onError(() => {
            console.log('歌曲图片加载失败:', this.song.pic);
          })
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
    .bindSheet(this.showMoreMenu, this.MoreOptionsBuilder(), {
      height: 200,
      backgroundColor: Color.Transparent,
      onDisappear: () => {
        this.showMoreMenu = false;
      }
    })
  }

  @Builder
  MoreOptionsBuilder() {
    Column() {
      Text('更多操作')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ bottom: 16 })

      // 添加到歌单
      Row() {
        Image($r('app.media.ic_add_icon'))
          .width(20)
          .height(20)
          .fillColor(CommonConstants.TEXT_PRIMARY)

        Text('添加到歌单')
          .fontSize(16)
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .margin({ left: 12 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.showMoreMenu = false;
        this.showAddToPlaylistDialog();
      })

      // 收藏歌曲
      Row() {
        Image($r('app.media.ic_public_favor'))
          .width(20)
          .height(20)
          .fillColor(CommonConstants.TEXT_PRIMARY)

        Text('收藏歌曲')
          .fontSize(16)
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .margin({ left: 12 })
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.showMoreMenu = false;
        this.collectSong();
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  private async playSong() {
    const playerManager = PlayerManager.getInstance();
    await playerManager.playSong(this.song);
  }

  private showMoreOptions() {
    this.showMoreMenu = true;
  }

  private showAddToPlaylistDialog() {
    // 创建新的对话框实例
    this.addToPlaylistDialogController = new CustomDialogController({
      builder: AddToPlaylistDialog({
        songId: this.song.id,
        songName: this.song.name
      }),
      alignment: DialogAlignment.Bottom,
      customStyle: true
    });
    
    this.addToPlaylistDialogController.open();
  }

  private collectSong() {
    // TODO: 实现收藏歌曲功能
    promptAction.showToast({ message: '收藏功能待实现' });
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
