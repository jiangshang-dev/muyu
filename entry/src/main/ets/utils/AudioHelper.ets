import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export const MUYU_SOUNDS: string[] = ['muyu1.mp3', 'muyu2.mp3', 'muyu3.mp3'];
export const MUYU_SOUND_NAMES: string[] = ['木鱼 · 一', '木鱼 · 二', '木鱼 · 三'];

export class SongItem {
  id: string = '';
  title: string = '';
  file: string = '';

  constructor(id: string, title: string, file: string) {
    this.id = id;
    this.title = title;
    this.file = file;
  }
}

export const BUDDHA_SONGS: SongItem[] = [
  new SongItem('xinjing', '心经', 'xinjing.m4a'),
  new SongItem('dabei', '大悲咒', 'song_dabei.m4a'),
  new SongItem('guanyin', '观世音菩萨在心中', 'song_guanyin.mp3'),
  new SongItem('lian', '愿做菩萨那朵莲', 'song_lian.mp3')
];

export class AudioHelper {
  private context: common.UIAbilityContext;
  private sfxPlayer: media.AVPlayer | null = null;
  private musicPlayer: media.AVPlayer | null = null;
  private currentMusicFile: string = '';
  private sfxToken: number = 0;

  onMusicState?: (playing: boolean, file: string) => void;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async playSfx(fileName: string): Promise<void> {
    const token = ++this.sfxToken;
    try {
      const old = this.sfxPlayer;
      this.sfxPlayer = null;
      if (old) {
        old.release().catch(() => {
        });
      }

      const player = await media.createAVPlayer();
      if (token !== this.sfxToken) {
        await player.release();
        return;
      }
      this.sfxPlayer = player;

      player.on('error', (_err: BusinessError) => {
      });

      player.on('stateChange', async (state: string) => {
        try {
          if (token !== this.sfxToken) {
            return;
          }
          if (state === 'initialized') {
            await player.prepare();
          } else if (state === 'prepared') {
            await player.play();
          } else if (state === 'completed') {
            await player.release();
            if (this.sfxPlayer === player) {
              this.sfxPlayer = null;
            }
          }
        } catch (_e) {
        }
      });

      const fd = await this.context.resourceManager.getRawFd(fileName);
      player.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length
      };
    } catch (_e) {
    }
  }

  async playMusic(fileName: string): Promise<void> {
    try {
      if (this.musicPlayer && this.currentMusicFile === fileName) {
        const state = this.musicPlayer.state;
        if (state === 'playing') {
          await this.musicPlayer.pause();
          this.onMusicState?.(false, fileName);
          return;
        }
        if (state === 'paused' || state === 'prepared') {
          await this.musicPlayer.play();
          this.onMusicState?.(true, fileName);
          return;
        }
      }

      await this.stopMusic();
      this.currentMusicFile = fileName;

      const player = await media.createAVPlayer();
      this.musicPlayer = player;

      player.on('error', (_err: BusinessError) => {
        this.onMusicState?.(false, fileName);
      });

      player.on('stateChange', async (state: string) => {
        try {
          if (this.musicPlayer !== player) {
            return;
          }
          if (state === 'initialized') {
            await player.prepare();
          } else if (state === 'prepared') {
            await player.play();
            this.onMusicState?.(true, fileName);
          } else if (state === 'completed') {
            this.onMusicState?.(false, fileName);
          } else if (state === 'playing') {
            this.onMusicState?.(true, fileName);
          } else if (state === 'paused') {
            this.onMusicState?.(false, fileName);
          }
        } catch (_e) {
        }
      });

      const fd = await this.context.resourceManager.getRawFd(fileName);
      player.fdSrc = {
        fd: fd.fd,
        offset: fd.offset,
        length: fd.length
      };
    } catch (_e) {
      this.onMusicState?.(false, fileName);
    }
  }

  async stopMusic(): Promise<void> {
    if (!this.musicPlayer) {
      this.currentMusicFile = '';
      return;
    }
    const player = this.musicPlayer;
    const file = this.currentMusicFile;
    this.musicPlayer = null;
    this.currentMusicFile = '';
    try {
      await player.stop();
    } catch (_e) {
    }
    try {
      await player.release();
    } catch (_e) {
    }
    this.onMusicState?.(false, file);
  }

  async release(): Promise<void> {
    this.sfxToken++;
    if (this.sfxPlayer) {
      try {
        await this.sfxPlayer.release();
      } catch (_e) {
      }
      this.sfxPlayer = null;
    }
    await this.stopMusic();
  }
}
