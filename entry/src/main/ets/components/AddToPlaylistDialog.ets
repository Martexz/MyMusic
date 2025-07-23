import { CommonConstants } from '../common/constants/CommonConstants';
import { SongList } from '../models/DataModels';
import { MusicService } from '../services/MusicService';
import { UserManager } from '../managers/UserManager';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import promptAction from '@ohos.promptAction';
import { ImageUtil } from '../utils/ImageUtil';

@CustomDialog
export struct AddToPlaylistDialog {
  @State playlists: SongList[] = [];
  @State isLoading: boolean = true;
  @State selectedPlaylistId: number = -1;
  @State themeMode: ThemeMode = themeManager.themeMode;
  
  songId: number = 0;
  songName: string = '';
  private controller: CustomDialogController;
  private userManager: UserManager = UserManager.getInstance();

  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    this.loadUserPlaylists();
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

  private async loadUserPlaylists() {
    try {
      this.isLoading = true;
      const currentUser = this.userManager.getCurrentUser();
      if (currentUser) {
        this.playlists = await MusicService.getUserCreatedPlaylists(currentUser.id);
      }
    } catch (error) {
      console.error('加载歌单失败:', error);
      promptAction.showToast({ message: '加载歌单失败' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('添加到歌单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .layoutWeight(1)

        Image($r('app.media.ic_public_cancel'))
          .width(24)
          .height(24)
          .fillColor(CommonConstants.TEXT_SECONDARY)
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Divider()
        .color('#F0F0F0')

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(30)
            .height(30)
            .color(CommonConstants.PRIMARY_COLOR)

          Text('加载中...')
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_SECONDARY)
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

      } else if (this.playlists.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.ic_public_music'))
            .width(60)
            .height(60)
            .fillColor(CommonConstants.TEXT_SECONDARY)

          Text('暂无歌单')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .margin({ top: 16 })

          Text('请先创建歌单')
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_SECONDARY)
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

      } else {
        // 歌单列表
        Scroll() {
          Column() {
            ForEach(this.playlists, (playlist: SongList) => {
              Row() {
                // 歌单封面
                Image(playlist.pic ? ImageUtil.getSongListCoverUrl(playlist.pic) : $r('app.media.ic_public_music'))
                  .width(40)
                  .height(40)
                  .borderRadius(4)
                  .alt($r('app.media.ic_public_music'))
                  .onError(() => {
                    console.log('歌单图片加载失败:', playlist.pic);
                  })

                // 歌单信息
                Column() {
                  Text(playlist.title)
                    .fontSize(16)
                    .fontColor(CommonConstants.TEXT_PRIMARY)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .alignSelf(ItemAlign.Start)

                  if (playlist.introduction) {
                    Text(playlist.introduction)
                      .fontSize(14)
                      .fontColor(CommonConstants.TEXT_SECONDARY)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .alignSelf(ItemAlign.Start)
                      .margin({ top: 2 })
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })

                // 选择状态
                if (this.selectedPlaylistId === playlist.id) {
                  Image($r('app.media.ic_public_ok_filled'))
                    .width(20)
                    .height(20)
                    .fillColor(CommonConstants.PRIMARY_COLOR)
                } else {
                  Image($r('app.media.ic_add_icon'))
                    .width(20)
                    .height(20)
                    .fillColor(CommonConstants.TEXT_SECONDARY)
                }
              }
              .width('100%')
              .height(60)
              .padding({ left: 16, right: 16 })
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.selectedPlaylistId = playlist.id;
                this.addToSelectedPlaylist(playlist);
              })
            })
          }
        }
        .height(200)
      }

      Divider()
        .color('#F0F0F0')

      // 底部按钮
      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .backgroundColor(CommonConstants.SECONDARY_COLOR)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Blank()
          .width(16)

        Button('确定')
          .type(ButtonType.Normal)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
          .enabled(this.selectedPlaylistId !== -1)
          .onClick(() => {
            this.confirmAdd();
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  private async addToSelectedPlaylist(playlist: SongList) {
    try {
      const success = await MusicService.addSongToPlaylist(playlist.id, this.songId);
      if (success) {
        promptAction.showToast({ 
          message: `已添加到《${playlist.title}》` 
        });
        this.controller.close();
      } else {
        promptAction.showToast({ 
          message: '添加失败，歌曲可能已在歌单中' 
        });
      }
    } catch (error) {
      console.error('添加歌曲到歌单失败:', error);
      promptAction.showToast({ message: '添加失败' });
    }
  }

  private async confirmAdd() {
    if (this.selectedPlaylistId === -1) {
      promptAction.showToast({ message: '请选择歌单' });
      return;
    }

    const selectedPlaylist = this.playlists.find(p => p.id === this.selectedPlaylistId);
    if (selectedPlaylist) {
      await this.addToSelectedPlaylist(selectedPlaylist);
    }
  }
}
