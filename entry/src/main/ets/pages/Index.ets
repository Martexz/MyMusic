import { CommonConstants } from '../common/constants/CommonConstants';
import { MainPage } from './MainPage';

@Entry
@Component
struct Index {
  build() {
    Navigation() {
      MainPage()
    }
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
  }
}