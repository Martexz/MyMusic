import { VoiceRecognitionService } from '../services/VoiceRecognitionService';
import { CommonConstants } from '../common/constants/CommonConstants';
import promptAction from '@ohos.promptAction';

/**
 * 语音输入状态
 */
export enum VoiceInputStatus {
  IDLE = 'idle',           // 待机状态
  LISTENING = 'listening', // 监听中
  PROCESSING = 'processing', // 处理中
  ERROR = 'error'          // 错误状态
}

/**
 * 语音输入组件
 */
@Component
export struct VoiceInputButton {
  @State voiceStatus: VoiceInputStatus = VoiceInputStatus.IDLE;
  @State statusText: string = '';
  @State isListening: boolean = false;
  
  // 回调函数
  onVoiceResult?: (text: string) => void;
  onError?: (error: string) => void;
  
  private voiceService: VoiceRecognitionService = VoiceRecognitionService.getInstance();
  
  aboutToAppear() {
    // 检查语音识别是否可用
    this.checkVoiceAvailability();
  }
  
  /**
   * 检查语音识别可用性
   */
  private async checkVoiceAvailability() {
    const isAvailable = await VoiceRecognitionService.checkAvailability();
    if (!isAvailable) {
      console.log('设备不支持语音识别功能');
      promptAction.showToast({ message: '设备不支持语音识别功能' });
    }
  }
  
  /**
   * 开始语音输入
   */
  private async startVoiceInput() {
    if (this.isListening) {
      // 如果正在听取，则停止
      await this.stopVoiceInput();
      return;
    }
    
    const success = await this.voiceService.startRecognition(
      (text: string) => {
        // 识别成功
        console.log('语音识别结果:', text);
        this.voiceStatus = VoiceInputStatus.IDLE;
        this.statusText = '';
        this.isListening = false;
        
        if (this.onVoiceResult) {
          this.onVoiceResult(text);
        }
        
        promptAction.showToast({ 
          message: `识别结果: ${text}`,
          duration: 2000
        });
      },
      (error: string) => {
        // 识别失败
        console.error('语音识别错误:', error);
        this.voiceStatus = VoiceInputStatus.ERROR;
        this.statusText = error;
        this.isListening = false;
        
        if (this.onError) {
          this.onError(error);
        }
        
        promptAction.showToast({ 
          message: error,
          duration: 2000
        });
        
        // 2秒后重置状态
        setTimeout(() => {
          this.voiceStatus = VoiceInputStatus.IDLE;
          this.statusText = '';
        }, 2000);
      },
      (status: 'start' | 'listening' | 'processing' | 'end') => {
        // 状态变化
        switch (status) {
          case 'start':
            this.voiceStatus = VoiceInputStatus.LISTENING;
            this.statusText = '准备中...';
            this.isListening = true;
            break;
          case 'listening':
            this.voiceStatus = VoiceInputStatus.LISTENING;
            this.statusText = '请说话...';
            break;
          case 'processing':
            this.voiceStatus = VoiceInputStatus.PROCESSING;
            this.statusText = '识别中...';
            break;
          case 'end':
            this.voiceStatus = VoiceInputStatus.IDLE;
            this.statusText = '';
            this.isListening = false;
            break;
        }
      }
    );
    
    if (!success) {
      this.voiceStatus = VoiceInputStatus.ERROR;
      this.statusText = '启动语音识别失败';
      this.isListening = false;
    }
  }
  
  /**
   * 停止语音输入
   */
  private async stopVoiceInput() {
    await this.voiceService.stopRecognition();
    this.voiceStatus = VoiceInputStatus.IDLE;
    this.statusText = '';
    this.isListening = false;
  }
  
  /**
   * 获取按钮颜色
   */
  private getButtonColor(): string {
    switch (this.voiceStatus) {
      case VoiceInputStatus.LISTENING:
        return '#FF4444'; // 红色表示录音中
      case VoiceInputStatus.PROCESSING:
        return '#FFA500'; // 橙色表示处理中
      case VoiceInputStatus.ERROR:
        return '#999999'; // 灰色表示错误
      default:
        return CommonConstants.PRIMARY_COLOR; // 默认主题色
    }
  }
  
  /**
   * 获取按钮图标
   */
  private getButtonIcon(): Resource {
    switch (this.voiceStatus) {
      case VoiceInputStatus.LISTENING:
        return $r('app.media.ic_public_voice_filled'); // 录音中图标
      case VoiceInputStatus.PROCESSING:
        return $r('app.media.ic_public_loading'); // 加载图标
      default:
        return $r('app.media.ic_public_voice'); // 默认麦克风图标
    }
  }
  
