import { Swiper } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';

@Component
export struct SwiperComponent {
  @Prop swipers: Swiper[];

  build() {
    if (this.swipers.length > 0) {
      Swiper() {
        ForEach(this.swipers, (swiper: Swiper) => {
          Image(swiper.pic)
            .width('100%')
            .height(180)
            .borderRadius(CommonConstants.BORDER_RADIUS)
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              if (swiper.url) {
                // 处理轮播图点击事件
                console.log('点击轮播图:', swiper.url);
              }
            })
        })
      }
      .autoPlay(true)
      .interval(3000)
      .indicator(true)
      .loop(true)
      .width('100%')
      .height(180)
      .margin({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
      .borderRadius(CommonConstants.BORDER_RADIUS)
    }
  }
}
