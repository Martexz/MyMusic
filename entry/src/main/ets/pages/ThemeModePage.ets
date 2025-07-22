import router from '@ohos.router';
import preferences from '@ohos.data.preferences';
import prompt from '@system.prompt';
import common from '@ohos.app.ability.common';
import themeManager from '../common/ThemeManager';
import {ThemeMode} from '../common/ThemeManager'
@Entry
@Component
struct ThemeModePage {
  private pref: preferences.Preferences | null = null;
  private context = getContext() as common.UIAbilityContext;

  async onPageShow() {
    this.pref = await preferences.getPreferences(this.context, 'app_settings');
  }

  build() {
    Column() {
      this.OptionButton('浅色模式', 'light')
      this.OptionButton('深色模式', 'dark')
      this.OptionButton('跟随系统', 'auto')
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  @Builder
  OptionButton(title: string, mode: ThemeMode) {
    Button(title)
      .margin({ bottom: 16 })
      .onClick(async () => {
        if (!this.pref) return;
        try {
          await this.pref.put('themeMode', mode);
          await this.pref.flush();

          themeManager.themeMode = mode;  // 这里触发通知

          prompt.showToast({ message: '设置成功' });
          router.back();
        } catch {
          prompt.showToast({ message: '保存失败' });
        }
      })
  }
}