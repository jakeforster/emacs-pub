(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 0)
(menu-bar-mode -1)
(setq visible-bell t)
(setq ring-bell-function 'ignore)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(blink-cursor-mode -1)
(setq native-comp-async-report-warnings-errors 'silent)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq help-window-select t)
(setq Man-notify-method 'aggressive)
(setq-default indent-tabs-mode nil)

(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))

(add-to-list 'load-path
             (expand-file-name "el-files/" user-emacs-directory))

(defvar jf/font
  (cond ((memq system-type '(gnu/linux berkeley-unix))
         (when (member "DejaVu Sans Mono" (font-family-list))
           "DejaVu Sans Mono"))
        ((eq system-type 'windows-nt)
         (when (member "Consolas" (font-family-list))
           "Consolas"))
        (t nil)))

(add-to-list 'default-frame-alist `(font . ,(concat jf/font "-13")))

(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-=") 'text-scale-increase)

(load-theme 'modus-operandi)

(column-number-mode)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)

;; disable line numbers for these modes
(dolist (mode '(vterm-mode-hook
                dired-mode-hook
                pdf-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; dired
(unless (eq system-type 'berkeley-unix)
  (setq dired-listing-switches "-agho --group-directories-first"))
(add-hook 'dired-mode-hook 'dired-hide-details-mode)

(with-eval-after-load 'dired
  (require 'dired-x)
  (setq dired-omit-extensions (delete ".bbl" dired-omit-extensions)))

(defun jf/kill-dired-buffers ()
  (interactive)
  (mapc (lambda (buffer)
          (when (eq 'dired-mode (buffer-local-value 'major-mode buffer))
            (kill-buffer buffer)))
        (buffer-list)))

(setq delete-by-moving-to-trash t
      trash-directory "~/.local/share/Trash/files/")

;; if gpg-agent is providing ssh-agent on Guix System
;; ensure SSH_AUTH_SOCK is set for the gpg-agent
(require 'jf-guix)
(when (and jf/is-guix-system (jf/guix-gpg-agent-providing-ssh-agent-p))
  (setenv "SSH_AUTH_SOCK"
	  (replace-regexp-in-string "\n\\'" "" (shell-command-to-string "gpgconf --list-dirs agent-ssh-socket"))))

;; decrypt .gpg files in emacs without gpg-agent and
;; without external pinentry program
(setq epg-pinentry-mode 'loopback)

;; ediff
(setq ediff-window-setup-function #'ediff-setup-windows-plain)

;; hunspell 
;; hunspell-dict-en-au
(setq ispell-program-name "hunspell")
(require 'cl-lib)
(cl-assert (executable-find "hunspell"))

(unless jf/is-guix-system
  (require 'package)
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/") t)

  ;; (package-refresh-contents)
  ;; (defvar jf/emacs-packages
  ;;   '(diminish
  ;;     f
  ;;     vertico
  ;;     marginalia
  ;;     evil
  ;;     evil-collection
  ;;     general
  ;;     vterm
  ;;     org-contrib 
  ;;     yasnippet
  ;;     pdf-tools
  ;;     magit
  ;;     python-black
  ;;     flycheck))
  ;; (when (eq system-type 'berkeley-unix)
  ;;   (setq jf/emacs-packages (remove 'pdf-tools jf/emacs-packages)))
  ;; (when (eq system-type 'windows-nt)
  ;;   (setq jf/emacs-packages (remove 'vterm jf/emacs-packages)))
  ;;
  ;; (dolist (pkg jf/emacs-packages)
  ;;   (unless (package-installed-p pkg)
  ;;     (package-install pkg)))

  (setq custom-file (concat user-emacs-directory "custom.el")))

(use-package vertico
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package marginalia
  :after vertico
  :init (marginalia-mode))

(use-package evil
  :init
  (setq evil-want-integration t
	evil-want-keybinding nil
	;; evil-want-C-u-scroll t
	)
  :config
  (evil-set-undo-system 'undo-redo)
  (setq evil-insert-state-cursor nil)
  (setq evil-kill-on-visual-paste nil)
  (evil-mode))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init)

  (require 'diminish)
  (diminish 'evil-collection-unimpaired-mode)

  ;; dired
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file
    "L" 'dired-find-file-other-window))

(use-package general
  :config
  (general-evil-setup)
  ;; (general-define-key :states 'insert
  ;; 		      "jj" 'evil-normal-state)
  (general-create-definer jf/leader-keys ;; global key bindings
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC") ;; leader key in insert mode

  (jf/leader-keys
    "b" '(:ignore t :which-key "buffer...")
    "bb" '(switch-to-buffer :which-key "switch to buffer")
    "bi" '(ibuffer :which-key "use Ibuffer")
    "bk" '(kill-this-buffer :which-key "kill this buffer"))

  (jf/leader-keys
    "w" '(:ignore t :which-key "window...")
    "wl" '(evil-window-right :which-key "move to window right")
    "wh" '(evil-window-left :which-key "move to window left")
    "wj" '(evil-window-down :which-key "move to window down")
    "wk" '(evil-window-up :which-key "move to window up")
    
    "wL" '(evil-window-move-far-right :which-key "move this window right")
    "wH" '(evil-window-move-far-left :which-key "move this window left")
    "wJ" '(evil-window-move-very-bottom :which-key "move this window down")
    "wK" '(evil-window-move-very-top :which-key "move this window up")

    "wv" '(evil-window-vsplit :which-key "split window vertical")
    "ws" '(evil-window-split :which-key "split window horizontal")
    "wc" '(evil-window-delete :which-key "close window"))
  
  (jf/leader-keys
    "t" '(:ignore t :which-key "toggle...")
    "tf" '(toggle-frame-maximized :which-key "toggle frame maximised")
    "tv" '(visual-line-mode :which-key "toggle visual-line-mode")
    "tl" '(jf/toggle-line-numbers-type :which-key "toggle line numbers type") 
    "tt" '(theme-choose-variant :which-key "toggle theme"))

  (jf/leader-keys
    "h" '(:ignore t :which-key "describe...")
    "hf" '(describe-function :which-key "describe function")
    "hv" '(describe-variable :which-key "describe variable")
    "hk" '(describe-key :which-key "describe key")
    "hm" '(describe-mode :which-key "describe mode"))

  (jf/leader-keys
    "f" '(:ignore t :which-key "file...")
    "fs" '(save-buffer :which-key "save file"))

  (jf/leader-keys
    "q" '(:ignore t :which-key "quit...")
    "qq" '(save-buffers-kill-terminal :which-key "save file"))
  
  (jf/leader-keys
    "." '(find-file :which-key "find-file")
    "," '(bookmark-jump :which-key "bookmark-jump"))
  
  (jf/leader-keys
    "o" '(:ignore t :which-key "open...")
    "oa" '(org-agenda :which-key "org agenda")
    "ot" '(jf/vterm :which-key "vterm")
    "og" '(magit :which-key "(ma)git")
    "os" '(scratch-buffer :which-key "scratch buffer")
    "om" '(jf/messages-buffer :which-key "messages buffer") 
    "oc" '(:ignore t :which-key "config...")
    "oce" '(jf/open-emacs-config-file :which-key "emacs config"))

  (jf/leader-keys
    "-" '(jf/comment-dwim :which-key "jf/comment-dwim"))

  (jf/leader-keys
    "i" '(:ignore t :which-key "indent...")
    "ii" '(indent-region :which-key "indent-region")
    "il" '(jf/indent-rigidly-l :which-key "indent-rigidly")
    "ih" '(jf/indent-rigidly-h :which-key "indent-rigidly")))

(defun jf/toggle-line-numbers-type ()
  "Toggle between absolute and relative line numbers."
  (interactive)
  (if (eq display-line-numbers-type 'relative)
      (setq display-line-numbers-type t)
    (setq display-line-numbers-type 'relative))
  (global-display-line-numbers-mode))

(defun jf/comment-dwim (arg)
  "Call `comment-dwim` normally, or with `extra-line` comment-style when called with a prefix argument."
  (interactive "P")
  (if arg
      (let ((comment-style 'extra-line))
        (comment-dwim nil))
    (comment-dwim nil)))

(defun jf/indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun jf/indent-rigidly-l ()
  (interactive)
  (call-interactively 'indent-rigidly)
  (command-execute (kbd "l")))

(defun jf/indent-rigidly-h ()
  (interactive)
  (call-interactively 'indent-rigidly)
  (command-execute (kbd "h")))

(defun jf/messages-buffer ()
  "Switch to the *Messages* buffer."
  (interactive)
  (switch-to-buffer "*Messages*")
  (evil-motion-state))

(defun jf/open-emacs-config-file ()
  (interactive)
  (find-file user-init-file))

;; shell
;; (because vterm doesn't work on windows)
(when (eq system-type 'windows-nt)
  (add-hook 'shell-mode-hook (lambda () (display-line-numbers-mode 0)))

  (jf/leader-keys
    ;; override jf/vterm
    "ot" '(jf/shell :which-key "shell"))

  (defun jf/shell ()
    "Open a new shell buffer. Each buffer will have a unique name starting with 'shell'."
    (interactive)
    (let ((new-shell-buffer (generate-new-buffer "shell")))
      (with-current-buffer new-shell-buffer
        (shell new-shell-buffer))))

  (defun jf/kill-shell-buffer ()
    "Kill the current shell buffer without confirmation."
    (interactive)
    (when (and (eq major-mode 'shell-mode) (string-match-p "^shell" (buffer-name)))
      (let ((process (get-buffer-process (current-buffer))))
	(when process
          (set-process-query-on-exit-flag process nil))
	(kill-buffer (current-buffer)))))

  (evil-collection-define-key 'normal 'shell-mode-map
    (kbd "SPC k") 'jf/kill-shell-buffer))

(unless (eq system-type 'windows-nt)
  (defun jf/vterm (&optional command)
    "Create a new 'vterm' buffer and optionally run a COMMAND."
    (interactive)
    (require 'vterm)
    (let ((buffer (generate-new-buffer "vterm")))
      (switch-to-buffer buffer)
      (vterm-mode)
      (when command
	(vterm-send-string command))))

  (use-package vterm
    :defer t
    :config
    (setq vterm-max-scrollback 10000)

    (evil-collection-define-key 'normal 'vterm-mode-map
      (kbd "M-w") #'kill-ring-save
      (kbd "SPC k") 'jf/kill-vterm-buffer)

    ;; fix cursor position after evil insert and append 
    (defun +vterm-update-cursor (&rest _args)
      (vterm-goto-char (point)))
    (advice-add #'vterm-send-key :before #'+vterm-update-cursor)

    (defun +vterm-update-cursor-boon (&rest _args)
      (vterm-goto-char (point)))
    (advice-add #'boon-insert :before #'+vterm-update-cursor-boon)

    (defun jf/kill-vterm-buffer ()
      "Kill the current 'vterm' buffer without confirmation if it's the active buffer."
      (interactive)
      (when (string-prefix-p "vterm" (buffer-name))
	(let ((kill-buffer-query-functions nil)) 
	  (kill-buffer (current-buffer)))))))

(use-package org
  :defer t
  :hook (org-mode . jf/org-mode-setup)
  :config
  (defun jf/org-mode-setup ()
    (org-indent-mode)
    (require 'diminish)
    (diminish 'org-indent-mode)
    (flyspell-buffer)
    (flyspell-mode))
  
  (evil-collection-define-key 'normal 'org-mode-map
    (kbd "SPC e") 'org-babel-execute-src-block
    (kbd "SPC k") 'org-babel-remove-result
    (kbd "SPC m") 'org-export-dispatch)
    (kbd "SPC '") 'org-edit-special

  (setq org-log-done 'time
        org-confirm-babel-evaluate nil
        org-startup-folded 'content
	org-M-RET-may-split-line '((default . nil))
	org-preview-latex-default-process 'dvisvgm ;; org-latex-preview use SVG for nice scaling
        org-list-allow-alphabetical t)

  (add-to-list 'display-buffer-alist
	       '("^\\*Org-Babel Error Output\\*" . ((display-buffer-same-window))))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (latex . t)
     (sqlite . t)))

    (setq org-latex-pdf-process
        (if (eq system-type 'berkeley-unix)
            '("latexmk -f -pdf -interaction=nonstopmode -shell-escape -output-directory=%o %f")
          '("latexmk -f -pdf -%latex -interaction=nonstopmode -shell-escape -output-directory=%o %f")))

  (evil-collection-define-key 'normal 'org-src-mode-map
    (kbd "<return>") 'org-edit-src-exit)

  ;; for org-src-mode-map to register the above keybinding
  (add-hook 'org-src-mode-hook (lambda () (evil-normal-state))))

;; org-contrib
(use-package ox
  :after org
  :config
  (use-package ox-extra
    :config
    (ox-extras-activate '(ignore-headlines))))

;; nicer compilation with M-x jf/compile
;; show compilation buffer in same window
;; and auto kill it unless compilation throws an error
(use-package jf-compile
  :config
  (add-to-list 'display-buffer-alist
	       '("^\\*compilation\\*" . ((display-buffer-same-window))))

  (jf/toggle-compilation-cleanup)

  (dolist (map '(latex-mode-map
                 c-mode-base-map
                 python-mode-map))
    (evil-collection-define-key 'normal map
      (kbd "SPC m") #'jf/compile))

  (evil-collection-define-key 'normal 'compilation-mode-map
    (kbd "SPC k") #'jf/kill-compilation-buffer)

  (setq compilation-scroll-output t))

(cl-assert (executable-find "latexmk"))
(use-package jf-latex
  :hook (latex-mode . jf/latex-mode-setup)
  :config
  (defun jf/latex-mode-setup ()
    (add-hook 'before-save-hook #'jf/indent-buffer nil t)
    (flyspell-buffer)
    (flyspell-mode))

  (add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))

  (add-hook 'hack-local-variables-hook 'jf/set-latex-compile-command))

(use-package yasnippet
  :config
  (yas-reload-all)
  (dolist (hook '(latex-mode-hook python-mode-hook org-mode-hook))
    (add-hook hook 'yas-minor-mode))
  (add-hook 'snippet-mode-hook (lambda () (setq-local require-final-newline nil))))

(unless (eq system-type 'berkeley-unix)
  (use-package pdf-tools
    :defer t
    :magic ("%PDF" . pdf-view-mode)
    :config
    (pdf-tools-install)

    ;; automatically annotate highlights, strikeouts
    (setq pdf-annot-activate-created-annotations t)

    (defun jf/pdf-annot-add-text-annotation ()
      (interactive)
      (call-interactively 'pdf-annot-add-text-annotation)
      (evil-insert-state))

    (defun jf/pdf-annot-add-highlight-markup-annotation ()
      (interactive)
      (call-interactively 'pdf-annot-add-highlight-markup-annotation)
      (evil-insert-state))

    (defun jf/pdf-annot-add-strikeout-markup-annotation ()
      (interactive)
      (call-interactively 'pdf-annot-add-strikeout-markup-annotation)
      (evil-insert-state))

    (evil-collection-define-key 'normal 'pdf-view-mode-map
      (kbd "SPC") nil 
      (kbd "SPC a") nil
      (kbd "SPC a t") 'jf/pdf-annot-add-text-annotation 
      (kbd "SPC a D") 'pdf-annot-delete
      (kbd "SPC a l") 'pdf-annot-list-annotations)

    (evil-collection-define-key 'visual 'pdf-view-mode-map
      (kbd "SPC a h") 'jf/pdf-annot-add-highlight-markup-annotation 
      (kbd "SPC a o") 'jf/pdf-annot-add-strikeout-markup-annotation)

    (with-eval-after-load 'pdf-annot
      (evil-collection-define-key 'normal 'pdf-annot-edit-contents-minor-mode-map
        (kbd "<return>") 'pdf-annot-edit-contents-commit)

      ;; auto save file after adding comment
      (advice-add 'pdf-annot-edit-contents-commit :after (lambda (&rest args) (save-buffer))))))

(use-package magit
  :defer t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :hook
  ((git-commit-setup . evil-insert-state)
   (magit-mode . (lambda () (setq left-fringe-width 10))))
  :config
  (defun jf/kill-magit-buffers ()
    (interactive)
    (let ((buffers (magit-mode-get-buffers)))
      (when buffers
        (when (eq major-mode 'magit-mode)
          (magit-restore-window-configuration))
        (mapc #'kill-buffer buffers))))
  
  (evil-collection-define-key 'normal 'magit-mode-map
    (kbd "SPC k") 'jf/kill-magit-buffers)
  
  (setq magit-diff-hide-trailing-cr-characters t
        transient-default-level 5))

(cl-assert (executable-find "black"))
(use-package python-black
  :after python
  :hook (python-mode . (lambda () (python-black-on-save-mode))))

(cl-assert (executable-find "pylint"))
(use-package flycheck
  :after python
  :config
  (defun jf/python-flycheck-setup ()
    (unless buffer-read-only  ;; flycheck checker warning 
      (flycheck-mode)
      (flycheck-select-checker 'python-pylint)))  ;; flake8 is the default
  
  (add-hook 'python-mode-hook 'jf/python-flycheck-setup))

(use-package eglot
  :config
  (defun jf/python-toggle-flycheck-with-eglot (&rest _args)
    (when (eq major-mode 'python-mode)
      (if (bound-and-true-p eglot--managed-mode)
          (flycheck-mode -1)  
        (flycheck-mode 1))))  

  (add-hook 'eglot-managed-mode-hook 'jf/python-toggle-flycheck-with-eglot)
  (advice-add 'eglot-shutdown :after 'jf/python-toggle-flycheck-with-eglot))
