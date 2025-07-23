import { CommonConstants } from '../common/constants/CommonConstants';
import { CreateSongListDto, SongList } from '../models/DataModels';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import promptAction from '@ohos.promptAction';
import { HttpUtil } from '../utils/HttpUtil';
import { UserManager } from '../managers/UserManager';
import { UserResponse } from '../models/ApiInterfaces';
import { router } from '@kit.ArkUI';




@Component
export struct PlaylistPage {
  @State myPlaylists: SongList[] = [];
  @StorageLink('createdPlaylists') createdPlaylists: SongList[] = [];
  @State collectedPlaylists: SongList[] = [];
  @State isCreatingPlaylist: boolean = false;
  @State newPlaylistName: string = '';
  @State newPlaylistDesc: string = '';
  @State username: string | null = null;
  @State userId: number = 0;
  @State songLists: SongList[] = [];
  @State isLoading: boolean = false;
  @State themeMode: ThemeMode = themeManager.themeMode;


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

  refreshCreatedPlaylists() {
    const userManager = UserManager.getInstance();
    const currentUser = userManager.getCurrentUser();

    if (!currentUser) {
      promptAction.showToast({
        message: '尚未登录，请先登录',
        duration: 2000
      });
      return;
    }

    this.username = currentUser.username;
    this.userId = currentUser.id;

    HttpUtil.getCreatedSongLists(this.userId).then((list: SongList[]) => {
      this.createdPlaylists = list;
    }).catch((err: Error) => {
      console.error('刷新创建歌单失败:', err.message);
      promptAction.showToast({
        message: '加载歌单失败，请稍后重试',
        duration: 2000
      });
    });
  }


  aboutToAppear() {
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
    const userManager = UserManager.getInstance();

    // 先尝试获取当前用户（可能是null）
    const currentUser = userManager.getCurrentUser();
    if (currentUser) {
      this.setUserAndLoadLists(currentUser);
    }

    // 添加监听器，等待用户数据变化
    const listener = (user: UserResponse | null) => {
      if (user) {
        this.setUserAndLoadLists(user); // 登录或切换账号
      } else {
        this.resetPageData(); // 退出登录
      }
    };


    userManager.addListener(listener);
  }

  aboutToDisappear() {
    themeManager.off(this.onThemeChanged);
  }

  private resetPageData() {
    this.username = null;
    this.userId = 0;
    this.createdPlaylists = [];
    this.collectedPlaylists = [];
    this.myPlaylists = [];
    this.songLists = [];
    this.isLoading = false;
  }


  setUserAndLoadLists(user: UserResponse) {
    this.username = user.username;
    this.userId = user.id;
    this.refreshCreatedPlaylists(); // 直接调用刷新函数
  }



  private createPlaylist() {
    this.isCreatingPlaylist = true;
    this.newPlaylistName = '';
    this.newPlaylistDesc = '';
  }

  private cancelCreatePlaylist() {
    this.isCreatingPlaylist = false;
    this.newPlaylistName = '';
    this.newPlaylistDesc = '';
  }

  private async confirmCreatePlaylist() {
    if (this.newPlaylistName.trim().length === 0) {
      promptAction.showToast({
        message: '请输入歌单名称',
        duration: 2000
      });
      return;
    }




    const payload: CreateSongListDto = {
      title: this.newPlaylistName.trim(),
      introduction: this.newPlaylistDesc.trim(),
      user_id: this.userId
    };

    try {
      const res = await HttpUtil.createSongList(payload);
      if (res.code === 0 && res.data) {
        this.createdPlaylists = [res.data, ...this.createdPlaylists];
        this.cancelCreatePlaylist();

        promptAction.showToast({
          message: `歌单"${res.data.title}"创建成功`,
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: `创建失败：${res.msg}`,
          duration: 2000
        });
      }
    } catch (err) {
      promptAction.showToast({
        message: '网络错误，创建失败',
        duration: 2000
      });
      console.error('创建歌单失败:', err);
    }
  }



