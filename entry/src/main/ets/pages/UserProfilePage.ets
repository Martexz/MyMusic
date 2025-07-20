import { CommonConstants } from '../common/constants/CommonConstants';
import { Consumer } from '../models/DataModels';
import { UserResponse } from '../models/ApiInterfaces';
import { UserManager } from '../managers/UserManager';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct UserProfilePage {
  @State userInfo: Consumer | null = null;
  @State isEditing: boolean = false;
  @State tempUsername: string = '';
  @State tempIntroduction: string = '';
  @State tempEmail: string = '';
  
  private userManager: UserManager = UserManager.getInstance();

  aboutToAppear() {
    this.loadUserInfo();
  }

  private loadUserInfo() {
    const currentUser = this.userManager.getCurrentUser();
    if (currentUser) {
      // 将UserResponse转换为Consumer类型
      const consumerUser: Consumer = {
        id: currentUser.id,
        username: currentUser.username,
        email: currentUser.email,
        introduction: currentUser.introduction,
        avator: currentUser.avator
      };
      this.userInfo = consumerUser;
      this.tempUsername = currentUser.username;
      this.tempIntroduction = currentUser.introduction || '';
      this.tempEmail = currentUser.email || '';
    } else {
      // 用户未登录，返回上一页
      router.back();
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopNavigationBar()
      
      // 用户头像区域
      this.UserAvatarSection()
      
      // 用户信息区域
      this.UserInfoSection()
      
      // 统计信息区域
      this.UserStatsSection()
      
      // 操作按钮区域
      this.ActionButtonsSection()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
  }

  @Builder
  TopNavigationBar() {
    Row() {
      Image($r('app.media.ic_public_back'))
        .width(24)
        .height(24)
        .fillColor(CommonConstants.TEXT_PRIMARY)
        .onClick(() => {
          router.back();
        })

      Text('个人主页')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      if (this.isEditing) {
        Text('保存')
          .fontSize(16)
          .fontColor(CommonConstants.PRIMARY_COLOR)
          .onClick(() => {
            this.saveUserInfo();
          })
      } else {
        Text('编辑')
          .fontSize(16)
          .fontColor(CommonConstants.PRIMARY_COLOR)
          .onClick(() => {
            this.isEditing = true;
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
  }

  @Builder
  UserAvatarSection() {
    Column() {
      Stack() {
        Image(this.userInfo?.avator || $r('app.media.ic_user_portrait'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 3, color: Color.White })

        if (this.isEditing) {
          Column() {
            Image($r('app.media.ic_public_arrow_right'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
          }
          .width(32)
          .height(32)
          .borderRadius(16)
          .backgroundColor('#80000000')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .position({ x: '70%', y: '70%' })
          .onClick(() => {
            this.selectAvatar();
          })
        }
      }
      .margin({ bottom: 16 })
    }
    .width('100%')
    .padding({ top: 32, bottom: 24 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(CommonConstants.PRIMARY_COLOR)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [[CommonConstants.PRIMARY_COLOR, 0.0], ['#8A2BE2', 1.0]]
    })
  }

  @Builder
  UserInfoSection() {
    Column() {
      // 用户名
      this.InfoItem('用户名', this.userInfo?.username || '', this.tempUsername, (value: string) => {
        this.tempUsername = value;
      })

      Divider()
        .color('#F0F0F0')
        .margin({ left: 16, right: 16 })

      // 邮箱
      this.InfoItem('邮箱', this.userInfo?.email || '未设置', this.tempEmail, (value: string) => {
        this.tempEmail = value;
      }, '请输入邮箱地址')

      Divider()
        .color('#F0F0F0')
        .margin({ left: 16, right: 16 })

      // 个人简介
      this.InfoItem('个人简介', this.userInfo?.introduction || '这个人很懒，什么都没留下', this.tempIntroduction, (value: string) => {
        this.tempIntroduction = value;
      }, '请输入个人简介')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
  }

  @Builder
  InfoItem(label: string, value: string, editValue: string, onChange: (value: string) => void, placeholder?: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .width(80)

      if (this.isEditing) {
        TextInput({ text: editValue, placeholder: placeholder || `请输入${label}` })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding(0)
          .fontSize(16)
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .onChange(onChange)
      } else {
        Text(value)
          .fontSize(16)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  UserStatsSection() {
    Row() {
      this.StatItem('收藏歌曲', '12')
      
      Divider()
        .vertical(true)
        .height(40)
        .color('#F0F0F0')
      
      this.StatItem('创建歌单', '3')
      
      Divider()
        .vertical(true)
        .height(40)
        .color('#F0F0F0')
      
      this.StatItem('播放时长', '24h')
    }
    .width('100%')
    .height(80)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  StatItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(14)
        .fontColor(CommonConstants.TEXT_SECONDARY)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ActionButtonsSection() {
    Column() {
      // 我的收藏
      this.ActionButton('我的收藏', $r('app.media.ic_public_favor_filled'), () => {
        // 跳转到收藏页面
        this.navigateToMyFavorites();
      })

      Divider()
        .color('#F0F0F0')
        .margin({ left: 16, right: 16 })

      // 创建的歌单
      this.ActionButton('创建的歌单', $r('app.media.ic_public_folder'), () => {
        // 跳转到歌单页面
        promptAction.showToast({ message: '跳转到创建的歌单' });
      })

      Divider()
        .color('#F0F0F0')
        .margin({ left: 16, right: 16 })

      // 最近播放
      this.ActionButton('最近播放', $r('app.media.ic_public_play_last'), () => {
        // 跳转到历史页面
        promptAction.showToast({ message: '跳转到最近播放' });
      })

      Divider()
        .color('#F0F0F0')
        .margin({ left: 16, right: 16 })

      // 设置
      this.ActionButton('设置', $r('app.media.ic_public_settings'), () => {
        // 跳转到设置页面
        promptAction.showToast({ message: '跳转到设置' });
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16, bottom: 16 })
  }

  @Builder
  ActionButton(title: string, icon: Resource, onClick: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(CommonConstants.TEXT_SECONDARY)

      Text(title)
        .fontSize(16)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ left: 12 })

      Blank()

      Text('>')
        .fontSize(16)
        .fontColor(CommonConstants.TEXT_SECONDARY)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .onClick(onClick)
  }

  private selectAvatar() {
    promptAction.showToast({ message: '选择头像功能待实现' });
  }

  private saveUserInfo() {
    if (this.tempUsername.trim().length === 0) {
      promptAction.showToast({ message: '用户名不能为空' });
      return;
    }

    // 这里应该调用API更新用户信息
    // 暂时只在本地更新
    if (this.userInfo) {
      this.userInfo.username = this.tempUsername;
      this.userInfo.email = this.tempEmail;
      this.userInfo.introduction = this.tempIntroduction;
    }

    this.isEditing = false;
    promptAction.showToast({ message: '保存成功' });
  }

  private navigateToMyFavorites() {
    router.pushUrl({
      url: 'pages/MyFavoritesPage'
    }).catch((error: Error) => {
      console.error('跳转到我的收藏失败:', error);
    });
  }
}
