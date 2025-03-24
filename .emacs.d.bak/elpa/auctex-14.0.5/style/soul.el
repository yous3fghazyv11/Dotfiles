;;; soul.el --- AUCTeX style for `soul.sty' (v3.0)  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2023-04-21
;; Keywords: tex

;; This file is part of AUCTeX.

;; AUCTeX is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; AUCTeX is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with AUCTeX; see the file COPYING.  If not, write to the Free
;; Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
;; 02110-1301, USA.

;;; Commentary:

;; This file adds support for `soul.sty' (v3.0) from 2023-18-02.
;; `soul.sty' is part of TeXLive.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords
                  "font-latex"
                  (keywords class))
(declare-function LaTeX-color-definecolor-list "color.el" ())
(declare-function LaTeX-xcolor-definecolor-list "xcolor.el" ())

;; Setup for \sodef:
(TeX-auto-add-type "soul-sodef" "LaTeX")

(defvar LaTeX-soul-sodef-regexp
  `(,(concat "\\\\sodef{?\\\\\\(" TeX-token-char "+\\)")
    1 LaTeX-auto-soul-sodef))

(defun LaTeX-soul-auto-prepare ()
  "Reset `LaTeX-auto-soul-sodef' before parsing."
  (setq LaTeX-auto-soul-sodef nil))

(defun LaTeX-soul-auto-cleanup ()
  "Process new macros defined with \\sodef."
  (dolist (elt (LaTeX-soul-sodef-list))
    (let ((mac (car elt)))
      (TeX-add-symbols `(,mac "Text"))
      (when (and (featurep 'font-latex)
                 (eq TeX-install-font-lock 'font-latex-setup))
        (font-latex-add-keywords `((,mac "{")) 'bold-command)))))

(add-hook 'TeX-auto-prepare-hook #'LaTeX-soul-auto-prepare t)
(add-hook 'TeX-auto-cleanup-hook #'LaTeX-soul-auto-cleanup t)
(add-hook 'TeX-update-style-hook #'TeX-auto-parse t)

(TeX-add-style-hook
 "soul"
 (lambda ()

   (TeX-auto-add-regexp LaTeX-soul-sodef-regexp)

   ;; New symbols
   (TeX-add-symbols
    '("so"   "Text")
    '("caps" "Text")
    '("ul"   "Text")
    '("st"   "Text")
    '("hl"   "Text")
    '("sloppyword" "Text")

    `("sodef"
      ,(lambda (optional)
         (let ((mac (TeX-read-string
                     (TeX-argument-prompt optional nil "Macro: \\" t)))
               (TeX-arg-opening-brace "")
               (TeX-arg-closing-brace ""))
           (LaTeX-add-soul-sodefs mac)
           (LaTeX-soul-auto-cleanup)
           (TeX-argument-insert mac optional TeX-esc)))
      (TeX-arg-completing-read LaTeX-font-shape "Font: \\" t ,TeX-esc)
      "Inner-letter space" "Inner space" "Outer space"
      (lambda (_optional)
        (set-marker TeX-exit-mark (point))))

    "resetso"

    `("capsdef"
      (TeX-arg-string "Font" "////")
      (TeX-arg-completing-read LaTeX-font-shape "Font: \\" t ,TeX-esc)
      "Inner-letter space" "Inner space" "Outer space")

    "capsreset"
    '("capssave" "Name")
    '("capsselect" "Name")

    '("setul" "Underline depth" "Underline thickness")
    "resetul"
    '("setuldepth" "Underline depth")

    '("setuloverlap" "Overlap")
    '("soulaccent" (TeX-arg-string "Accent command" "\\"))
    '("soulregister" TeX-arg-macro "Number of arguments"))

   ;; The next macros are only added if a color package is loaded:
   (when (TeX-member "\\`x?color\\'" (TeX-style-list) #'string-match)
     (TeX-add-symbols
      `("setulcolor" (TeX-arg-completing-read
                      ,(lambda ()
                         (if (member "xcolor" (TeX-style-list))
                             (LaTeX-xcolor-definecolor-list)
                           (LaTeX-color-definecolor-list)))
                      "Color"))
      `("setstcolor" (TeX-arg-completing-read
                      ,(lambda ()
                         (if (member "xcolor" (TeX-style-list))
                             (LaTeX-xcolor-definecolor-list)
                           (LaTeX-color-definecolor-list)))
                      "Color"))
      `("sethlcolor" (TeX-arg-completing-read
                      ,(lambda ()
                         (if (member "xcolor" (TeX-style-list))
                             (LaTeX-xcolor-definecolor-list)
                           (LaTeX-color-definecolor-list)))
                      "Color"))))
   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("so"         "|{\\")
                                ("caps"       "|{\\")
                                ("st"         "|{\\")
                                ("hl"         "|{\\")
                                ("sloppyword" "|{\\"))
                              'bold-command)
     (font-latex-add-keywords '(("ul"   "|{\\"))
                              'underline-command)
     (font-latex-add-keywords '(("setulcolor" "{")
                                ("setstcolor" "{")
                                ("sethlcolor" "{")
                                ("sodef"      "|{\\{{{{")
                                ("resetso"    "")
                                ("capsdef"    "|{\\{{{{")
                                ("capsreset"  "")
                                ("capssave"   "{")
                                ("capsselect" "{")
                                ("setul"      "{{")
                                ("resetul"    "")
                                ("setuldepth" "{")
                                ("setuloverlap" "{")
                                ("soulaccent"   "{")
                                ("soulregister" "{{"))
                              'function)))
 TeX-dialect)

(defvar LaTeX-soul-package-options '("capsdefault")
  "Package options for the soul package.")

;;; soul.el ends here
