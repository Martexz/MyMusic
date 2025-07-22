import { CommonConstants } from '../common/constants/CommonConstants';
import { MainPage } from './MainPage';

@Entry
@Component
struct Index {
  build() {
    Column() {
      MainPage()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
  }
}