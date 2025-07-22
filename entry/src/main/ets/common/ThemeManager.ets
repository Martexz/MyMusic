// src/common/ThemeManager.ts

export type ThemeMode = 'light' | 'dark' | 'auto';
type Listener = (mode: ThemeMode) => void;

class ThemeManager {
  private static instance: ThemeManager | null = null;
  private _themeMode: ThemeMode = 'light';
  private listeners: Listener[] = [];

  private constructor() {}

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  get themeMode(): ThemeMode {
    return this._themeMode;
  }

  set themeMode(mode: ThemeMode) {
    if (this._themeMode !== mode) {
      this._themeMode = mode;
      this.emitChange(mode);
    }
  }

  on(listener: Listener): void {
    this.listeners.push(listener);
  }

  off(listener: Listener): void {
    this.listeners = this.listeners.filter(l => l !== listener);
  }

  private emitChange(mode: ThemeMode): void {
    this.listeners.forEach(listener => {
      try {
        listener(mode);
      } catch (e) {
        console.error('ThemeManager listener error:', e);
      }
    });
  }
}

export default ThemeManager.getInstance();
