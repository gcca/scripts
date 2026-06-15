;; --- 1. Straight.el (modern package manager) ---
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
(setq straight-use-package-by-default t)

;; --- 2. Basics ---
(setq inhibit-startup-message t
      inhibit-startup-screen t
      ring-bell-function 'ignore
      create-lockfiles nil
      ;; LSP servers send large JSON; read in 1 MB chunks to reduce allocation churn
      read-process-output-max (* 1024 1024))

(let ((tmp-dir (expand-file-name "wks" user-emacs-directory)))
  (make-directory tmp-dir t)
  (setq backup-directory-alist         `(("." . ,tmp-dir))
        auto-save-file-name-transforms `((".*" ,tmp-dir t))))

(global-display-line-numbers-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(setq history-length 100
      history-delete-duplicates t)
(setq vc-follow-symlinks t)

;; --- 3. UI chrome ---
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(xterm-mouse-mode 1)
(when (fboundp 'mouse-wheel-mode)
  (mouse-wheel-mode 1))
(setq mouse-wheel-scroll-amount '(3
                                  ((shift) . hscroll)
                                  ((control) . text-scale))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse t)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; --- 5. Theme ---
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-solarized-dark t))

;; --- 6. Tree-sitter ---
(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

(setq major-mode-remap-alist
      '((c-mode      . c-ts-mode)
        (c++-mode    . c++-ts-mode)
        (python-mode . python-ts-mode)
        (go-mode     . go-ts-mode)))

;; --- 7. Eglot (LSP) ---
(use-package eglot
  :hook ((c-ts-mode c++-ts-mode python-ts-mode go-ts-mode zig-mode)
         . eglot-ensure)
  :config
  (setq eglot-autoshutdown t
        eglot-events-buffer-size 0)
  (add-to-list 'eglot-server-programs
               '(fish-mode . ("fish-lsp" "start"))))

;; --- 8. Language support ---
(defun my/fish-eglot-ensure ()
  "Start Eglot for Fish when fish-lsp is available."
  (when (executable-find "fish-lsp")
    (eglot-ensure)))

(defun my/fish-enable-format-on-save ()
  "Format Fish buffers before save when fish_indent is available."
  (when (executable-find "fish_indent")
    (add-hook 'before-save-hook #'fish_indent-before-save nil t)))

(use-package fish-mode
  :mode "\\.fish\\'"
  :interpreter "fish"
  :hook ((fish-mode . my/fish-eglot-ensure)
         (fish-mode . my/fish-enable-format-on-save))
  :config
  (setq fish-enable-auto-indent t))

(use-package zig-mode
  :mode "\\.zig\\'")

;; --- 9. Version control ---
(use-package diff-hl
  :straight (:host github :repo "dgutov/diff-hl")
  :init
  (global-diff-hl-mode)
  :hook
  (dired-mode . diff-hl-dired-mode))

;; --- 10. Corfu (completion popup) ---
(use-package corfu
  :init (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.08
        corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-popupinfo-mode 1))

;; Cape: merge Eglot + dabbrev completions
(use-package cape
  :init
  (setq cape-dabbrev-check-other-buffers nil)
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (setq-local completion-at-point-functions
                          (list (cape-capf-super
                                 #'eglot-completion-at-point
                                 #'cape-dabbrev)
                                #'cape-file)))))

;; --- 11. Minibuffer: Vertico + Orderless + Marginalia ---
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion)))
        orderless-matching-styles
        '(orderless-literal orderless-regexp orderless-flex)))

(use-package marginalia
  :init (marginalia-mode))

;; --- 12. Project management ---
(use-package projectile
  :init (projectile-mode +1)
  :bind-keymap ("C-c p" . projectile-command-map))

;; --- 13. Which-key ---
(use-package which-key
  :init (which-key-mode))
