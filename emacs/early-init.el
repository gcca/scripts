;;; early-init.el -*- lexical-binding: t; -*-

;; Defer package.el; this config uses straight.el.
(setq package-enable-at-startup nil)

;; Raise GC threshold during startup; restored on emacs-startup-hook in init.el.
(setq gc-cons-threshold (* 64 1024 1024)
      gc-cons-percentage 0.6)

;; UI chrome as early as possible (avoids a flash of menu/tool/scroll bars).
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
