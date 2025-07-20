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

interface SearchHistoryItem {
  keyword: string;
  timestamp: number;
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
  @State showHistory: boolean = false;
  @State searchHistory: SearchHistoryItem[] = [];

  private tabs: string[] = ['歌曲', '歌手', '歌单', '排行榜'];
  private maxHistoryCount: number = 10;

  aboutToAppear() {
    this.loadSearchHistory();
  }

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

  @Builder
  HistoryItemView(item: SearchHistoryItem) {
    Row() {
      Text(item.keyword)
        .fontSize(14)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#f5f5f5')
        .borderRadius(15)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Button() {
        Image('resources/base/media/ic_public_cancel.svg')
          .width(12)
          .height(12)
          .backgroundColor("#eeeeee")
      }
      .type(ButtonType.Normal)
      .margin({ left: 4 })
      .opacity(0.6)
      .onClick(() => {
        this.removeHistoryItem(item);
      })
    }
    .borderRadius(15)
    .backgroundColor('#f5f5f5')
    .padding({ right: 8 })
    .margin({ right: 8, bottom: 8 })
    .onClick(() => {
      this.searchKeyword = item.keyword;
      this.showHistory = false;
      this.performSearch();
    })
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
          }, (song: Song) => song.id.toString())
        }
        .layoutWeight(1)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
      } else {
        Text('请输入关键词搜索歌曲')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  @Builder
  SingerSearchContent() {
    Column() {
      if (this.isSearching) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(CommonConstants.PRIMARY_COLOR)
      } else if (this.hasSearched && this.searchResults.singers.length > 0) {
        List() {
          ForEach(this.searchResults.singers, (singer: Singer) => {
            ListItem() {
              SingerItem({ singer: singer })
            }
          }, (singer: Singer) => singer.id.toString())
        }
        .layoutWeight(1)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
      } else {
        Text('请输入关键词搜索歌手')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  @Builder
  SongListSearchContent() {
    Column() {
      if (this.isSearching) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(CommonConstants.PRIMARY_COLOR)
      } else if (this.hasSearched && this.searchResults.songLists.length > 0) {
        List() {
          ForEach(this.searchResults.songLists, (songList: SongList) => {
            ListItem() {
              SongListItem({ songList: songList })
            }
          }, (songList: SongList) => songList.id.toString())
        }
        .layoutWeight(1)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
      } else {
        Text('请输入关键词搜索歌单')
          .fontSize(14)
          .fontColor(CommonConstants.TEXT_SECONDARY)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(CommonConstants.MARGIN_MEDIUM)
  }

  @Builder
  RankContent() {
    Column() {
      Text('音乐排行榜')
        .fontSize(16)
      Text('暂无排行榜数据')
        .fontSize(14)
        .fontColor(CommonConstants.TEXT_SECONDARY)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // 搜索框区域
      Row() {
        TextInput({ placeholder: '搜索歌曲、歌手、歌单' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onClick(() => {
            this.showHistory = true;
          })

        Button('搜索')
          .width(80)
          .height(40)
          .type(ButtonType.Capsule)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .fontColor(Color.White)
          .margin({ left: 12 })
          .onClick(() => {
            this.showHistory = false;
            this.performSearch();
          })
      }
      .width('100%')
      .padding(16)

      // 历史记录面板
      if (this.showHistory) {
        Column() {
          Row() {
            Text('搜索历史')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)

            if (this.searchHistory.length > 0) {
              Button('清空全部')
                .fontSize(14)
                .fontColor('#666')
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .margin({ left: 8 })
                .onClick(() => {
                  this.clearSearchHistory();
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16, top: 12, bottom: 8 })

          if (this.searchHistory.length > 0) {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.searchHistory, (item: SearchHistoryItem) => {
                this.HistoryItemView(item)
              }, (item: SearchHistoryItem) => item.timestamp.toString())
            }
            .width('100%')
            .padding({ left: 8, right: 8, bottom: 8 })
          } else {
            Column() {
              Image('resources/base/media/ic_no_history.png')
                .width(80)
                .height(80)
              Text('暂无搜索历史')
                .fontSize(14)
                .fontColor('#999')
                .margin({ top: 8 })
            }
            .width('100%')
            .height(120)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ top: 8 })
        .padding({ bottom: 8 })
        .shadow({ radius: 4, color: '#20000000', offsetX: 1, offsetY: 1 })
      }

      // 标签栏
      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          this.TabBuilder(tab, index)
        }, (tab: string, index: number) => index.toString())
      }
      .width('100%')
      .margin({ top: 8 })
      .backgroundColor(Color.White)

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
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.activeTab = index;
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
    .onClick(() => {
      this.showHistory = false;
    })
  }

  private async performSearch() {
    const keyword = this.searchKeyword.trim();
    if (keyword) {
      this.isSearching = true;
      try {
        const songsResult = await MusicService.searchSongs(keyword);
        const singersResult = await MusicService.searchSingers(keyword);
        const songListsResult = await MusicService.searchSongLists(keyword);

        this.searchResults = {
          songs: songsResult ? songsResult.songs : [],
          singers: singersResult ? singersResult.singers : [],
          songLists: songListsResult ? songListsResult.songLists : []
        };

        this.hasSearched = true;
        this.addSearchHistory(keyword);
      } catch (error) {
        console.error('搜索失败:', error);
      } finally {
        this.isSearching = false;
      }
    }
  }

  private addSearchHistory(keyword: string) {
    const existingIndex = this.searchHistory.findIndex(item => item.keyword === keyword);
    let newHistory = [...this.searchHistory];

    if (existingIndex >= 0) {
      newHistory.splice(existingIndex, 1);
    }

    newHistory.unshift({
      keyword: keyword,
      timestamp: Date.now()
    });

    if (newHistory.length > this.maxHistoryCount) {
      newHistory = newHistory.slice(0, this.maxHistoryCount);
    }

    this.searchHistory = newHistory;
    this.saveSearchHistory();
  }

  private removeHistoryItem(item: SearchHistoryItem) {
    this.searchHistory = this.searchHistory.filter(history => history.keyword !== item.keyword);
    this.saveSearchHistory();
  }

  private clearSearchHistory() {
    this.searchHistory = [];
    this.saveSearchHistory();
  }

  private saveSearchHistory() {
    AppStorage.SetOrCreate('searchHistory', JSON.stringify(this.searchHistory));
  }

  private loadSearchHistory() {
    const history = AppStorage.Get<string>('searchHistory');
    this.searchHistory = history ? JSON.parse(history) : [];
  }
}