import { CommonConstants } from '../common/constants/CommonConstants';
import { Consumer } from '../models/DataModels';
import { UserResponse, UpdateUserRequest } from '../models/ApiInterfaces';
import { UserManager } from '../managers/UserManager';
import { UserService } from '../services/UserService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct UserProfilePage {
  @State userInfo: Consumer | null = null;
  @State isEditing: boolean = false;
  @State isSaving: boolean = false;
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
        if (this.isSaving) {
          LoadingProgress()
            .width(16)
            .height(16)
            .color(CommonConstants.PRIMARY_COLOR)
        } else {
          Text('保存')
            .fontSize(16)
            .fontColor(CommonConstants.PRIMARY_COLOR)
            .onClick(() => {
              this.saveUserInfo();
            })
        }
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
      this.InfoItem('个人简介', this.userInfo?.introduction || '这个人很懒，什么都没留下', this.tempIntroduction,
        (value: string) => {
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

  private selectAvatar() {
    promptAction.showToast({ message: '选择头像功能待实现' });
  }

  private async saveUserInfo() {
    if (this.tempUsername.trim().length === 0) {
      promptAction.showToast({ message: '用户名不能为空' });
      return;
    }

    if (!this.userInfo) {
      promptAction.showToast({ message: '用户信息错误' });
      return;
    }

    this.isSaving = true;

    try {
      // 构建更新请求数据
      const updateRequest: UpdateUserRequest = {
        id: this.userInfo.id,
        username: this.tempUsername.trim(),
        email: this.tempEmail.trim() || undefined,
        introduction: this.tempIntroduction.trim() || undefined
      };

      // 调用API更新用户信息
      const updatedUser = await UserService.updateUserInfo(updateRequest);
      
      if (updatedUser) {
        // 更新本地用户信息
        this.userInfo.username = updatedUser.username;
        this.userInfo.email = updatedUser.email;
        this.userInfo.introduction = updatedUser.introduction;

        // 更新UserManager中的用户信息
        this.userManager.setCurrentUser(updatedUser);

        this.isEditing = false;
        promptAction.showToast({ message: '保存成功' });
      } else {
          promptAction.showToast({ message: '保存失败，请稍后重试' });
        }
    } catch (error) {
      console.error('保存用户信息失败:', error);
      promptAction.showToast({ message: '保存失败，请检查网络连接' });
    } finally {
      this.isSaving = false;
    }
  }
}