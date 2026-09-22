import { AudioHelper, BUDDHA_SONGS, SongItem } from '../utils/AudioHelper';

@Component
export struct SongPage {
  audio: AudioHelper | null = null;

  @State private bgIndex: number = 0;
  @State private bgOpacity: number = 0.78;
  @State private breathScale: number = 1;
  @State private playingFile: string = '';
  @State private isPlaying: boolean = false;

  private bgTimer: number = -1;
  private breathTimer: number = -1;

  private readonly backgrounds: Resource[] = [
    $r('app.media.buddha_scene1'),
    $r('app.media.buddha_scene2'),
    $r('app.media.buddha_scene3'),
    $r('app.media.zen_kanpo'),
    $r('app.media.zen_xinwu'),
    $r('app.media.zen_cibei')
  ];

  private readonly captions: string[] = [
    '真诚清净 · 慈悲念佛',
    '南无阿弥陀佛',
    '弥陀慈光 · 护佑念佛人',
    '看破放下 · 专念佛',
    '心无罣碍 · 如莲从容',
    '仁慈悲愍 · 心无恨怨'
  ];

  aboutToAppear(): void {
    this.bgIndex = Math.floor(Math.random() * this.backgrounds.length);
    this.startBreath();
    this.startBgRotate();
    if (this.audio) {
      this.audio.onMusicState = (playing: boolean, file: string) => {
        this.isPlaying = playing;
        if (playing) {
          this.playingFile = file;
        } else if (this.playingFile === file) {
          this.playingFile = '';
        }
      };
    }
  }

  aboutToDisappear(): void {
    if (this.bgTimer !== -1) {
      clearInterval(this.bgTimer);
      this.bgTimer = -1;
    }
    if (this.breathTimer !== -1) {
      clearInterval(this.breathTimer);
      this.breathTimer = -1;
    }
  }

  private startBreath(): void {
    let growing = true;
    this.breathTimer = setInterval(() => {
      animateTo({ duration: 2600, curve: Curve.EaseInOut }, () => {
        this.breathScale = growing ? 1.08 : 1.0;
      });
      growing = !growing;
    }, 2800);
  }

  private startBgRotate(): void {
    this.bgTimer = setInterval(() => {
      animateTo({ duration: 700, curve: Curve.EaseIn }, () => {
        this.bgOpacity = 0;
      });
      setTimeout(() => {
        let next = Math.floor(Math.random() * this.backgrounds.length);
        if (next === this.bgIndex) {
          next = (this.bgIndex + 1) % this.backgrounds.length;
        }
        this.bgIndex = next;
        animateTo({ duration: 900, curve: Curve.EaseOut }, () => {
          this.bgOpacity = 0.78;
        });
      }, 720);
    }, 9000);
  }

  private async onToggleSong(song: SongItem): Promise<void> {
    await this.audio?.playMusic(song.file);
  }

  build() {
    Stack() {
      Image(this.backgrounds[this.bgIndex])
        .width('120%')
        .height('120%')
        .objectFit(ImageFit.Cover)
        .opacity(this.bgOpacity)
        .scale({ x: this.breathScale, y: this.breathScale })

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#99000000', 0], ['#33000000', 0.35], ['#F2000000', 1]]
        })

      Column() {
        Text('佛歌')
          .fontSize(22)
          .fontColor('#F2E6C8')
          .fontWeight(FontWeight.Medium)
          .letterSpacing(4)
          .margin({ top: 20 })

        Text(this.captions[this.bgIndex])
          .fontSize(13)
          .fontColor('#A09070')
          .margin({ top: 8, bottom: 24 })

        Blank()

        Column({ space: 12 }) {
          ForEach(BUDDHA_SONGS, (song: SongItem) => {
            Row() {
              Column({ space: 4 }) {
                Text(song.title)
                  .fontSize(16)
                  .fontColor('#F5F0E6')
                  .fontWeight(FontWeight.Medium)
                Text(this.playingFile === song.file && this.isPlaying ? '播放中…' : '轻触聆听')
                  .fontSize(12)
                  .fontColor('#8A7A5C')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Image(this.playingFile === song.file && this.isPlaying ?
                $r('app.media.ic_pause') : $r('app.media.ic_play'))
                .width(44)
                .height(44)
                .objectFit(ImageFit.Contain)
            }
            .width('100%')
            .padding({ left: 18, right: 16, top: 16, bottom: 16 })
            .borderRadius(16)
            .backgroundColor('#22FFFFFF')
            .onClick(() => {
              this.onToggleSong(song);
            })
          }, (song: SongItem) => song.id)
        }
        .width('100%')
        .padding({ left: 22, right: 22, bottom: 28 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .clip(true)
  }
}
