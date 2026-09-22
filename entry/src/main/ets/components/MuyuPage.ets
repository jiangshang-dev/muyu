import { MeritStore } from '../utils/MeritStore';
import { AudioHelper, MUYU_SOUNDS, MUYU_SOUND_NAMES } from '../utils/AudioHelper';
import { FloatMerit } from './FloatMerit';

class FloatItem {
  id: number = 0;
  text: string = '功德 +10';
}

@Component
export struct MuyuPage {
  audio: AudioHelper | null = null;
  @Link merit: number;
  @Link soundIndex: number;
  @Link styleIndex: number;

  @State private scaleValue: number = 1;
  @State private showSheet: boolean = false;
  @State private floats: FloatItem[] = [];
  private floatSeq: number = 0;

  private getMuyuImage(): Resource {
    return this.styleIndex === 0 ? $r('app.media.muyu_wood') : $r('app.media.muyu_white');
  }

  private async onKnock(): Promise<void> {
    animateTo({ duration: 80, curve: Curve.EaseOut }, () => {
      this.scaleValue = 0.9;
    });
    setTimeout(() => {
      animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
        this.scaleValue = 1;
      });
    }, 80);

    const sound = MUYU_SOUNDS[this.soundIndex] ?? MUYU_SOUNDS[0];
    this.audio?.playSfx(sound);

    this.floatSeq += 1;
    const item: FloatItem = { id: this.floatSeq, text: '功德 +10' };
    this.floats = [...this.floats, item];
    setTimeout(() => {
      this.floats = this.floats.filter((f: FloatItem) => f.id !== item.id);
    }, 1000);

    this.merit = await MeritStore.addMerit(10);
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text(`功德：${this.merit}`)
            .fontSize(18)
            .fontColor('#E8E8E8')
            .fontWeight(FontWeight.Medium)
            .letterSpacing(1)
          Blank()
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 16 })

        Blank()

        Stack({ alignContent: Alignment.Center }) {
          Image(this.getMuyuImage())
            .width('68%')
            .aspectRatio(1)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#00000000')
            .scale({ x: this.scaleValue, y: this.scaleValue })
            .onClick(() => {
              this.onKnock();
            })

          ForEach(this.floats, (item: FloatItem) => {
            FloatMerit({ text: item.text, animKey: item.id })
              .margin({ bottom: 140 })
          }, (item: FloatItem) => item.id.toString())
        }
        .width('100%')
        .height(380)

        Text('轻触木鱼 · 积攒今日功德')
          .fontSize(13)
          .fontColor('#666666')
          .margin({ top: 8 })

        Blank()

        Row() {
          Blank()
          Image($r('app.media.ic_settings'))
            .width(28)
            .height(28)
            .opacity(0.85)
            .onClick(() => {
              this.showSheet = true;
            })
        }
        .width('100%')
        .padding({ left: 28, right: 28, bottom: 12 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showSheet, this.SoundSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: '#141414',
      showClose: true,
      dragBar: true
    })
  }

  @Builder
  SoundSheet() {
    Column({ space: 0 }) {
      Text('设置')
        .fontSize(17)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 24, right: 24, top: 8, bottom: 16 })

      Text('木鱼音效')
        .fontSize(13)
        .fontColor('#888888')
        .width('100%')
        .padding({ left: 24, bottom: 10 })

      ForEach(MUYU_SOUND_NAMES, (name: string, index: number) => {
        Row() {
          Text(name)
            .fontSize(16)
            .fontColor('#EEEEEE')
            .layoutWeight(1)
          if (this.soundIndex === index) {
            Text('✓')
              .fontSize(16)
              .fontColor('#D4AF37')
          }
        }
        .width('100%')
        .height(48)
        .padding({ left: 24, right: 24 })
        .backgroundColor(this.soundIndex === index ? '#1F1F1F' : '#00000000')
        .onClick(async () => {
          this.soundIndex = index;
          await MeritStore.setSoundIndex(index);
          const sound = MUYU_SOUNDS[index];
          this.audio?.playSfx(sound);
        })
      }, (name: string, index: number) => `${name}_${index}`)

      Text('木鱼样式')
        .fontSize(13)
        .fontColor('#888888')
        .width('100%')
        .padding({ left: 24, top: 18, bottom: 10 })

      Row({ space: 12 }) {
        this.StyleCard('木质', 0, $r('app.media.muyu_wood'))
        this.StyleCard('简白', 1, $r('app.media.muyu_white'))
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 32 })
    }
    .width('100%')
    .padding({ bottom: 20 })
  }

  @Builder
  StyleCard(label: string, index: number, img: Resource) {
    Column({ space: 8 }) {
      Image(img)
        .width('100%')
        .height(72)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#0A0A0A')
        .borderRadius(12)
        .padding(8)
      Text(label)
        .fontSize(13)
        .fontColor(this.styleIndex === index ? '#D4AF37' : '#AAAAAA')
    }
    .layoutWeight(1)
    .padding(10)
    .borderRadius(14)
    .border({
      width: this.styleIndex === index ? 1.5 : 1,
      color: this.styleIndex === index ? '#D4AF37' : '#2A2A2A'
    })
    .onClick(async () => {
      this.styleIndex = index;
      await MeritStore.setStyleIndex(index);
    })
  }
}
