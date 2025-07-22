import { CommonConstants } from '../common/constants/CommonConstants';
import router from '@ohos.router';
import prompt from '@system.prompt';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import themeManager from '../common/ThemeManager';
import {ThemeMode} from '../common/ThemeManager'
@Entry
@Component
struct SettingsPage {
  @State notificationsEnabled: boolean = true;
  @State allowBackgroundPlay: boolean = true;
  @State allowMultiAppPlay: boolean = false;
  @State themeMode: ThemeMode = themeManager.themeMode;
  private pref: preferences.Preferences | null = null;
  private context = getContext() as common.UIAbilityContext;

  async onPageShow(): Promise<void> {
    try {
      this.pref = await preferences.getPreferences(this.context, 'app_settings');
      this.notificationsEnabled = await this.getBooleanPreference('notifications', true);
      this.allowBackgroundPlay = await this.getBooleanPreference('backgroundPlay', true);
      this.allowMultiAppPlay = await this.getBooleanPreference('multiAppPlay', false);
      themeManager.on(this.onThemeChanged);

      // 这里不再直接从pref读themeMode
      this.themeMode = themeManager.themeMode;
    } catch {
      prompt.showToast({ message: '加载设置失败' });
    }
  }
  private onThemeChanged = (mode: ThemeMode): void => {
    this.themeMode = mode; // 这里是 @State，UI 会自动刷新
  }
  private async getBooleanPreference(key: string, defaultValue: boolean): Promise<boolean> {
    if (!this.pref) return defaultValue;
    const value = await this.pref.get(key, defaultValue);
    return !!value;
  }

  build() {
    Column() {
      this.TitleBar()

      Scroll() {
        Column() {
          this.DisplaySettingsGroup()
          this.NotificationSettingsGroup()
          this.AudioSettingsGroup()
          this.AboutGroup()
        }
        .padding(12)
        .padding({ top: 12, bottom: 24, left: 12, right: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBackgroundColor())
  }

  private getBackgroundColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.BACKGROUND_DARK : CommonConstants.BACKGROUND_LIGHT;
  }

  private getTextPrimaryColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_PRIMARY : CommonConstants.TEXT_COLOR_LIGHT_PRIMARY;
  }

  private getTextSecondaryColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_SECONDARY : CommonConstants.TEXT_COLOR_LIGHT_SECONDARY;
  }

  @Builder
  TitleBar(): void {
    Row() {
      Image($r('app.media.ic_public_arrow_left_filled'))
        .width(24)
        .height(24)
        .fillColor(this.themeMode === 'dark'? '#ffffff':'#000000')
        .onClick(() => router.back());

      Text('设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTextPrimaryColor())
        .margin({ left: 16 })

      Blank()
    }
    .width('100%')
    .height(56)
    .padding(16)
    .backgroundColor(this.themeMode==='dark'? '#ff181818':'#ffe2dfdf')
  }

  @Builder
  DisplaySettingsGroup(): void {
    Column() {
      this.GroupTitle($r('app.media.ic_public_devices_phone_filled'), '显示设置')

      Row() {
        Text('主题模式')
          .fontSize(16)
          .fontColor(this.getTextPrimaryColor())
          .layoutWeight(1)

        Text(this.getThemeLabel(this.themeMode))
          .fontSize(14)
          .fontColor(this.getTextSecondaryColor())
          .margin({ right: 8 })

        Image($r('app.media.ic_public_arrow_right'))
          .width(16)
          .height(16)
          .fillColor(this.themeMode === 'dark'? '#ffffff':'#000000')
      }
      .width('100%')
      .height(48)
      .onClick(() => this.jumpToThemePage())
    }
    .margin({ bottom: 24 })
  }

  private getThemeLabel(mode: string): string {
    if (mode === 'dark') return '深色'
    if (mode === 'auto') return '跟随系统'
    return '浅色'
  }

  private jumpToThemePage(): void {
    router.pushUrl({ url: 'pages/ThemeModePage' })
      .catch(() => prompt.showToast({ message: '跳转失败' }));
  }

  @Builder
  NotificationSettingsGroup(): void {
    Column() {
      this.GroupTitle($r('app.media.ic_public_message'), '通知设置')

      this.ToggleSetting('启用通知', this.notificationsEnabled, (value: boolean) => {
        this.notificationsEnabled = value;
        this.saveSetting('notifications', value);
      });

      //this.NavigationSetting('通知偏好', '', 'NotificationPreferencePage');
    }
    .margin({ bottom: 24 })
  }

  @Builder
  AudioSettingsGroup(): void {
    Column() {
      this.GroupTitle($r('app.media.ic_public_music'), '音频设置')

      this.ToggleSetting('后台播放', this.allowBackgroundPlay, (value: boolean) => {
        this.allowBackgroundPlay = value;
        this.saveSetting('backgroundPlay', value);
      });

      this.ToggleSetting('多应用同时播放', this.allowMultiAppPlay, (value: boolean) => {
        this.allowMultiAppPlay = value;
        this.saveSetting('multiAppPlay', value);
      });
    }
    .margin({ bottom: 24 })
  }

  @Builder
  AboutGroup(): void {
    Column() {
      this.GroupTitle($r('app.media.ic_public_help'), '关于')

      this.InfoSetting('版本', '1.0.0')
      //this.NavigationSetting('隐私政策', '', 'PrivacyPolicyPage')
      //this.NavigationSetting('用户协议', '', 'TermsPage')
    }
  }

  @Builder
  GroupTitle(icon: Resource, title: string): void {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .margin({ right: 12 })
        .fillColor(this.themeMode ==='dark'?'#ffffff':'#000000')

      Text(title)
        .fontSize(16)
        .fontColor(this.getTextPrimaryColor())
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  ToggleSetting(title: string, value: boolean, onChange: (value: boolean) => void): void {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor(this.getTextPrimaryColor())
        .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: value })
        .onChange((isOn: boolean) => onChange(isOn))
    }
    .width('100%')
    .height(48)
    .padding({ right: 16 })
  }

  @Builder
  NavigationSetting(title: string, value: string, targetPage: string): void {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor(this.getTextPrimaryColor())
        .layoutWeight(1)

      if (value) {
        Text(value)
          .fontSize(14)
          .fontColor(this.getTextSecondaryColor())
          .margin({ right: 8 })
      }

      Image($r('app.media.ic_public_contacts'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .height(48)
    .onClick(() => {
      router.pushUrl({ url: `pages/${targetPage}` })
        .catch(() => prompt.showToast({ message: '跳转失败' }));
    })
  }

  @Builder
  InfoSetting(title: string, value: string): void {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor(this.getTextPrimaryColor())
        .layoutWeight(1)

      Text(value)
        .fontSize(14)
        .fontColor(this.getTextSecondaryColor())
    }
    .width('100%')
    .height(48)
  }

  private async saveSetting(key: string, value: preferences.ValueType): Promise<void> {
    if (!this.pref) return;
    try {
      await this.pref.put(key, value);
      await this.pref.flush();
    } catch {
      prompt.showToast({ message: '保存设置失败' });
    }
  }
}
