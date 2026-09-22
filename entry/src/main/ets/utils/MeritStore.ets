import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const STORE_NAME = 'muyu_prefs';
const KEY_MERIT = 'merit_count';
const KEY_DATE = 'merit_date';
const KEY_SOUND = 'sound_index';
const KEY_STYLE = 'muyu_style';

export class MeritStore {
  private static prefs: preferences.Preferences | null = null;

  private static today(): string {
    const d = new Date();
    const m = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${d.getFullYear()}-${m}-${day}`;
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    MeritStore.prefs = await preferences.getPreferences(context, STORE_NAME);
  }

  static async loadMerit(): Promise<number> {
    if (!MeritStore.prefs) {
      return 0;
    }
    const savedDate = await MeritStore.prefs.get(KEY_DATE, '') as string;
    const today = MeritStore.today();
    if (savedDate !== today) {
      await MeritStore.prefs.put(KEY_MERIT, 0);
      await MeritStore.prefs.put(KEY_DATE, today);
      await MeritStore.prefs.flush();
      return 0;
    }
    return await MeritStore.prefs.get(KEY_MERIT, 0) as number;
  }

  static async addMerit(delta: number): Promise<number> {
    if (!MeritStore.prefs) {
      return delta;
    }
    const today = MeritStore.today();
    const savedDate = await MeritStore.prefs.get(KEY_DATE, '') as string;
    let current = 0;
    if (savedDate === today) {
      current = await MeritStore.prefs.get(KEY_MERIT, 0) as number;
    }
    const next = current + delta;
    await MeritStore.prefs.put(KEY_MERIT, next);
    await MeritStore.prefs.put(KEY_DATE, today);
    await MeritStore.prefs.flush();
    return next;
  }

  static async getSoundIndex(): Promise<number> {
    if (!MeritStore.prefs) {
      return 0;
    }
    return await MeritStore.prefs.get(KEY_SOUND, 0) as number;
  }

  static async setSoundIndex(index: number): Promise<void> {
    if (!MeritStore.prefs) {
      return;
    }
    await MeritStore.prefs.put(KEY_SOUND, index);
    await MeritStore.prefs.flush();
  }

  static async getStyleIndex(): Promise<number> {
    if (!MeritStore.prefs) {
      return 0;
    }
    return await MeritStore.prefs.get(KEY_STYLE, 0) as number;
  }

  static async setStyleIndex(index: number): Promise<void> {
    if (!MeritStore.prefs) {
      return;
    }
    await MeritStore.prefs.put(KEY_STYLE, index);
    await MeritStore.prefs.flush();
  }
}
