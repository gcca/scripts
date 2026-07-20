;;; init.el -*- lexical-binding: t; indent-tabs-mode: nil; tab-width: 2; -*-

;;; Terminal compatibility

;;;; Ghostty focus reports

;; Ghostty advertises an xterm-compatible TERM, but Emacs 30.2 does not
;; alias it yet.  Without xterm's terminal init, focus reports can leak
;; literal "I"/"O" characters into buffers.
(dolist (term '(("xterm-ghostty" . "xterm")
                ("ghostty" . "xterm")))
  (add-to-list 'term-file-aliases term))

(defun gcca/setup-terminal-focus-report-decoding ()
  "Decode terminal focus reports before they reach normal keymaps."
  (unless (display-graphic-p)
    (require 'term/xterm)
    (define-key input-decode-map "\e[I" #'xterm-translate-focus-in)
    (define-key input-decode-map "\e[O" #'xterm-translate-focus-out)))

(gcca/setup-terminal-focus-report-decoding)
(add-hook 'tty-setup-hook #'gcca/setup-terminal-focus-report-decoding)

;;;; Terminal mouse

;; Terminal-only builds (no x-create-frame) never preload mwheel.el, so
;; mouse-wheel-mode's init-value of t does not install wheel-up/down
;; bindings.  xterm-mouse-mode remaps buttons 4/5 to those events, which
;; then appear unbound.  Require mwheel so scrolling works.
(defun gcca/enable-terminal-mouse ()
  "Enable mouse clicks and wheel scrolling in terminal frames."
  (unless (or noninteractive (display-graphic-p))
    (require 'mwheel)
    (mouse-wheel-mode 1)
    (xterm-mouse-mode 1)))

(gcca/enable-terminal-mouse)
(add-hook 'tty-setup-hook #'gcca/enable-terminal-mouse)

;;; Package management

;;;; straight.el

(setq straight-check-for-modifications '(check-on-save find-when-checking))
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t
      ;; Defer packages by default; use :demand on startup-critical ones.
      use-package-always-defer t)

;;; Terminal input

;;;; Kitty keyboard protocol

;; Kitty Keyboard Protocol: lets terminals like Ghostty report
;; unambiguous key events (e.g. C-S-z) instead of legacy control bytes.
(use-package kkp
  :demand t
  :init
  (global-kkp-mode 1))

;;; Core settings

;;;; Startup and defaults

(setq inhibit-startup-message t
      inhibit-startup-screen t
      ring-bell-function 'ignore
      create-lockfiles nil
      ;; LSP servers send large JSON; read in 1 MB chunks to reduce allocation churn
      read-process-output-max (* 1024 1024))

;;;; PATH (GUI Emacs does not load fish config.fish)

;; Bun installs to ~/.bun/bin; Homebrew tools to /opt/homebrew/bin.  Without
;; these, `executable-find' misses bun/bunx and JS/TS Eglot never starts.
(dolist (dir (list (expand-file-name "~/.bun/bin")
                   "/opt/homebrew/bin"
                   "/opt/homebrew/sbin"
                   "/usr/local/bin"))
  (when (file-directory-p dir)
    (add-to-list 'exec-path dir)
    (setenv "PATH" (concat dir path-separator (getenv "PATH")))))

;;;; macOS clipboard

(defun gcca/pbcopy (beg end)
  "Copy the selected region (BEG..END) to the macOS clipboard via pbcopy.
Uses a synchronous pipe so the whole block is written before returning."
  (interactive "r")
  (unless (use-region-p)
    (user-error "No active region to copy"))
  (let ((beg (region-beginning))
        (end (region-end)))
    ;; call-process-region waits until pbcopy exits; start-process +
    ;; process-send-region can return before stdin is fully consumed.
    (let ((status (call-process-region beg end "pbcopy" nil nil nil)))
      (unless (eq status 0)
        (error "pbcopy failed with status %s" status)))
    (message "Copied %d characters to clipboard" (- end beg))))

(defun gcca/pbpaste ()
  "Insert the macOS clipboard at point via pbpaste.
Reads clipboard synchronously.  With an active region and
`delete-selection-mode', the selection is replaced."
  (interactive "*")
  (let ((text
         (with-temp-buffer
           (let ((status (call-process "pbpaste" nil t nil)))
             (unless (eq status 0)
               (error "pbpaste failed with status %s" status))
             (buffer-string)))))
    (insert text)
    (message "Pasted %d characters from clipboard" (length text))))

;; Replace active region when pasting (same as yank under delete-selection-mode).
(put 'gcca/pbpaste 'delete-selection t)

;;;; Buffer commands

(defun gcca/revert-all-buffers ()
  "Revert all unmodified file-visiting buffers."
  (interactive)
  (let ((reverted 0)
        (skipped 0))
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when buffer-file-name
          (if (and (file-exists-p buffer-file-name)
                   (not (buffer-modified-p)))
              (progn
                (revert-buffer t t t)
                (setq reverted (1+ reverted)))
            (setq skipped (1+ skipped))))))
    (message "Reverted %d buffer%s%s"
             reverted
             (if (= reverted 1) "" "s")
             (if (> skipped 0)
                 (format "; skipped %d modified/missing buffer%s"
                         skipped
                         (if (= skipped 1) "" "s"))
               ""))))

;;;; Files and backups

(let ((backup-dir (expand-file-name "backup" user-emacs-directory)))
  (make-directory backup-dir t)
  (setq backup-directory-alist         `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,backup-dir t))
        backup-by-copying t
        version-control t
        delete-old-versions t
        kept-new-versions 6
        kept-old-versions 2
        auto-save-default t))

;;;; Shell

;; Prefer fish for interactive and non-interactive shell executions
;; (M-x shell, compile, M-!, M-&, etc.) and any child that reads $SHELL.
(let ((fish (or (executable-find "fish") "/opt/homebrew/bin/fish")))
  (setq shell-file-name fish
        explicit-shell-file-name fish
        shell-command-switch "-c")
  (setenv "SHELL" fish))

;; Stream process output into Emacs as it arrives:
;; - PTY so children line-buffer (pipes often fully buffer)
;; - disable adaptive read buffering (Emacs otherwise coalesces small chunks)
(setq process-connection-type t
      process-adaptive-read-buffering nil)

;;;; Undo history

;; Persistent undo history, like Vim's undofile.
(use-package undo-fu
  :demand t
  :bind (("C-z" . undo-fu-only-undo)
         ("C-S-z" . undo-fu-only-redo)))

(use-package undo-fu-session
  :demand t
  :after undo-fu
  :config
  (setq undo-fu-session-directory
        (expand-file-name "undo" user-emacs-directory))
  (make-directory undo-fu-session-directory t)
  (undo-fu-session-global-mode))

;;;; Display and history

;; (defun gcca/add-line-number-gap ()
;;   (when display-line-numbers-mode
;;     (setq-local line-prefix "    "
;;                 wrap-prefix "    ")))
;; (add-hook 'display-line-numbers-mode-hook #'gcca/add-line-number-gap)

(setq display-line-numbers-width 4
      display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(show-paren-mode 1)
;; Typing replaces the active region (needed for multi-cursor rename flows).
(delete-selection-mode 1)
;; (electric-pair-mode 1)
(recentf-mode 1)
(setq recentf-exclude '("/straight/repos/" "/backup/" "/undo/"))
(savehist-mode 1)
(save-place-mode 1)
(setq history-length 100
      history-delete-duplicates t)
(setq require-final-newline t)
(setq-default indent-tabs-mode nil
              tab-width 2
              standard-indent 2)

;;;; Whitespace

;; Buffer-local so Markdown/Org and similar stay untouched.
(defun gcca/enable-whitespace-cleanup ()
  "Remove trailing whitespace before saving the current buffer."
  (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

(add-hook 'prog-mode-hook #'gcca/enable-whitespace-cleanup)
(add-hook 'conf-mode-hook #'gcca/enable-whitespace-cleanup)
(setq vc-follow-symlinks t)

;;; Build and compilation

(defvar gcca/compile-directory
  (file-name-as-directory
   (expand-file-name command-line-default-directory))
  "Directory used as `default-directory' for `compile' and `recompile'.")

(defun gcca/compile-in-project (orig-fun command &optional _comint)
  "Run `compile' under `gcca/compile-directory' with a comint buffer.
Comint + PTY makes output show while the process runs (fish-friendly)."
  (let ((default-directory gcca/compile-directory)
        (compilation-directory gcca/compile-directory))
    ;; Second arg t => comint mode + compilation-shell-minor-mode.
    (funcall orig-fun command t)))

(defun gcca/recompile-in-project (orig-fun &rest args)
  "Run `recompile' under `gcca/compile-directory'."
  (let ((default-directory gcca/compile-directory)
        (compilation-directory gcca/compile-directory))
    (apply orig-fun args)))

(with-eval-after-load 'compile
  (advice-add 'compile :around #'gcca/compile-in-project)
  (advice-add 'recompile :around #'gcca/recompile-in-project)
  (setq compilation-scroll-output t))

;; Keep compilation / shell windows scrolling as chunks arrive.
(setq comint-scroll-to-bottom-on-output t
      comint-move-point-for-output t
      comint-scroll-show-maximum-output t)

(defun gcca/shell-command-in-project (command &optional output-buffer error-buffer)
  "Like `shell-command', but run under the session project root.
Uses the project containing `gcca/compile-directory' (Emacs startup
cwd), else that directory.  Leaves the buffer's `default-directory'
unchanged."
  (interactive
   (list (read-shell-command "Shell command: ")
         current-prefix-arg
         shell-command-default-error-buffer))
  ;; project.el is deferred (use-package-always-defer); load before project-*.
  (require 'project)
  (let* ((base gcca/compile-directory)
         (proj (project-current nil base))
         (default-directory
          (file-name-as-directory
           (if proj (project-root proj) base))))
    (shell-command command output-buffer error-buffer)))

;;; Global keybindings

;;;; Execution

(global-set-key (kbd "<f6>") #'recompile)
;; C-` is free in vanilla Emacs and unused elsewhere in this config.
(global-set-key (kbd "C-`") #'gcca/shell-command-in-project)

;;;; Completion

(global-set-key (kbd "M-TAB") #'completion-at-point)
(global-set-key (kbd "C-M-i") #'completion-at-point)

;;;; Movement

(global-set-key (kbd "C-M-]") #'forward-sexp)
(global-set-key (kbd "C-M-[") #'backward-sexp)

;; Directional window focus: S-<left/down/up/right>.
;; Shift keeps plain arrows free for point motion.
;; Disable shift-select so Shift+arrows do not start/extend the region
;; (Emacs default shift-select-mode is t) and conflict with windmove.
(setq shift-select-mode nil)
(windmove-default-keybindings 'shift)
(setq windmove-wrap-around t)

;;;; File navigation

(global-set-key (kbd "C-c o") #'ff-find-other-file)

(defun gcca/save-buffer-no-fmt ()
  "Save current buffer without running `before-save-hook' (no fmt/cleanup)."
  (interactive)
  (let ((before-save-hook nil))
    (save-buffer)))

(global-set-key (kbd "C-x C-S-s") #'gcca/save-buffer-no-fmt)

;;; Editing

;;;; Multiple cursors

;; https://github.com/magnars/multiple-cursors.el
;; Exit multi-cursor mode with RET or C-g; insert newlines with C-j.
(use-package multiple-cursors
  :bind (;; ABC: `>` / `<` are S-. / S-,. With Ghostty+KKP, Shift is
         ;; reported, so bind C-S-. / C-S-, (not C-. / C-,).
         ("C-S-." . mc/mark-next-like-this)
         ("C-S-," . mc/mark-previous-like-this)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-S-." . mc/mark-all-like-this)
         ("C-c C-S-," . mc/mark-all-like-this)
         ("C-c C->" . mc/mark-all-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-c C-S-c" . mc/edit-lines)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click))
  :init
  ;; Remember run-once / run-for-all choices outside the package defaults.
  (setq mc/list-file (expand-file-name "mc-lists.el" user-emacs-directory)))

;;;; Avy

;; https://github.com/abo-abo/avy
;; Jump to visible text with a char-based decision tree (like easymotion).
;; M-g f / M-g g stay with consult; use M-g l for line jumps.
(use-package avy
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("C-c C-j" . avy-resume))
  :config
  ;; Bind avy-isearch to C-' in isearch-mode-map (pick among visible matches).
  (avy-setup-default))

;;; UI

;;;; Theme

(use-package doom-themes
  :demand t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
        doom-themes-padded-modeline t))
  ;; (load-theme 'doom-tokyo-night t)
  ;; (set-face-attribute 'line-number nil
  ;;                      :foreground "#3a3f5c"))

;;;; Tree-sitter

;; Prefer tree-sitter major modes and richer highlighting when grammars exist.
(setq treesit-font-lock-level 4)

(use-package treesit-auto
  :demand t
  :config
  (setq treesit-auto-install (if noninteractive nil 'prompt))
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;;; LSP

(defun gcca/eglot-ensure-if (&rest programs)
  "Start Eglot when any of PROGRAMS is on `exec-path'.
With no PROGRAMS, always call `eglot-ensure'."
  (when (or (null programs)
            (seq-some #'executable-find programs))
    (eglot-ensure)))

(defun gcca/eglot-ensure-clangd ()
  "Start Eglot for C/C++ when clangd or ccls is available."
  (gcca/eglot-ensure-if "clangd" "ccls"))

(defun gcca/eglot-ensure-python ()
  "Start Eglot for Python when a known language server is available."
  (gcca/eglot-ensure-if "pylsp" "pyls" "pyright" "pyright-langserver"
                        "jedi-language-server" "ruff" "ruff-lsp"))

(defun gcca/eglot-ensure-gopls ()
  "Start Eglot for Go when gopls is available."
  (gcca/eglot-ensure-if "gopls"))

(defun gcca/eglot-ensure-fish-lsp ()
  "Start Eglot for Fish when fish-lsp is available."
  (gcca/eglot-ensure-if "fish-lsp"))

(defun gcca/eglot-ensure-zls ()
  "Start Eglot for Zig when zls is available."
  (gcca/eglot-ensure-if "zls"))

(defun gcca/eglot-ensure-nimlsp ()
  "Start Eglot for Nim when nimlsp is available."
  (gcca/eglot-ensure-if "nimlsp"))

(defun gcca/eglot-ensure-cmake-ls ()
  "Start Eglot for CMake when cmake-language-server is available."
  (gcca/eglot-ensure-if "cmake-language-server"))

(defun gcca/eglot-ensure-yaml-ls ()
  "Start Eglot for YAML when yaml-language-server is available."
  (gcca/eglot-ensure-if "yaml-language-server"))

(defun gcca/eglot-ensure-typescript ()
  "Start Eglot for JS/TS when bun or typescript-language-server is available."
  (gcca/eglot-ensure-if "bun" "bunx" "typescript-language-server"))

(defun gcca/typescript-ls-contact (&optional interactive)
  "Eglot contact for JS/TS via project-local bin, then bunx, then PATH.

Prefer `node_modules/.bin/typescript-language-server' so the server matches
the project.  Falls back to `bunx typescript-language-server --stdio'.

Install in the project (required for go-to-definition on JSX/imports):
  bun add -d typescript typescript-language-server
  bun install"
  (let* ((root (cond
                ((and (fboundp 'project-current) (project-current))
                 (project-root (project-current)))
                (t default-directory)))
         (local (expand-file-name
                 "node_modules/.bin/typescript-language-server" root))
         (bunx (executable-find "bunx"))
         (tls (executable-find "typescript-language-server")))
    (cond
     ((file-executable-p local)
      (list local "--stdio"))
     (bunx
      (list bunx "typescript-language-server" "--stdio"))
     (tls
      (list tls "--stdio"))
     (interactive
      (user-error
       "No typescript-language-server.  In the project run:
  bun add -d typescript typescript-language-server && bun install"))
     (t
      ;; Non-interactive lookup: return a contact eglot will fail clearly on.
      (list "typescript-language-server" "--stdio")))))

(defvar gcca/c3-home (expand-file-name "~/.c3")
  "Root of the C3 toolchain install (c3c, c3fmt, c3lsp, stdlib).")

(defun gcca/c3-executable (name)
  "Return absolute path to C3 tool NAME under `gcca/c3-home', or NAME on PATH."
  (let ((local (expand-file-name name gcca/c3-home)))
    (cond
     ((file-executable-p local) local)
     ((executable-find name) (executable-find name))
     (t nil))))

(defun gcca/eglot-ensure-c3lsp ()
  "Start Eglot for C3 when c3lsp is available under `gcca/c3-home' or PATH."
  (when (gcca/c3-executable "c3lsp")
    (eglot-ensure)))

(defun gcca/c3lsp-contact (&optional _interactive)
  "Return the Eglot contact for c3lsp using `gcca/c3-home' for tools and stdlib.

c3lsp expects:
- `-c3c-path' to be the c3c *binary* (it runs `c3c --version')
- `-stdlib-path' to be the *lib* directory (it scans LIB/std for sources)

Without a correct stdlib path, completion may still work from a partial index
but Go to Definition/Declaration for stdlib symbols returns nothing."
  (let* ((c3lsp (or (gcca/c3-executable "c3lsp") "c3lsp"))
         (c3c (gcca/c3-executable "c3c"))
         ;; c3lsp does ScanForC3(filepath.Join(stdlib-path, "std"))
         (lib (expand-file-name "lib" gcca/c3-home))
         (args (list c3lsp)))
    (when c3c
      (setq args (append args (list "-c3c-path" c3c))))
    (when (file-directory-p (expand-file-name "std" lib))
      (setq args (append args (list "-stdlib-path" lib))))
    args))

(use-package eglot
  :straight nil
  :hook (((c-ts-mode c++-ts-mode) . gcca/eglot-ensure-clangd)
         (python-ts-mode . gcca/eglot-ensure-python)
         (go-ts-mode . gcca/eglot-ensure-gopls)
         ((js-ts-mode typescript-ts-mode tsx-ts-mode) . gcca/eglot-ensure-typescript))
  :config
  (setq eglot-autoshutdown t
        ;; Allow M-. into files outside the project (e.g. node_modules / deps).
        eglot-extend-to-xref t)
  ;; (set-face-attribute 'eglot-inlay-hint-face nil
  ;;                     :foreground "#34384c"
  ;;                     :background 'unspecified)
  (add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1)))
  (add-to-list 'eglot-server-programs
               '(cmake-ts-mode . ("cmake-language-server")))
  (add-to-list 'eglot-server-programs
               '(yaml-ts-mode . ("yaml-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(fish-mode . ("fish-lsp" "start")))
  (add-to-list 'eglot-server-programs
               '(nim-mode . ("nimlsp")))
  (add-to-list 'eglot-server-programs
               '(c3-ts-mode . gcca/c3lsp-contact))
  ;; Keep :language-id plists — bare mode symbols shadow eglot's defaults
  ;; and derive ids like "tsx"/"js", so tsserver won't resolve JSX tags (M-.).
  ;; Use typescriptreact for *.ts as well (Bun/Hono JSX often lives in .ts).
  (add-to-list 'eglot-server-programs
               `(((js-mode :language-id "javascript")
                  (js-ts-mode :language-id "javascriptreact")
                  (tsx-ts-mode :language-id "typescriptreact")
                  (typescript-ts-mode :language-id "typescriptreact")
                  (typescript-mode :language-id "typescriptreact"))
                 . gcca/typescript-ls-contact)))

;;; Languages

;;;; Fish

(defun gcca/fish-enable-format-on-save ()
  "Format Fish buffers before save when fish_indent is available."
  (when (executable-find "fish_indent")
    (add-hook 'before-save-hook #'fish_indent-before-save nil t)))

(use-package fish-mode
  :mode "\\.fish\\'"
  :interpreter "fish"
  :hook ((fish-mode . gcca/eglot-ensure-fish-lsp)
         (fish-mode . gcca/fish-enable-format-on-save))
  :config
  (setq fish-enable-auto-indent t))

;;;; Go

(use-package go-ts-mode
  :straight nil
  :mode "\\.go\\'")

;;;; JavaScript / TypeScript (Bun)

;; Prefer tsx/js tree-sitter modes for React/JSX (needed for eglot language ids).
;; Order matters: more specific extensions first.  Eglot still sends
;; language-id "typescriptreact" for typescript-ts-mode (*.ts), not only *.tsx.
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cjs\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))

(defun gcca/js-set-compile-command ()
  "Set `compile-command' for JS/TS buffers (Bun)."
  (setq-local compile-command "bun run test"))

(dolist (hook '(js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook))
  (add-hook hook #'gcca/js-set-compile-command))

;;;; Python

(use-package python
  :straight nil
  :mode ("\\.py[iw]?\\'" . python-ts-mode)
  :interpreter (("python" . python-ts-mode)
                ("python3" . python-ts-mode)))

;;;; Zig

(defun gcca/zig-set-compile-command ()
  "Set `compile-command' for Zig buffers."
  (setq-local compile-command "TERM=dumb zig build --color off test"))

(use-package zig-mode
  :mode "\\.zig\\'"
  :hook ((zig-mode . gcca/eglot-ensure-zls)
         (zig-mode . gcca/zig-set-compile-command)))

;;;; C3

(defun gcca/c3fmt-buffer-if-available ()
  "Format the current buffer with c3fmt when available.
c3fmt defaults to hard tabs and only accepts style via a config *file*
(`--config=PATH`); this command never writes config files.  After a
successful format, hard tabs are expanded to 2 spaces (Emacs soft tabs)."
  (when-let ((c3fmt (gcca/c3-executable "c3fmt")))
    (let ((out (generate-new-buffer " *c3fmt*")))
      (unwind-protect
          (let* ((path (or buffer-file-name default-directory))
                 (status (call-process-region
                          (point-min) (point-max)
                          c3fmt nil out nil
                          "--stdin"
                          "--stdout"
                          (concat "--stdin-filepath=" path))))
            (if (zerop status)
                (progn
                  (with-current-buffer out
                    ;; One tab from c3fmt = one indent level → two spaces.
                    (goto-char (point-min))
                    (while (search-forward "\t" nil t)
                      (replace-match "  " t t)))
                  (replace-buffer-contents out))
              (message "c3fmt failed (%s): %s"
                       status
                       (with-current-buffer out (buffer-string)))))
        (when (buffer-name out)
          (kill-buffer out))))))

(defun gcca/enable-c3fmt-on-save ()
  "Format C3 buffers with c3fmt before saving."
  (add-hook 'before-save-hook #'gcca/c3fmt-buffer-if-available nil t))

(defun gcca/c3-set-compile-command ()
  "Set `compile-command' for C3 buffers."
  (setq-local compile-command "c3c --ansi=no build"))

;; c3-ts-mode is not on MELPA; install from the upstream repo.  The
;; tree-sitter grammar is separate — run
;; `M-x treesit-install-language-grammar RET c3 RET' once (needs `cc').
(use-package c3-ts-mode
  :straight (:host github :repo "c3lang/c3-ts-mode")
  :mode "\\.c3[it]?\\'"
  :hook ((c3-ts-mode . gcca/eglot-ensure-c3lsp)
         (c3-ts-mode . gcca/enable-c3fmt-on-save)
         (c3-ts-mode . gcca/c3-set-compile-command))
  :init
  (add-to-list 'treesit-language-source-alist
               '(c3 "https://github.com/c3lang/tree-sitter-c3"))
  :config
  (setq c3-ts-mode-indent-offset 2))

;;;; Nim

(use-package nim-mode
  :mode (("\\.nim\\'" . nim-mode)
         ("\\.nims\\'" . nim-mode)
         ("\\.nimble\\'" . nim-mode))
  :hook (nim-mode . gcca/eglot-ensure-nimlsp))

;;;; SQL

;; Emacs 30 has no built-in `sql-ts-mode' (treesit-auto recipe is a no-op).
(use-package sql
  :straight nil
  :mode ("\\.sql\\'" . sql-mode)
  :hook (sql-mode . (lambda ()
                      (setq-local indent-tabs-mode nil
                                  tab-width 2))))

;;;; CMake

(use-package cmake-ts-mode
  :straight nil
  :mode (("CMakeLists\\.txt\\'" . cmake-ts-mode)
         ("\\.cmake\\'" . cmake-ts-mode))
  :hook (cmake-ts-mode . gcca/eglot-ensure-cmake-ls))

;;;; Ninja

(use-package ninja-mode
  :mode (("\\.ninja\\'" . ninja-mode)
         ("/build\\.ninja\\'" . ninja-mode)))

;;;; C and C++

(defun gcca/c++-in-raw-string-p ()
  "Return non-nil when point is inside a C++ raw string literal."
  (and (derived-mode-p 'c++-ts-mode)
       (let* ((syntax-state (syntax-ppss))
              (string-start (nth 8 syntax-state)))
         (and (nth 3 syntax-state)
              string-start
              (eq (char-before string-start) ?R)))))

(defun gcca/c++-raw-string-previous-indent ()
  "Return indentation of the previous nonblank line in the same raw string."
  (let* ((syntax-state (syntax-ppss))
         (string-start (nth 8 syntax-state)))
    (save-excursion
      (catch 'indent
        (forward-line -1)
        (while (> (point) string-start)
          (back-to-indentation)
          (when (and (not (eolp))
                     (nth 3 (syntax-ppss))
                     (eq (nth 8 (syntax-ppss)) string-start))
            (throw 'indent (current-indentation)))
          (forward-line -1))
        nil))))

(defun gcca/c++-indent-for-tab-command ()
  "Indent normally, but keep indentation inside C++ raw strings."
  (interactive)
  (if (gcca/c++-in-raw-string-p)
      (let ((indent (gcca/c++-raw-string-previous-indent)))
        (if indent
            (indent-line-to indent)
          (indent-to (* tab-width (1+ (/ (current-column) tab-width))))))
    (indent-for-tab-command)))

(defun gcca/c++-newline-and-indent ()
  "Insert newline, keeping indentation inside C++ raw strings."
  (interactive)
  (if (gcca/c++-in-raw-string-p)
      (let ((indent (current-indentation)))
        (newline)
        (indent-line-to indent))
    (newline)))

(defun gcca/c++-enable-raw-string-indentation ()
  "Let TAB insert indentation inside C++ raw string literals."
  (local-set-key (kbd "TAB") #'gcca/c++-indent-for-tab-command)
  (local-set-key (kbd "<tab>") #'gcca/c++-indent-for-tab-command)
  (local-set-key (kbd "RET") #'gcca/c++-newline-and-indent))

(defun gcca/clang-format-buffer-if-available ()
  "Format the current buffer with clang-format when available."
  (when (executable-find "clang-format")
    (clang-format-buffer)))

(defun gcca/enable-clang-format-on-save ()
  "Format C/C++ buffers before saving."
  (add-hook 'before-save-hook #'gcca/clang-format-buffer-if-available nil t))

(defun gcca/c-set-compile-command ()
  "Set `compile-command' for C/C++ buffers."
  (setq-local compile-command "cmake --build build -j 10"))

;; Prefer built-in tree-sitter modes over classic cc-mode.
;; `.h' still uses `c-or-c++-mode', which treesit-auto remaps to *-ts-mode.
(use-package c-ts-mode
  :straight nil
  :mode (("\\.c\\'" . c-ts-mode)
         ("\\.h\\'" . c-or-c++-mode)
         ("\\.cc\\'" . c++-ts-mode)
         ("\\.cpp\\'" . c++-ts-mode)
         ("\\.cxx\\'" . c++-ts-mode)
         ("\\.c\\+\\+\\'" . c++-ts-mode)
         ("\\.hh\\'" . c++-ts-mode)
         ("\\.hpp\\'" . c++-ts-mode)
         ("\\.hxx\\'" . c++-ts-mode)
         ("\\.h\\+\\+\\'" . c++-ts-mode)
         ("\\.ipp\\'" . c++-ts-mode)
         ("\\.tpp\\'" . c++-ts-mode)
         ("\\.inl\\'" . c++-ts-mode))
  :hook ((c++-ts-mode . gcca/c++-enable-raw-string-indentation)
         ((c-ts-mode c++-ts-mode) . gcca/enable-clang-format-on-save)
         ((c-ts-mode c++-ts-mode) . gcca/c-set-compile-command)))

(use-package clang-format
  :commands (clang-format-buffer clang-format-region)
  :config
  (setq clang-format-fallback-style "LLVM"))

;;;; YAML

(use-package yaml-ts-mode
  :straight nil
  :mode "\\.ya?ml\\'"
  :hook (yaml-ts-mode . gcca/eglot-ensure-yaml-ls))

;;;; Dockerfile

(use-package dockerfile-ts-mode
  :straight nil
  :mode (("/Dockerfile\\(?:\\..*\\)?\\'" . dockerfile-ts-mode)
         ("\\.dockerfile\\'" . dockerfile-ts-mode)))

;;;; Markdown

(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

;;;; Config files

(use-package conf-mode
  :straight nil
  :mode (("\\(?:\\.config/ghostty/config\\|ghostty-config\\)\\'" . conf-unix-mode)))

;;;; Protocol buffers

(use-package protobuf-mode
  :mode "\\.proto\\'")

;;;; Web

(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.csp\\'" . web-mode))
  :config
  (add-to-list 'web-mode-engines-alist '("erb" . "\\.csp\\'"))
  (setq web-mode-markup-indent-offset 2
        web-mode-code-indent-offset 2))

;;; Version control

(use-package diff-hl
  :demand t
  :init
  (global-diff-hl-mode)
  :config
  ;; Fringe indicators are invisible on TTY; use the margin instead.
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1)))

;;; Completion

;;;; Corfu

(use-package corfu
  :demand t
  :init (global-corfu-mode)
  :config
  (setq corfu-auto nil
        corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-popupinfo-mode 1)
  (corfu-history-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history))

;;;; Corfu terminal

(use-package popon
  :if (and (not (display-graphic-p)) (< emacs-major-version 31))
  :demand t
  :straight (:type git :repo "https://codeberg.org/akib/emacs-popon.git"))

(use-package corfu-terminal
  :if (and (not (display-graphic-p)) (< emacs-major-version 31))
  :demand t
  :straight (:type git :repo "https://codeberg.org/akib/emacs-corfu-terminal.git")
  :after corfu
  :config
  (corfu-terminal-mode 1))

;;;; Copilot

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :init
  (setq copilot-indent-offset-warning-disable t)
  :bind (:map copilot-completion-map
              ("<tab>" . copilot-accept-completion)
              ("TAB" . copilot-accept-completion)
              ("C-<tab>" . copilot-accept-completion-by-word)
              ("C-TAB" . copilot-accept-completion-by-word)
              ("M-n" . copilot-next-completion)
              ("M-p" . copilot-previous-completion)))

;;;; Cape

;; Cape: merge Eglot + dabbrev completions
(use-package cape
  :demand t
  :init
  (setq cape-dabbrev-check-other-buffers nil)
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local completion-at-point-functions
                          (list (cape-capf-super
                                 #'eglot-completion-at-point
                                 #'cape-dabbrev)
                                #'cape-file))))
  :config
  ;; Bust Eglot CAPF cache so completions stay fresh while typing.
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

;;; Minibuffer

;;;; Vertico

(use-package vertico
  :demand t
  :init (vertico-mode))

;;;; Orderless

(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion)))
        orderless-matching-styles
        '(orderless-literal orderless-regexp orderless-flex)))

;;;; Marginalia

(use-package marginalia
  :demand t
  :init (marginalia-mode))

;;;; Consult

(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x p b" . consult-project-buffer)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-g f" . consult-flymake)
         ("M-s l" . consult-line)
         ("M-s r" . consult-ripgrep)
         ("M-s g" . consult-grep))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (setq consult-narrow-key "<"
        consult-preview-key '(:debounce 0.2 any)))

;;; Projects

(use-package project
  :straight nil
  :bind-keymap ("C-c p" . project-prefix-map))

;;; Git

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c g" . magit-file-dispatch))
  :config
  (defun gcca/git-commit-default-message ()
    "Pre-fill empty commit buffer with timestamp `date +%Y%m%d%H%M%S'.
Does not auto-commit; opens the normal Magit COMMIT_EDITMSG buffer so the
message can be edited, then confirmed with C-c C-c.

`git-commit-setup' clears `buffer-modified-p' after this hook.  If we only
insert into the buffer, a bare C-c C-c (no further typing) makes
`with-editor-finish' skip writing the file, so Git still sees its empty
template and aborts with \"empty commit message\".  Write the file so the
default message is on disk even when the buffer looks unmodified."
    (save-excursion
      (goto-char (point-min))
      (let ((msg-end (save-excursion
                       (if (re-search-forward "^#" nil t)
                           (match-beginning 0)
                         (point-max)))))
        (when (string-match-p "\\`[[:space:]]*\\'"
                              (buffer-substring-no-properties (point-min) msg-end))
          (goto-char (point-min))
          (insert (format-time-string "%Y%m%d%H%M%S") "\n")
          (when buffer-file-name
            (write-region nil nil buffer-file-name nil 'silent))))))
  (add-hook 'git-commit-setup-hook #'gcca/git-commit-default-message))

;;; Help

(use-package which-key
  :straight nil
  :demand t
  :init (which-key-mode))

;;; Diagnostics

(use-package sideline
  :hook (flymake-mode . sideline-mode)
  :init
  (setq sideline-backends-right '(sideline-flymake)
        sideline-delay 0.2))

(use-package sideline-flymake
  :after sideline)

;;; Startup finalize

;; Restore GC settings raised in early-init.el once idle after startup.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;;; Custom output

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(doom-tokyo-night))
 '(custom-safe-themes t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
