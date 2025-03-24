;;; refcount.el --- AUCTeX style for refcount package v3.6  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Free Software Foundation, Inc.

;; Author: Uwe Brauer <oub@mat.ucm.es>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2023-12-02
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

;; This file adds support for the refcount package v3.6.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords
                  "font-latex"
                  (keywords class))

(TeX-add-style-hook
 "refcount"
 (lambda ()
   (TeX-add-symbols
    ;; 1.1 Setting counters
    '("setcounterref" TeX-arg-counter TeX-arg-ref)
    '("addtocounterref" TeX-arg-counter TeX-arg-ref)
    '("setcounterpageref" TeX-arg-counter TeX-arg-ref)
    '("addcounterpageref" TeX-arg-counter TeX-arg-ref)
    ;; 1.2 Expandable commands
    '("getrefnumber"  TeX-arg-ref)
    '("getpagerefnumber"  TeX-arg-ref)
    '("setrefcountdefault" "Default")
    '("getrefbykeydefault"
      TeX-arg-ref
      (TeX-arg-completing-read ("page" "title" "name" "anchor" "url"))
      "Default")
    ;; 1.3 Undefined references
    '("refused" TeX-arg-ref)
    '("IfRefUndefinedExpandable" TeX-arg-ref 2)
    '("IfRefUndefinedBabel" TeX-arg-ref 2))

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("setcounterref"     "{{")
                                ("addtocounterref"   "{{")
                                ("setcounterpageref" "{{")
                                ("addcounterpageref" "{{"))
                              'variable)
     (font-latex-add-keywords '(("getrefnumber"       "{")
                                ("getpagerefnumber"   "{")
                                ("getrefbykeydefault" "{{{")
                                ("refused"            "{"))
                              'reference)
     (font-latex-add-keywords '(("setrefcountdefault"       "{")
                                ("IfRefUndefinedExpandable" "{{{")
                                ("IfRefUndefinedBabel"      "{{{"))
                              'function))

   ;; Activate RefTeX reference style
   (and LaTeX-reftex-ref-style-auto-activate
        (fboundp 'reftex-ref-style-activate)
        (reftex-ref-style-activate "Refcount")))
 TeX-dialect)

(defvar LaTeX-refcount-package-options nil
  "Package options for the refcount package.")

;;; refcount.el ends here
