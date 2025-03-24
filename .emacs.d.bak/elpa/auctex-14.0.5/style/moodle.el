;;; moodle.el --- AUCTeX style for `moodle.sty' (v0.5)  -*- lexical-binding: t; -*-

;; Copyright (C) 2017--2024 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2017-06-10
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

;; This file adds support for `moodle.sty' (v0.5) from 2016/01/11.

;; In multi environments, the correct answer is marked with `\item*'.
;; This style adds asterisk to the list of key=values queried after
;; \item in this environment in order to make the input procedure
;; easier.

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords
                  "font-latex"
                  (keywords class))

(defvar LaTeX-moodle-answer-key-val-options
  '(("fraction")
    ("fractiontol")
    ("feedback")))

(defvar LaTeX-moodle-key-val-options
  (append '(("points")
            ("default grade")
            ("penalty")
            ("tags"))
          LaTeX-moodle-answer-key-val-options)
  "Key=value options for moodle macros and environments.")

(defun LaTeX-moodle-item-argument ()
  "Insert an \\item with optional argument in environments of moodle package."
  ;; Do not query for an optional argument here, this happens below:
  (let ((TeX-insert-macro-default-style 'mandatory-args-only))
    (TeX-insert-macro "item"))
  ;; Now delete any horizonal spaces:
  (delete-horizontal-space)
  (let* ((currenv (LaTeX-current-environment))
         (opts (unless (member currenv '("essay"))
                 (TeX-read-key-val t
                                   (if (member currenv '("numerical"))
                                       (append '(("tolerance"))
                                               LaTeX-moodle-answer-key-val-options)
                                     LaTeX-moodle-answer-key-val-options))))
         (starred (when (member currenv '("truefalse" "multi"))
                    (let ((help-form "\
* marks the correct answer and is appended to \\item[<opt arg>]"))
                      (y-or-n-p "Mark item with *?")))))
    ;; Insert key=values if available:
    (unless (string-empty-p opts)
      (insert LaTeX-optop opts LaTeX-optcl))
    ;; Attach * to it:
    (when starred (insert "*"))
    ;; Now make sure one space is there and indent:
    (just-one-space)
    (indent-according-to-mode))
  ;; Bonus point: Insert the macro \answer in matching environment:
  (when (string= "matching" (LaTeX-current-environment))
    (save-excursion
      (insert TeX-esc "answer")
      (just-one-space))))

(defun LaTeX-moodle-query-question-text (optional)
  "Query for question text inside environments provided by moodle package.
If OPTIONAL is non-nil, indicate that during query."
  (let ((qtext (TeX-read-string
                (TeX-argument-prompt optional nil "Question text"))))
    (unless (string-empty-p qtext)
      (save-excursion
        (goto-char TeX-exit-mark)
        (insert-before-markers qtext)
        (when auto-fill-function
          (LaTeX-fill-paragraph))
        (insert-before-markers "\n")))))

(TeX-add-style-hook
 "moodle"
 (lambda ()

   (LaTeX-add-environments
    ;; 2.3 Quiz and Question Environments1
    '("quiz" LaTeX-env-args
      [TeX-arg-key-val LaTeX-moodle-key-val-options]
      "Category name")

    ;; 2.4.1 True/False
    '("truefalse" LaTeX-env-item-args
      [TeX-arg-key-val LaTeX-moodle-key-val-options nil nil ?\s]
      "Question name"
      LaTeX-moodle-query-question-text)

    ;; 2.4.2 Multiple Choice
    '("multi" LaTeX-env-item-args
      [TeX-arg-key-val (lambda ()
                         (append '(("shuffle" ("true" "false"))
                                   ("numbering")
                                   ("single" ("true" "false"))
                                   ("sanction")
                                   ("multiple")
                                   ("allornothing"))
                                 LaTeX-moodle-key-val-options))
                       nil nil ?\s]
      (TeX-arg-conditional (string= (LaTeX-current-environment 2) "quiz")
          ("Question name")
        ())
      LaTeX-moodle-query-question-text)

    ;; 2.4.3 Numerical
    '("numerical" LaTeX-env-item-args
      [TeX-arg-key-val (lambda ()
                         (append '(("tolerance"))
                                 LaTeX-moodle-key-val-options))
                       nil nil ?\s]
      (TeX-arg-conditional (string= (LaTeX-current-environment 2) "quiz")
          ("Question name")
        ())
      LaTeX-moodle-query-question-text)

    ;; 2.4.4 Short Answer
    '("shortanswer" LaTeX-env-item-args
      [TeX-arg-key-val (lambda ()
                         (append '(("case sensitive" ("true" "false"))
                                   ("usecase" ("true" "false")))
                                 LaTeX-moodle-key-val-options))
                       nil nil ?\s]
      (TeX-arg-conditional (string= (LaTeX-current-environment 2) "quiz")
          ("Question name")
        ())
      LaTeX-moodle-query-question-text)

    ;; 2.4.5 Essay
    '("essay" LaTeX-env-item-args
      [TeX-arg-key-val (lambda ()
                         (append '(("response required" ("true" "false"))
                                   ("response format" ("html" "file"
                                                       "html+file"
                                                       "text" "monospaced"))
                                   ("response field lines" ("5" "10" "15"
                                                            "20" "25" "30"
                                                            "35" "40"))
                                   ("attachments allowed" ("0" "1" "2" "3"
                                                           "unlimited"))
                                   ("attachments required" ("0" "1"
                                                            "2" "3"))
                                   ("template"))
                                 LaTeX-moodle-key-val-options))
                       nil nil ?\s]
      "Question name"
      LaTeX-moodle-query-question-text)

    ;; 2.4.6 Matching
    '("matching" LaTeX-env-item-args
      [TeX-arg-key-val (lambda ()
                         (append '(("shuffle" ("true" "false"))
                                   ("drag and drop" ("true" "false"))
                                   ("dd"))
                                 LaTeX-moodle-key-val-options))
                       nil nil ?\s]
      LaTeX-moodle-query-question-text)

    ;; 2.4.7 Cloze Questions and Subquestions
    '("cloze" "Question bank name"))

   ;; Tell AUCTeX about special insertion of \item:
   (dolist (env '("truefalse" "multi" "numerical"
                  "shortanswer" "essay" "matching"))
     (add-to-list 'LaTeX-item-list `(,env . LaTeX-moodle-item-argument) t))

   (TeX-add-symbols
    '("moodleset"
      (TeX-arg-key-val (lambda ()
                         (append '(("ppi")) LaTeX-moodle-key-val-options))))

    ;; 5 Graphics
    '("ghostscriptcommand" "File name")
    '("imagemagickcommand" "File name")
    '("opensslcommand"     "File name"))

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("moodleset"          "{")
                                ("ghostscriptcommand" "{")
                                ("imagemagickcommand" "{")
                                ("opensslcommand"     "{"))
                              'function)
     (font-latex-add-keywords '(("answer" "")
                                ;; Cater for a fontified starred \item
                                ("item"   "*["))
                              'textual)))
 TeX-dialect)

(defvar LaTeX-moodle-package-options
  '("draft" "final" "handout" "samepage" "nostamp"
    "section" "subsection" "section*" "subsection*"
    "tikz" "svg" "LMS" "feedbackleft" "feedbackright")
  "Package options for the moodle package.")

;;; moodle.el ends here
