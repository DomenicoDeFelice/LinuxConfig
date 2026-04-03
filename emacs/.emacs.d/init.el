;;; init.el --- Dom's Config --- -*- lexical-binding: t; -*-
;;
;; Target: Emacs 30.x (native-comp, tree-sitter, eglot, which-key built-in)
;; Languages: C · C++ · Python · Rust · Go · Emacs Lisp
;;
;; ╔═══════════════════════════════════════════════════════════════════╗
;; ║  QUICK REFERENC E                                                 ║
;; ║                                                                   ║
;; ║  C-x p f → find file in project   M-s r   → ripgrep in project    ║
;; ║  C-x p b → project buffer switch  M-s l   → search lines          ║
;; ║  M-.     → jump to definition     M-,     → jump back             ║
;; ║  M-?     → find references        M-g i   → imenu (symbols)       ║
;; ║  C-x g   → magit-status           C-c e r → eglot rename          ║
;; ║  C-c l c → gptel chat             C-c l r → gptel rewrite         ║
;; ║  C-.     → embark-act             M-j     → avy jump              ║
;; ║  F5      → compile from root      S-F5    → recompile             ║
;; ╚═══════════════════════════════════════════════════════════════════╝

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 0. BOOTSTRAP
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu" . 10) ("nongnu" . 8) ("melpa" . 5))
      ;; Allow upgrading built-in packages (needed for transient, etc.)
      package-install-upgrade-built-in t)
(package-initialize)

;; Ensure package archive contents are available on first launch.
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer  t
      use-package-expand-minimally t)

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 1. SANE DEFAULTS
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; ── Restore sane GC after startup ────────────────────────────────────
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024)   ; 64 MB (generous for LSP)
                  gc-cons-percentage 0.1)
            (message "Emacs ready in %.2fs (%d GCs)."
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;; ── Custom file ──────────────────────────────────────────────────────
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file) (load custom-file nil t))

;; ── Directories ──────────────────────────────────────────────────────
(dolist (dir '("backups" "auto-save"))
  (make-directory (expand-file-name dir user-emacs-directory) t))

;; ── General behaviour ────────────────────────────────────────────────
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80
              truncate-lines t)

