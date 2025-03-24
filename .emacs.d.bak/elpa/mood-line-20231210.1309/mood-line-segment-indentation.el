;;; mood-line-segment-indentation.el --- An indentation info segment for mood-line -*- lexical-binding: t; -*-
;;
;; Author: Alynx Zhou <alynx.zhou@gmail.com>
;;         Jessie Hildebrandt <jessieh.net>
;; Homepage: https://gitlab.com/jessieh/mood-line
;;
;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; This segment displays indentation style information for the current buffer.

;;; License:
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Code:

;; -------------------------------------------------------------------------- ;;
;;
;; Byte-compiler declarations
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; External function decls
;; ---------------------------------- ;;

(eval-when-compile
  (declare-function mood-line--get-glyph "mood-line"))

;; -------------------------------------------------------------------------- ;;
;;
;; Custom definitions
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Group definitions
;; ---------------------------------- ;;

(defgroup mood-line-segment-indentation nil
  "An indentation info segment for mood-line."
  :group 'mood-line)

;; ---------------------------------- ;;
;; Variable definitions
;; ---------------------------------- ;;

(defcustom mood-line-segment-indentation-always-show-offset nil
  "When non-nil, always show the indentation offset of the current mode.

Default behavior of the indentation segment is to display the indentation offset
 of the current mode when `indent-tabs-mode' is non-nil and an offset value can
 be found for the current mode.  Otherwise, `tab-wdith' will be shown.

When `mood-line-segment-indentation-always-show-offset' is set to non-nil, the
 indentation offset will always be shown alongside `tab-width'.  If an offset
 value cannot be found for the current mode, a \"?\" character will be displayed
 alongside `tab-width'."
  :group 'mood-line-segment-indentation
  :type 'boolean)

;; Assembled from `editorconfig-indentation-alist' and `doom-modeline-indent-alist':
;; https://github.com/editorconfig/editorconfig-emacs/blob/b8043702f3d977db0e030c6c64ee4a810cad5f45/editorconfig.el#L175
;; https://github.com/seagle0128/doom-modeline/blob/fe9ee5a2a950f9ded10261a05a12adc577ae9e36/doom-modeline-core.el#L284
(defcustom mood-line-segment-indentation-mode-offset-alist
  '((apache-mode apache-indent-level)
    (awk-mode c-basic-offset)
    (bpftrace-mode c-basic-offset)
    (c++-mode c-basic-offset)
    (c-mode c-basic-offset)
    (cmake-mode cmake-tab-width)
    (coffee-mode coffee-tab-width)
    (cperl-mode cperl-indent-level)
    (crystal-mode crystal-indent-level)
    (csharp-mode c-basic-offset)
    (css-mode css-indent-offset)
    (d-mode c-basic-offset)
    (emacs-lisp-mode lisp-indent-offset)
    (enh-ruby-mode enh-ruby-indent-level)
    (erlang-mode erlang-indent-level)
    (ess-mode ess-indent-offset)
    (f90-mode f90-associate-indent
              f90-continuation-indent
              f90-critical-indent
              f90-do-indent
              f90-if-indent
              f90-program-indent
              f90-type-indent)
    (feature-mode feature-indent-offset
                  feature-indent-level)
    (fsharp-mode fsharp-continuation-offset
                 fsharp-indent-level
                 fsharp-indent-offset)
    (groovy-mode groovy-indent-offset)
    (haskell-mode haskell-indent-spaces
                  haskell-indent-offset
                  haskell-indentation-layout-offset
                  haskell-indentation-left-offset
                  haskell-indentation-starter-offset
                  haskell-indentation-where-post-offset
                  haskell-indentation-where-pre-offset
                  shm-indent-spaces)
    (haxor-mode haxor-tab-width)
    (idl-mode c-basic-offset)
    (jade-mode jade-tab-width)
    (java-mode c-basic-offset)
    (js-mode js-indent-level)
    (js-jsx-mode js-indent-level sgml-basic-offset)
    (js2-mode js2-basic-offset)
    (js2-jsx-mode js2-basic-offset sgml-basic-offset)
    (js3-mode js3-indent-level)
    (json-mode js-indent-level)
    (json-ts-mode json-ts-mode-indent-offset)
    (julia-mode julia-indent-offset)
    (kotlin-mode kotlin-tab-width)
    (latex-mode tex-indent-basic)
    (lisp-mode lisp-indent-offset)
    (livescript-mode livescript-tab-width)
    (lua-mode lua-indent-level)
    (matlab-mode matlab-indent-level)
    (meson-mode meson-indent-basic)
    (mips-mode mips-tab-width)
    (mustache-mode mustache-basic-offset)
    (nasm-mode nasm-basic-offset)
    (nginx-mode nginx-indent-level)
    (nxml-mode nxml-child-indent)
    (objc-mode c-basic-offset)
    (octave-mode octave-block-offset)
    (perl-mode perl-indent-level)
    (php-mode c-basic-offset)
    (pike-mode c-basic-offset)
    (ps-mode ps-mode-tab)
    (pug-mode pug-tab-width)
    (puppet-mode puppet-indent-level)
    (python-mode python-indent-offset)
    (rjsx-mode js-indent-level sgml-basic-offset)
    (ruby-mode ruby-indent-level)
    (rust-mode rust-indent-offset)
    (rustic-mode rustic-indent-offset)
    (scala-mode scala-indent:step)
    (scss-mode css-indent-offset)
    (sgml-mode sgml-basic-offset)
    (sh-mode sh-basic-offset sh-indentation)
    (slim-mode slim-indent-offset)
    (sml-mode sml-indent-level)
    (tcl-mode tcl-indent-level
              tcl-continued-indent-level)
    (terra-mode terra-indent-level)
    (typescript-mode typescript-indent-level)
    (typescript-ts-base-mode typescript-ts-mode-indent-offset)
    (verilog-mode verilog-indent-level
                  verilog-indent-level-behavioral
                  verilog-indent-level-declaration
                  verilog-indent-level-module
                  verilog-cexp-indent
                  verilog-case-indent)
    (web-mode web-mode-attr-indent-offset
              web-mode-attr-value-indent-offset
              web-mode-code-indent-offset
              web-mode-css-indent-offset
              web-mode-markup-indent-offset
              web-mode-sql-indent-offset
              web-mode-block-padding
              web-mode-script-padding
              web-mode-style-padding)
    (yaml-mode yaml-indent-offset))
  "Alist mapping major mode names to their respective indent offset variables.

When multiple variables are specified for a given mode, the offset value will
 be retrieved from the first variable that resolves to a value, evaluated in the
 order provided."
  :group 'mood-line-segment-indentation
  :type '(alist :key-type symbol :value-type sexp))

;; -------------------------------------------------------------------------- ;;
;;
;; Indentation style info segment
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Segment function
;; ---------------------------------- ;;

(defun mood-line-segment-indentation ()
  "Return the indentation style of the current buffer."
  (let* ((mode-offset (symbol-value
                       (seq-some #'identity
                                 (cdr (assoc major-mode
                                             mood-line-segment-indentation-mode-offset-alist))))))
    (propertize (concat (if indent-tabs-mode "TAB" "SPC")
                        (mood-line--get-glyph :count-separator)
                        (if mood-line-segment-indentation-always-show-offset
                            (format "%s:%d"
                                    (or mode-offset "?")
                                    tab-width)
                          (number-to-string (if indent-tabs-mode
                                                tab-width
                                              (or mode-offset tab-width)))))
                'face 'mood-line-encoding)))

;; -------------------------------------------------------------------------- ;;
;;
;; Provide package
;;
;; -------------------------------------------------------------------------- ;;

(provide 'mood-line-segment-indentation)

;;; mood-line-segment-indentation.el ends here
