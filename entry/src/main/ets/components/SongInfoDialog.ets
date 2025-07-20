import { Song } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';

@Component
export struct SongInfoDialog {
  @Prop song?: Song;
  
  build() {
    Column() {
      // 标题
      Text('歌曲信息')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ bottom: 20 })
      
      // 歌曲信息
      if (this.song) {
        Column({ space: 16 }) {
          // 歌曲名
          Row() {
            Text('歌曲名：')
              .fontSize(14)
              .fontColor(CommonConstants.TEXT_SECONDARY)
              .width(80)
            
            Text(this.song.name)
              .fontSize(14)
              .fontColor(CommonConstants.TEXT_PRIMARY)
              .layoutWeight(1)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          
          // 歌手
          Row() {
            Text('歌手：')
              .fontSize(14)
              .fontColor(CommonConstants.TEXT_SECONDARY)
              .width(80)
            
            Text(this.song.singer?.name || '未知歌手')
              .fontSize(14)
              .fontColor(CommonConstants.TEXT_PRIMARY)
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          // 专辑
          if (this.song.album) {
            Row() {
              Text('专辑：')
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_SECONDARY)
                .width(80)
              
              Text(this.song.album)
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_PRIMARY)
                .layoutWeight(1)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }
          
          // 时长
          if (this.song.duration) {
            Row() {
              Text('时长：')
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_SECONDARY)
                .width(80)
              
              Text(this.formatDuration(this.song.duration))
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_PRIMARY)
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          
          // 文件大小
          if (this.song.size) {
            Row() {
              Text('大小：')
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_SECONDARY)
                .width(80)
              
              Text(this.formatFileSize(this.song.size))
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_PRIMARY)
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          
          // 发布时间
          if (this.song.releaseDate) {
            Row() {
              Text('发布时间：')
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_SECONDARY)
                .width(80)
              
              Text(this.song.releaseDate)
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_PRIMARY)
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      
      Blank()
      
      // 关闭按钮
      Button('关闭')
        .width('100%')
        .height(44)
        .backgroundColor(CommonConstants.PRIMARY_COLOR)
        .fontSize(16)
        .fontColor(Color.White)
        .borderRadius(8)
        .onClick(() => {
          // TODO: 关闭对话框
        })
    }
    .width('100%')
    .height(400)
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
  
  /**
   * 格式化时长
   */
  private formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  
  /**
   * 格式化文件大小
   */
  private formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 B';
    
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
}