(setq read-process-output-max (* 4 1024 1024) ; 4 MB – LSP throughput
      sentence-end-double-space nil
      require-final-newline t
      uniquify-buffer-name-style 'forward
      create-lockfiles nil
      make-backup-files t
      backup-directory-alist
      `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-default t
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t))
      use-short-answers t
      confirm-kill-emacs 'y-or-n-p
      scroll-preserve-screen-position t
      help-window-select t
      enable-recursive-minibuffers t
      tab-always-indent 'complete           ; TAB completes when already indented
      ;; Case-insensitive completion everywhere.
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      ;; Use ripgrep for xref searches (M-? etc.)
      xref-search-program 'ripgrep
      ;; Compilation
      compilation-scroll-output 'first-error
      ;; Project detection: recognise Go modules, Cargo workspaces, etc.
      ;; even without a .git at the same level.
      project-vc-extra-root-markers
      '("go.mod" "Cargo.toml" "pyproject.toml"
        "compile_commands.json" "Makefile")
      ;; Ediff: side-by-side in the same frame.
      ediff-window-setup-function #'ediff-setup-windows-plain
      ediff-split-window-function #'split-window-horizontally)

;; ── UI modes ─────────────────────────────────────────────────────────
(blink-cursor-mode -1)
(pixel-scroll-precision-mode 1)
(column-number-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(setq show-paren-delay 0
      show-paren-context-when-offscreen 'overlay)
(global-subword-mode 1)                ; camelCase navigation (Go, C++, Rust)
(winner-mode 1)                        ; C-c left/right to undo window changes
(repeat-mode 1)                        ; after C-x o, just press o o o…
(minibuffer-depth-indicate-mode 1)

;; Line numbers and hl-line in prog buffers, not terminals.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'prog-mode-hook (lambda () (setq-local show-trailing-whitespace t)))
(dolist (hook '(eat-mode-hook vterm-mode-hook eshell-mode-hook
               shell-mode-hook term-mode-hook compilation-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode -1))))

;; ── Session / history ────────────────────────────────────────────────
(save-place-mode 1)
(savehist-mode 1)
(setq history-length 1000)
(recentf-mode 1)
(setq recentf-max-saved-items 500)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; ── Scrolling ────────────────────────────────────────────────────────
(setq scroll-conservatively 101
      scroll-margin 3
      mouse-wheel-scroll-amount '(3 ((shift) . hscroll))
      mouse-wheel-progressive-speed nil)

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 2. APPEARANCE
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; ── Theme (modus-themes ship with Emacs 30) ──────────────────────────
(use-package modus-themes
  :ensure t
  :demand t
  :config
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-org-blocks 'tinted-background)
  (load-theme 'modus-vivendi-tinted t))  ; M-x modus-themes-toggle for light

;; ── Font ─────────────────────────────────────────────────────────────
(when (display-graphic-p)
  (set-face-attribute 'default nil
                      :family "JetBrains Mono"
                      :height 120)
  (set-face-attribute 'variable-pitch nil
                      :family "Noto Sans"
                      :height 120))

;; ── Modeline ─────────────────────────────────────────────────────────
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-height 28
        doom-modeline-bar-width 4
        doom-modeline-project-detection 'project
        doom-modeline-buffer-encoding nil
        doom-modeline-vcs-max-length 20))

(use-package nerd-icons :demand t)

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 3. MINIBUFFER COMPLETION (Vertico + Orderless + Marginalia)
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(use-package vertico
  :demand t
  :config
  (vertico-mode 1)
  (setq vertico-cycle t
        vertico-count 15))

(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :demand t
  :config (marginalia-mode 1))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 4. SEARCH & NAVIGATION (Consult + Embark + Avy)
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(defun dom/consult-ripgrep-project ()
  "Run consult-ripgrep rooted at the current project."
  (interactive)
  (consult-ripgrep (if-let ((proj (project-current)))
                       (project-root proj)
                     default-directory)))

(use-package consult
  :bind (("C-x b"   . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("M-y"     . consult-yank-pop)
         ;; Search
         ("M-s r"   . dom/consult-ripgrep-project)  ; grep the whole project
         ("M-s f"   . consult-find)                  ; find file by name
         ("M-s l"   . consult-line)                  ; search lines in buffer
         ("M-s L"   . consult-line-multi)
         ("M-s k"   . consult-keep-lines)
         ;; Go-to
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)                 ; jump to symbol in buffer
         ("M-g I"   . consult-imenu-multi)
         ("M-g o"   . consult-outline)
         ("M-g e"   . consult-compile-error)
         ("M-g f"   . consult-flymake)
         ("M-g m"   . consult-mark)
         ;; Project
         ("C-x p b" . consult-project-buffer)
         ("C-x p r" . dom/consult-ripgrep-project)
         ;; Misc
         ("C-x r b" . consult-bookmark)
         ("M-#"     . consult-register-load)
         ("M-'"     . consult-register-store))
  :config
  (setq consult-ripgrep-args
        (concat "rg --null --line-buffered --color=never --max-columns=1000 "
                "--path-separator / --smart-case --no-heading --with-filename "
                "--line-number --search-zip --hidden --glob=!.git/"))
  (setq consult-narrow-key "<"
        consult-preview-key "M-."))

;; Embark – contextual actions on any completion candidate.
;; NOTE: We bind C-. (not M-.) to embark-act.  M-. stays as xref-find-definitions.
(use-package embark
  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)
         ("C-h B" . embark-bindings))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Avy – jump to any visible text in 2-3 keystrokes.
(use-package avy
  :bind (("M-j"   . avy-goto-char-timer)
         ("C-c j" . avy-goto-line)))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 5. IN-BUFFER COMPLETION (Corfu + Cape)
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(use-package corfu
  :demand t
  :bind (:map corfu-map
         ("TAB"     . corfu-next)
         ([tab]     . corfu-next)
         ("S-TAB"   . corfu-previous)
         ([backtab] . corfu-previous)
         ("RET"     . corfu-insert)
         ("M-SPC"   . corfu-insert-separator))
  :config
  (global-corfu-mode 1)
  (corfu-popupinfo-mode 1)
  (setq corfu-auto t
        corfu-auto-delay 0.12
        corfu-auto-prefix 2
        corfu-cycle t
        corfu-preselect 'prompt
        corfu-quit-no-match 'separator
        corfu-popupinfo-delay '(0.3 . 0.15)))

(use-package cape
  :demand t
  :init
  ;; Append so LSP capfs remain first-class.
  (add-hook 'completion-at-point-functions #'cape-file    t)
  (add-hook 'completion-at-point-functions #'cape-dabbrev t)
  (add-hook 'completion-at-point-functions #'cape-keyword t))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 6. TREE-SITTER
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; Pinned to last ABI 14 tags (Emacs 30.1 does not support ABI 15).
;; Format: (LANG . (URL REVISION SOURCE-DIR CC C++))
(setq treesit-language-source-alist
      '((c          "https://github.com/tree-sitter/tree-sitter-c"          "v0.23.2")
        (cpp        "https://github.com/tree-sitter/tree-sitter-cpp"        "v0.23.4")
        (python     "https://github.com/tree-sitter/tree-sitter-python"     "v0.23.6")
        (go         "https://github.com/tree-sitter/tree-sitter-go"         "v0.23.4")
        (gomod      "https://github.com/camdencheek/tree-sitter-go-mod"     "v1.0.2")
        (rust       "https://github.com/tree-sitter/tree-sitter-rust"       "v0.23.2")
        (bash       "https://github.com/tree-sitter/tree-sitter-bash"       "v0.23.3")
        (json       "https://github.com/tree-sitter/tree-sitter-json"       "v0.24.8")
        (toml       "https://github.com/tree-sitter/tree-sitter-toml")
        (yaml       "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "v0.7.2")
        (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile" "v0.2.0")
        (cmake      "https://github.com/uyha/tree-sitter-cmake"            "v0.5.0")
        (make       "https://github.com/alemuller/tree-sitter-make")))


(defun dom/treesit-install-all-grammars ()
  "Install all tree-sitter grammars from `treesit-language-source-alist'."
  (interactive)
  (dolist (grammar treesit-language-source-alist)
    (unless (treesit-language-available-p (car grammar))
      (treesit-install-language-grammar (car grammar)))))

