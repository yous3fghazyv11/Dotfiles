;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("bf42a0e2b86f1789f5c49ab6ccd6251a018d96728794832b3035da80ed01e693" "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" default))
 '(package-selected-packages
   '(beacon org-bullets toc-org corfu ligature ligatures company company-mode auto-complete vterm vterm-toggle all-the-icons-dired rainbow-mode all-the-icons-ivy-rich general all-the-icons helpful ivy-rich which-key rainbow-delimiters doom-themes counsel evil-collection evil ivy command-log-mode)))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-buffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil))

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
                          ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))

(setq display-line-numbers-type 'relative) 
(global-display-line-numbers-mode)

;; Disable line numbers for some modes
(dolist (mode '(term-mode-hook
                eshell-mode-hook
                org-mode-hook
                shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 30)))
(display-time-mode 1)
(display-battery-mode 1)

(use-package modus-themes)
(add-hook 'after-init-hook (lambda () (load-theme 'modus-vivendi-deuteranopia)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package all-the-icons
    :ensure t
    :if (display-graphic-p))
  (use-package all-the-icons-nerd-fonts)
  ;; uncomment me for doom modeline fonts
;;(nerd-icons-install-fonts)

  (use-package all-the-icons-dired
    :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package rainbow-mode
  :hook 
  ((org-mode prog-mode text-mode conf-mode) . rainbow-mode))

(global-hl-line-mode 1)

(global-prettify-symbols-mode 1)
(defun add-pretty-lambda ()
  "Make some word or string show as pretty Unicode symbols.  See https://unicodelookup.com for more."
  (setq prettify-symbols-alist
        '(("lambda" . 955)
          ("delta" . 120517)
          ("epsilon" . 120518)
          ("->" . 8594)
          ("<=" . 8804)
          (">=" . 8805))))
(add-hook 'prog-mode-hook 'add-pretty-lambda)
(add-hook 'org-mode-hook 'add-pretty-lambda)

(electric-pair-mode 1)
(setq electric-pair-inhibit-predicate
      (lambda (c)
        (if (char-equal c ?<) t (electric-pair-default-inhibit c))))