  build() {
    Column() {
      // 语音输入按钮
      Button() {
        Image(this.getButtonIcon())
          .width(20)
          .height(20)
          .fillColor(Color.White)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor(this.getButtonColor())
      .onClick(() => {
        this.startVoiceInput();
      })
      
      // 状态文本
      if (this.statusText) {
        Text(this.statusText)
          .fontSize(10)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .margin({ top: 4 })
          .maxLines(1)
          .width(60)
      }
    }
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 语音输入弹窗组件
 */
@CustomDialog
export struct VoiceInputDialog {
  @State voiceStatus: VoiceInputStatus = VoiceInputStatus.IDLE;
  @State statusText: string = '点击开始录音';
  @State recognizedText: string = '';
  @State waveAnimation: number = 0;
  
  controller: CustomDialogController;
  onConfirm?: (text: string) => void;
  onCancel?: () => void;
  
  private voiceService: VoiceRecognitionService = VoiceRecognitionService.getInstance();
  private animationTimer: number = -1;
  
  aboutToAppear() {
    this.startWaveAnimation();
  }
  
  aboutToDisappear() {
    this.stopWaveAnimation();
    this.voiceService.stopRecognition();
  }
  
  /**
   * 开始波形动画
   */
  private startWaveAnimation() {
    this.animationTimer = setInterval(() => {
      if (this.voiceStatus === VoiceInputStatus.LISTENING) {
        this.waveAnimation = (this.waveAnimation + 1) % 4;
      }
    }, 200);
  }
  
  /**
   * 停止波形动画
   */
  private stopWaveAnimation() {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }
  
  /**
   * 开始语音识别
   */
  private async startRecognition() {
    await this.voiceService.startRecognition(
      (text: string) => {
        this.recognizedText = text;
        this.voiceStatus = VoiceInputStatus.IDLE;
        this.statusText = '识别完成，点击确认使用';
      },
      (error: string) => {
        this.voiceStatus = VoiceInputStatus.ERROR;
        this.statusText = error;
      },
      (status: 'start' | 'listening' | 'processing' | 'end') => {
        switch (status) {
          case 'start':
            this.voiceStatus = VoiceInputStatus.LISTENING;
            this.statusText = '准备中...';
            break;
          case 'listening':
            this.statusText = '请说话...';
            break;
          case 'processing':
            this.voiceStatus = VoiceInputStatus.PROCESSING;
            this.statusText = '识别中，请稍候...';
            break;
          case 'end':
            if (!this.recognizedText) {
              this.voiceStatus = VoiceInputStatus.IDLE;
              this.statusText = '点击重新录音';
            }
            break;
        }
      }
    );
  }
  
  build() {
    Column() {
      // 标题
      Text('语音搜索')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(CommonConstants.TEXT_PRIMARY)
        .margin({ bottom: 20 })
      
      // 录音区域
      Column() {
        // 麦克风图标和动画
        Stack() {
          Circle({ width: 80, height: 80 })
            .fill(this.voiceStatus === VoiceInputStatus.LISTENING ? '#FF4444' : CommonConstants.PRIMARY_COLOR)
            .opacity(0.1)
          
          Circle({ width: 60, height: 60 })
            .fill(this.voiceStatus === VoiceInputStatus.LISTENING ? '#FF4444' : CommonConstants.PRIMARY_COLOR)
            .opacity(0.3)
            .scale({ 
              x: this.voiceStatus === VoiceInputStatus.LISTENING ? 1 + this.waveAnimation * 0.1 : 1,
              y: this.voiceStatus === VoiceInputStatus.LISTENING ? 1 + this.waveAnimation * 0.1 : 1
            })
            .animation({
              duration: 200,
              curve: Curve.EaseInOut
            })
          
          Button() {
            Image($r('app.media.ic_public_voice_filled'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
          }
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor(this.voiceStatus === VoiceInputStatus.LISTENING ? '#FF4444' : CommonConstants.PRIMARY_COLOR)
          .onClick(() => {
            if (this.voiceStatus === VoiceInputStatus.IDLE) {
              this.startRecognition();
            }
          })
        }
        .margin({ bottom: 20 })
        
        // 状态文本
        Text(this.statusText)
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })
        
        // 识别结果
        if (this.recognizedText) {
          Column() {
            Text('识别结果:')
              .fontSize(12)
              .fontColor(CommonConstants.TEXT_SECONDARY)
              .margin({ bottom: 8 })
            
            Text(this.recognizedText)
              .fontSize(16)
              .fontColor(CommonConstants.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .width('100%')
          }
          .width('100%')
          .margin({ bottom: 20 })
        }
      }
      .width('100%')
      .padding(20)
      
      // 按钮区域
      Row() {
        Button('取消')
          .type(ButtonType.Normal)
          .backgroundColor('#F5F5F5')
          .fontColor(CommonConstants.TEXT_PRIMARY)
          .layoutWeight(1)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
            this.controller.close();
          })
        
        Button('确认')
          .type(ButtonType.Normal)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .fontColor(Color.White)
          .layoutWeight(1)
          .margin({ left: 12 })
          .enabled(!!this.recognizedText)
          .onClick(() => {
            if (this.recognizedText && this.onConfirm) {
              this.onConfirm(this.recognizedText);
            }
            this.controller.close();
          })
      }
      .width('100%')
    }
    .width(300)
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
