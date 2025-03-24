;;; changebar.el --- AUCTeX style for `changebar.sty' (v3.7b)  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2023-12-30
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

;; This file adds support for `changebar.sty' (v3.7b) from 2023/12/30.
;; `changebar.sty' is part of TeXLive.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords "font-latex" (keywords class))

(TeX-add-style-hook
 "changebar"
 (lambda ()

   ;; 2.2 Macros defined by the package
   (TeX-add-symbols
    '("cbstart"
      [TeX-arg-length "Width"]
      (lambda (_)
        (indent-according-to-mode)
        (LaTeX-newline)
        (indent-according-to-mode)
        (save-excursion
          (LaTeX-newline)
          (insert "\\cbend")
          (indent-according-to-mode))))
    '("cbend" 0)
    '("cbdelete" [TeX-arg-length "Width"])
    "nochangebars")

   ;; Options management:
   (when (LaTeX-provided-package-options-member "changebar" "color")
     (TeX-run-style-hooks "color")
     (TeX-add-symbols '("cbcolor" TeX-arg-color)))

   (when (LaTeX-provided-package-options-member "changebar" "xcolor")
     (TeX-run-style-hooks "xcolor")
     (TeX-add-symbols '("cbcolor" TeX-arg-xcolor)))

   (when (or (LaTeX-provided-package-options-member "changebar" "xetex")
             (LaTeX-provided-package-options-member "changebar" "XeTeX"))
     (TeX-check-engine-add-engines 'xetex))

   (when (or (LaTeX-provided-package-options-member "changebar" "luatex")
             (LaTeX-provided-package-options-member "changebar" "luaTeX"))
     (TeX-check-engine-add-engines 'luatex))

   (LaTeX-add-environments
    '("changebar" LaTeX-env-args [TeX-arg-length "Width"]))

   ;; Let the commands have their own lines:
   (LaTeX-paragraph-commands-add-locally '("cbstart" "cbend"))

   ;; Cater for indentation:
   (add-to-list 'LaTeX-indent-begin-list "cbstart" t)
   (add-to-list 'LaTeX-indent-end-list "cbend" t)
   (LaTeX-indent-commands-regexp-make)

   ;; 2.3 Changebar parameters
   (LaTeX-add-lengths "changebarwidth" "deletebarwidth" "changebarsep")
   (LaTeX-add-counters "changebargrey")

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("cbstart"  "[")
                                ("cbdelete" "["))
                              'function)
     (font-latex-add-keywords '("cbend" "nochangebars")
                              'function-noarg)
     (when (or (member "xcolor" (TeX-style-list))
               (member "color" TeX-active-styles))
       (font-latex-add-keywords '(("cbcolor" "[{"))
                                'type-declaration))))
 TeX-dialect)

(defvar LaTeX-changebar-package-options
  '("dvitoln03" "dvitops" "dvips" "emtex" "textures"
    "vtex" "pdftex" "xetex" "luatex"
    "outerbars" "innerbars" "leftbars" "rightbars"
    "traceon" "traceoff" "tracestacks"
    "grey" "color" "xcolor")
  "Package options for the changebar package.
This variable contains only the lowercase version of the options.")
