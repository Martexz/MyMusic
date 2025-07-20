import { CommonConstants } from '../common/constants/CommonConstants';
import { Consumer } from '../models/DataModels';
import { UserResponse } from '../models/ApiInterfaces';
import { UserManager } from '../managers/UserManager';
import router from '@ohos.router';

@Component
export struct ProfilePage {
  @State userInfo: Consumer | null = null;
  @State isLogin: boolean = false;
  
  private userManager: UserManager = UserManager.getInstance();
  private userStateListener = (user: UserResponse | null) => {
    this.checkLoginStatus();
  };

  aboutToAppear() {
    this.checkLoginStatus();
    this.userManager.addListener(this.userStateListener);
  }

  aboutToDisappear() {
    this.userManager.removeListener(this.userStateListener);
  }

  private checkLoginStatus() {
    const currentUser = this.userManager.getCurrentUser();
    if (currentUser) {
      this.isLogin = true;
      // 将UserResponse转换为Consumer类型
      const consumerUser: Consumer = {
        id: currentUser.id,
        username: currentUser.username,
        email: currentUser.email,
        introduction: currentUser.introduction,
        avator: currentUser.avator
      };
      this.userInfo = consumerUser;
    } else {
      this.isLogin = false;
      this.userInfo = null;
    }
  }

  build() {
    Column() {
      if (this.isLogin) {
        this.UserInfoSection()
      } else {
        this.LoginSection()
      }

      // 功能菜单
      this.MenuSection()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
  }

  @Builder
  LoginSection() {
    Column() {
      Image($r('app.media.ic_user_portrait'))
        .width(80)
        .height(80)
        .borderRadius(40)
        .margin({ bottom: CommonConstants.MARGIN_MEDIUM })

      Text('点击登录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ bottom: CommonConstants.MARGIN_SMALL })

      Text('登录后可以收藏歌曲、创建歌单')
        .fontSize(14)
        .fontColor(CommonConstants.TEXT_SECONDARY)
        .margin({ bottom: CommonConstants.MARGIN_LARGE })

      Button('立即登录')
        .type(ButtonType.Normal)
        .backgroundColor(CommonConstants.PRIMARY_COLOR)
        .fontColor(Color.White)
        .borderRadius(CommonConstants.BORDER_RADIUS)
        .width(120)
        .onClick(() => {
          this.navigateToLogin();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(CommonConstants.MARGIN_LARGE)
  }

  @Builder
  UserInfoSection() {
    Row() {
      // 头像
      Row() {
        Image(this.userInfo?.avator || $r('app.media.ic_user_portrait'))
          .width(60)
          .height(60)
          .borderRadius(30)
        
        Column() {
          Text(this.userInfo?.username || '用户名')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .alignSelf(ItemAlign.Start)

          Text(this.userInfo?.introduction || '这个人很懒，什么都没留下')
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_SECONDARY)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: CommonConstants.MARGIN_MEDIUM })

        Text('>')
          .fontSize(18)
          .fontColor(CommonConstants.TEXT_SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding(CommonConstants.MARGIN_MEDIUM)
      .onClick(() => {
        // 跳转到个人主页
        this.navigateToUserProfile();
      })
    }
    .width('100%')
  }

  @Builder
  MenuSection() {
    Column() {
      // 我的收藏
      this.MenuItem('我的收藏', $r('app.media.ic_public_favor_filled'), () => {
        // 跳转到收藏页面
        this.navigateToMyFavorites();
      })
      
      Divider()
        .color('#F0F0F0')
        .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })

      // 创建的歌单
      this.MenuItem('创建的歌单', $r('app.media.ic_public_folder'), () => {
        // 跳转到歌单页面
      })
      
      Divider()
        .color('#F0F0F0')
        .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })

      // 最近播放
      this.MenuItem('最近播放', $r('app.media.ic_public_play_last'), () => {
        // 跳转到历史页面
      })
      
      Divider()
        .color('#F0F0F0')
        .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })

      if (this.isLogin) {
        // 退出登录
        this.MenuItem('退出登录', $r('app.media.ic_public_back'), () => {
          this.handleLogout();
        })
        
        Divider()
          .color('#F0F0F0')
          .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
      }

      // 设置
      this.MenuItem('设置', $r('app.media.ic_public_settings'), () => {
        // 跳转到设置页面
      })
    }
    .width('100%')
    .margin({ top: CommonConstants.MARGIN_LARGE })
  }

  @Builder
  MenuItem(title: string, icon: Resource, onClick: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(CommonConstants.TEXT_SECONDARY)

      Text(title)
        .fontSize(16)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ left: CommonConstants.MARGIN_MEDIUM })

      Blank()

      Text('>')
        .fontSize(16)
        .fontColor(CommonConstants.TEXT_SECONDARY)
    }
    .width('100%')
    .height(56)
    .padding({ 
      left: CommonConstants.MARGIN_MEDIUM, 
      right: CommonConstants.MARGIN_MEDIUM 
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .onClick(onClick)
  }

  private navigateToLogin() {
    router.pushUrl({
      url: 'pages/LoginPage'
    }).catch((error: Error) => {
      console.error('跳转到登录页面失败:', error);
    });
  }

  private navigateToUserProfile() {
    router.pushUrl({
      url: 'pages/UserProfilePage'
    }).catch((error: Error) => {
      console.error('跳转到个人主页失败:', error);
    });
  }

  private navigateToMyFavorites() {
    router.pushUrl({
      url: 'pages/MyFavoritesPage'
    }).catch((error: Error) => {
      console.error('跳转到我的收藏失败:', error);
    });
  }

  private handleLogout() {
    this.userManager.logout();
  }
}
