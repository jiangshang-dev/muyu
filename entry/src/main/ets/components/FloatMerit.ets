@Component
export struct FloatMerit {
  @Prop text: string = '功德 +10';
  @Prop animKey: number = 0;

  @State private opacityValue: number = 0;
  @State private offsetY: number = 20;

  aboutToAppear(): void {
    setTimeout(() => {
      animateTo({ duration: 850, curve: Curve.EaseOut }, () => {
        this.opacityValue = 1;
        this.offsetY = -90;
      });
    }, 10);
    setTimeout(() => {
      animateTo({ duration: 350, curve: Curve.EaseIn }, () => {
        this.opacityValue = 0;
      });
    }, 650);
  }

  build() {
    Text(this.text)
      .fontSize(18)
      .fontColor('#F5F5F5')
      .fontWeight(FontWeight.Medium)
      .opacity(this.opacityValue)
      .translate({ y: this.offsetY })
  }
}
