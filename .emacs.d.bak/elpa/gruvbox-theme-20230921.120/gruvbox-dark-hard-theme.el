;;; gruvbox-dark-hard-theme.el --- A retro-groove colour theme for Emacs -*- lexical-binding: t -*-

;; Copyright (c) 2013 Lee Machin
;; Copyright (c) 2013-2016 Eduardo Lavaque
;; Copyright (c) 2016-2022 Jason Milkins
;; Copyright (c) 2017-2018 Martijn Terpstra

;; Author: Jason Milkins <jasonm23@gmail.com>
;; (current maintainer)
;;
;; Author-list: Jason Milkins <jasonm23@gmail.com>,
;;              Martijn Terpstra,
;;              Eduardo Lavaque <me@greduan.com>,
;;              Lee Machin <ljmachin@gmail.com>
;;
;; URL: https://github.com/greduan/emacs-theme-gruvbox
;; Version: 1.30.1

;; Package-Requires: ((autothemer "0.2"))

;;; Commentary:

;; Using autothemer since 1.00

;; A port of the Gruvbox colorscheme for Vim, built on top of the new built-in
;; theme support in Emacs 24.
;;
;; This theme contains my own modifications and it's a bit opinionated
;; sometimes, deviating from the original because of it. I try to stay
;; true to the original as much as possible, however. I only make
;; changes where I would have made the changes on the original.
;;
;; Since there is no direct equivalent in syntax highlighting from Vim to Emacs
;; some stuff may look different, especially in stuff like JS2-mode, where it
;; adds stuff that Vim doesn't have, in terms of syntax.

;;; Credits:

;; Pavel Pertsev created the original theme for Vim, on which this port
;; is based.

;; Lee Machin created the first port of the original theme, which
;; Greduan developed further adding support for several major modes.
;;
;; Jason Milkins (ocodo) has maintained the theme since 2015 and is
;; working with the community to add further mode support and align
;; the project more closely with Vim Gruvbox.

