;;; early-init.el --- Pre-frame optimisations -*- lexical-binding: t; -*-
;;
;; Emacs 30+ loads this before init.el and the first frame.

;;; ── Startup performance ─────────────────────────────────────────────
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(setq native-comp-async-report-warnings-errors 'silent)
(setq load-prefer-newer t)

;;; ── Prevent package.el from loading before init.el ──────────────────
(setq package-enable-at-startup nil)

;;; ── Suppress frame resize churn ─────────────────────────────────────
(setq frame-inhibit-implied-resize t)

;;; ── Kill chrome before the first frame draws ────────────────────────
(setq default-frame-alist
      '((menu-bar-lines        . 0)
        (tool-bar-lines        . 0)
        (vertical-scroll-bars  . nil)
        (horizontal-scroll-bars . nil)
        (internal-border-width . 8)))

(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name)

;;; early-init.el ends here
