import { CommonConstants } from '../common/constants/CommonConstants';
import { Consumer } from '../models/DataModels';

@Component
export struct ProfilePage {
  @State userInfo: Consumer | null = null;
  @State isLogin: boolean = false;

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
          this.showLoginDialog();
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
        Image(this.userInfo?.avatar || $r('app.media.ic_user_portrait'))
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
        // 跳转到个人信息编辑页面
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
          this.logout();
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

  private showLoginDialog() {
    // 显示登录对话框
    this.isLogin = true;
    this.userInfo = {
      id: 1,
      username: '测试用户',
      avatar: undefined,
      introduction: '音乐爱好者'
    };
  }

  private logout() {
    this.isLogin = false;
    this.userInfo = null;
  }
}