;;; Code:
(eval-when-compile
  (require 'cl-lib))

(require 'gruvbox)

(gruvbox-deftheme
 gruvbox-dark-hard
 "A retro-groove colour theme (dark version, hard contrast)"

 ((((class color) (min-colors #xFFFFFF))        ; col 1 GUI/24bit
   ((class color) (min-colors #xFF)))           ; col 2 Xterm/256

  (gruvbox-dark0_hard      "#000000" "#000000")
  (gruvbox-dark0           "#000000" "#000000")
  (gruvbox-dark0_soft      "#000000" "#000000")
  (gruvbox-dark1           "#000000" "#000000")
  (gruvbox-dark2           "#000000" "#000000")
  (gruvbox-dark3           "#000000" "#000000")
  (gruvbox-dark4           "#000000" "#000000")

  (gruvbox-gray            "#000000" "#000000")

  (gruvbox-light0_hard     "#000000" "#000000")
  (gruvbox-light0          "#000000" "#000000")
  (gruvbox-light1          "#000000" "#000000")
  (gruvbox-light2          "#000000" "#000000")
  (gruvbox-light3          "#000000" "#000000")
  (gruvbox-light4          "#000000" "#000000")

  (gruvbox-bright_red      "#000000" "#000000")
  (gruvbox-bright_green    "#000000" "#000000")
  (gruvbox-bright_yellow   "#000000" "#000000")
  (gruvbox-bright_blue     "#000000" "#000000")
  (gruvbox-bright_purple   "#000000" "#000000")
  (gruvbox-bright_aqua     "#8ec07c" "#000000")
  (gruvbox-bright_orange   "#000000" "#000000")

  (gruvbox-neutral_red     "#000000" "#000000")
  (gruvbox-neutral_green   "#000000" "#000000")
  (gruvbox-neutral_yellow  "#000000" "#000000")
  (gruvbox-neutral_blue    "#000000" "#000000")
  (gruvbox-neutral_purple  "#000000" "#000000")
  (gruvbox-neutral_aqua    "#000000" "#000000")
  (gruvbox-neutral_orange  "#000000" "#000000")
  
  (gruvbox-faded_red       "#000000" "#000000")
  (gruvbox-faded_green     "#000000" "#000000")
  (gruvbox-faded_yellow    "#000000" "#000000")
  (gruvbox-faded_blue      "#000000" "#000000")
  (gruvbox-faded_purple    "#000000" "#000000")
  (gruvbox-faded_aqua      "#000000" "#000000")
  (gruvbox-faded_orange    "#000000" "#000000")

  (gruvbox-dark_red        "#000000" "#000000")
  (gruvbox-dark_blue       "#000000" "#000000")
  (gruvbox-dark_aqua       "#000000" "#000000")

  (gruvbox-delimiter-one   "#000000" "#000000")
  (gruvbox-delimiter-two   "#000000" "#000000")
  (gruvbox-delimiter-three "#000000" "#000000")
  (gruvbox-delimiter-four  "#000000" "#000000")
  (gruvbox-white           "#000000" "#000000")
  (gruvbox-black           "#000000" "#000000")
  (gruvbox-sienna          "#000000" "#000000")
  (gruvbox-lightblue4      "#000000" "#000000")
  (gruvbox-burlywood4      "#000000" "#000000")
  (gruvbox-aquamarine4     "#000000" "#000000")
  (gruvbox-turquoise4      "#000000" "#000000")

  (gruvbox-accent-00       "#000000" "#000000")
  (gruvbox-accent-01       "#000000" "#000000")
  (gruvbox-accent-02       "#000000" "#000000")
  (gruvbox-accent-03       "#000000" "#000000")
  (gruvbox-accent-04       "#000000" "#000000")
  (gruvbox-accent-05       "#8ec07c" "#87af87")
  (gruvbox-accent-06       "#fe8019" "#ff8700")
  (gruvbox-accent-07       "#fb4934" "#d75f5f")
  (gruvbox-accent-08       "#b8bb26" "#afaf00")
  (gruvbox-accent-09       "#fabd2f" "#ffaf00")
  (gruvbox-accent-10       "#83a598" "#87afaf")
  (gruvbox-accent-11       "#d3869b" "#d787af")
  (gruvbox-accent-12       "#8ec07c" "#87af87")
  (gruvbox-accent-13       "#fe8019" "#ff8700")
  (gruvbox-accent-14       "#fb4934" "#d75f5f")
  (gruvbox-accent-15       "#b8bb26" "#afaf00")

  (gruvbox-ediff-current-diff-A        "#4f2121" "#4f2121")
  (gruvbox-ediff-current-diff-B        "#243c24" "#5f5f00")
  (gruvbox-ediff-current-diff-C        "#4f214f" "#4f214f")
  (gruvbox-ediff-current-diff-Ancestor "#21214f" "#21214f")
  (gruvbox-ediff-fine-diff-A           "#761919" "#761919")
  (gruvbox-ediff-fine-diff-B           "#1c691c" "#1c691c")
  (gruvbox-ediff-fine-diff-C           "#761976" "#761976")
  (gruvbox-ediff-fine-diff-Ancestor    "#12129d" "#12129d")

  (gruvbox-bg gruvbox-dark0_hard)
  (gruvbox-bg_inactive gruvbox-dark0))

 (custom-theme-set-variables 'gruvbox-dark-hard
                             `(ansi-color-names-vector
                               [,gruvbox-dark1
                                ,gruvbox-bright_red
                                ,gruvbox-bright_green
                                ,gruvbox-bright_yellow
                                ,gruvbox-bright_blue
                                ,gruvbox-bright_purple
                                ,gruvbox-bright_aqua
                                ,gruvbox-light1])
                             `(pdf-view-midnight-colors '(,gruvbox-light0 . ,gruvbox-bg))))

;;;###autoload
(and load-file-name
     (boundp 'custom-theme-load-path)
     (add-to-list 'custom-theme-load-path
                  (file-name-as-directory
                   (file-name-directory load-file-name))))

(provide-theme 'gruvbox-dark-hard)

;; Local Variables:
;; eval: (when (fboundp 'rainbow-mode) (rainbow-mode +1))
;; End:

;;; gruvbox-dark-hard-theme.el ends here
