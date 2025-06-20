(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"

  			                  :ref nil
  			                  :files (:defaults (:exclude "extensions"))
  			                  :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
  	             ((zerop (call-process "git" nil buffer t "clone"
  				                       (plist-get order :repo) repo)))
  	             ((zerop (call-process "git" nil buffer t "checkout"
  				                       (or (plist-get order :ref) "--"))))
  	             (emacs (concat invocation-directory invocation-name))
  	             ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
  				                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
  	             ((require 'elpaca))
  	             ((elpaca-generate-autoloads "elpaca" repo)))
            (kill-buffer buffer)
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))



;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use `elpaca-wait' to block until that package has been installed/configured.
;;For example:
;;(use-package general :demand t)
;;(elpaca-wait)

;;Turns off elpaca-use-package-mode current declartion
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
;;(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;;(elpaca nil (message "deferred"))
(elpaca-use-package-mode) ;; enables :ensure in use-package to work with elpaca

;; Expands to: (elpaca evil (use-package evil :demand t))
;; Evil mode
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  :config
  (evil-mode)
;; ;; Evil-states per major mode
;;   (setq evil-default-state 'emacs)
;;   (setq evil-normal-state-modes '(fundamental-mode
;;                                   ssh-config-mode
;;                                   conf-mode
;;                                   prog-mode
;;                                   text-mode
;;                                   repos-mode
;;                                   dired-mode
;;                                   dashboard-mode))
  ;; Minor mode evil states
  (add-hook 'with-editor-mode-hook 'evil-insert-state)

  ;; Per mode cursors
  (setq evil-insert-state-cursor '(box "green"))
  (setq evil-normal-state-cursor '(box "yellow"))
  (setq evil-emacs-state-cursor '(bar "red"))
  (setq evil-replace-state-cursor '(box "purple"))
  (setq evil-visual-state-cursor '(box "blue"))

  (define-key evil-normal-state-map (kbd "C-d") #'my/evil-scroll-down-and-center)
  (define-key evil-normal-state-map (kbd "C-u") #'my/evil-scroll-up-and-center)
  (define-key evil-visual-state-map (kbd "C-d") #'my/evil-scroll-down-and-center)
  (define-key evil-visual-state-map (kbd "C-u") #'my/evil-scroll-up-and-center)

  ;; Movement
  (define-key evil-normal-state-map (kbd "C-a") 'evil-first-non-blank)
  (define-key evil-normal-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-visual-state-map (kbd "C-a") 'evil-first-non-blank)
  (define-key evil-visual-state-map (kbd "C-e") #'my/evil-end-of-line)
  ;; ESC to quit prompts
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
  (evil-set-undo-system 'undo-redo))

;; Key-chord for jk escape
(use-package key-chord
  :ensure t
  :after evil
  :config
  (setq key-chord-two-keys-delay 1)
  (key-chord-mode 1)
  (with-eval-after-load 'evil
    (key-chord-define evil-insert-state-map "jk" 'evil-normal-state)))

;; ;; Evil extras
;; (use-package evil-collection
;;   :after company
;;   :after evil
;;   :config
;;   ;; (setq evil-collection-mode-list '(company dashboard dired ibuffer))
;;   (setq evil-collection-company-complete-in-complete-state nil)
;;   (evil-collection-init))

;; List of modes where evil-mode should be disabled
(defvar my/evil-excluded-modes
  '(dired-mode
    org-agenda-mode
    calendar-mode
    ibuffer-mode
    help-mode
    comint-mode
    messages-buffer-mode)
    ;; special-mode)
  "Major modes in which evil-mode should be disabled.")

(defun my/conditionally-disable-evil-mode ()
  "Disable evil-mode in buffers where it's not appropriate."
  (when (apply #'derived-mode-p my/evil-excluded-modes)
    (evil-local-mode -1)))

(add-hook 'evil-mode-hook #'my/conditionally-disable-evil-mode)

(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode) 
  ;; Define the function to copy the file path
  (defun ivy-copy-file-path (file)
    "Copy the full path of the selected file in `counsel-find-file'."
    (kill-new (expand-file-name file ivy--directory))
    (message "Copied: %s" (expand-file-name file ivy--directory)))

  ;; Bind C-c to copy the path in Ivy minibuffer
  (with-eval-after-load 'ivy
    (define-key ivy-minibuffer-map (kbd "C-c")
                (lambda ()
                  (interactive)
                  (ivy-copy-file-path (ivy-state-current ivy-last))))))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
                          ivy-rich-switch-buffer-align-virtual-buffer t
                          ivy-rich-path-style 'abbrev))
