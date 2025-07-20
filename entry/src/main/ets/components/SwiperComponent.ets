import { Swiper } from '../models/DataModels';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ImageUtil } from '../utils/ImageUtil';

@Component
export struct SwiperComponent {
  @Prop swipers: Swiper[];

  build() {
    if (this.swipers.length > 0) {
      Swiper() {
        ForEach(this.swipers, (swiper: Swiper) => {
          Image(ImageUtil.getSwiperImageUrl(swiper.pic))
            .width('100%')
            .height(180)
            .borderRadius(CommonConstants.BORDER_RADIUS)
            .objectFit(ImageFit.Cover)
            .alt(ImageUtil.getSwiperImageUrl('/images/default_banner.jpg'))  // 使用后端默认图片作为占位图
            .onError(() => {
              // 图片加载失败时的处理逻辑
              console.log('轮播图加载失败:', swiper.pic);
            })
            .onClick(() => {
              if (swiper.url) {
                // 处理轮播图点击事件
                console.log('点击轮播图:', swiper.url);
                // TODO: 可以在这里添加页面跳转逻辑
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
