import { CommonConstants } from '../common/constants/CommonConstants';
import { MusicService } from '../services/MusicService';
import { Song, Singer, SongList } from '../models/DataModels';
import { SongItem } from '../components/SongItem';
import { SingerItem } from '../components/SingerItem';
import { SongListItem } from '../components/SongListItem';

interface SearchResults {
  songs: Song[];
  singers: Singer[];
  songLists: SongList[];
}

@Component
export struct DiscoverPage {
  @State searchKeyword: string = '';
  @State activeTab: number = 0;
  @State searchResults: SearchResults = {
    songs: [],
    singers: [],
    songLists: []
  };
  @State isSearching: boolean = false;
  @State hasSearched: boolean = false;
  
  private tabs: string[] = ['歌曲', '歌手', '歌单', '排行榜'];

  @Builder
  TabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontColor(this.activeTab === index ? CommonConstants.PRIMARY_COLOR : CommonConstants.TEXT_SECONDARY)
        .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Normal)
      
      if (this.activeTab === index) {
        Divider()
          .width(20)
          .height(2)
          .color(CommonConstants.PRIMARY_COLOR)
          .margin({ top: 4 })
      }
    }
    .padding({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM, top: CommonConstants.MARGIN_SMALL, bottom: CommonConstants.MARGIN_SMALL })
    .onClick(() => {
      this.activeTab = index;
    })
  }

  build() {
    Column() {
      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索歌曲、歌手、歌单' })
          .layoutWeight(1)
          .backgroundColor(Color.White)
          .borderRadius(CommonConstants.BORDER_RADIUS)
          .padding({ left: CommonConstants.MARGIN_MEDIUM, right: CommonConstants.MARGIN_MEDIUM })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            // 执行搜索
            this.performSearch();
          })
        
        Button('搜索')
          .type(ButtonType.Normal)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .fontColor(Color.White)
          .borderRadius(CommonConstants.BORDER_RADIUS)
          .margin({ left: CommonConstants.MARGIN_SMALL })
          .onClick(() => {
            this.performSearch();
          })
      }
      .width('100%')
      .padding(CommonConstants.MARGIN_MEDIUM)
      .backgroundColor(CommonConstants.BACKGROUND_COLOR)

      // 标签栏
      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          this.TabBuilder(tab, index)
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceAround)

      // 内容区域
      Tabs({ index: this.activeTab }) {
        TabContent() {
          this.SongSearchContent()
        }
        
        TabContent() {
          this.SingerSearchContent()
        }
        
        TabContent() {
          this.SongListSearchContent()
        }
        
        TabContent() {
          this.RankContent()
        }
      }
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.activeTab = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
  }

  @Builder
  SongSearchContent() {
    Column() {
      if (this.isSearching) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(CommonConstants.PRIMARY_COLOR)
          .margin(CommonConstants.MARGIN_LARGE)
      } else if (this.hasSearched && this.searchResults.songs.length > 0) {
        List() {
          ForEach(this.searchResults.songs, (song: Song) => {
            ListItem() {
              SongItem({ song: song })
            }
            .margin({ bottom: CommonConstants.MARGIN_SMALL })
          })
        }
        .layoutWeight(1)
        .padding(CommonConstants.MARGIN_MEDIUM)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        Text('请输入关键词搜索歌曲')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(this.isSearching || !this.hasSearched ? FlexAlign.Center : FlexAlign.Start)
  }

  @Builder
  SingerSearchContent() {
    Column() {
      if (this.isSearching) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(CommonConstants.PRIMARY_COLOR)
          .margin(CommonConstants.MARGIN_LARGE)
      } else if (this.hasSearched && this.searchResults.singers.length > 0) {
        List() {
          ForEach(this.searchResults.singers, (singer: Singer) => {
            ListItem() {
              SingerItem({ singer: singer })
            }
            .margin({ bottom: CommonConstants.MARGIN_SMALL })
          })
        }
        .layoutWeight(1)
        .padding(CommonConstants.MARGIN_MEDIUM)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        Text('请输入关键词搜索歌手')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(this.isSearching || !this.hasSearched ? FlexAlign.Center : FlexAlign.Start)
  }

  @Builder
  SongListSearchContent() {
    Column() {
      if (this.isSearching) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(CommonConstants.PRIMARY_COLOR)
          .margin(CommonConstants.MARGIN_LARGE)
      } else if (this.hasSearched && this.searchResults.songLists.length > 0) {
        List() {
          ForEach(this.searchResults.songLists, (songList: SongList) => {
            ListItem() {
              SongListItem({ songList: songList })
            }
            .margin({ bottom: CommonConstants.MARGIN_SMALL })
          })
        }
        .layoutWeight(1)
        .padding(CommonConstants.MARGIN_MEDIUM)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      } else {
        Text('请输入关键词搜索歌单')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
          .margin(CommonConstants.MARGIN_LARGE)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(this.isSearching || !this.hasSearched ? FlexAlign.Center : FlexAlign.Start)
  }

  @Builder
  RankContent() {
    Column() {
      Text('音乐排行榜')
        .fontSize(16)
        .margin(CommonConstants.MARGIN_MEDIUM)
      
      // TODO: 实现排行榜列表
      Text('暂无排行榜数据')
        .fontSize(14)
        .fontColor(CommonConstants.TEXT_SECONDARY)
        .margin(CommonConstants.MARGIN_MEDIUM)
    }
    .width('100%')
    .height('100%')
  }

  private async performSearch() {
    if (this.searchKeyword.trim()) {
      this.isSearching = true;
      try {
        console.log('搜索关键词:', this.searchKeyword);
        
        // 并行搜索所有类型
        const songsResult = await MusicService.searchSongs(this.searchKeyword.trim());
        const singersResult = await MusicService.searchSingers(this.searchKeyword.trim());
        const songListsResult = await MusicService.searchSongLists(this.searchKeyword.trim());
        
        this.searchResults = {
          songs: songsResult.songs,
          singers: singersResult.singers,
          songLists: songListsResult.songLists
        } as SearchResults;
        
        this.hasSearched = true;
      } catch (error) {
        console.error('搜索失败:', error);
      } finally {
        this.isSearching = false;
      }
    }
  }
}