;;:config
;;(ivy-set-display-transformer 'ivy-switch-buffer 'ivy-rich-switch-buffer-transformer))

(use-package general
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer yousef/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (yousef/leader-keys
    "f f" '(find-file :wk "Find file")
    "f c" '((lambda () (interactive) (find-file "~/.emacs.d/config.org")) :wk "Edit emacs config")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f m p" '((lambda () (interactive) (find-file "~/org/roadmap.org")) :wk "Roadmap")
    "TAB TAB" '(comment-line :wk "Comment lines"))

  (yousef/leader-keys
    "b" '(:ignore t :wk "buffer")
    "b b" #'(lambda () (interactive) (let ((counsel-buffer-filter-fn #'buffer-file-name)) (counsel-switch-buffer)))
    "B B" '(switch-to-buffer :wk "Switch buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" #'(lambda () (interactive) (kill-buffer (current-buffer)))
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer"))

  (yousef/leader-keys
    "l" '(:ignore t :wk "lsp")
    "B B" '(switch-to-buffer :wk "Switch buffer")
    "l n" '(flycheck-next-error :wk "next error")
    "l p" '(flycheck-previous-error :wk "previous error"))

  (yousef/leader-keys
    "e" '(:ignore t :wk "Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e s" '(eshell :which-key "Eshell")
    "e r" '(eval-region :wk "Evaluate elisp in region")) 

  (yousef/leader-keys
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe function")
    "h v" '(describe-variable :wk "Describe variable")
    "h k" '(describe-key :wk "Describe key")
    ;;"h r r" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config"))
    "h r r" '(reload-init-file :wk "Reload emacs config"))

  (yousef/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle truncated lines")
    "t v" '(vterm-toggle :wk "Toggle vterm"))

  (yousef/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current"))

  (yousef/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))
  )
(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-c x") 'compile)
(global-set-key (kbd "C-c m") 'magit)
(global-set-key (kbd "C-c a") 'org-agenda)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

;; Scroll and recenter
(defun my/evil-scroll-down-and-center ()
  (interactive)
  (evil-scroll-down nil)
  (recenter))

(defun my/evil-scroll-up-and-center ()
  (interactive)
  (evil-scroll-up nil)
  (recenter))

(defun my/evil-end-of-line ()
  (interactive)
  (evil-end-of-line)
  (evil-backward-char))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
  ;;  "Switches between the current buffer, and the buffer above the
  ;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	     (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
  "Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	     (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
  "Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	     (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
  "Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	     (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(set-face-attribute 'default nil
                    :font "Iosevka"
                    :height 140
                    :weight 'medium)
(set-face-attribute 'variable-pitch nil
                    :font "Iosevka"
                    :height 140
                    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
                    :font "Iosevka"
                    :height 140
                    :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
                    :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "Iosevka-13.5"))

;; Uncomment the following line if line spacing needs adjusting.
;; (setq-default line-spacing 0.12)
(set-fontset-font t 'arabic "Noto Sans Arabic UI")

(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 'prog-mode
                          '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "||=" "||>"
                            ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                            "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                            "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                            "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                            "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                            "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                            "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                            ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                            "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                            "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                            "?=" "?." "//" "__" "~~" "(*" "*)"))
  (global-ligature-mode t))

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package ef-themes
  :config
  (custom-set-variables
   '(custom-enabled-themes '(ef-dark))
   '(custom-safe-themes
     '("1ad12cda71588cc82e74f1cabeed99705c6a60d23ee1bb355c293ba9c000d4ac"
       default)))
  (custom-set-faces
   '(internal-border ((t (:background "#000000"))))
   '(highlight-indent-guides-character-face ((t (:foreground "dim gray"))))
   '(org-block ((t (:background "#000000" :extend t))))
   '(org-block-begin-line ((t (:background "#000000" :extend t))))
   '(org-block-end-line ((t (:background "#000000" :extend t))))
   '(org-level-1 ((t (:inherit outline-1 :height 2.0))))
   '(org-level-2 ((t (:inherit outline-2 :height 1.8))))
   '(org-level-3 ((t (:inherit outline-3 :height 1.6))))
   '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
   '(org-level-5 ((t (:inherit outline-5 :height 1.2))))))

(setq inhibit-startup-message t)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(tool-bar-mode 0)
(setq-default indent-tabs-mode nil)  ;; Disable tabs (use spaces instead)
(setq-default tab-width 4)           ;; Set tab width to 4 spaces
(setq-default standard-indent 4)     ;; Set standard indentation to 4 spaces

(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative
      display-line-numbers-width 3)
(global-visual-line-mode t)

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :config
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (with-selected-frame frame
                (doom-modeline-mode 1))))
  (setq doom-modeline-buffer-file-name-style 'truncate-nil)
  (setq doom-modeline-total-line-number t))

(use-package nyan-mode
  :init (nyan-mode))

(set-frame-parameter nil 'alpha-background 100) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background . 100)) ; For all new frames henceforth

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Welcome Home...")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "/home/yousef/.emacs.d/images/image.jpg")  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package uniline)

(setq org-agenda-files '("/home/yousef/org/diary.org" 
                         "/home/yousef/org/my_todo_list.org" 
                         "/home/yousef/org/roadmap.org" 
                         "/home/yousef/org/25_todo_list.org"))

(setq org-ellipsis " ▾")
(setq org-hide-emphasis-markers t)
;; (setq org-hide-leading-stars t)
(setq org-startup-indented t)

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

;; (use-package org-depend
;;   :config
;;   (org-depend-initialize))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(require 'org-tempo)

(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))

(with-eval-after-load 'evil
  (evil-define-key 'normal org-mode-map (kbd "TAB") #'org-cycle) 
  (evil-define-key 'insert org-mode-map (kbd "TAB") #'org-cycle))

(use-package org-appear
  :config
    (add-hook 'org-mode-hook 'org-appear-mode))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  ;; Disable everything else
  (setq org-modern-table t               ;; no table styling
        org-modern-keyword nil             ;; keep #+keywords normal
        org-modern-block-fringe nil        ;; no fringe decoration
        org-modern-todo nil                ;; keep TODO keywords normal
        org-modern-tag nil                 ;; no special tag style
        org-modern-statistics nil          ;; don't prettify [1/3]
        org-modern-priority nil            ;; no special priority symbol
        org-modern-horizontal-rule nil     ;; disable HR line styling
        org-modern-checkbox nil)           ;; keep checkboxes normal
        org-modern-star '("" "")  ; Empty strings for both prefix and suffix
        org-modern-hide-stars t   ; Ensure stars are hidden
        org-indent-mode nil
        org-hide-leading-stars t)

(use-package avy
  :bind (("C-;" . avy-goto-char-timer))  ; Example: Jump to char with timer
  :config
  (setq avy-all-windows nil)  ; Only current window
  (setq avy-timeout-seconds 0.01))  ; Shorter delay
(use-package evil-snipe
  :config
  (evil-snipe-mode +1)
  (evil-snipe-override-mode +1))  ; Replace default f/F/t/T

(use-package projectile
  :config
  (projectile-mode 1))

(use-package transient)
(use-package magit
  :ensure t)
(use-package git-gutter
  :config
  (global-git-gutter-mode +1))

(use-package dired-open
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv")
                                ("pdf" . "zathura"))))

(use-package sudo-edit
  :config
  (yousef/leader-keys
    "fu" '(sudo-edit-find-file :wk "Sudo find file")
    "fU" '(sudo-edit :wk "Sudo edit file")))

(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit nil
        which-key-separator " → " ))

(use-package spacious-padding
  :after ef-themes
  :config (spacious-padding-mode 1))
(setq spacious-padding-widths
      '( :internal-border-width 30
         :header-line-width 2
         :mode-line-width 6
         :tab-width 6
         :right-divider-width 30
         :scroll-bar-width 15
         :fringe-width 20))
(let ((bg (face-background 'default)))
  (custom-set-faces
   `(internal-border ((t (:background ,bg))))
   `(fringe ((t (:background ,bg))))))
(let ((bg (face-attribute 'default :background)))
  (custom-set-faces
   `(internal-border ((t (:background ,bg :foreground ,bg))))))

;; Read the doc string of `spacious-padding-subtle-mode-line' as it
;; is very flexible and provides several examples.
;; (setq spacious-padding-subtle-mode-line
;;       `( :mode-line-active 'default
;;          :mode-line-inactive vertical-border))

(define-key global-map (kbd "<f8>") #'spacious-padding-mode)

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (add-hook 'eshell-mode-hook
            (lambda ()
              (define-key eshell-mode-map (kbd "M-j") 'eshell-next-input)    ; newer command
              (define-key eshell-mode-map (kbd "M-k") 'eshell-previous-input) ; older command
              ))
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.

(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))
(add-hook 'eshell-mode-hook
          (lambda ()
            (when (get-buffer-process (current-buffer))
              (goto-char (point-max)))))
(use-package esh-autosuggest  ; Install via MELPA
  :hook (eshell-mode . esh-autosuggest-mode)
  :config
  (define-key eshell-mode-map (kbd "M-j") 'esh-autosuggest-next)
  (define-key eshell-mode-map (kbd "M-k") 'esh-autosuggest-previous))

(add-hook 'eshell-mode-hook (lambda () (display-line-numbers-mode -1)))

(electric-pair-mode)

(defun my/inhibit-angle-bracket-pairing (char)
  (eq char ?<)) ;; inhibit pairing for '<'
(setq electric-pair-inhibit-predicate #'my/inhibit-angle-bracket-pairing)

(setq org-edit-src-content-indentation 0) ;; Set src block automatic indent to 0 instead of 2.
(use-package rainbow-delimiters
  :ensure t 
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (message "Rainbow delimiters loaded in programming buffers"))

(use-package rainbow-mode)

(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))
(setq auto-save-file-name-transforms '((".*" "~/.local/share/Trash/files/" t)))

(setq org-file-apps
      '((auto-mode . emacs)
        ("\\.pdf\\'" . "zathura %s")
        ("\\.png\\'" . "sxiv %s")
        ("\\.jpeg\\'" . "sxiv %s")
        ("\\.jpg\\'" . "sxiv %s")))

(with-eval-after-load 'ivy
  (define-key ivy-minibuffer-map (kbd "C-c")
              (lambda ()
                (interactive)
                (ivy-copy-file-path (ivy-state-current ivy-last)))))

(setq scroll-step 1
      scroll-margin 5
      scroll-conservatively 10000
      scroll-preserve-screen-position t)
(pixel-scroll-precision-mode t)



(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  ;; Core settings
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.1
        company-selection-wrap-around t
        company-show-numbers t
        company-tooltip-limit 10
        company-require-match 'never)

  ;; UI Enhancements
  (use-package company-box
    :ensure t
    :hook (company-mode . company-box-mode)
    :config
    (setq company-box-icons-alist 'company-box-icons-all-the-icons
          company-box-show-single-candidate t
          company-box-max-candidates 10))

  ;; Keybindings
  (with-eval-after-load 'company
    (define-key company-active-map (kbd "C-n") 'company-select-next)
    (define-key company-active-map (kbd "C-p") 'company-select-previous)
    (define-key company-active-map (kbd "C-y") 'company-complete-selection)))

;;(load "~/.emacs.d/crafted-emacs/modules/crafted-init-config")

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (racket-mode . lsp)
         (python-mode . lsp)
         (python-ts-mode . lsp)
         (c++-mode . lsp)
         (c++-ts-mode . lsp)
         (sh-mode . lsp)
         (c-mode . lsp)
         (c-ts-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)
;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package clang-format
  :config
  (setq clang-format-executable "/usr/bin/clang-format"))

(use-package racket-mode)

(use-package aggressive-indent
  :init (aggressive-indent-mode))

(use-package evil-surround
  :ensure t
  :after evil
  :config
  ;; Define our desired pairs without spaces
  (defconst my/evil-surround-pairs
    '((?\( . ("(" . ")"))
      (?\[ . ("[" . "]"))
      (?\{ . ("{" . "}"))
      (?\) . ("(" . ")"))
      (?\] . ("[" . "]"))
      (?\} . ("{" . "}"))))
  
  ;; Define our operator behavior without spaces
  (defconst my/evil-surround-operators
    (mapcar (lambda (entry)
              (if (member (car entry) '(?\( ?\[ ?\{ ?\) ?\] ?\}))
                  (cons (car entry) (cons "" ""))  ; No spaces
                entry))
            evil-surround-operator-alist))
  
  ;; Function to force our settings
  (defun my/apply-evil-surround-settings ()
    (setq-local evil-surround-pairs-alist my/evil-surround-pairs)
    (setq-local evil-surround-operator-alist my/evil-surround-operators))
  
  ;; Apply to all existing and future buffers
  (add-hook 'evil-surround-mode-hook 'my/apply-evil-surround-settings)
  (add-hook 'after-change-major-mode-hook 'my/apply-evil-surround-settings)
  
  ;; Initialize in all current buffers
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (bound-and-true-p evil-surround-mode)
        (my/apply-evil-surround-settings))))
  
  (global-evil-surround-mode 1))

(use-package yuck-mode)

;; Set C-style indentation to 4 spaces
(setq c-default-style "linux")  ; Uses 8 spaces by default, but we'll override
(setq c-basic-offset 4)         ; Force 4 spaces for all C indentation
;; C/C++ Indentation
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq c-default-style "linux")
            (setq c-basic-offset 4)
            (setq c++-default-style "linux")
            (setq c++-basic-offset 4)
            (c-set-offset 'substatement-open 0)  ; Align braces with control statements
            (electric-indent-local-mode 1)))     ; Auto-indent
(defun my/c++-ts-mode-setup ()
  "Set 4-space indentation in c++-ts-mode using treesit-simple-indent."
  (setq-local indent-tabs-mode nil)          ;; use spaces, not tabs
  (setq-local tab-width 4)                   ;; visual width of a tab
  (setq-local c-ts-mode-indent-offset 4))    ;; actual indent width

(add-hook 'c++-ts-mode-hook #'my/c++-ts-mode-setup)

(use-package geiser
  :ensure t
  :config
  (setq geiser-default-implementation 'mit)
  (setq geiser-active-implementations '(mit)))
(use-package geiser-mit
  :ensure t)

(defun toggle-fold ()
  (interactive)
  (save-excursion
    (end-of-line)
    (hs-toggle-hiding)))
(with-eval-after-load 'evil
(define-key evil-normal-state-map (kbd "zc") 'toggle-fold))

(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-responsive 'top) ; Highlight current scope
  (setq highlight-indent-guides-auto-enabled nil)
  (setq highlight-indent-guides-method 'character))

;;Enable Tree-sitter
(use-package tree-sitter
  :ensure t
  :config
  (add-hook 'sh-mode-hook #'tree-sitter-hl-mode))

;; Load the C grammar
(use-package tree-sitter-langs
  :ensure t
  :after tree-sitter)
(setq treesit-font-lock-level 4)
(add-to-list 'major-mode-remap-alist
             '(python-mode . python-ts-mode)
             '(c-mode . c-ts-mode)
             '(c++-mode . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . c-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-ts-mode))

(defun recover-my-wife ()
  "Wife gone? No problem. emacs got you covered"
  (interactive)
  (message "starting wife recovery")
  (let ((script-path "/home/yousef/.emacs.d/scripts/recover_this_wife.py"))
    (start-process "discord-dm" "*discord-dm-output*" script-path)))

(defun get-job ()
  "No job? No problem. emacs got you coverd... agian."
  (interactive)
  (message "Looking for a job")
  (let ((script-path "/home/yousef/.emacs.d/scripts/get_job.py"))
    (start-process "discord-dm" "*discord-dm-output*" script-path)))
