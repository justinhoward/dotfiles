import { createHash } from 'node:crypto';

export const STYLE_ID = 'dotfiles-slack-terminal-css';
export const STYLE_OWNER = 'dotfiles/slack-terminal/v1';

export function isSlackClient(url) {
  try {
    const parsed = new URL(url);
    return parsed.protocol === 'https:' &&
      (parsed.hostname === 'app.slack.com' || parsed.hostname.endsWith('.slack.com')) &&
      /^\/(client|messages)(\/|$)/.test(parsed.pathname);
  } catch {
    return false;
  }
}

export function validateCSS(css) {
  if (!css.trim()) throw new Error('The stylesheet is empty.');
  if (Buffer.byteLength(css) > 512 * 1024) throw new Error('The stylesheet exceeds 512 KiB.');
  // Intentionally conservative: this loader needs no imported styles/assets.
  // Local CSS is trusted input, not a security sandbox for third-party themes.
  const code = css.replace(/\/\*[\s\S]*?\*\//g, '');
  if (/@import\b|url\s*\(/i.test(code)) {
    throw new Error('Imported styles and URL assets are not supported; use local fonts and inline CSS.');
  }
  return css;
}

export function cssHash(css) {
  return createHash('sha256').update(css).digest('hex');
}

export function debuggerURL(url, port) {
  const parsed = new URL(url);
  if (parsed.protocol !== 'ws:' || parsed.hostname !== '127.0.0.1' ||
      Number(parsed.port) !== port || !parsed.pathname.startsWith('/devtools/page/') ||
      parsed.username || parsed.password || parsed.search || parsed.hash) {
    throw new Error('Refusing an unexpected DevTools endpoint.');
  }
  return parsed.href;
}

// Fixed local JavaScript only creates/removes our style element. CSS is passed
// as a JSON string, never evaluated as JavaScript. Don't read message content,
// credentials, cookies, storage, screenshots, channel titles or workspace IDs.
export function styleExpression(css, enabled) {
  return `(() => {
    const id = ${JSON.stringify(STYLE_ID)};
    const owner = ${JSON.stringify(STYLE_OWNER)};
    let style = document.getElementById(id);
    if (style && (style.tagName !== 'STYLE' || style.dataset.slackTerminal !== owner)) {
      return { conflict: true, applied: false };
    }
    const permitted = ${isSlackClient.toString()}(location.href);
    if (!permitted) {
      if (style) style.remove();
      return { applied: false };
    }
    if (${JSON.stringify(enabled)}) {
      if (!style) {
        style = document.createElement('style');
        style.id = id;
        style.dataset.slackTerminal = owner;
        (document.head || document.documentElement).appendChild(style);
      }
      style.textContent = ${JSON.stringify(css)};
      if (!style.sheet) return { blocked: true, applied: false };
    } else if (style) {
      style.remove();
    }
    const computed = getComputedStyle(document.body || document.documentElement);
    return {
      applied: ${JSON.stringify(enabled)},
      background: computed.backgroundColor,
      foreground: computed.color,
      font: computed.fontFamily,
      size: computed.fontSize
    };
  })()`;
}

export class CDPClient {
  constructor(url, { socketFactory = address => new WebSocket(address), timeout = 5000 } = {}) {
    this.socket = socketFactory(url);
    this.timeout = timeout;
    this.pending = new Map();
    this.sequence = 0;
    this.closed = false;
    this.dirty = true;
    this.applied = false;
    this.sample = null;
    this.hash = null;
    this.ready = new Promise((resolve, reject) => {
      const timer = setTimeout(() => { reject(new Error('DevTools connection timed out.')); this.close(); }, timeout);
      this.socket.addEventListener('open', () => { clearTimeout(timer); resolve(); }, { once: true });
      this.socket.addEventListener('error', () => { clearTimeout(timer); reject(new Error('DevTools connection failed.')); }, { once: true });
      this.socket.addEventListener('close', () => { clearTimeout(timer); reject(new Error('DevTools connection closed.')); }, { once: true });
    });
    // Consumers attach immediately, but keep failed handshakes from becoming
    // unhandled rejections when a renderer disappears during discovery.
    this.ready.catch(() => {});
    this.socket.addEventListener('message', event => {
      if (typeof event.data !== 'string') return;
      let message;
      try { message = JSON.parse(event.data); } catch { return; }
      if (message.id) {
        const pending = this.pending.get(message.id);
        if (!pending) return;
        clearTimeout(pending.timer);
        this.pending.delete(message.id);
        if (message.error) pending.reject(new Error(`DevTools rejected ${pending.method}.`));
        else pending.resolve(message.result || {});
      } else if (['Page.frameNavigated', 'Page.domContentEventFired', 'Page.frameStartedLoading'].includes(message.method)) {
        this.dirty = true;
      }
    });
    this.socket.addEventListener('close', () => this.finish());
    this.socket.addEventListener('error', () => this.finish());
  }

  finish() {
    this.closed = true;
    for (const pending of this.pending.values()) {
      clearTimeout(pending.timer);
      pending.reject(new Error('DevTools connection closed.'));
    }
    this.pending.clear();
  }

  close() {
    this.finish();
    try { this.socket.close(); } catch { /* Renderer already gone. */ }
  }

  async request(method, params = {}) {
    await this.ready;
    if (this.closed) throw new Error('DevTools connection closed.');
    const id = ++this.sequence;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`DevTools request timed out: ${method}.`));
      }, this.timeout);
      this.pending.set(id, { resolve, reject, timer, method });
      try { this.socket.send(JSON.stringify({ id, method, params })); }
      catch { clearTimeout(timer); this.pending.delete(id); reject(new Error('DevTools send failed.')); }
    });
  }

  async initialize() {
    // Page events suffice for reload recovery. Don't enable Runtime events,
    // which would also stream Slack's console output into this process.
    await this.request('Page.enable');
  }

  async apply(css, enabled) {
    const hash = enabled ? cssHash(css) : null;
    if (!this.dirty && this.hash === hash && this.applied === enabled) return;
    this.dirty = false;
    try {
      const response = await this.request('Runtime.evaluate', {
        expression: styleExpression(css, enabled), returnByValue: true,
      });
      if (response.exceptionDetails) throw new Error('Renderer rejected the stylesheet operation.');
      const result = response.result?.value;
      if (result?.conflict) throw new Error('A foreign element uses the theme ID; it was left untouched.');
      if (result?.blocked) throw new Error('Slack blocked inline styling; CSP will not be disabled.');
      if (!result || result.applied !== enabled) throw new Error('The Slack client is not ready for styling.');
      this.applied = enabled;
      this.hash = hash;
      this.sample = result;
    } catch (error) {
      this.dirty = true;
      throw error;
    }
  }
}

export async function discoverTargets(port, fetcher = fetch) {
  const response = await fetcher(`http://127.0.0.1:${port}/json/list`, { signal: AbortSignal.timeout(3000) });
  if (!response.ok) throw new Error('DevTools discovery failed.');
  const text = await response.text();
  if (Buffer.byteLength(text) > 1024 * 1024) throw new Error('DevTools discovery response is too large.');
  let targets;
  try { targets = JSON.parse(text); }
  catch { throw new Error('Unexpected DevTools discovery response.'); }
  if (!Array.isArray(targets)) throw new Error('Unexpected DevTools discovery response.');
  return targets.filter(target => target.type === 'page' && isSlackClient(target.url) && target.webSocketDebuggerUrl)
    .map(target => ({ id: target.id, websocket: debuggerURL(target.webSocketDebuggerUrl, port) }));
}