  build() {
    Column() {
      // 头部
      Row() {
        Text('我的歌单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextPrimary())
        
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
      .backgroundColor(this.getBackgroundColor())

      // 创建歌单弹窗
      if (this.isCreatingPlaylist) {
        this.CreatePlaylistDialog()
      }

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
    .backgroundColor(this.getBackgroundColor())
  }

  @Builder
  SectionHeader(title: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTextPrimary())
      
      Blank()
      
      Text('查看全部')
        .fontSize(14)
        .fontColor(this.getTextSecondary())
        .onClick(() => {
          // 查看全部逻辑
        })
    }
    .width('100%')
    .padding({
      left: CommonConstants.MARGIN_MEDIUM,
      right: CommonConstants.MARGIN_MEDIUM,
      top: CommonConstants.MARGIN_SMALL,
      bottom: CommonConstants.MARGIN_SMALL
    })
    .margin({ top: CommonConstants.MARGIN_MEDIUM })
  }

  @Builder
  RecentPlaySection() {
    Column() {
      if (this.myPlaylists.length === 0) {
        Text('暂无最近播放记录')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        // TODO: 实现最近播放列表
        Text('最近播放列表')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .margin({
      left: CommonConstants.MARGIN_MEDIUM,
      right: CommonConstants.MARGIN_MEDIUM
    })
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  @Builder
  CreatedPlaylistSection() {
    Column() {
      Row() {
        Text('创建的歌单')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextPrimary())

        Blank()

        Button('刷新')
          .width(60)
          .height(28)
          .fontSize(14)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .borderRadius(CommonConstants.BORDER_RADIUS)
          .fontColor(Color.White)
          .onClick(() => {
            this.refreshCreatedPlaylists();
          })
      }
      .width('100%')
      .padding({
        left: CommonConstants.MARGIN_MEDIUM,
        right: CommonConstants.MARGIN_MEDIUM,
        top: CommonConstants.MARGIN_SMALL,
        bottom: CommonConstants.MARGIN_SMALL
      })

      if (this.createdPlaylists.length === 0) {
        Text('还没有创建歌单，快去创建一个吧！')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        ForEach(this.createdPlaylists, (playlist: SongList) => {
          Row() {
            Column() {
              Text(playlist.title)
                .fontSize(16)
                .fontColor(this.getTextPrimary())
                .margin({ bottom: 4 })

              if (playlist.introduction && playlist.introduction.length > 0) {
                Text(playlist.introduction)
                  .fontSize(14)
                  .fontColor(this.getTextSecondary())
              }
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .onClick(() => {
            // 跳转歌单详情
            router.pushUrl({
              url: CommonConstants.MY_SONG_LIST_PAGE,
              params: {
                id: playlist.id,
                title: playlist.title,
                username: this.username ?? ''
              }
            })
          })
        })
      }
    }
    .width('100%')
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .margin({
      left: CommonConstants.MARGIN_MEDIUM,
      right: CommonConstants.MARGIN_MEDIUM
    })
    .padding(CommonConstants.MARGIN_MEDIUM)
  }


  @Builder
  CollectedPlaylistSection() {
    Column() {
      if (this.collectedPlaylists.length === 0) {
        Text('还没有收藏歌单')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        // TODO: 实现收藏的歌单列表
        Text('收藏的歌单列表')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(CommonConstants.BORDER_RADIUS)
    .margin({
      left: CommonConstants.MARGIN_MEDIUM,
      right: CommonConstants.MARGIN_MEDIUM
    })
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  @Builder
  CreatePlaylistDialog() {
    Column() {
      // 半透明背景
      Stack() {
        Column() {
          // 弹窗内容
          Column() {
            Text('新建歌单')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getTextPrimary())
              .margin({ bottom: CommonConstants.MARGIN_LARGE })

            TextInput({ placeholder: '输入歌单名称', text: this.newPlaylistName })
              .width('100%')
              .height(40)
              .fontSize(14)
              .type(InputType.Normal)
              .borderRadius(CommonConstants.BORDER_RADIUS)
              .backgroundColor(CommonConstants.INPUT_BACKGROUND)
              .padding(8)
              .onChange((value: string) => {
                this.newPlaylistName = value;
              })

            TextInput({ placeholder: '输入歌单描述(可选)', text: this.newPlaylistDesc })
              .width('100%')
              .height(40)
              .fontSize(14)
              .type(InputType.Normal)
              .margin({ top: CommonConstants.MARGIN_SMALL })
              .borderRadius(CommonConstants.BORDER_RADIUS)
              .backgroundColor(CommonConstants.INPUT_BACKGROUND)
              .padding(8)
              .onChange((value: string) => {
                this.newPlaylistDesc = value;
              })

            // 按钮区域
            Row() {
              Button('取消', { type: ButtonType.Normal })
                .width('40%')
                .height(40)
                .fontSize(14)
                .backgroundColor(CommonConstants.SECONDARY_COLOR)
                .onClick(() => {
                  this.cancelCreatePlaylist();
                })

              Button('创建', { type: ButtonType.Normal })
                .width('40%')
                .height(40)
                .fontSize(14)
                .margin({ left: CommonConstants.MARGIN_LARGE })
                .backgroundColor(CommonConstants.PRIMARY_COLOR)
                .enabled(this.newPlaylistName.trim().length > 0)
                .onClick(() => {
                  this.confirmCreatePlaylist();
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: CommonConstants.MARGIN_LARGE })
          }
          .width('80%')
          .padding(CommonConstants.MARGIN_LARGE)
          .backgroundColor(this.getBackgroundColor())
          .borderRadius(CommonConstants.BORDER_RADIUS)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0,0,0,0.5)')
      .onClick(() => {
        this.cancelCreatePlaylist();
      })
}
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1)
  }
}