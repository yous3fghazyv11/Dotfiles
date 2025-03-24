;;; amsrefs.el --- AUCTeX style for `amsrefs.sty'  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2024-02-21
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
;; Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;; MA 02110-1301 USA.

;;; Commentary:

;; This file adds support for `amsrefs.sty' form 2013-01-16.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords
                  "font-latex"
                  (keywords class))

(defun LaTeX-item-amsrefs-bib ()
  "Insert a new bib item from the amsrefs package."
  (TeX-insert-macro "bib"))

(defun LaTeX-env-amsrefs-biblist (_environment)
  "Ignore ENVIRONMENT and insert a \"biblist\" environment with arguments."
  (let ((opt (TeX-read-string
              (TeX-argument-prompt t nil "argument")))
        (keyvals (unless (LaTeX-provided-class-options-member "amsrefs"
                                                              "author-year")
                   (TeX-read-key-val t '(("labels" ("numeric" "alphabetic"
                                                    "shortalphabetic"))
                                         ("prefix"))))))
    (LaTeX-insert-environment "biblist"
                              (concat (unless (string-empty-p opt)
                                        (concat LaTeX-optop opt LaTeX-optcl))
                                      (unless (string-empty-p keyvals)
                                        (concat "*" TeX-grop keyvals TeX-grcl)))))
  (end-of-line 0)
  (delete-char 1)
  (delete-horizontal-space)
  (LaTeX-insert-item))

(defvar LaTeX-amsrefs-bib-regexp
  `(,(concat "\\\\bib\\*?{\\(" TeX-token-char "[^, \n\r\t%\"#'()={}]*\\)}")
    1 LaTeX-auto-bibitem)
  "Matches the cite key after the \\bib macro.")

(defvar LaTeX-amsrefs-bib-key-val
  '(;; Simple fields
    ("accessdate")
    ("address")
    ("booktitle")
    ("date")
    ("edition")
    ("eprint")
    ("hyphenation")
    ("journal")
    ("label")
    ("language")
    ("note")
    ("number")
    ("organization")
    ("pages")
    ("part")
    ("publisher")
    ("series")
    ("status")
    ("subtitle")
    ("title")
    ("type")
    ("volume")
    ;; Repeatable fields
    ("author")
    ("editor")
    ("translator")
    ("isbn")
    ("issn")
    ("review")
    ;; Compound fields: Not support by key=val system
    ("book" ("{}"))
    ("conference" ("{}"))
    ("contribution" ("{}"))
    ("partial" ("{}"))
    ("reprint" ("{}"))
    ("translation" ("{}")))
  "Key=val options for the \\bib macro from amsrefs package.")

(defun LaTeX-amsrefs-bib-key-val ()
  "Return an updated list of key=vals for the amsrefs package."
  (append `(("xref" ,(mapcar #'car (LaTeX-bibitem-list))))
          LaTeX-amsrefs-bib-key-val))

(TeX-add-style-hook
 "amsrefs"
 (lambda ()

   ;; Add the entry to the parser
   (TeX-auto-add-regexp LaTeX-amsrefs-bib-regexp)

   ;; 3 The biblist and biblist* environments
   (LaTeX-add-environments
    '("bibdiv")
    '("biblist" LaTeX-env-amsrefs-biblist)
    '("biblist*" LaTeX-env-amsrefs-biblist))

   (TeX-add-symbols
    ;; 5 More about the \bib command
    '("bib" "Bibitem label"
      (TeX-arg-completing-read ("article" "book" "misc" "report"
                                "thesis" "web")
                               "Entry type")
      (TeX-arg-key-val (LaTeX-amsrefs-bib-key-val)
                       "Field names"))

    '("bib*" "Bibitem label"
      (TeX-arg-completing-read ("article" "book" "misc" "report"
                                "thesis" "web")
                               "Entry type")
      (TeX-arg-key-val (LaTeX-amsrefs-bib-key-val)
                       "Field names"))

    ;; 7 Citing entries: \cite and friends: \cite is provided by
    ;; latex.el:
    '("cite*"
      ;; We have to delete the `*' inserted by the hook and insert it
      ;; later after the citation key:
      (lambda (_optional)
        (when (= (preceding-char) ?*)
          (delete-char -1)))
      TeX-arg-cite
      (TeX-arg-literal "*")
      (TeX-arg-conditional TeX-arg-cite-note-p ("Note") ()))

    '("citelist" t)

    '("cites" TeX-arg-cite)

    ;; 8.4 Abbreviations: \DefineName, \DefineJournal, and
    '("DefineName" 2)
    '("DefinePublisher" 4)
    '("DefineJournal" 4))

   ;; 7.1 Author-year citation schemes
   (when (LaTeX-provided-class-options-member "amsrefs" "author-year")
     (TeX-add-symbols
      '("ycite" TeX-arg-cite)
      '("ocite" TeX-arg-cite)
      '("citeauthor" TeX-arg-cite)
      '("ycites" TeX-arg-cite)
      '("ocites" TeX-arg-cite)
      '("citeyear" TeX-arg-cite)
      '("fullcite" TeX-arg-cite)
      '("fullocite" TeX-arg-cite)))

   ;; Cater for `M-RET':
   (add-to-list 'LaTeX-item-list
                '("biblist" . LaTeX-item-amsrefs-bib)
                t)

   ;; Don't indent material inside the "bibdiv" env:
   (unless (string-match-p "bibdiv" LaTeX-document-regexp)
     (setq-local LaTeX-document-regexp
                 (concat LaTeX-document-regexp "\\|bibdiv")))

   ;; Try harder and don't match the wrong "bib" in
   ;; "\\(bib\\)?item\\b":
   (unless (string-match-p "\\\\|bib\\\\b" LaTeX-item-regexp)
     (setq-local LaTeX-item-regexp
                 (concat LaTeX-item-regexp "\\|bib\\b")))

   ;; Make \bib stay in its own line:
   (LaTeX-paragraph-commands-add-locally "bib")

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("citelist" "{")
                                ("cites"    "{"))
                              'reference)
     ;; Don't fontify the last argument which can be a long list of
     ;; key=vals:
     (font-latex-add-keywords '(("bib"  "*{{"))
                              'textual)
     (font-latex-add-keywords '(("DefineName"      "{{")
                                ("DefinePublisher" "{{{{")
                                ("DefineJournal"   "{{{{"))
                              'function)
     (when (LaTeX-provided-class-options-member "amsrefs" "author-year")
       (font-latex-add-keywords '(("ycite"      "{")
                                  ("ocite"      "{")
                                  ("citeauthor" "{")
                                  ("ycites"     "{")
                                  ("ocites"     "{")
                                  ("citeyear"   "{")
                                  ("fullcite"   "{")
                                  ("fullocite"  "{"))
                                'reference))))
 TeX-dialect)

(defvar LaTeX-amsrefs-package-options
  '(;; 6.1 Citation labels
    "alphabetic" "shortalphabetic" "author-year" "y2k"
    ;; 6.2 Citation sorting and compression
    "non-compressed-cites" "non-sorted-cites"
    ;; 6.3 Abbreviations
    "abbrev" "initials" "short-journals" "short-months"
    "short-publishers"
    ;; 6.4 Miscellaneous options
    "backrefs" "bibtex-style" "citation-order" "lite" "msc-links"
    "nobysame")
  "Package options for the amsrefs package.")

;;; amsrefs.el ends here
