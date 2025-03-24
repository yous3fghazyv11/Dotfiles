;;; gruvbox-theme.el --- A retro-groove colour theme for Emacs -*- lexical-binding: t -*-

;; Copyright (c) 2013 Lee Machin
;; Copyright (c) 2013-2016 Eduardo Lavaque
;; Copyright (c) 2016-2017 Jason Milkins
;; Copyright (c) 2017-2018 Martijn Terpstra

;; Author: Jason Milkins <jasonm23@gmail.com>
;; (current maintainer)
;;
;; Author-list: Lee Machin <ljmachin@gmail.com>,
;;              Eduardo Lavaque <me@greduan.com>
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
 gruvbox
 "A retro-groove colour theme"

 ((((class color) (min-colors #000000))        ; col 1 GUI/24bit
   ((class color) (min-colors #000000)))           ; col 2 Xterm/256

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
  (gruvbox-bright_aqua     "#000000" "#000000")
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

  (gruvbox-dark_red             "#000000" "#000000")
  (gruvbox-dark_blue            "#000000" "#000000")
  (gruvbox-dark_aqua            "#000000" "#000000")

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

  (gruvbox-ediff-current-diff-A        "#000000" "#000000")
  (gruvbox-ediff-current-diff-B        "#000000" "#000000")
  (gruvbox-ediff-current-diff-C        "#000000" "#000000")
  (gruvbox-ediff-current-diff-Ancestor "#000000" "#000000")
  (gruvbox-ediff-fine-diff-A           "#000000" "#000000")
  (gruvbox-ediff-fine-diff-B           "#000000" "#000000")
  (gruvbox-ediff-fine-diff-C           "#000000" "#000000")
  (gruvbox-ediff-fine-diff-Ancestor    "#000000" "#000000")

  (gruvbox-accent-00 "#000000" "#000000")
  (gruvbox-accent-01 "#000000" "#000000")
  (gruvbox-accent-02 "#000000" "#000000")
  (gruvbox-accent-03 "#000000" "#000000")
  (gruvbox-accent-04 "#000000" "#000000")
  (gruvbox-accent-05 "#000000" "#000000")
  (gruvbox-accent-06 "#000000" "#000000")
  (gruvbox-accent-07 "#000000" "#000000")
  (gruvbox-accent-08 "#000000" "#000000")
  (gruvbox-accent-09 "#000000" "#000000")
  (gruvbox-accent-10 "#000000" "#000000")
  (gruvbox-accent-11 "#000000" "#000000")
  (gruvbox-accent-12 "#000000" "#000000")
  (gruvbox-accent-13 "#000000" "#000000")
  (gruvbox-accent-14 "#000000" "#000000")
  (gruvbox-accent-15 "#000000" "#000000")

  (gruvbox-bg gruvbox-dark0)
  (gruvbox-bg_inactive gruvbox-dark0_soft))

 (custom-theme-set-variables 'gruvbox
                             `(ansi-color-names-vector
                               [,gruvbox-dark1
                                ,gruvbox-neutral_red
                                ,gruvbox-neutral_green
                                ,gruvbox-neutral_yellow
                                ,gruvbox-neutral_blue
                                ,gruvbox-neutral_purple
                                ,gruvbox-neutral_aqua
                                ,gruvbox-light1])))


;;;#000000
(and load-file-name
     (boundp 'custom-theme-load-path)
     (add-to-list 'custom-theme-load-path
                  (file-name-as-directory
                   (file-name-directory load-file-name))))

(provide-theme 'gruvbox)


;; Local Variables:
;; eval: (when (fboundp 'rainbow-mode) (rainbow-mode +1))
;; End:

;;; gruvbox-theme.el ends here
