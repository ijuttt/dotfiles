# ============================================================================
# QUTEBROWSER CONFIGURATION
# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html
# ============================================================================

# ============================================================================
# INITIAL SETUP
# ============================================================================
config.load_autoconfig(False)
config.source('themes/warm-brown.py')

# ============================================================================
# GENERAL SETTINGS
# ============================================================================

c.content.blocking.enabled = True
c.content.blocking.method = 'both'
# Auto-save
c.auto_save.interval = 60000

# Editor
c.editor.command = ['kitty', 'nvim', '{file}']

# Scrolling
c.scrolling.smooth = False

# ============================================================================
# TABS
# ============================================================================

c.tabs.position = 'left'
c.tabs.show = 'multiple'
c.tabs.width = 140
c.tabs.wrap = False
c.tabs.indicator.padding = {'bottom': 2, 'left': 0, 'right': 4, 'top': 2}
c.tabs.indicator.width = 0
c.tabs.padding = {'bottom': 3, 'left': 5, 'right': 5, 'top': 3}

# ============================================================================
# STATUSBAR
# ============================================================================

c.statusbar.show = 'always'
c.statusbar.padding = {'bottom': 5, 'left': 10, 'right': 10, 'top': 5}
c.statusbar.widgets = ['keypress', 'search_match', 'url', 'progress']

# ============================================================================
# COLORS
# ============================================================================
# Dark mode
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'smart'

# ============================================================================
# FONTS
# ============================================================================

c.fonts.web.size.default = 18
c.fonts.web.size.default_fixed = 15

# ============================================================================
# HINTS
# ============================================================================

c.hints.chars = 'kwxuiopemrjql'

# ============================================================================
# DOWNLOADS
# ============================================================================

c.downloads.location.remember = False
c.downloads.position = 'bottom'

# ============================================================================
# URL & SEARCH ENGINES
# ============================================================================

c.url.default_page = 'https://start.duckduckgo.com/'
c.url.start_pages = 'https://start.duckduckgo.com'

c.url.searchengines = {
    'DEFAULT': 'https://www.duckduckgo.com/?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'gh': 'https://github.com/search?q={}',
    'reddit': 'https://www.reddit.com/search?q={}',
    'gm': 'https://www.google.com/maps/search/{}'
}

# ============================================================================
# CONTENT SETTINGS
# ============================================================================

c.content.dns_prefetch = True

# Cookies
config.set('content.cookies.accept', 'all', 'chrome-devtools://*')
config.set('content.cookies.accept', 'all', 'devtools://*')

# Images
config.set('content.images', True, 'chrome-devtools://*')
config.set('content.images', True, 'devtools://*')

# JavaScript
config.set('content.javascript.enabled', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'devtools://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')

# JavaScript clipboard access per domain
config.set('content.javascript.clipboard', 'access-paste', 'https://chat.deepseek.com')
config.set('content.javascript.clipboard', 'access-paste', 'https://chatgpt.com')
config.set('content.javascript.clipboard', 'access-paste', 'https://claude.ai')
config.set('content.javascript.clipboard', 'access-paste', 'https://gemini.google.com')
config.set('content.javascript.clipboard', 'access-paste', 'https://github.com')
config.set('content.javascript.clipboard', 'access-paste', 'https://grok.com')

# Media
config.set('content.media.audio_capture', True, 'https://chatgpt.com')

# Notifications
config.set('content.notifications.enabled', True, 'https://web.whatsapp.com')

# Local content access
config.set('content.local_content_can_access_remote_urls', True, 'file:///home/jegesmk/.local/share/qutebrowser/userscripts/*')
config.set('content.local_content_can_access_file_urls', False, 'file:///home/jegesmk/.local/share/qutebrowser/userscripts/*')

# Headers
config.set('content.headers.accept_language', '', 'https://matchmaker.krunker.io/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:145.0) Gecko/20100101 Firefox/145.0', 'https://accounts.google.com/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {qt_key}/{qt_version} {upstream_browser_key}/{upstream_browser_version_short} Safari/{webkit_version}', 'https://gitlab.gnome.org/*')

# ============================================================================
# QT/CHROMIUM SETTINGS
# ============================================================================

c.qt.chromium.low_end_device_mode = 'always'
c.qt.chromium.process_model = 'process-per-site-instance'
c.session.lazy_restore = True

c.qt.args = [
    "ignore-gpu-blocklist",
    "enable-gpu-rasterization",
    # "enable-zero-copy",
    # "disable-gpu-driver-bug-workarounds",
    # "enable-accelerated-video-encode",
]

