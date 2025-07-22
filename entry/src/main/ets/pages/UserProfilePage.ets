import { CommonConstants } from '../common/constants/CommonConstants';
import { Consumer } from '../models/DataModels';
import { UserResponse, UpdateUserRequest } from '../models/ApiInterfaces';
import { UserManager } from '../managers/UserManager';
import { UserService } from '../services/UserService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ImageUtil } from '../utils/ImageUtil';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { BusinessError, request } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';

// 定义头像上传响应接口
interface AvatarUploadResponse {
  code: number;
  data?: string;
  message?: string;
}

@Entry
@Component
struct UserProfilePage {
  @State userInfo: Consumer | null = null;
  @State isEditing: boolean = false;
  @State isSaving: boolean = false;
  @State tempUsername: string = '';
  @State tempIntroduction: string = '';
  @State tempEmail: string = '';
  @State localAvatarPath: string = ''; // 本地选择的头像路径
  @State isUploadingAvatar: boolean = false; // 头像上传状态
  private userManager: UserManager = UserManager.getInstance();
  private context = getContext() as common.UIAbilityContext;

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
        // 显示头像
        if (this.localAvatarPath) {
          // 显示本地选择的图片（上传前预览）
          Image(this.localAvatarPath)
            .width(100)
            .height(100)
            .borderRadius(50)
            .border({ width: 3, color: Color.White })
            .objectFit(ImageFit.Cover)
        } else if (this.userInfo?.avator) {
          // 显示服务器上的头像
          Image(ImageUtil.getUserAvatarUrl(this.userInfo.avator))
            .width(100)
            .height(100)
            .borderRadius(50)
            .border({ width: 3, color: Color.White })
            .objectFit(ImageFit.Cover)
            .alt($r('app.media.ic_user_portrait'))
            .onError(() => {
              console.log('头像加载失败:', this.userInfo?.avator);
            })
        } else {
          // 默认头像
          Image($r('app.media.ic_user_portrait'))
            .width(100)
            .height(100)
            .borderRadius(50)
            .border({ width: 3, color: Color.White })
        }

