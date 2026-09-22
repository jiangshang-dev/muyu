import { common } from '@kit.AbilityKit';
import { MeritStore } from '../utils/MeritStore';
import { AudioHelper } from '../utils/AudioHelper';
import { MuyuPage } from '../components/MuyuPage';
import { SongPage } from '../components/SongPage';

@Entry
@Component
struct Index {
  @State private currentTab: number = 0;
  @State private merit: number = 0;
  @State private soundIndex: number = 0;
  @State private styleIndex: number = 0;
  @State private ready: boolean = false;

  private audio: AudioHelper | null = null;

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    this.audio = new AudioHelper(ctx);
    MeritStore.init(ctx).then(async () => {
      this.merit = await MeritStore.loadMerit();
      this.soundIndex = await MeritStore.getSoundIndex();
      this.styleIndex = await MeritStore.getStyleIndex();
      this.ready = true;
    });
  }

  aboutToDisappear(): void {
    this.audio?.release();
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentTab }) {
        TabContent() {
          if (this.ready) {
            MuyuPage({
              audio: this.audio,
              merit: $merit,
              soundIndex: $soundIndex,
              styleIndex: $styleIndex
            })
          }
        }
        .tabBar(this.TabBuilder('木鱼', 0, $r('app.media.ic_tab_muyu')))

        TabContent() {
          if (this.ready) {
            SongPage({ audio: this.audio })
          }
        }
        .tabBar(this.TabBuilder('佛歌', 1, $r('app.media.ic_tab_song')))
      }
      .width('100%')
      .layoutWeight(1)
      .barHeight(56)
      .barBackgroundColor('#0A0A0A')
      .animationDuration(280)
      .onChange((index: number) => {
        this.currentTab = index;
      })
      .scrollable(false)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  TabBuilder(title: string, index: number, icon: Resource) {
    Column({ space: 4 }) {
      Image(icon)
        .width(22)
        .height(22)
        .fillColor(this.currentTab === index ? '#D4AF37' : '#666666')
        .opacity(this.currentTab === index ? 1 : 0.7)
      Text(title)
        .fontSize(11)
        .fontColor(this.currentTab === index ? '#D4AF37' : '#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