# ============================================================================
# KEYBINDINGS - NORMAL MODE
# ============================================================================
# ciw - change inner word
config.bind('ciw', 'fake-key <Ctrl-Left><Ctrl-Shift-Right><Delete> ;; mode-enter insert', mode='normal')
# cw - change word
config.bind('cw', 'fake-key <Ctrl-Shift-Right><Delete> ;; mode-enter insert', mode='normal')
# diw - delete inner word
config.bind('diw', 'fake-key <Ctrl-Left><Ctrl-Shift-Right><Delete>', mode='normal')
# dw - delete word
config.bind('dw', 'fake-key <Ctrl-Shift-Right><Delete>', mode='normal')
# yiw - yank/copy inner word
config.bind('yiw', 'fake-key <Ctrl-Left><Ctrl-Shift-Right><Ctrl-c>', mode='normal')
# yw - yank word
config.bind('yw', 'fake-key <Ctrl-Shift-Right><Ctrl-c>', mode='normal')
config.bind('u', 'fake-key <Ctrl-z>', mode='normal')
config.bind('a', 'fake-key <Right> ;; mode-enter insert', mode='normal')

# Change/Delete/Yank line operations
config.bind('cc', 'fake-key <Home><Shift-End><Delete> ;; mode-enter insert', mode='normal')  # change line
config.bind('dd', 'fake-key <Home><Shift-End><Delete>', mode='normal')  # delete line
config.bind('yy', 'fake-key <Home><Shift-End><Ctrl-c>', mode='normal')  # yank line

# Change/Delete to end of line (capital letters)
config.bind('C', 'fake-key <Shift-End><Delete> ;; mode-enter insert', mode='normal')
config.bind('D', 'fake-key <Shift-End><Delete>', mode='normal')
config.bind('Y', 'fake-key <Shift-End><Ctrl-c>', mode='normal')  # yank to end (konsisten sama Vim)

# Redo (komplemen dari undo)
config.bind('<Ctrl-r>', 'fake-key <Ctrl-Shift-z>', mode='normal')  # redo text

# Visual selection word
config.bind('viw', 'fake-key <Ctrl-Left><Ctrl-Shift-Right>', mode='normal')

# -------------------- BASIC NAVIGATION (No prefix) --------------------
config.bind('j', 'scroll down')
config.bind('k', 'scroll up')
config.bind('h', 'scroll left')
config.bind('l', 'scroll right')
config.bind('gg', 'scroll-to-perc 0')
config.bind('G', 'scroll-to-perc')
config.bind('0', 'scroll-to-perc --horizontal 0')
config.bind('$', 'scroll-to-perc --horizontal')
config.bind('<Ctrl-d>', 'scroll-page 0 0.5')
config.bind('<Ctrl-u>', 'scroll-page 0 -0.5')
config.bind('<Ctrl-f>', 'scroll-page 0 1')
config.bind('<Ctrl-b>', 'scroll-page 0 -1')

# History
config.bind('H', 'back')
config.bind('L', 'forward')

# Tab navigation
config.bind('J', 'tab-next')
config.bind('K', 'tab-prev')

config.bind('gt1', 'tab-focus 1')
config.bind('gt2', 'tab-focus 2')
config.bind('gt3', 'tab-focus 3')
config.bind('gt4', 'tab-focus 4')
config.bind('gt5', 'tab-focus 5')
config.bind('gt6', 'tab-focus 6')
config.bind('gt7', 'tab-focus 7')
config.bind('gt8', 'tab-focus 8')
config.bind('gt9', 'tab-focus 9')

# -------------------- TAB OPERATIONS --------------------
config.bind('x', 'tab-close')
config.bind('U', 'undo')
config.bind('X', 'tab-only')

config.bind('>>', 'tab-move +')
config.bind('<<', 'tab-move -')

# -------------------- OPEN LAYER (o = current tab, O = new tab) --------------------
config.bind('o', 'cmd-set-text -s :open ')                    # open: prompt URL
config.bind('O', 'cmd-set-text -s :open -t ')                 # Open: new tab
config.bind('go', 'cmd-set-text :open {url:pretty}')          # go: edit current URL
config.bind('gO', 'cmd-set-text :open -t {url:pretty}')       # gO: edit URL in new tab

# -------------------- YANK LAYER (y prefix) --------------------
config.bind('yu', 'yank')                             # yank url
config.bind('yt', 'yank title')                       # yank title
config.bind('ym', 'yank inline [{title}]({url})')     # yank markdown
config.bind('yo', 'yank inline {url} --- {title}')    # yank org-mode
config.bind('yT', 'tab-clone')                        # Yank Tab = clone

