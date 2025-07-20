import { CommonConstants } from '../common/constants/CommonConstants';
import { UserService } from '../services/UserService';
import { UserManager } from '../managers/UserManager';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State showRegister: boolean = false;
  @State email: string = '';
  
  private userManager: UserManager = UserManager.getInstance();
  
  build() {
    Column() {
      // 顶部标题区域
      Column() {
        Image($r('app.media.ic_music_fill'))
          .width(80)
          .height(80)
          .fillColor(Color.White)
          .margin({ bottom: 20 })
        
        Text('MyMusic')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 8 })
        
        Text(this.showRegister ? '创建新账户' : '欢迎回来')
          .fontSize(16)
          .fontColor('#CCFFFFFF')
          .margin({ bottom: 40 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ top: 60, bottom: 40 })
      
      // 表单区域
      Column() {
        // 用户名输入框
        Column() {
          Text('用户名')
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '请输入用户名' })
            .width('100%')
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .placeholderColor(CommonConstants.TEXT_SECONDARY)
            .onChange((value: string) => {
              this.username = value;
            })
        }
        .width('100%')
        .margin({ bottom: 20 })
        
        // 密码输入框
        Column() {
          Text('密码')
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '请输入密码' })
            .width('100%')
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .placeholderColor(CommonConstants.TEXT_SECONDARY)
            .type(InputType.Password)
            .onChange((value: string) => {
              this.password = value;
            })
        }
        .width('100%')
        .margin({ bottom: this.showRegister ? 20 : 30 })
        
        // 邮箱输入框（仅注册时显示）
        if (this.showRegister) {
          Column() {
            Text('邮箱（可选）')
              .fontSize(14)
              .fontColor(CommonConstants.TEXT_PRIMARY)
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '请输入邮箱地址' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .fontSize(16)
              .fontColor(CommonConstants.TEXT_PRIMARY)
              .placeholderColor(CommonConstants.TEXT_SECONDARY)
              .type(InputType.Email)
              .onChange((value: string) => {
                this.email = value;
              })
          }
          .width('100%')
          .margin({ bottom: 30 })
        }
        
        // 主要操作按钮
        Button(this.showRegister ? '注册' : '登录')
          .width('100%')
          .height(48)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(8)
          .enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0)
          .onClick(() => {
            if (this.showRegister) {
              this.handleRegister();
            } else {
              this.handleLogin();
            }
          })
        
        // 切换登录/注册
        Row() {
          Text(this.showRegister ? '已有账户？' : '还没有账户？')
            .fontSize(14)
            .fontColor(CommonConstants.TEXT_SECONDARY)
          
          Text(this.showRegister ? '立即登录' : '立即注册')
            .fontSize(14)
            .fontColor(CommonConstants.PRIMARY_COLOR)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.showRegister = !this.showRegister;
              this.clearForm();
            })
        }
        .margin({ top: 20 })
        .justifyContent(FlexAlign.Center)
        
        // 加载指示器
        if (this.isLoading) {
          LoadingProgress()
            .width(30)
            .height(30)
            .color(CommonConstants.PRIMARY_COLOR)
            .margin({ top: 20 })
        }
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 20, topRight: 20 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.PRIMARY_COLOR)
    .backgroundImage($r('app.media.bg4'))
    .backgroundImageSize(ImageSize.Cover)
  }
  
  /**
   * 处理登录
   */
  private async handleLogin(): Promise<void> {
    if (this.username.length === 0 || this.password.length === 0) {
      promptAction.showToast({ message: '请输入用户名和密码' });
      return;
    }
    
    this.isLoading = true;
    
    try {
      const user = await UserService.login(this.username, this.password);
      if (user) {
        this.userManager.setCurrentUser(user);
        promptAction.showToast({ message: '登录成功' });
        router.back();
      } else {
        promptAction.showToast({ message: '登录失败，请检查用户名和密码' });
      }
    } catch (error) {
      console.error('登录失败:', error);
      promptAction.showToast({ message: '登录失败，请稍后重试' });
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 处理注册
   */
  private async handleRegister(): Promise<void> {
    if (this.username.length === 0 || this.password.length === 0) {
      promptAction.showToast({ message: '请输入用户名和密码' });
      return;
    }
    
    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码长度至少6位' });
      return;
    }
    
    this.isLoading = true;
    
    try {
      const user = await UserService.register(this.username, this.password, this.email);
      if (user) {
        this.userManager.setCurrentUser(user);
        promptAction.showToast({ message: '注册成功' });
        router.back();
      } else {
        promptAction.showToast({ message: '注册失败，用户名可能已存在' });
      }
    } catch (error) {
      console.error('注册失败:', error);
      promptAction.showToast({ message: '注册失败，请稍后重试' });
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 清空表单
   */
  private clearForm(): void {
    this.username = '';
    this.password = '';
    this.email = '';
  }
}
