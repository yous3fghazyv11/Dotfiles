;;; tex-site.el - Site specific variables.  Don't edit.  -*- lexical-binding: t; -*-

;; Copyright (C) 2005-2024  Free Software Foundation, Inc.
;;
;; completely rewritten.

;; Author: David Kastrup <dak@gnu.org>
;; Maintainer: auctex-devel@gnu.org
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

;; This file contains startup code, autoloads and variables adapted to
;; the local site configuration.  It is generated and placed by the
;; installation procedure and should not be edited by hand, nor moved
;; to a different place, as some settings may be established relative
;; to the file.

;; All user customization should be done with
;; M-x customize-variable RET

;;; Code:

(when (< emacs-major-version 27)
  (error "AUCTeX requires Emacs 27.1 or later"))

(declare-function BibTeX-auto-store "latex")

(unless (or (fboundp 'TeX-modes-set)     ;Avoid inf-looping.
            (fboundp 'TeX-tex-mode))     ;auctex-autoloads is not loaded.
  ;; Try and support the case where someone loads tex-site.el or
  ;; auctex.el directly, in the old way.
  (provide 'tex-site)        ;Avoid (re)loading tex-site from auctex-autoloads.

  (load "auctex-autoloads" 'noerror 'nomessage))

;; Define here in order for `M-x customize-group <RET> AUCTeX <RET>'
;; to work if the main AUCTeX files are not loaded yet.
(defgroup AUCTeX nil
  "A (La)TeX environment."
  :tag "AUCTeX"
  :link '(custom-manual "(auctex)Top")
  :link '(url-link :tag "Home Page" "https://www.gnu.org/software/auctex/")
  :prefix "TeX-"
  :group 'tex
  :load "tex" :load "latex" :load "tex-style")

(defvar TeX-lisp-directory
  (file-name-directory load-file-name)
  "The directory where most of the AUCTeX lisp files are located.
For the location of lisp files associated with
styles, see the variables TeX-style-* (hand-generated lisp) and
TeX-auto-* (automatically generated lisp).")

(add-to-list 'load-path TeX-lisp-directory)

(defvar TeX-data-directory
  (file-name-directory load-file-name)
  "The directory where the AUCTeX non-Lisp data is located.")

(defcustom TeX-auto-global
  (if (file-writable-p "/usr/local/var/auctex") "/usr/local/var/auctex" "~/.emacs.d/auctex")
  "Directory containing automatically generated information.

For storing automatic extracted information about the TeX macros
shared by all users of a site."
  :group 'TeX-file
  :type 'directory)

(defconst TeX-mode-alist
  '((tex-mode . TeX-tex-mode)
    (plain-tex-mode . plain-TeX-mode)
    (texinfo-mode . Texinfo-mode)
    (latex-mode . LaTeX-mode)
    (doctex-mode . docTeX-mode))
  "Alist of built-in TeX modes and their counterparts in AUCTeX.")

(defalias 'TeX-load-hack #'ignore)

(defun tex-site-unload-function ()
  (TeX-modes-set 'TeX-modes nil)

  ;; COMPATIBILITY for Emacs<29
  (put 'plain-TeX-mode 'auctex-function-definition nil)
  (put 'LaTeX-mode 'auctex-function-definition nil)
  (put 'TeX-mode 'auctex-function-definition nil)

  (setq load-path (delq TeX-lisp-directory load-path))
  ;; Tell emacs to continue standard unloading procedure.
  nil)

(defun TeX-modes-set (var value &optional _ignored)
  "Set VAR (which should be `TeX-modes') to VALUE.

Arrange the redirection of the built-in TeX modes according to VALUE.
- The built-in modes in VALUE are redirected to the corresponding
  AUCTeX major modes.
- The built-in modes not in VALUE discard redirection, if any.
If `major-mode-remap-alist' is available, use it for redirection.
Otherwise, use advice facility."
  (custom-set-default var value)
  (let (elt dst)
    (dolist (entry TeX-mode-alist)
      (setq elt (car entry)
            dst (cdr entry))
      (if (memq elt value)
          (if (boundp 'major-mode-remap-alist)
              (or (eq (cdr-safe (assq elt major-mode-remap-alist)) dst)
                  (push (cons elt dst) major-mode-remap-alist))
            ;; COMPATIBILITY for Emacs<29
            (advice-add elt :override dst
                        ;; COMPATIBILITY for Emacs 28.[12]
                        ;; Give it higher precedence than the :around
                        ;; advice given to `tex-mode' in tex-mode.el.
                        ;; <URL:https://lists.gnu.org/r/auctex-devel/2022-09/msg00050.html>
                        '((depth . -10))))
        (if (boundp 'major-mode-remap-alist)
            (setq major-mode-remap-alist
                  (delete entry major-mode-remap-alist))
          ;; COMPATIBILITY for Emacs<29
          (advice-remove elt dst))))))

(defcustom TeX-modes
  (mapcar #'car TeX-mode-alist)
  "List of built-in TeX modes redirected to AUCTeX modes.

This variable can't be set normally; use customize for that, or
set it with `TeX-modes-set'."
  :type (cons 'set
              (mapcar (lambda(x) (list 'const (car x))) TeX-mode-alist))
  :set #'TeX-modes-set
  :initialize #'custom-initialize-reset)

(defun TeX--alias-overlapped-modes (&optional restore)
  "Delete or restore definition of overlapped modes via `defalias'.
Set function definition for modes overlapped between tex-mode.el
and AUCTeX, `plain-TeX-mode', `LaTeX-mode' and `TeX-mode'.
If optional argument RESTORE is nil, delete the definition.
Otherwise, restore AUCTeX definition saved in the symbol property
`auctex-function-definition'."
  (dolist (mode '(plain-TeX-mode LaTeX-mode TeX-mode))
    (if (eq (symbol-function mode)
            (intern (downcase (symbol-name mode))))
        (defalias mode (if restore
                           (get mode 'auctex-function-definition))))))

;; COMPATIBILITY for Emacs<29, which executes
;; (defalias 'LaTeX-mode #'latex-mode) etc. in tex-mode.el.
(with-eval-after-load 'tex-mode
  ;; This must be no-op after (unload-feature 'tex-site).
  (if (featurep 'tex-site)
      (TeX--alias-overlapped-modes t)))

(defconst AUCTeX-version "14.0.5"
  "AUCTeX version.
If not a regular release, the date of the last change.")

(defconst AUCTeX-date "2024-05-19_09:43:32"
  "AUCTeX release date using the ISO 8601 format, yyyy-mm-dd.")

;; Store bibitems when saving a BibTeX buffer
(add-hook 'bibtex-mode-hook #'BibTeX-auto-store)

;;; Code specific to ELPA packaging:

;; From preview-latex.el:

(defvar preview-TeX-style-dir
  (expand-file-name "latex" (file-name-directory load-file-name)))

;;; Ensure that loading the autoloads file also loads this file.
;;;###autoload (require 'tex-site)

(provide 'tex-site)
;;; tex-site.el ends here