# -------------------- PASTE LAYER (p = current, P = new tab) --------------------
config.bind('p', 'open -- {clipboard}')                        # paste: current tab
config.bind('P', 'open -t -- {clipboard}')                     # Paste: new tab

# -------------------- HINT LAYER (f/F = basic, ; = advanced) --------------------
# Basic hints (no prefix)
config.bind('f', 'hint all')                                   # follow hint (current tab)
config.bind('F', 'hint all tab-fg')                            # Follow hint (new tab, foreground)

# Advanced hints (; prefix)
config.bind(';f', 'hint links tab-bg')                         # ;follow (background tab)
config.bind(';i', 'hint inputs')                               # ;input
config.bind(';y', 'hint links yank')                           # ;yank
config.bind(';Y', 'hint links yank-primary')                   # ;Yank (primary)
config.bind(';d', 'hint links download')                       # ;download
config.bind(';m', 'hint images')                               # ;media (current)
config.bind(';M', 'hint images tab')                           # ;Media (new tab)
config.bind(';v', 'hint links spawn mpv {hint-url}')          # ;video (mpv)
config.bind(';w', 'hint links window')                         # ;window
config.bind(';r', 'hint --rapid links tab-bg')                # ;rapid (multiple)

# -------------------- VISUAL MODE --------------------
config.bind('v', 'mode-enter caret')
config.bind('V', 'mode-enter caret ;; selection-toggle --line')

# -------------------- SEARCH --------------------
config.bind('/', 'cmd-set-text /')
config.bind('?', 'cmd-set-text ?')
config.bind('n', 'search-next')
config.bind('N', 'search-prev')

# -------------------- VIEW & NAVIGATION --------------------
config.bind('gf', 'view-source')
config.bind('gi', 'hint inputs --first ;; mode-enter insert')
config.bind('gF', 'hint all tab')
config.bind('gI', 'devtools')
config.bind('gd', 'download')
config.bind('gs', 'open -t qute://settings')

# -------------------- RELOAD --------------------
config.bind('r', 'reload')
config.bind('R', 'reload -f')

# -------------------- COMMAND MODE --------------------
config.bind(':', 'cmd-set-text :')

# -------------------- ESCAPE --------------------
config.bind('<Escape>', 'clear-keychain ;; search ;; fullscreen --leave ;; jseval -q document.body.dispatchEvent(new MouseEvent("click", {bubbles: true, clientX: 0, clientY: 0}));')

# -------------------- LEADER KEY COMMANDS (,) --------------------
# Window operations (tab-give)
config.bind('w0', 'tab-give 0')
config.bind('w1', 'tab-give 1')
config.bind('w2', 'tab-give 2')
config.bind('w3', 'tab-give 3')
config.bind('wn', 'tab-give')
config.bind('wg', 'cmd-set-text -s :tab-give ')

# Hints actions
config.bind(',y', 'hint links yank')
config.bind(',Y', 'hint --rapid links yank')
config.bind(',D', 'hint links download')
config.bind(',r', 'hint --rapid links tab-bg')

# Downloads
config.bind(',dd', 'download')
config.bind(',dc', 'download-cancel')
config.bind(',dr', 'download-retry')
config.bind(',dl', 'open -t qute://downloads')

# Config
config.bind(',ce', 'config-edit')
config.bind(',cr', 'config-source')

# Other leader commands
config.bind(',s', 'config-cycle statusbar.show always never')
config.bind(',fs', 'fullscreen')
config.bind(',d', 'config-cycle colors.webpage.darkmode.enabled')
config.bind(',m', 'spawn --userscript view_in_mpv')
config.bind(',cm', 'clear-messages')

# ============================================================================
# KEYBINDINGS - COMMAND MODE
# ============================================================================

config.bind('<Escape>', 'mode-leave', mode='command')
config.bind('<Return>', 'command-accept', mode='command')

# ============================================================================
# KEYBINDINGS - HINT MODE
# ============================================================================

config.bind('f', 'mode-leave', mode='hint')

# ============================================================================
# KEYBINDINGS - INSERT MODE
# ============================================================================

config.bind('<Ctrl+a>', 'fake-key <Ctrl+a>', mode='insert')
config.bind('<Ctrl+e>', 'fake-key <End>', mode='insert')
config.bind('<Ctrl+i>', 'fake-key <Home>', mode='insert')
config.bind('<Ctrl+u>', 'fake-key <Shift-Home><Delete>', mode='insert')
config.bind('<Ctrl+v>', 'fake-key <Ctrl-v>', mode='insert')
config.bind('<Ctrl+w>', 'fake-key <Ctrl-Backspace>', mode='insert')
config.bind('<Escape>', 'mode-leave', mode='insert')
