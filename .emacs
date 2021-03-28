;; -*- Emacs-Lisp -*-
;; import the master.emacs file
(defconst master-dir (getenv "LOCAL_ADMIN_SCRIPTS"))
(defconst engshare-master (getenv "ADMIN_SCRIPTS"))
(if (file-exists-p (expand-file-name "master.emacs" master-dir))
    (load-library (expand-file-name "master.emacs" master-dir))
  (when (file-exists-p (expand-file-name "master.emacs" engshare-master))
    (load-library (expand-file-name "master.emacs" engshare-master))))
(setq pfff-flymake-enabled nil)

(setq scroll-preserve-screen-position 1)
(global-set-key (kbd "M-n") (kbd "C-u 1 C-v"))
(global-set-key (kbd "M-p") (kbd "C-u 1 M-v"))

;; MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; Ensure needed packages are installed.
(dolist (package '(guru-mode counsel))
   (unless (package-installed-p package)
     (package-install package)
     (require package)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ido-enable-last-directory-history nil)
 '(ido-max-work-directory-list 0)
 '(ido-max-work-file-list 0)
 '(ido-record-commands nil)
 '(package-selected-packages
   '(monky guru-mode counsel prettier-js web-mode tuareg thrift pabbrev modern-cpp-font-lock lsp-ui lsp-pyre js2-mode hack-mode graphql git-gutter git flycheck d-mode company-ycmd company-php company-lsp company-go auto-complete))
 '(web-mode-attr-indent-offset 2)
 '(web-mode-attr-value-indent-offset 2)
 '(web-mode-code-indent-offset 2)
 '(web-mode-css-indent-offset 2)
 '(web-mode-markup-indent-offset 2)
 '(web-mode-sql-indent-offset 2))

(menu-bar-mode      0)
(ido-mode           1)
(column-number-mode 1)
(subword-mode       1)
(guru-global-mode   0)

(setq auto-save-default nil)
(setq make-backup-files nil) ; stop creating ~ files

(add-to-list 'load-path "~/.emacs.d/lisp")


;; (setq tags-table-list '("~/www/TAGS"))

(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)


;; Hack For HipHop
(when (require 'hack-for-hiphop nil 'noerror)
  (setq hack-for-hiphop-root "~/www"))


;; Hack mode
(add-to-list 'auto-mode-alist '("\\.php$" . hack-mode))


;; MURAL
(when (require 'mural nil 'noerror)
  (mural-add-tagfile "~/www/TAGS")
  (global-set-key (kbd "C-o") 'mural-open-dwim))


;; MYLES
(require 'myles nil 'noerror)
(require 'counsel)



(setq confirm-kill-emacs 'y-or-n-p)
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))


;; Setup proxy to talk to internet
;; (setq url-proxy-services
;;    '(("no_proxy" . "^\\(localhost\\|10.*\\)")
;;      ("http" . "fwdproxy:8080")
;;      ("https" . "fwdproxy:8080")))


;; web-mode
(add-to-list 'auto-mode-alist '("\\.jsx?$" . web-mode)) ;; auto-enable for .js/.jsx files
(setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'"))) ;; enable JSX syntax highlighting in .js/.jsx files
(defun web-mode-init-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-attr-indent-offset 2)
  ;; (set-face-attribute 'web-mode-block-delimiter-face nil :inherit nil)
  ;; (set-face-attribute 'web-mode-html-attr-name-face nil :foreground "maroon")
  ;; (set-face-attribute 'web-mode-html-tag-bracket-face nil :foreground nil)
  ;; (set-face-attribute 'web-mode-html-tag-face nil :foreground "slateblue1" :weight 'semi-bold)
  (prettier-js-mode)
  (setq compile-command "flow --from emacs ~/www")
  (global-set-key (kbd "M-RET") 'compile)
  )
(add-hook 'web-mode-hook 'web-mode-init-hook)


;; Format on save
(defun format-after-save ()
  (interactive)
  (when (eq major-mode 'python-mode)
    (shell-command (concat "pyfmt "
                           (shell-quote-argument buffer-file-name))
                   "*pyfmt Output*")
    (revert-buffer t t))
  (when (eq major-mode 'hack-mode)
    (shell-command (concat "hackfmt -i "
                           (shell-quote-argument buffer-file-name))
                   "*hackfmt Output*")
    (revert-buffer t t))
)

(add-hook 'after-save-hook 'format-after-save)


;; Set terminal prefix to C-x.
(add-hook 'term-mode-hook
   (lambda ()
     ;; C-x is the prefix command, rather than C-c
     (term-set-escape-char ?\C-x)
     (define-key term-raw-map "\M-y" 'yank-pop)
     (define-key term-raw-map "\M-w" 'kill-ring-save)))


;; Custom functions

;; From https://emacsredux.com/blog/2013/03/28/google/
(defun google ()
  "Google the selected region if any, display a query prompt otherwise."
  (interactive)
  (browse-url
   (concat
    "https://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (url-hexify-string (if mark-active
			   (buffer-substring (region-beginning) (region-end))
			 (read-string "Google: "))))))
(global-set-key (kbd "C-c g") 'google)

;; From https://emacsredux.com/blog/2013/03/27/copy-filename-to-the-clipboard/
(defun ddom-copy-file-name ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied %s" filename))))

;; From https://www.emacswiki.org/emacs/IncrementNumber
(defun ddom-increment-number-at-point (&optional arg)
  "Increment the number forward from point by 'arg'."
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
