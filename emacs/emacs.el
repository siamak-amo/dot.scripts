;; copy this file to ~/.emacs

;; to use proxy
;; (load-file "~/.emacs.d/proxy.el")

;;;;;;;;;;;;;;;;;;;;;;;
;; my custom configs ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; custom.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))
;; always y/n
(defalias 'yes-or-no-p 'y-or-n-p)
;; my basic configs
(set-face-attribute 'default nil :font "Monoid")
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default line-spacing 8)
;;(setq indent-line-function 'insert-tab)
(setq-default TeX-engine 'xetex)
(setq inhibit-startup-screen t)
(menu-bar-mode 0)
(global-display-line-numbers-mode 1)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(which-function-mode 1)
(electric-indent-mode -1)
(setq-default mode-line-format (delq 'mode-line-modes mode-line-format))
(setq confirm-kill-emacs 'y-or-n-p)
(set-face-attribute 'font-lock-comment-face nil :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil :slant 'italic)
(setq column-number-mode t)
(when window-system (set-fontset-font "fontset-default" '(#x600 . #x6ff) "arimo"))
;; disable line number
(add-hook 'pdf-view-mode-hook #'(lambda () (interactive) (display-line-numbers-mode -1)))
(add-hook 'image-dired-display-image-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'image-mode-hook #'(lambda () (interactive) (display-line-numbers-mode -1)))
;; pdf viewer
(setq TeX-view-program-list '(("Okular" "okular %o")))
(setq TeX-view-program-selection '((output-pdf "Okular")))
;; search in dictionary
(defun search_dict ()
  "Search for the word under the cursor in the dictionary."
  (interactive)
  (let ((word (thing-at-point 'word)))
    (if word
        (let ((custom-word (read-string
                            (format "Search (default %s): " word) nil nil word)))
          (dictionary-search custom-word))
      (dictionary))))
;; regenerate TAGS
(defun regenerate-tags ()
  (interactive)
  (let* ((file (or buffer-file-name (dired-get-file-for-visit)))
         (default-directory (file-name-directory file)))
    (if (eq major-mode 'dired-mode)
        (shell-command "find . -name '*.h' -o -name '*.c' | xargs etags")
        (if (y-or-n-p "Regenerate TAGS for the current file only? ")
            (shell-command (format "etags %s" (file-name-nondirectory file)))
            (shell-command "find . -name '*.h' -o -name '*.c' | xargs etags")))))
;; grep command support
(setq grep-cmd-comm "grep -rn -I --exclude-dir=.git --exclude=TAG")
(defun do_grep_in_dir ()
  (interactive)
  (let* ((directory (read-directory-name "Directory: "))
         (search-string (read-string "Search: "))
         (grep-command (format "%s -- '%s' %s"
                               grep-cmd-comm search-string directory)))
    (grep grep-command)))
(defun do_grep ()
  (interactive)
  (let* ((search-string (read-string "Search: "))
         (grep-command (format "%s -- '%s' ."
                               grep-cmd-comm search-string)))
    (grep grep-command)))
;; windmove improvement
(defun windmove-right2 ()
  (interactive)
  (let ((current-window (selected-window)))
    (if (window-in-direction 'right current-window)
        (windmove-right)
      (windmove-left))))
(defun windmove-left2 ()
  (interactive)
  (let ((current-window (selected-window)))
    (if (window-in-direction 'left current-window)
        (windmove-left)
      (windmove-right))))
(defun windmove-up2 ()
  (interactive)
  (let ((current-window (selected-window)))
    (if (window-in-direction 'above current-window)
        (windmove-up)
      (windmove-down))))
(defun windmove-down2 ()
  (interactive)
  (let ((current-window (selected-window)))
    (if (window-in-direction 'below current-window)
        (windmove-down)
      (windmove-up))))
;; transparency
(defun increase-transparency ()
  "Increase transparency of the frame by 5%."
  (interactive)
  (let ((current-alpha (or (frame-parameter nil 'alpha-background) 100)))
    (if (> current-alpha 95)
        (message "Maximum Alpha 100%%")
      (setq current-alpha (+ current-alpha 5))
      (set-frame-parameter nil 'alpha-background current-alpha)
      (message "+ Alpha %d%%" current-alpha))))
(defun decrease-transparency ()
  "Decrease transparency of the frame by 10%."
  (interactive)
  (let ((current-alpha (or (frame-parameter nil 'alpha-background) 100)))
    (if (< current-alpha 5)
        (message "Minimum Alpha 0%%")
      (setq current-alpha (- current-alpha 5))
      (set-frame-parameter nil 'alpha-background current-alpha)
      (message "- Alpha %d%%" current-alpha))))
;; hide Dired details
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
;; <up> and <down> bindings in shell mode
(add-hook 'shell-mode-hook
          (lambda ()
            (define-key shell-mode-map (kbd "<up>") 'comint-previous-input)
            (define-key shell-mode-map (kbd "<down>") 'comint-next-input)))
(add-hook 'inferior-python-mode-hook
          (lambda ()
            (define-key inferior-python-mode-map (kbd "<up>") 'comint-previous-input)
            (define-key inferior-python-mode-map (kbd "<down>") 'comint-next-input)))
;; C-c to break in compilation mode
(eval-after-load 'compile
  '(define-key compilation-mode-map (kbd "C-c") 'kill-compilation))
;; load custom themes
(add-to-list 'load-path "~/.emacs.d/themes")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
;; setup backup path to ~/.emacs.saves and /tmp/emacs
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . "~/.emacs.saves")))
(setq auto-save-file-name-transforms
      `((".*" "/tmp/emacs/" t)))
(setq undo-tree-history-directory-alist
      `((".*" . "/tmp/emacs/undo/")))


;;;;;;;;;;;;;;;;;;;;;;
;; custom shortcuts ;;
;;;;;;;;;;;;;;;;;;;;;;

;; <Fn>
(global-set-key (kbd "<M-f5>")     'regenerate-tags)
(global-set-key (kbd "<f5>")      #'compile)
(global-set-key (kbd "<f6>")      #'recompile)
(global-set-key (kbd "<f8>")      #'flyspell-mode)
(global-set-key (kbd "<f9>")      #'ispell-word)
;; managing buffers / tabs
(global-set-key (kbd "C-<end>")   #'switch-to-next-buffer)
(global-set-key (kbd "C-<home>")  #'switch-to-prev-buffer)
(global-set-key (kbd "C-<next>")  #'tab-bar-switch-to-next-tab)
(global-set-key (kbd "C-<prior>") #'tab-bar-switch-to-prev-tab)
(global-set-key (kbd "M-n")       #'switch-to-next-buffer)
(global-set-key (kbd "M-p")       #'switch-to-prev-buffer)
(global-set-key (kbd "C-k")        'kill-buffer)
(global-set-key (kbd "s-k")        'kill-buffer)
(global-set-key (kbd "M-o")        'other-window)
;; dired
(global-set-key (kbd "M-b")       #'switch-to-buffer)
(global-set-key (kbd "s-b")       #'switch-to-buffer)
(global-set-key (kbd "C-x C-i")   #'image-dired)
(eval-after-load "dired"
  '(progn
     ;; backspace  --> go one dir up
     (define-key dired-mode-map (kbd "<backspace>") 'dired-up-directory)
     ;; Ctrl-return  --> opens files and dirs in the current (dired) buffer
     (define-key dired-mode-map (kbd "C-<return>") 'dired-find-file)
     ;; return  --> open files in other window, dirs in the current one
     (define-key dired-mode-map (kbd "<return>")
                 (lambda ()
                   (interactive)
                   (let ((file (dired-get-file-for-visit)))
                     (if (file-directory-p file)
                         (dired-find-alternate-file)
                       (find-file-other-window file)))))
     ))
;; split window
(global-set-key (kbd "M-0")  #'delete-window)
(global-set-key (kbd "M-1")  #'delete-other-windows)
(global-set-key (kbd "M-2")  #'split-window-below)
(global-set-key (kbd "M-;")  #'split-window-right)
(global-set-key (kbd "M-3")  #'split-window-right)
(global-set-key (kbd "M-'")  #'split-window-below)
;; move to window (vi like)
(global-set-key (kbd "M-l")  #'windmove-right2)
(global-set-key (kbd "M-h")  #'windmove-left2)
(global-set-key (kbd "M-k")  #'windmove-up2)
(global-set-key (kbd "M-j")  #'windmove-down2)
;; resize window
(global-set-key (kbd "M-<left>")  (lambda () (interactive) (shrink-window-horizontally 1)))
(global-set-key (kbd "M-<right>") (lambda () (interactive) (enlarge-window-horizontally 1)))
(global-set-key (kbd "M-<up>")    (lambda () (interactive) (shrink-window 1)))
(global-set-key (kbd "M-<down>")  (lambda () (interactive) (enlarge-window 1)))
;; zoom in/out
(global-set-key (kbd "C-+")   'text-scale-increase)
(global-set-key (kbd "C-=")   'text-scale-increase)
(global-set-key [C-mouse-4]   'text-scale-increase)
(global-set-key [C-mouse-5]   'text-scale-decrease)
(global-set-key (kbd "C--")   'text-scale-decrease)
;; others
(global-set-key (kbd "M-m")  #'man)
(global-set-key (kbd "M-]")   'increase-transparency)
(global-set-key (kbd "M-[")   'decrease-transparency)
(global-set-key (kbd "C-`")   'vterm-toggle)


;;;;;;;;;;;;
;; Elpaca ;;
;;;;;;;;;;;;

(load-file "~/.emacs.d/init.el")
(require 'elpaca)
(package-activate-all)
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;;; evil mode (vi mode)
(use-package evil
  :ensure t
  :hook
  (c-mode . set-c-comments)
  (c-mode . (lambda ()
              (define-key evil-normal-state-map (kbd "M-.") 'find-tag)
              (define-key evil-normal-state-map (kbd "M-,") 'xref-pop-marker-stack)))
  :config
  (defun set-c-comments ()
    (setq comment-start "// "
          comment-end ""))
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-bellow t)
  (add-hook 'prog-mode-hook #'hs-minor-mode)
  (add-hook 'prog-mode-hook #'electric-indent-local-mode)
  (evil-mode)
  )
(use-package evil-collection
  :ensure t
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init)
  (evil-set-undo-system 'undo-tree)
  )
(use-package general
  :ensure t
  :config
  (general-evil-setup)
  (general-create-definer dt/leader-keys
                          :states '(normal insert visual emacs)
                          :keymaps 'override
                          :prefix "SPC"
                          :global-prefix "M-SPC")
  (dt/leader-keys
    ;; emacs
    "e"  '(:ignore t :wk "Emacs")
    "ee" '(save-buffers-kill-terminal :wk "Exit")
    ;; buffer management
    "b"  '(:ignore t :wk "buffer")
    "bb" '(switch-to-buffer :wk "Switch buffer")
    "bk" '(kill-this-buffer :wk "Kill this buffer")
    "bn" '(next-buffer :wk "Next buffer")
    "bp" '(previous-buffer :wk "Previous buffer")
     ;; git / grep
    "g"  '(:ignore t :wk "Git & Grep")
    "gg" '(git-gutter:update-all-windows :wk "Update All Windows")
    "gm" '(magit :wk "Magit")
    "gr"  '(:ignore t :wk "Grep")
    "grr" '(do_grep_in_dir :wk "Grep in Directory")
    "grc" '(do_grep :wk "Grep in the current dir")
    ;; revert / reload
    "r"  '(:ignore t :wk "Reload")
    "rr" 'revert-buffer
    "re" '((lambda () (interactive)
             (load-file "~/.emacs")
             (ignore (elpaca-process-queues)))
           :wk "Reload emacs config")
    "rb" '(revert-buffer :wk "Reload buffer")
    ;; file and dir
    "f"   '(:ignore t :wk "File / Dir")
    "ff"  '(find-file :wk "Find file")
    "fd"  '(:ignore t :wk "Dir")
    "fdd" '(dired :wk "Open dired")
    "fdw" '(wdired-change-to-wdired-mode :wk "Writable dired")
    "fdf" '(wdired-finish-edit :wk "Finish editing")
    ;; tabs / vterm / themes and face
    "t"  '(:ignore t :wk "Tab / Vterm")
    "tt" '(tab-new :wk "Tab new")
    "tc" '(tab-close :wk "Tab close")
    "tv" '(vterm-toggle :wk "Vterm toggle")
    "th" '(customize-themes :wk "Customize themes")
    "tf" '(customize-face :wk "Customize face")
    ;; fuzz
    "z"  '(:ignore t :wk "FUZZ")
    "zz" '(fzf :wk "Fuzz")
    "zd" '(fzf-directory :wk "Directory Fuzz")
    "zb" '(fzf-switch-buffer :wk "Switch buffer Fuzz")
    "zg" '(fzf-grep :wk "Grep")
    "zG" '(fzf-grep-in-dir :wk "Grep in directory")
    "zf" '(fzf-find-in-buffer :wk "Find in buffer Fuzz")
    "zF" '(fzf-find-file-in-dir :wk "Find file Fuzz")
    ;; langtool
    "l"  '(:ignore t :wk "Langtool")
    "lc" '(langtool-check :wk "langtool check")
    "ll" '(langtool-check :wk "langtool check")
    "ld" '(langtool-check-done :wk "langtool check done")
    "lm" '(langtool-show-message-at-point :wk "langtool show message")
     )
  )

;;; which key
(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  )
(use-package company
  :ensure t
  :hook ((emacs-lisp-mode . (lambda()
                              (setq-local company-backends '(company-elisp))))
         (emacs-list-mode . company-mode))
  :config
  (company-keymap--unbind-quick-access company-active-map)
  (company-tng-configure-default)
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1)
  )
;;; auto complete mode
(use-package auto-complete
  :ensure t
  :init
  (ac-config-default)
  :config
  (setq ac-use-menu-map t)
  (setq ac-auto-show-menu nil)
  (setq ac-auto-start 2)
  (setq ac-dwim t)
  (global-auto-complete-mode t)
)
;;; ivy mode
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  )
;;; drag-stuff package
(use-package drag-stuff
  :ensure t
  :config
  (global-set-key (kbd "<C-up>") 'drag-stuff-up)
  (global-set-key (kbd "<C-down>") 'drag-stuff-down)
  )
;;; undo redo package
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1)
  )
;;; git support
(use-package transient :ensure t)
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status))
  )
(use-package git-gutter
  :ensure t
  :init
  (global-git-gutter-mode +1)
  :config
  (setq git-gutter:update-interval 0)
  (setq gutter:window-width 2)
  )
(use-package git-gutter-fringe
  :ensure t
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom)
  )
;;; markdown support
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  )
;;; latex support
(use-package auctex
  :ensure t
  :defer t
  )
;;; pdf support
(use-package pdf-tools
  :ensure t
  :defer t
  :commands (pdf-loader-install)
  :mode "\\.pdf\\'"
  :bind (:map pdf-view-mode-map
              ("j" . pdf-view-next-line-or-next-page)
              ("k" . pdf-view-previous-line-or-previous-page)
              ("C-i" . pdf-view-themed-minor-mode)
              ("C-+" . pdf-view-enlarge)
              ("C--" . pdf-view-shrink))
  :init (pdf-loader-install)
  :config (add-to-list 'revert-without-query ".pdf")
  )
;;; fuzzy searching support
(use-package fzf
  :ensure t
  :config
  (require 'fzf)
  (setq fzf/args "-x --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "--exclude-dir='.git;.svn' -i --line-number %s"
        fzf/grep-command "grep --exclude-dir='.git;.svn' -nrH"
        fzf/position-bottom t
        fzf/window-height 15)
  )
;;; a proper terminal support
(use-package vterm
  :ensure t
  :config
  (define-key vterm-mode-map (kbd "C-c")
              (lambda () (interactive) (vterm-send-key (kbd "C-c"))))
  (define-key vterm-mode-map (kbd "C-<home>")  nil)
  (define-key vterm-mode-map (kbd "C-<end>")   nil)
  (define-key vterm-mode-map (kbd "C-<next>")  nil)
  (define-key vterm-mode-map (kbd "C-<prior>") nil)
  (setq shell-file-name "/bin/zsh"
        vterm-max-scrollback 1000)
  )
(use-package vterm-toggle
  :after vterm
  :ensure t
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3)))
  )

;;; LSP support
;; lsp-mode
(use-package lsp-mode
  :ensure t
  :bind (:map lsp-mode-map
         ("C-c d" . lsp-describe-thing-at-point)
         ("C-c a" . lsp-execute-code-action))
  :config
  (lsp-enable-which-key-integration t)
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  (setq lsp-completion-show-detail nil
        lsp-completion-show-kind nil)
  )
(use-package lsp-ui
  :ensure t
  :after lsp-mode
  )

;;; fly-check
(use-package flycheck :ensure t)

;;; Python
(setq python-shell-interpreter "python3")
(use-package python-mode
  :ensure t
  :hook ((python-mode . lsp-deferred)
         (python-mode . company-mode))
  :config
  (require 'lsp-python)
  )
;;; GoLang
(use-package go-mode
  :ensure t
  :hook
  (go-mode . lsp-deferred)
  (go-mode . subword-mode)
  (before-save . gofmt-before-save)
  (go-mode . (lambda ()
               (define-key evil-normal-state-map (kbd "M-.") 'godef-jump)
               (define-key evil-normal-state-map (kbd "M-,") 'pop-tag-mark)
               ))
  :config
  (require 'lsp-go)
  (require 'tree-widget)
  (setq lsp-go-analyses
        '((fieldalignment . t)
          (nilness . t)
          (unusedwrite . t)
          (unusedparams . t)))
  (add-to-list 'exec-path "$GOPATH/bin")
  (setq gofmt-command "goimports")
  ;; interactive go doc command
  (defun go-doc-int ()
    (interactive)
    (let ((symbol (read-string "Go documentation of: ")))
      (shell-command (format "go doc %s" symbol))))

  :bind (:map go-mode-map
              ("C-c C-d" . go-doc-int)
              ("C-c C-c" . gofmt))
  )
;;; End of LSP support

;;; Some useful packages
;;; mpd client
(use-package mpdel
  :ensure t
  :config
  (require 'mpdel)
  (mpdel-mode)
  )
;;; jupyter support
(use-package ein :ensure t)
(use-package multiple-cursors :ensure t)  ;;; I prefer using vi stuff
(use-package langtool
  :ensure t
  :config
  (setq langtool-language-tool-jar "/opt/share/languagetool/languagetool-server.jar"
        langtool-http-server-host "localhost"
        langtool-http-server-port 8081)
  )
;; docker support
(use-package docker
  :ensure t
  :bind ("C-c d" . docker)
  )
;; modern org mode
(use-package org-modern
  :ensure t
  :config
  (require 'org-modern)
  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda)
  )
;; org presentation mode
(use-package org-present
  :ensure t
  :config
  (require 'org-present)
  (eval-after-load "org-present"
    '(progn
       (add-hook 'org-present-mode-hook
                 (lambda ()  ;; setting
                   (org-present-big)
                   (display-line-numbers-mode -1)
                   (org-display-inline-images)
                   (org-present-hide-cursor)
                   (visual-line-mode 1)
                   (setq-local face-remapping-alist
                               '((default (:height 1.5) variable-pitch)
                                 (header-line (:height 4.0) variable-pitch)
                                 (org-document-title (:height 1.75) org-document-title)
                                 (org-code (:height 1.55) org-code)
                                 (org-verbatim (:height 1.55) org-verbatim)
                                 (org-block (:height 1.25) org-block)
                                 (org-block-begin-line (:height 0.7) org-block)))
                   (let* ((max-text-width 110)
                          (margin (max 0 (/ (- (window-width) max-text-width) 2))))
                     (set-window-margins nil margin margin))))
       (add-hook 'org-present-mode-quit-hook
                 (lambda ()  ;; resetting
                   (set-window-margins nil 0 0)
                   (org-present-small)
                   (display-line-numbers-mode 1)
                   (org-remove-inline-images)
                   (org-present-show-cursor)
                   (setq-local face-remapping-alist '((default variable-pitch default)))
                   (visual-line-mode 0)))))
  :bind (("C-c p" . org-present-prev)
         ("C-c n" . org-present-next))
  )
;; prettify symbols mode
;; (use-package prettify-symbols
;;   :ensure nil
;;   ; :hook ((prog-mode . prettify-symbols-mode)
;;   ;        (c-mode . prettify-symbols-mode))
;;   :config
;;   (setq prettify-symbols-alist
;;         '(("->"     . ?→)
;;           ("/="     . ?≠)
;;           ("!="     . ?≠)
;;           ("=="     . ?≡)
;;           ("<="     . ?≤)
;;           (">="     . ?≥)
;;           ))
;;   )

;; Don't install anything. Defer execution of BODY
(use-package emacs :ensure nil :config (setq ring-bell-function #'ignore))