;; Remap to tree-sitter modes when grammars are available.
;; In Emacs 30, ts-modes inherit from their non-ts parents.
(setq treesit-font-lock-level 4)       ; maximum highlighting detail
(setq major-mode-remap-alist
      '((c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (c-or-c++-mode   . c-or-c++-ts-mode)
        (python-mode     . python-ts-mode)
        (rust-mode       . rust-ts-mode)
        (go-mode         . go-ts-mode)
        (bash-mode       . bash-ts-mode)
        (sh-mode         . bash-ts-mode)
        (json-mode       . json-ts-mode)
        (yaml-mode       . yaml-ts-mode)
        (toml-mode       . toml-ts-mode)
        (dockerfile-mode . dockerfile-ts-mode)
        (cmake-mode      . cmake-ts-mode)))

;; Fallback packages for when grammars are absent (first launch, etc.)
(use-package go-mode   :mode "\\.go\\'")
(use-package rust-mode :mode "\\.rs\\'")

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 7. LSP via EGLOT
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;
;; Required on $PATH:
;;   clangd · pyright · rust-analyzer · gopls
;;
;; CRITICAL for C/C++: provide a compile_commands.json or compile_flags.txt.
;; Without it clangd is guessing and your experience will be poor.
;; See: https://clangd.llvm.org/installation#compile_commandsjson

