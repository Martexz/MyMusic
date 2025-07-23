import { CommonConstants } from '../common/constants/CommonConstants';
import { MusicService } from '../services/MusicService';
import { Song, Singer, SongList } from '../models/DataModels';
import { SongItem } from '../components/SongItem';
import { SingerItem } from '../components/SingerItem';
import { SongListItem } from '../components/SongListItem';
import themeManager, { ThemeMode } from '../common/ThemeManager';
import { VoiceInputButton, VoiceInputDialog } from '../components/VoiceInputComponent';
import promptAction from '@ohos.promptAction';

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
  @State themeMode: ThemeMode = themeManager.themeMode;
  
  // 语音输入弹窗控制器
  voiceDialogController: CustomDialogController = new CustomDialogController({
    builder: VoiceInputDialog({
      onConfirm: (text: string) => {
        this.handleVoiceResult(text);
      },
      onCancel: () => {
        console.log('语音输入已取消');
      }
    }),
    customStyle: true,
    autoCancel: true
  });

  private readonly onThemeChanged = (mode: ThemeMode): void => {
    this.themeMode = mode;
  };

  aboutToAppear() {
    this.loadSearchHistory();
    themeManager.on(this.onThemeChanged);
    this.themeMode = themeManager.themeMode;
  }

  aboutToDisappear() {
    themeManager.off(this.onThemeChanged);
  }
  
  /**
   * 处理语音识别结果
   */
  private handleVoiceResult(text: string) {
    if (text && text.trim()) {
      this.searchKeyword = text.trim();
      this.showHistory = false;
      this.performSearch();
      
      promptAction.showToast({
        message: `正在搜索: ${text}`,
        duration: 1500
      });
    }
  }
  
  /**
   * 显示语音输入弹窗
   */
  private showVoiceDialog() {
    this.voiceDialogController.open();
  }
  
  private getBackgroundColor(): string {
    return this.themeMode === 'dark' ? CommonConstants.BACKGROUND_DARK : CommonConstants.BACKGROUND_LIGHT;
  }

  private getTextPrimary(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_PRIMARY : CommonConstants.TEXT_COLOR_LIGHT_PRIMARY;
  }

  private getTextSecondary(): string {
    return this.themeMode === 'dark' ? CommonConstants.TEXT_COLOR_DARK_SECONDARY : CommonConstants.TEXT_COLOR_LIGHT_SECONDARY;
  }

  private getTabTextColor(isActive: boolean): string {
    return isActive ? CommonConstants.PRIMARY_COLOR : this.getTextSecondary();
  }

  private tabs: string[] = ['歌曲', '歌手', '歌单', '排行榜'];
  private maxHistoryCount: number = 10;


  @Builder
  TabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontColor(this.getTabTextColor(this.activeTab === index))
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
        .fontColor(this.themeMode==='dark'?CommonConstants.TEXT_COLOR_DARK_SECONDARY:"#000000")
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.themeMode==='dark'?"#ff6b6969":"#eeeeee")
        .borderRadius(15)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Button() {
        Image('resources/base/media/ic_public_cancel.svg')
          .width(12)
          .height(12)
          .fillColor(this.themeMode==='dark'?CommonConstants.TEXT_COLOR_DARK_SECONDARY:"#000000")
          .backgroundColor(this.themeMode==='dark'? "#ff6b6969" :"#eeeeee")
      }
      .type(ButtonType.Normal)
      .margin({ left: 4 , right: 6})
      .opacity(0.6)
      .backgroundColor(this.themeMode==='dark'?"#ff6b6969":"#eeeeee")
      .onClick(() => {
        this.removeHistoryItem(item);
      })
    }
    .borderRadius(15)
    .backgroundColor(this.themeMode==='dark'?"#ff6b6969":"#eeeeee")
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
              SongItem({ song: song, themeMode: this.themeMode })
            }
          }, (song: Song) => song.id.toString())
        }
        .layoutWeight(1)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
      } else {
        Text('请输入关键词搜索歌曲')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
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
              SingerItem({ singer: singer, themeMode: this.themeMode  })
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
              SongListItem({ songList: songList , themeMode: this.themeMode })
            }
          }, (songList: SongList) => songList.id.toString())
        }
        .layoutWeight(1)
      } else if (this.hasSearched) {
        Text('暂无搜索结果')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
      } else {
        Text('请输入关键词搜索歌单')
          .fontSize(14)
          .fontColor(this.getTextSecondary())
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
        .fontColor(this.getTextPrimary())
      Text('暂无排行榜数据')
        .fontSize(14)
        .fontColor(this.getTextSecondary())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      // 搜索框区域
      Row() {
        TextInput({ placeholder: '搜索歌曲、歌手、歌单', text: this.searchKeyword })
          .layoutWeight(1)
          .height(40)
          .fontColor(this.getTextPrimary())
          .placeholderColor(this.getTextPrimary())
          .backgroundColor(this.themeMode==='dark'?"#ff454343":"#ffffff")
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onClick(() => {
            this.showHistory = true;
          })

        // 语音输入按钮
        VoiceInputButton({
          onVoiceResult: (text: string) => {
            this.handleVoiceResult(text);
          },
          onError: (error: string) => {
            promptAction.showToast({ 
              message: error,
              duration: 2000 
            });
          }
        })
        .margin({ left: 8, right: 8 })

        Button('搜索')
          .width(80)
          .height(40)
          .type(ButtonType.Capsule)
          .backgroundColor(CommonConstants.PRIMARY_COLOR)
          .fontColor(Color.White)
          .margin({ left: 4 })
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
              .fontColor(this.getTextSecondary())

            if (this.searchHistory.length > 0) {
              Button('清空全部')
                .fontSize(14)
                .fontColor(this.getTextSecondary())
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
        .backgroundColor(this.themeMode==='dark'?"#ff454343":"#ffffff")
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
      .backgroundColor(this.themeMode==='dark'?"#ff454343":"#ffffff")

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
    .backgroundColor(this.getBackgroundColor())
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