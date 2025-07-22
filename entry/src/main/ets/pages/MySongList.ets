import router from '@ohos.router';
import {SongListParams} from '../models/DataModels'


@Entry
@Component
export struct MySongList {
  @State songListId: number = -1
  @State songListName: string = ''
  @State creatorName: string = ''


  aboutToAppear() {
    const params = router.getParams() as SongListParams
    if (params) {
      this.songListId = params.id ?? -1
      this.songListName = params.title ?? ''
      this.creatorName = params.username ?? ''
    }
  }



  build() {
    Column() {
      // 播放页整体
      Column() {
        // 歌单头部区域
        Column() {
          // 简介区域
          Row({ space: 8 }) {
            Row() {
              Image($r('app.media.bg_default'))
                .width('80%')
                .opacity(0.8)
                .fillColor('#ff5186')
            }
            .width(100)
            .aspectRatio(1)
            .borderRadius(8)
            .backgroundColor(Color.White)
            .justifyContent(FlexAlign.Center)

            Column({ space: 12 }) {
              Text(this.songListName)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .fontSize(20)

              Text(`歌单创建人：${this.creatorName}`)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .fontSize(14)


              Blank()
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }

          // 操作按钮区域
          Row() {
            Button() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_public_share_filled'))
                  .width(20)
                  .fillColor('#ec5c87')
                Text('分享')
                  .fontColor(Color.White)
                  .fontSize(12)
              }
              .width(100)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ff353333')
            }
            .clip(true)

            Button() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_public_message'))
                  .width(20)
                  .fillColor('#ec5c87')
                Text('评论')
                  .fontColor(Color.White)
                  .fontSize(12)
              }
              .width(100)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ff353333')
            }
            .clip(true)

            Button() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_public_favor'))
                  .width(20)
                  .fillColor('#ec5c87')
                Text('收藏')
                  .fontColor(Color.White)
                  .fontSize(12)
              }
              .width(100)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ff353333')
            }
            .clip(true)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .height('30%')
        .justifyContent(FlexAlign.SpaceAround)
        .radialGradient({
          center: ['80%', '-10%'],
          radius: '100%',
          colors: [['#ff865d13', 0.0], [Color.Transparent, 1.0]]
        })
        .padding(16)

        // 歌单播放列表区域
        Column() {
          // 播放全部按钮
          Row({ space: 8 }) {
            Row({ space: 8 }) {
              Image($r("app.media.ic_public_play_norm"))
                .width(16)
                .fillColor('#ff5186')
              Text('播放全部 (0)')
                .fontColor('#333333')
                .fontSize(14)
            }
          }
          .width('100%')
          .padding(16)
          .border({
            width: { bottom: 1 },
            color: '#12ec5c87'
          })

          // 歌曲列表（示例空结构）
          Column() {
            List({ space: 15 }) {
              // 歌曲列表项可以用 SongItem 占位，具体逻辑后续补充
              ListItem() {
                Row() {
                  Text('到底了——')
                    .fontColor(Color.Gray)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding(16)
              }
            }
            .layoutWeight(1)
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#cccccc')
        .borderRadius({ topLeft: 12, topRight: 12 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#eeeeee')
  }
}