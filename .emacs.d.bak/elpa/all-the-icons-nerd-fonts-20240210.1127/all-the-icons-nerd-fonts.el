;;; all-the-icons-nerd-fonts.el --- Nerd font integration for all-the-icons -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Mohsin Kaleem

;; Author: Mohsin Kaleem <mohkale@gmail.com>
;; Keywords: convenience, lisp
;; Package-Requires: ((emacs "28.1") (all-the-icons "5.0") (nerd-icons "0.0.1"))
;; Version: 0.2
;; Homepage: https://github.com/mohkale/all-the-icons-nerd-fonts

;; Copyright (C) 2021 Mohsin Kaleem

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

;;; Commentary:

;; Set up `nerd-fonts' for use with `all-the-icons'.
;;
;; This involves creating several all-the-icons font families for the
;; various nerd-font families (each prefixed with "nerd-") and allowing
;; users to convert any references to an all-the-icons icon to an
;; equivalent or similair nerd-fonts icon.

;;; Code:

(require 'cl-lib)
(eval-when-compile (require 'subr-x))

(require 'all-the-icons)
(require 'nerd-icons-data)

(defgroup all-the-icons-nerd-fonts nil
  "Nerd font integration for all-the-icons."
  :prefix "all-the-icons-nerd-fonts-"
  :group 'all-the-icons)

(defcustom all-the-icons-nerd-fonts-family "Symbols Nerd Font"
  "The font-family to use with `nerd-fonts' icons."
  :type 'string)

;; Define new `all-the-icons' families for available nerd fonts.
(defmacro all-the-icons-nerd-fonts--define-family (family data-alist prefix)
  "Define a `all-the-icons' font for the nerd-font family FAMILY.
Generate a new all-the-icons backend for FAMILY using the icon definitions
in DATA-ALIST that have a prefix of PREFIX."
  (let ((font-alist
         (intern (concat "all-the-icons-data/" (symbol-name family) "-alist"))))
    `(progn
       (defvar ,font-alist
         (eval-when-compile
           (cl-loop for (name . icon) in ,data-alist
                    when (string-prefix-p ,prefix name)
                    collect (cons (string-replace "_" "-" (substring name ,(length prefix)))
                                  icon))))

       (all-the-icons-define-icon ,family ,font-alist all-the-icons-nerd-fonts-family))))

(all-the-icons-nerd-fonts--define-family nerd-iec     nerd-icons/ipsicon-alist   "nf-iec-")
(all-the-icons-nerd-fonts--define-family nerd-pom     nerd-icons/pomicon-alist   "nf-pom-")
(all-the-icons-nerd-fonts--define-family nerd-oct     nerd-icons/octicon-alist   "nf-oct-")
(all-the-icons-nerd-fonts--define-family nerd-pl      nerd-icons/powerline-alist "nf-pl-")
(all-the-icons-nerd-fonts--define-family nerd-ple     nerd-icons/powerline-alist "nf-ple-")
(all-the-icons-nerd-fonts--define-family nerd-fa      nerd-icons/faicon-alist    "nf-fa-")
(all-the-icons-nerd-fonts--define-family nerd-fae     nerd-icons/faicon-alist    "nf-fae-")
(all-the-icons-nerd-fonts--define-family nerd-weather nerd-icons/wicon-alist     "nf-weather-")
(all-the-icons-nerd-fonts--define-family nerd-seti    nerd-icons/sucicon-alist   "nf-seti-")
(all-the-icons-nerd-fonts--define-family nerd-custom  nerd-icons/sucicon-alist   "nf-custom-")
(all-the-icons-nerd-fonts--define-family nerd-dev     nerd-icons/devicon-alist   "nf-dev-")
(all-the-icons-nerd-fonts--define-family nerd-cod     nerd-icons/codicon-alist   "nf-cod-")
(all-the-icons-nerd-fonts--define-family nerd-linux   nerd-icons/flicon-alist    "nf-linux-")
(all-the-icons-nerd-fonts--define-family nerd-mdi     nerd-icons/mdicon-alist    "nf-mdi-")
(all-the-icons-nerd-fonts--define-family nerd-md      nerd-icons/mdicon-alist    "nf-md-")

;; Replace any none nerd-font lookups with nerd-font lookups.
(defcustom all-the-icons-nerd-fonts-convert-families
  '((all-the-icons-material . all-the-icons-nerd-mdi)
    (all-the-icons-faicon . all-the-icons-nerd-fa)
    (all-the-icons-octicon . all-the-icons-nerd-oct)
    (all-the-icons-wicon . all-the-icons-nerd-weather))
  "Alist of `all-the-icons' to `nerd-fonts' families to auto convert.
This expects these families to be compatible between each other, that is
both families contain the same set of icons. If any icons have different
names you should override the icon instead with
`all-the-icons-nerd-fonts-overrides'."
  :type '(alist :key-type symbol :value-type symbol))

(make-obsolete-variable 'all-the-icons-nerd-fonts-convert-icons "Use `all-the-icons-nerd-fonts-overrides' instead." "0.2")

(defcustom all-the-icons-nerd-fonts-overrides
  '(;; alltheicon
    (all-the-icons-alltheicon "aws"                      all-the-icons-nerd-fa     "amazon")
    (all-the-icons-alltheicon "c-line"                   all-the-icons-nerd-custom "c")
    (all-the-icons-alltheicon "clojure-line"             all-the-icons-nerd-dev    "clojure")
    (all-the-icons-alltheicon "cplusplus-line"           all-the-icons-nerd-custom "cpp")
    (all-the-icons-alltheicon "csharp-line"              all-the-icons-nerd-md     "language-csharp")
    (all-the-icons-alltheicon "elixir"                   all-the-icons-nerd-custom "elixir")
    (all-the-icons-alltheicon "git"                      all-the-icons-nerd-md     "git")
    (all-the-icons-alltheicon "go"                       all-the-icons-nerd-seti   "go")
    (all-the-icons-alltheicon "google-drive"             all-the-icons-nerd-md     "google-drive")
    (all-the-icons-alltheicon "gulp"                     all-the-icons-nerd-seti   "gulp")
    (all-the-icons-alltheicon "haskell"                  all-the-icons-nerd-seti   "haskell")
    (all-the-icons-alltheicon "html5"                    all-the-icons-nerd-fa     "html5")
    (all-the-icons-alltheicon "java"                     all-the-icons-nerd-fae    "java")
    (all-the-icons-alltheicon "javascript"               all-the-icons-nerd-seti   "javascript")
    (all-the-icons-alltheicon "nodejs"                   all-the-icons-nerd-md     "nodejs")
    (all-the-icons-alltheicon "prolog"                   all-the-icons-nerd-dev    "prolog")
    (all-the-icons-alltheicon "python"                   all-the-icons-nerd-fae    "python")
    (all-the-icons-alltheicon "react"                    all-the-icons-nerd-md     "react")
    (all-the-icons-alltheicon "ruby-alt"                 all-the-icons-nerd-cod    "ruby")
    (all-the-icons-alltheicon "rust"                     all-the-icons-nerd-dev    "rust")
    (all-the-icons-alltheicon "sass"                     all-the-icons-nerd-dev    "sass")
    (all-the-icons-alltheicon "scala"                    all-the-icons-nerd-dev    "scala")
    (all-the-icons-alltheicon "script"                   all-the-icons-nerd-seti   "html")
    (all-the-icons-alltheicon "swift"                    all-the-icons-nerd-dev    "swift")
    (all-the-icons-alltheicon "terminal"                 all-the-icons-nerd-fa     "terminal")
    ;; fontawesome icon
    (all-the-icons-faicon     "github"                   all-the-icons-nerd-cod    "github")
    (all-the-icons-faicon     "git"                      all-the-icons-nerd-md     "git")
    (all-the-icons-faicon     "newspaper-o"              all-the-icons-nerd-md     "newspaper")
    (all-the-icons-faicon     "shitsinbulk"              all-the-icons-nerd-fa     "shirtsinbulk")
    ;; fileicon
    (all-the-icons-fileicon   "bib"                      all-the-icons-nerd-fa     "book")
    (all-the-icons-fileicon   "cljs"                     all-the-icons-nerd-dev    "clojure")
    (all-the-icons-fileicon   "dockerfile"               all-the-icons-nerd-linux  "docker")
    (all-the-icons-fileicon   "go"                       all-the-icons-nerd-seti   "go")
    (all-the-icons-fileicon   "gnu"                      all-the-icons-nerd-dev    "gnu")
    (all-the-icons-fileicon   "php"                      all-the-icons-nerd-dev    "php")
    (all-the-icons-fileicon   "racket"                   all-the-icons-fileicon    "lisp")
    (all-the-icons-fileicon   "test-ruby"                all-the-icons-nerd-cod    "ruby")
    (all-the-icons-fileicon   "tex"                      all-the-icons-nerd-cod    "text-size")
    ;; material
    (all-the-icons-material   "email"                    all-the-icons-nerd-md     "email")
    (all-the-icons-material   "error"                    all-the-icons-nerd-seti "error")
    (all-the-icons-material   "git"                      all-the-icons-nerd-md     "git")
    (all-the-icons-material   "message"                  all-the-icons-nerd-md     "message-text")
    (all-the-icons-material   "star"                     all-the-icons-nerd-md     "star")
    (all-the-icons-material   "style"                    all-the-icons-nerd-md     "border-style")
    ;; octicon
    (all-the-icons-octicon    "dashboard"                all-the-icons-nerd-cod    "dashboard")
    (all-the-icons-octicon    "file-pdf"                 all-the-icons-nerd-cod    "file-pdf")
    (all-the-icons-octicon    "file-symlink-directory"   all-the-icons-nerd-cod    "file-symlink-directory")
    (all-the-icons-octicon    "file-text"                all-the-icons-nerd-oct    "file")
    (all-the-icons-octicon    "gist"                     all-the-icons-nerd-cod    "notebook")
    (all-the-icons-octicon    "mail-read"                all-the-icons-nerd-cod    "mail-read")
    (all-the-icons-octicon    "ruby"                     all-the-icons-nerd-cod    "ruby")
    (all-the-icons-octicon    "message-text"             all-the-icons-nerd-md     "message-text")
    (all-the-icons-octicon    "settings"                 all-the-icons-nerd-cod    "settings")
    (all-the-icons-octicon    "settings"                 all-the-icons-nerd-cod    "settings"))
  "Icon overrides.
Force replace any references to the source icon with the destination icon."
  :type '(list (symbol :tag "Source family")
               (string :tag "Soruce icon")
               (symbol :tag "Destination family")
               (symbol :tag "Destination icon")))

(defconst all-the-icons-nerd-fonts--alist-vars
  '(all-the-icons-chevron-icon-alist
    all-the-icons-dir-icon-alist
    all-the-icons-dir-icon-overrides
    all-the-icons-extension-icon-alist
    all-the-icons-icon-alist
    all-the-icons-mode-icon-alist
    all-the-icons-url-alist
    all-the-icons-weather-icon-alist
    all-the-icons-web-mode-icon-alist))

;;;###autoload
(defun all-the-icons-nerd-fonts-prefer (&optional list-vars)
  "Replace any `all-the-icons' associations with `nerd-fonts'.
When LIST-VARS is set update LIST-VARS instead of the standard all-the-icons
list variables."
  (let ((override-map (make-hash-table
                       :size (length all-the-icons-nerd-fonts-overrides))))
    (dolist (it all-the-icons-nerd-fonts-overrides)
      (puthash (intern (concat (symbol-name (car it)) "-" (cadr it)))
               (cddr it)
               override-map))

    (dolist (var (or list-vars all-the-icons-nerd-fonts--alist-vars))
      (dolist (assoc (when (boundp var) (symbol-value var)))
        (if-let* ((override-key
                   (intern (concat (symbol-name (cadr assoc))
                                   "-"
                                   (caddr assoc))))
                  (override (gethash override-key override-map)))
            (setf (cadr  assoc) (car override)
                  (caddr assoc) (cadr override))
          (when-let ((family-override
                      (alist-get (cadr assoc)
                                 all-the-icons-nerd-fonts-convert-families)))
            (setf (cadr assoc) family-override)))))))

(defconst all-the-icons-nerd-fonts--data-remap-alist
  '((all-the-icons-data/alltheicon-alist . all-the-icons-data/alltheicons-alist)
    (all-the-icons-data/fileicon-alist . all-the-icons-data/file-icon-alist)
    (all-the-icons-data/wicon-alist . all-the-icons-data/weather-icons-alist)))

(defconst all-the-icons-nerd-fonts--skip-families
  '(all-the-icons--web-mode-icon))

(defun all-the-icons-nerd-fonts--check-configs ()
  "Ensure all the icons in the `all-the-icons' configuration variables exist."
  (dolist (var all-the-icons-nerd-fonts--alist-vars)
    (if (boundp var)
        (dolist (assoc (symbol-value var))
          (let* ((family (intern (string-remove-prefix
                                  "all-the-icons-" (symbol-name (cadr assoc)))))
                 (icon (caddr assoc))
                 (data-var (intern (concat "all-the-icons-data/" (symbol-name family) "-alist"))))
            (setq data-var (alist-get data-var all-the-icons-nerd-fonts--data-remap-alist data-var))
            (cond
             ((boundp data-var)
              (unless (assoc icon (symbol-value data-var) #'equal)
                (display-warning 'all-the-icons-nerd-fonts
                                 (format "Missing icon=%s from family=%s in var=%s"
                                         icon family var))))
             ((member (cadr assoc) all-the-icons-nerd-fonts--skip-families) nil)
             (t
              (display-warning 'all-the-icons-nerd-fonts
                               (format "Could not find data-alist=%s from var=%s" data-var var))))))
      (display-warning 'all-the-icons-nerd-fonts
                       (format "all-the-icons override variable not bound: %s" var)))))

(provide 'all-the-icons-nerd-fonts)
;;; all-the-icons-nerd-fonts.el ends here