        // 编辑状态下的相机图标或上传状态
        if (this.isEditing) {
          if (this.isUploadingAvatar) {
            Column() {
              LoadingProgress()
                .width(20)
                .height(20)
                .color(Color.White)
              Text('上传中')
                .fontSize(10)
                .fontColor(Color.White)
                .margin({ top: 2 })
            }
            .width(32)
            .height(32)
            .borderRadius(16)
            .backgroundColor('#80000000')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .position({ x: '70%', y: '70%' })
          } else {
            Column() {
              Image($r('app.media.ic_public_add_filled'))
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
      // 编辑状态下的更改头像按钮
      if (this.isEditing) {
        Row() {
          Text('更改头像')
            .fontSize(16)
            .fontColor(CommonConstants.TEXT_PRIMARY)
            .width(80)

          Row() {
            if (this.isUploadingAvatar) {
              LoadingProgress()
                .width(16)
                .height(16)
                .color(CommonConstants.PRIMARY_COLOR)
                .margin({ right: 8 })
              Text('上传中...')
                .fontSize(14)
                .fontColor(CommonConstants.TEXT_SECONDARY)
            } else {
              Image($r('app.media.ic_public_add_filled'))
                .width(16)
                .height(16)
                .fillColor(CommonConstants.PRIMARY_COLOR)
                .margin({ right: 8 })
              Text('选择图片')
                .fontSize(14)
                .fontColor(CommonConstants.PRIMARY_COLOR)
            }
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .onClick(() => {
            if (!this.isUploadingAvatar) {
              this.selectAvatar();
            }
          })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Divider()
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })
      }

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

  /**
   * 选择头像图片
   */
  private selectAvatar() {
    if (this.isUploadingAvatar) {
      return;
    }

    try {
      // 配置图片选择器
      let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      // 打开图片选择器
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
          this.localAvatarPath = photoSelectResult.photoUris[0];
          this.convertAndUploadAvatar(photoSelectResult.photoUris[0]);
        }
      }).catch((err: BusinessError) => {
        console.error(`选择图片失败: ${err.code}, ${err.message}`);
        promptAction.showToast({ message: '选择图片失败' });
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`图片选择器错误: ${err.code}, ${err.message}`);
      promptAction.showToast({ message: '打开图片选择器失败' });
    }
  }

  /**
   * 转换文件URI并上传头像
   */
  private convertAndUploadAvatar = (uri: string) => {
    fs.open(uri, fs.OpenMode.READ_ONLY).then((data) => {
      // 生成新的文件名
      let fileName = Date.now();
      let extname = uri.split(".").pop() || 'jpg';
      let newDir = this.context.cacheDir + "/" + fileName + "." + extname;

      // 复制文件到缓存目录
      fs.copyFile(data.fd, newDir).then(() => {
        this.uploadAvatar(newDir, extname);
      }).catch((err: Error) => {
        console.error("文件复制失败:", err.message);
        promptAction.showToast({ message: '文件处理失败' });
        this.localAvatarPath = '';
      });
    }).catch((err: Error) => {
      console.error("文件打开失败:", err.message);
      promptAction.showToast({ message: '文件打开失败' });
      this.localAvatarPath = '';
    });
  }

  /**
   * 上传头像到服务器
   */
  private uploadAvatar = (filePath: string, extname: string) => {
    this.isUploadingAvatar = true;
    
    let fileName = filePath.split("cache")[1];
    let uri = "internal://cache" + fileName;

    // 根据文件扩展名确定MIME类型
    let mimeType = 'image/jpeg'; // 默认值
    switch (extname.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;
      case 'png':
        mimeType = 'image/png';
        break;
      case 'gif':
        mimeType = 'image/gif';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
      case 'bmp':
        mimeType = 'image/bmp';
        break;
      default:
        mimeType = 'image/jpeg';
    }

    let uploadConfig: request.UploadConfig = {
      url: 'http://10.130.3.83:8000/api/upload/avatar', // 头像上传接口
      header: { 'Accept': '*/*' },
      method: "POST",
      files: [{
        name: 'avatar',
        filename: fileName,
        uri: uri,
        type: mimeType // 使用正确的MIME类型
      }],
      data: [
        { name: "userId", value: this.userInfo?.id?.toString() || "" }
      ]
    };

    try {
      console.log('开始上传头像...');
      console.log('上传配置:', JSON.stringify(uploadConfig));
      
      request.uploadFile(this.context, uploadConfig).then((uploadTask: request.UploadTask) => {
        console.log('上传任务创建成功');
        
        // 监听上传进度
        uploadTask.on("progress", (uploadedSize: number, totalSize: number) => {
          let progress = Math.round((uploadedSize / totalSize) * 100);
          console.log(`头像上传进度: ${progress}%`);
        });

        // 监听服务器响应
        uploadTask.on('headerReceive', (headers: object) => {
          try {
            console.log('======================================');
            console.log('收到服务器响应:', JSON.stringify(headers));
            
            // 参考UserEdit的处理方式
            const responseBody: string = (headers as Record<string, string>)["body"];
            console.log('响应体:', responseBody);
            
            const response: AvatarUploadResponse = JSON.parse(responseBody);
            console.log('解析后的响应:', response);
            
            if (response.code === 0) {
              // 上传成功，更新用户头像
              const avatarPath: string = response.data || '';
              console.log('头像路径:', avatarPath);
              this.updateUserAvatar(avatarPath);
              promptAction.showToast({ message: '头像上传成功' });
            } else {
              console.log('上传失败:', response.message);
              promptAction.showToast({ message: response.message || '头像上传失败' });
              this.localAvatarPath = '';
            }
          } catch (parseError) {
            console.error('解析服务器响应失败:', parseError);
            console.error('原始headers:', headers);
            promptAction.showToast({ message: '头像上传失败' });
            this.localAvatarPath = '';
          }
          this.isUploadingAvatar = false;
        });

        uploadTask.on('fail', (err) => {
          console.error('头像上传失败:', err);
          promptAction.showToast({ message: '头像上传失败' });
          this.isUploadingAvatar = false;
          this.localAvatarPath = '';
        });

      }).catch((err: BusinessError) => {
        console.error(`上传文件失败: ${err.code}, ${err.message}`);
        promptAction.showToast({ message: '头像上传失败' });
        this.isUploadingAvatar = false;
        this.localAvatarPath = '';
      });
    } catch (err) {
      console.error(`上传请求失败: ${JSON.stringify(err)}`);
      promptAction.showToast({ message: '头像上传失败' });
      this.isUploadingAvatar = false;
      this.localAvatarPath = '';
    }
  }

  /**
   * 更新用户头像信息
   */
  private updateUserAvatar = (avatarPath: string) => {
    console.log('UserProfilePage 开始更新用户头像:', avatarPath);
    if (this.userInfo) {
      this.userInfo.avator = avatarPath;
      // 更新UserManager中的用户信息
      const currentUser = this.userManager.getCurrentUser();
      if (currentUser) {
        console.log('UserProfilePage 更新前的用户信息:', currentUser);
        currentUser.avator = avatarPath;
        this.userManager.setCurrentUser(currentUser);
        console.log('UserProfilePage 已调用 setCurrentUser, 新头像路径:', avatarPath);
      }
      // 清除本地预览路径
      this.localAvatarPath = '';
    }
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