(use-package smooth-scroll)
(smooth-scroll-mode 1)
;; Vertical Scroll
(setq scroll-step 1)
(setq scroll-margin 20)
(setq scroll-conservatively 101)
(setq scroll-up-aggressively 0.01)
(setq scroll-down-aggressively 0.01)
(setq auto-window-vscroll nil)
(setq fast-but-imprecise-scrolling nil)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
;; Horizontal Scroll
(setq hscroll-step 1)
(setq hscroll-margin 1)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit outline-1 :height 1.4))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.2))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.2))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.0)))))

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(require 'org-tempo)

(use-package org-download)
(org-display-inline-images 1)

(use-package org-present)
;; Install visual-fill-column
(unless (package-installed-p 'visual-fill-column)
  (package-install 'visual-fill-column))

;; Configure fill width
(setq visual-fill-column-width 110
      visual-fill-column-center-text t)

(defun my/org-present-start ()
  ;; Center the presentation and wrap lines
  (visual-fill-column-mode 1)
  (visual-line-mode 1))

(defun my/org-present-end ()
  ;; Stop centering the document
  (visual-fill-column-mode 0)
  (visual-line-mode 0))

;; Register hooks with org-present
(add-hook 'org-present-mode-hook 'my/org-present-start)
(add-hook 'org-present-mode-quit-hook 'my/org-present-end)

(add-hook 'org-mode-hook #'visual-fill-column-mode)

(with-eval-after-load 'org
  (defvar-local rasmus/org-at-src-begin -1
    "Variable that holds whether last position was a ")

  (defvar rasmus/ob-header-symbol ?☰
    "Symbol used for babel headers")

  (defun rasmus/org-prettify-src--update ()
    (let ((case-fold-search t)
          (re "^[ \t]*#\\+begin_src[ \t]+[^ \f\t\n\r\v]+[ \t]*")
          found)
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward re nil t)
          (goto-char (match-end 0))
          (let ((args (org-trim
                       (buffer-substring-no-properties (point)
                                                       (line-end-position)))))
            (when (org-string-nw-p args)
              (let ((new-cell (cons args rasmus/ob-header-symbol)))
                (cl-pushnew new-cell prettify-symbols-alist :test #'equal)
                (cl-pushnew new-cell found :test #'equal)))))
        (setq prettify-symbols-alist
              (cl-set-difference prettify-symbols-alist
                                 (cl-set-difference
                                  (cl-remove-if-not
                                   (lambda (elm)
                                     (eq (cdr elm) rasmus/ob-header-symbol))
                                   prettify-symbols-alist)
                                  found :test #'equal)))
        ;; Clean up old font-lock-keywords.
        (font-lock-remove-keywords nil prettify-symbols--keywords)
        (setq prettify-symbols--keywords (prettify-symbols--make-keywords))
        (font-lock-add-keywords nil prettify-symbols--keywords)
        (while (re-search-forward re nil t)
          (font-lock-flush (line-beginning-position) (line-end-position))))))

  (defun rasmus/org-prettify-src ()
    "Hide src options via `prettify-symbols-mode'.

  `prettify-symbols-mode' is used because it has uncollpasing. It's
  may not be efficient."
    (let* ((case-fold-search t)
           (at-src-block (save-excursion
                           (beginning-of-line)
                           (looking-at "^[ \t]*#\\+begin_src[ \t]+[^ \f\t\n\r\v]+[ \t]*"))))
      ;; Test if we moved out of a block.
      (when (or (and rasmus/org-at-src-begin
                     (not at-src-block))
                ;; File was just opened.
                (eq rasmus/org-at-src-begin -1))
        (rasmus/org-prettify-src--update))
      ;; Remove composition if at line; doesn't work properly.
      ;; (when at-src-block
      ;;   (with-silent-modifications
      ;;     (remove-text-properties (match-end 0)
      ;;                             (1+ (line-end-position))
      ;;                             '(composition))))
      (setq rasmus/org-at-src-begin at-src-block)))

  (defun rasmus/org-prettify-symbols ()
    (mapc (apply-partially 'add-to-list 'prettify-symbols-alist)
          (cl-reduce 'append
                     (mapcar (lambda (x) (list x (cons (upcase (car x)) (cdr x))))
                             `(("#+begin_src" . ?➤) ;; ➤ 🖝 ➟ ➤ ✎
                               ("#+end_src"   . ?⏹) ;; ⏹
                               ("#+header:" . ,rasmus/ob-header-symbol)
                               ("#+begin_quote" . ?»)
                               ("#+end_quote" . ?«)))))
    (turn-on-prettify-symbols-mode)
    (add-hook 'post-command-hook 'rasmus/org-prettify-src t t))
  (add-hook 'org-mode-hook #'rasmus/org-prettify-symbols))
(setq org-hide-emphasis-markers t)

(define-key evil-insert-state-map [escape] 'evil-normal-state)
;; Normal mode key mappings
(define-key evil-normal-state-map (kbd "M-l") 'evil-last-non-blank)
(define-key evil-normal-state-map (kbd "M-h") 'evil-first-non-blank)
(define-key evil-insert-state-map (kbd "M-k") 'eshell-previous-matching-input-from-input)
(define-key evil-insert-state-map (kbd "M-j") 'eshell-next-matching-input-from-input)

;; Visual mode key mappings
(evil-define-key 'visual evil-visual-state-map (kbd "M-l") 'evil-forward-char)
(evil-define-key 'visual evil-visual-state-map (kbd "M-h") 'evil-backward-char)

(use-package general
  :config
  (general-evil-setup t))

;; set up 'SPC' as the global leader key
(general-create-definer ghazy/leader-keys
  :states '(normal insert visual emacs)
  :keymaps 'override
  :prefix "SPC" ;; set leader
  :global-prefix "M-SPC") ;; access leader in insert mode

(ghazy/leader-keys
  "b" '(:ignore t :wk "buffer")
  "bi" '(ibuffer :wk "Ibuffer")
  "bb" '(counsel-ibuffer :wk "Switch buffer")
  "bk" '(kill-this-buffer :wk "Kill this buffer")
  "bn" '(next-buffer :wk "Next buffer")
  "bp" '(previous-buffer :wk "Previous buffer")
  "br" '(revert-buffer :wk "Reload buffer")
  "be" '(switch-to-eshell-buffer :wk "switch buffer to eshell"))

(ghazy/leader-keys
  "." '(counsel-find-file :wk "Find file")
  "f c" '((lambda () (interactive) (find-file "~/.emacs.d/config.org")) :wk "Edit emacs config")
  "TAB TAB" '(comment-line :wk "Comment lines")
  "v f" '(visual-fill-column-mode :wk "centre text")
  "t t" '(visual-line-mode :wk "Toggle truncated lines")
  "m t" '(modus-themes-select :wk "Toggle truncated lines"))

(ghazy/leader-keys
  "e" '(:ignore t :wk "Evaluate")    
  "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
  "e d" '(eval-defun :wk "Evaluate defun containing or after point")
  "e e" '(eval-expression :wk "Evaluate and elisp expression")
  "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
  "e r" '(eval-region :wk "Evaluate elisp in region"))

(ghazy/leader-keys
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

(ghazy/leader-keys
  "l" '(:ignore t :wk "lsp")    
  "l f" '(lsp-format-buffer :wk "format current document")
  "c a" '(lsp-execute-code-action :wk "apply code actions")
  "l j" '(flycheck-next-error :wk "goto next error")
  "l k" '(flycheck-previous-error :wk "goto previous error")
  "g D" '(lsp-find-declaration :wk "go to declaration")
  "g d" '(lsp-find-definition :wk "go to definition")
  "l K" '(lsp-ui-doc-toggle :wk "toggle documentation")
  "l r" '(lsp-rename :wk "rename"))

(use-package key-chord)
;;Exit insert mode by pressing j and then j quickly
(setq key-chord-two-keys-delay 0.5)
(key-chord-define evil-insert-state-map "jk" 'evil-normal-state)
(key-chord-define evil-insert-state-map "تن" 'evil-normal-state)
(key-chord-mode 1)

;; Define keybindings for Emacs
(evil-define-key 'insert 'global (kbd "M-l") 'forward-char)
(evil-define-key 'insert 'global (kbd "M-h") 'backward-char)

(set-face-attribute 'default nil
                    :font "JetBrains Mono NF"
                    :height 100
                    :weight 'bold)
(set-face-attribute 'variable-pitch nil
                    :font "JetBrains Mono NF"
                    :height 100
                    :weight 'bold)
(set-face-attribute 'fixed-pitch nil
                    :font "JetBrains Mono NF"
                    :height 100
                    :weight 'bold)
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
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-9"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

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



(use-package yasnippet
  :diminish yas-minor-mode
  :init
  (use-package yasnippet-snippets :after yasnippet)
  :hook ((prog-mode LaTeX-mode org-mode markdown-mode) . yas-minor-mode)
  :bind
  (:map yas-minor-mode-map ("C-c C-n" . yas-expand-from-trigger-key))
  (:map yas-keymap
        (("TAB" . smarter-yas-expand-next-field)
         ([(tab)] . smarter-yas-expand-next-field)))
  :config
  (yas-reload-all)
  (defun smarter-yas-expand-next-field ()
    "Try to `yas-expand' then `yas-next-field' at current cursor position."
    (interactive)
    (let ((old-point (point))
          (old-tick (buffer-chars-modified-tick)))
      (yas-expand)
      (when (and (eq old-point (point))
                 (eq old-tick (buffer-chars-modified-tick)))
        (ignore-errors (yas-next-field))))))

(use-package flycheck
  :defer t
  :diminish
  :hook (after-init . global-flycheck-mode)
  :commands (flycheck-add-mode)
  :custom
  (flycheck-global-modes
   '(not outline-mode diff-mode shell-mode eshell-mode term-mode))
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-indication-mode (if (display-graphic-p) 'right-fringe 'right-margin))
  :init
  (if (display-graphic-p)
      (use-package flycheck-posframe
        :custom-face
        (flycheck-posframe-face ((t (:foreground ,(face-foreground 'success)))))
        (flycheck-posframe-info-face ((t (:foreground ,(face-foreground 'success)))))
        :hook (flycheck-mode . flycheck-posframe-mode)
        :custom
        (flycheck-posframe-position 'window-bottom-left-corner)
        (flycheck-posframe-border-width 3)
        (flycheck-posframe-inhibit-functions
         '((lambda (&rest _) (bound-and-true-p company-backend)))))
    (use-package flycheck-pos-tip
      :defines flycheck-pos-tip-timeout
      :hook (flycheck-mode . flycheck-pos-tip-mode)
      :custom (flycheck-pos-tip-timeout 30)))
  :config
  (use-package flycheck-popup-tip
    :hook (flycheck-mode . flycheck-popup-tip-mode))
  (when (fboundp 'define-fringe-bitmap)
    (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
      [16 48 112 240 112 48 16] nil nil 'center))
  (when (executable-find "vale")
    (use-package flycheck-vale
      :config
      (flycheck-vale-setup)
      (flycheck-add-mode 'vale 'latex-mode))))

(use-package flyspell
  :ensure nil
  :diminish
  :if (executable-find "aspell")
  :hook (((text-mode outline-mode latex-mode org-mode markdown-mode) . flyspell-mode))
  :custom
  (flyspell-issue-message-flag nil)
  (ispell-program-name "aspell")
  (ispell-extra-args
   '("--sug-mode=ultra" "--lang=en_US" "--camel-case"))
  :config
  (use-package flyspell-correct-ivy
    :after ivy
    :bind
    (:map flyspell-mode-map
          ([remap flyspell-correct-word-before-point] . flyspell-correct-wrapper)
          ("C-." . flyspell-correct-wrapper))
    :custom (flyspell-correct-interface #'flyspell-correct-ivy)))

(setq package-selected-packages '(lsp-mode lsp-treemacs 
                                           projectile hydra company avy which-key dap-mode))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

(which-key-mode)
(add-hook 'c-mode-hook 'lsp 'tree-sitter-hl-mode)
(add-hook 'c++-mode-hook 'lsp 'tree-sitter-hl-mode)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (require 'dap-cpptools)
  (yas-global-mode))

(setq backup-directory-alist '((".*" . "~/.Trash")))

(use-package highlight-indent-guides
  :ensure t
  :hook (python-ts-mode . highlight-indent-guides-mode)
  :config
  (set-face-foreground 'highlight-indent-guides-character-face "white")
  (setq highlight-indent-guides-method 'character))

(use-package lsp-ui)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq c-set-style "k&r")
(setq c-basic-offset 4)

(defun switch-to-eshell-buffer ()
  "Switch to the eshell buffer."
  (interactive)
  (if (get-buffer "*eshell*")
      (switch-to-buffer "*eshell*")
    (eshell)))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package highlight-indent-guides)
(add-hook 'c-mode-hook 'highlight-indent-guides-mode)

(use-package modern-cpp-font-lock
  :diminish t
  :init (modern-c++-font-lock-global-mode t))
(font-lock-add-keywords 'c++-mode
                        `((,(concat
                             "\\<[_a-zA-Z][_a-zA-Z0-9]*\\>"       ; Object identifier
                             "\\s *"                              ; Optional white space
                             "\\(?:\\.\\|->\\)"                   ; Member access
                             "\\s *"                              ; Optional white space
                             "\\<\\([_a-zA-Z][_a-zA-Z0-9]*\\)\\>" ; Member identifier
                             "\\s *"                              ; Optional white space
                             "(")                                 ; Paren for method invocation
                           1 'font-lock-function-name-face t)))

(setq js-indent-level 4)
(use-package typescript-ts-mode
  :config
  (defun my/ts-mode-hook ()
    (lsp-deferred))
  (add-hook 'typescript-ts-mode-hook  #'my/ts-mode-hook)
  :mode (("\\.ts\\'" . typescript-ts-mode)
         ("\\.js\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)))

(add-to-list 'org-emphasis-alist
             '("*" (:foreground "red")
               ))

(use-package auctex
  :ensure t
  :defer t
  :hook (LaTeX-mode . (lambda ()
                        (push (list 'output-pdf "Zathura")
                              TeX-view-program-selection))))
(add-hook 'doc-view-mode-hook 'auto-revert-mode)

(use-package pdf-tools
  :defer t
  :commands (pdf-loader-install)
  :mode "\\.pdf\\'"
  :init (pdf-loader-install)
  :config (add-to-list 'revert-without-query ".pdf"))
(add-hook 'pdf-view-mode-hook #'(lambda () (interactive) (display-line-numbers-mode -1)))