(use-package eglot
  :ensure nil
  :hook ((c-ts-mode     . eglot-ensure)
         (c++-ts-mode   . eglot-ensure)
         (c-mode        . eglot-ensure)
         (c++-mode      . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (python-mode   . eglot-ensure)
         (rust-ts-mode  . eglot-ensure)
         (rust-mode     . eglot-ensure)
         (go-ts-mode    . eglot-ensure)
         (go-mode       . eglot-ensure))
  :bind (:map eglot-mode-map
         ("C-c e r" . eglot-rename)
         ("C-c e a" . eglot-code-actions)
         ("C-c e f" . eglot-format)
         ("C-c e F" . eglot-format-buffer)
         ("C-c e o" . eglot-code-action-organize-imports)
         ("C-c e h" . eldoc-doc-buffer))
  :config
  (setq eglot-autoshutdown t
        eglot-sync-connect 0                   ; non-blocking server start
        eglot-events-buffer-size 0             ; no event log (faster)
        eglot-send-changes-idle-time 0.2)

  ;; ElDoc: show signatures and docs ("strcmp(…)").
  (setq eldoc-idle-delay 0.1
        eldoc-echo-area-use-multiline-p 3      ; up to 3 lines in echo area
        eldoc-echo-area-prefer-doc-buffer t
        ;;; Collect output from all sources (eglot signatures, documentation, and
        ;;; flymake diagnostics) and display them together, both in the echo area
        ;;; and in the eldoc buffer.
        eldoc-documentation-strategy #'eldoc-documentation-compose)

  ;; ── clangd ──
  (add-to-list 'eglot-server-programs
               '((c-mode c-ts-mode c++-mode c++-ts-mode)
                 . ("clangd"
                    "--background-index"
                    "--clang-tidy"
                    "--completion-style=detailed"
                    "--header-insertion=iwyu"
                    "--header-insertion-decorators=0"
                    "--pch-storage=memory")))

  ;; ── gopls ──
  (setq-default eglot-workspace-configuration
                '(:gopls (:staticcheck t
                          :usePlaceholders t
                          :completeUnimported t
                          :gofumpt t))))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 8. PROJECT / COMPILE / NAVIGATION
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; project.el is built-in; auto-detects git repos + extra root markers above.
(setq project-switch-commands 'project-find-file)

;; Standard xref bindings (documented here, not rebound).
;; M-.   → xref-find-definitions
;; M-,   → xref-go-back
;; M-?   → xref-find-references
;; C-M-. → xref-find-apropos

;; Compile from project root.
(defun dom/project-compile ()
  "Run `compile' from the current project root."
  (interactive)
  (let ((default-directory
          (if-let ((proj (project-current)))
              (project-root proj)
            default-directory)))
    (call-interactively #'compile)))

(global-set-key (kbd "<f5>")   #'dom/project-compile)
(global-set-key (kbd "S-<f5>") #'recompile)

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 9. GIT
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(use-package magit
  :bind (("C-x g"   . magit-status)
         ("C-c g l" . magit-log-current)
         ("C-c g b" . magit-blame-addition))
  :config
  (setq magit-display-buffer-function
        #'magit-display-buffer-same-window-except-diff-v1
        magit-save-repository-buffers 'dontask))

;; Git change markers in the fringe.
(use-package diff-hl
  :demand t
  :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 10. FORMATTING ON SAVE (Apheleia)
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;
;; Runs the real CLI formatters asynchronously — same output as CI.
;; Required on $PATH: ruff · gofmt · rustfmt · clang-format

(use-package apheleia
  :hook ((python-mode    . apheleia-mode)
         (python-ts-mode . apheleia-mode)
         (go-mode        . apheleia-mode)
         (go-ts-mode     . apheleia-mode)
         (rust-mode      . apheleia-mode)
         (rust-ts-mode   . apheleia-mode)
         (c-mode         . apheleia-mode)
         (c-ts-mode      . apheleia-mode)
         (c++-mode       . apheleia-mode)
         (c++-ts-mode    . apheleia-mode))
  :config
  (setf (alist-get 'python-mode    apheleia-mode-alist) 'ruff)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'go-mode        apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'go-ts-mode     apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'rust-mode      apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'rust-ts-mode   apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'c-mode         apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'c-ts-mode      apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'c++-mode       apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'c++-ts-mode    apheleia-mode-alist) 'clang-format))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 11. LLM – gptel (Claude / Anthropic)
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;
;; Store your key in ~/.authinfo.gpg:
;;   machine api.anthropic.com login apikey password sk-ant-XXXX

(use-package gptel
  :bind (("C-c l c" . gptel)                  ; chat buffer
         ("C-c l s" . gptel-send)             ; send region/buffer
         ("C-c l r" . gptel-rewrite)          ; rewrite region in-place
         ("C-c l m" . gptel-menu)             ; transient options menu
         ("C-c l a" . gptel-add)              ; add file/region to context
         ("C-c l k" . gptel-abort))           ; cancel request
  :config
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key 'gptel-api-key-from-auth-source))
  (setq gptel-model 'claude-sonnet-4-20250514
        gptel-default-mode 'org-mode))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 12. LANGUAGE-SPECIFIC
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; ── C / C++ ──────────────────────────────────────────────────────────
(add-hook 'c-ts-mode-hook
          (lambda () (setq-local c-ts-mode-indent-offset 2)))
(add-hook 'c++-ts-mode-hook
          (lambda () (setq-local c-ts-mode-indent-offset 4)))
;; Legacy cc-mode fallback.
(use-package cc-mode
  :ensure nil
  :hook ((c-mode c++-mode)
         . (lambda ()
             (setq-local c-default-style "linux"
                         c-basic-offset 4))))

;; ── Go ───────────────────────────────────────────────────────────────
(dolist (hook '(go-mode-hook go-ts-mode-hook))
  (add-hook hook (lambda ()
                   (setq-local indent-tabs-mode t
                               tab-width 4))))

;; Organize imports on save via eglot (apheleia handles gofmt).
(defun dom/go-organize-imports ()
  (when (and (derived-mode-p 'go-mode 'go-ts-mode) (eglot-managed-p))
    (eglot-code-action-organize-imports (point-min) (point-max))))
(add-hook 'before-save-hook #'dom/go-organize-imports)

;; go.mod support.
(add-to-list 'auto-mode-alist '("go\\.mod\\'" . go-mod-ts-mode))

;; ── Python ───────────────────────────────────────────────────────────
(use-package python
  :ensure nil
  :hook ((python-mode python-ts-mode)
         . (lambda () (setq-local python-indent-offset 4)))
  :config
  (when (executable-find "ipython")
    (setq python-shell-interpreter "ipython"
          python-shell-interpreter-args "-i --simple-prompt")))

;; ── Emacs Lisp ───────────────────────────────────────────────────────
(add-hook 'emacs-lisp-mode-hook
          (lambda () (setq-local indent-tabs-mode nil)))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 13. SNIPPETS
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config (yas-reload-all))

(use-package yasnippet-snippets
  :after yasnippet)

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 14. TERMINAL
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; Eat – lightweight, pure-Elisp terminal.  No cmake/libvterm deps.
(use-package eat
  :bind ("C-c t" . eat)
  :config
  (with-eval-after-load 'eshell
    (eat-eshell-mode 1)
    (eat-eshell-visual-command-mode 1)))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 15. PER-PROJECT ENVIRONMENT
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; envrc – buffer-local direnv integration.
(use-package envrc
  :demand t
  :config (envrc-global-mode 1))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 16. QUALITY OF LIFE
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; which-key (built-in Emacs 30).
(use-package which-key
  :ensure nil
  :demand t
  :config
  (which-key-mode 1)
  (setq which-key-idle-delay 0.4
        which-key-max-description-length 40
        which-key-sort-order 'which-key-key-order-alpha))

;; editorconfig (built-in Emacs 30).
(use-package editorconfig
  :ensure nil
  :demand t
  :config (editorconfig-mode 1))

;; wgrep – edit grep/ripgrep results in-place, apply to source files.
(use-package wgrep
  :config (setq wgrep-auto-save-buffer t))

;; rainbow-delimiters – colored matching parens.
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Flymake diagnostics navigation.
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
         ("M-n" . flymake-goto-next-error)
         ("M-p" . flymake-goto-prev-error)
         ("C-c ! l" . flymake-show-buffer-diagnostics)
         ("C-c ! L" . flymake-show-project-diagnostics)))

;; Dired.
(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh --group-directories-first"
        dired-dwim-target t
        dired-recursive-copies 'always
        dired-recursive-deletes 'top
        dired-kill-when-opening-new-dired-buffer t))

;; Pulse current line after jumps (M-., avy, etc.)
(defun dom/pulse-line (&rest _)
  "Briefly highlight the current line."
  (pulse-momentary-highlight-one-line (point)))
(dolist (fn '(xref-find-definitions xref-go-back
              consult-goto-line consult-imenu
              avy-goto-char-timer avy-goto-line))
  (advice-add fn :after #'dom/pulse-line))

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; 17. PERSONAL UTILITIES
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

;; From https://emacsredux.com/blog/2013/03/27/copy-filename-to-the-clipboard/
(defun dom/copy-file-name ()
  "Copy the current buffer's file name to the kill ring."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied: %s" filename))))
(global-set-key (kbd "C-c f") #'dom/copy-file-name)

;; From https://www.emacswiki.org/emacs/IncrementNumber
(defun dom/increment-number-at-point (&optional arg)
  "Increment the number at point by ARG (default 1)."
  (interactive "p*")
  (save-excursion
    (save-match-data
      (let (inc-by field-width answer)
        (setq inc-by (if arg arg 1))
        (skip-chars-backward "0123456789")
        (when (re-search-forward "[0-9]+" nil t)
          (setq field-width (- (match-end 0) (match-beginning 0)))
          (setq answer (+ (string-to-number (match-string 0) 10) inc-by))
          (when (< answer 0)
            (setq answer (+ (expt 10 field-width) answer)))
          (replace-match (format (concat "%0" (int-to-string field-width) "d")
                                 answer)))))))
(global-set-key (kbd "C-c +") #'dom/increment-number-at-point)

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; KEYBINDING REFERENCE
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;
;; ┌──────────────────────────────────────────────────────────────────┐
;; │  NAVIGATION                                                      │
;; │  M-.           Jump to definition       (xref / eglot)           │
;; │  M-,           Jump back                (xref)                   │
;; │  M-?           Find all references      (xref / eglot)           │
;; │  M-g i         Symbol index (imenu)     (consult)                │
;; │  M-j           Jump to visible char     (avy)                    │
;; ├──────────────────────────────────────────────────────────────────┤
;; │  SEARCH                                                          │
;; │  M-s r         Ripgrep in project       (consult)                │
;; │  M-s f         Find file by name        (consult-find)           │
;; │  M-s l         Search lines in buffer   (consult-line)           │
;; │  C-x p f       Find file in project     (project-find-file)      │
;; ├──────────────────────────────────────────────────────────────────┤
;; │  LSP (Eglot)                                                     │
;; │  C-c e r       Rename symbol                                     │
;; │  C-c e a       Code actions                                      │
;; │  C-c e f / F   Format region / buffer                            │
;; │  C-c e o       Organize imports                                  │
;; │  C-c e h       Docs in dedicated buffer                          │
;; ├──────────────────────────────────────────────────────────────────┤
;; │  GIT                                                             │
;; │  C-x g         Magit status                                      │
;; │  C-c g l       Magit log                                         │
;; │  C-c g b       Magit blame                                       │
;; ├──────────────────────────────────────────────────────────────────┤
;; │  LLM                                                             │
;; │  C-c l c       Chat buffer              (gptel)                  │
;; │  C-c l s       Send region to LLM                                │
;; │  C-c l r       Rewrite region                                    │
;; │  C-c l m       Options menu                                      │
;; │  C-c l a       Add to context                                    │
;; ├──────────────────────────────────────────────────────────────────┤
;; │  DIAGNOSTICS                                                     │
;; │  M-n / M-p     Next / prev error        (flymake)                │
;; │  C-c ! l / L   Buffer / project diagnostics                      │
;; ├──────────────────────────────────────────────────────────────────┤
;; │  BUILD                                                           │
;; │  F5            Compile from project root                         │
;; │  S-F5          Recompile                                         │
;; ├──────────────────────────────────────────────────────────────────┤
;; │  MISC                                                            │
;; │  C-.           Embark act               (context actions)        │
;; │  C-;           Embark dwim                                       │
;; │  C-c t         Terminal                  (eat)                   │
;; │  C-c f         Copy file name to kill ring                       │
;; │  C-c +         Increment number at point                         │
;; │  C-c left/right Winner undo/redo        (window layout)          │
;; └──────────────────────────────────────────────────────────────────┘

;;; init.el ends here
