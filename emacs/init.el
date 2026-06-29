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

(defun my/add-line-number-gap ()
  (when display-line-numbers-mode
    (setq-local line-prefix "                "
                wrap-prefix "                ")))

(setq display-line-numbers-width 4)
(add-hook 'display-line-numbers-mode-hook #'my/add-line-number-gap)
(global-display-line-numbers-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(setq history-length 100
      history-delete-duplicates t)
(setq require-final-newline t)
(add-hook 'before-save-hook #'delete-trailing-whitespace)
(setq vc-follow-symlinks t)

(global-auto-revert-mode 1)
(setq auto-revert-verbose nil
      global-auto-revert-non-file-buffers t)

;; --- 3. UI chrome ---
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(xterm-mouse-mode 1)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; --- 5. Theme ---
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-tokyo-night t))

;; --- 6. Tree-sitter ---
(use-package treesit-auto
  :config
  (setq treesit-auto-install (if noninteractive nil 'prompt))
  (global-treesit-auto-mode))

;; --- 7. Eglot (LSP) ---
(use-package eglot
  :hook ((c-mode c-ts-mode c++-mode c++-ts-mode python-mode python-ts-mode go-mode go-ts-mode zig-mode)
         . eglot-ensure)
  :config
  (setq eglot-autoshutdown t
        eglot-events-buffer-config '(:size 0 :format full))
  (add-to-list 'eglot-server-programs
               '((cmake-mode cmake-ts-mode) . ("cmake-language-server")))
  (add-to-list 'eglot-server-programs
               '((yaml-mode yaml-ts-mode) . ("yaml-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(fish-mode . ("fish-lsp" "start"))))

;; --- 8. Language support ---
(defun my/cmake-eglot-ensure ()
  "Start Eglot for CMake when cmake-language-server is available."
  (when (executable-find "cmake-language-server")
    (eglot-ensure)))

(defun my/fish-eglot-ensure ()
  "Start Eglot for Fish when fish-lsp is available."
  (when (executable-find "fish-lsp")
    (eglot-ensure)))

(defun my/yaml-eglot-ensure ()
  "Start Eglot for YAML when yaml-language-server is available."
  (when (executable-find "yaml-language-server")
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

(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode))
  :hook (cmake-mode . my/cmake-eglot-ensure))

(use-package cmake-ts-mode
  :straight nil
  :hook (cmake-ts-mode . my/cmake-eglot-ensure))

(use-package modern-cpp-font-lock
  :hook ((c++-mode c++-ts-mode) . modern-c++-font-lock-mode))

(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :hook (yaml-mode . my/yaml-eglot-ensure))

(use-package yaml-ts-mode
  :straight nil
  :hook (yaml-ts-mode . my/yaml-eglot-ensure))

(use-package dockerfile-mode
  :mode (("/Dockerfile\\(?:\\..*\\)?\\'" . dockerfile-mode)
         ("\\.dockerfile\\'" . dockerfile-mode)))

(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(use-package conf-mode
  :straight nil
  :mode (("/\\.config/ghostty/config\\'" . conf-unix-mode)))

(use-package protobuf-mode
  :mode "\\.proto\\'")

(use-package web-mode
  :mode "\\.csp\\'"
  :config
  (add-to-list 'web-mode-engines-alist '("erb" . "\\.csp\\'"))
  (setq web-mode-markup-indent-offset 2
        web-mode-code-indent-offset 2))

;; --- 9. Version control ---
(use-package diff-hl
  :straight (:host github :repo "dgutov/diff-hl")
  :init
  (global-diff-hl-mode)
  :hook
  (dired-mode . diff-hl-dired-mode))

;; --- 10. Completion: Corfu + Copilot + Cape ---
(use-package corfu
  :init (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.25
        corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-popupinfo-mode 1))

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :init
  (setq copilot-indent-offset-warning-disable t)
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . copilot-accept-completion)
              ("TAB" . copilot-accept-completion)
              ("C-<tab>" . copilot-accept-completion-by-word)
              ("C-TAB" . copilot-accept-completion-by-word)
              ("M-n" . copilot-next-completion)
              ("M-p" . copilot-previous-completion)))

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

;; --- 14. Inline diagnostics ---
(use-package sideline
  :hook (flymake-mode . sideline-mode)
  :init
  (setq sideline-backends-right '(sideline-flymake)
        sideline-delay 0.2))

(use-package sideline-flymake
  :after sideline)

;; -------------------------------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("d97ac0baa0b67be4f7523795621ea5096939a47e8b46378f79e78846e0e4ad3d"
     "21d2bf8d4d1df4859ff94422b5e41f6f2eeff14dd12f01428fa3cb4cb50ea0fb"
     "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d"
     "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098"
     "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19"
     default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
