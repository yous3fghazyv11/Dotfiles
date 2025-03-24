;;; mood-line-segment-modal.el --- A modal editing status segment for mood-line -*- lexical-binding: t; -*-
;;
;; Author: trevDev() <trev@trevdev.ca>
;;         Jessie Hildebrandt <jessieh.net>
;; Homepage: https://gitlab.com/jessieh/mood-line
;;
;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; This segment displays modal editing information for the current buffer.

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
;; Custom definitions
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Group definitions
;; ---------------------------------- ;;

(defgroup mood-line-segment-modal nil
  "A modal editing status segment for mood-line."
  :group 'mood-line)

;; ---------------------------------- ;;
;; Variable definitions
;; ---------------------------------- ;;

(defcustom mood-line-segment-modal-evil-state-alist
  '((normal . ("<N>" . font-lock-variable-name-face))
    (insert . ("<I>" . font-lock-string-face))
    (visual . ("<V>" . font-lock-keyword-face))
    (replace . ("<R>" . font-lock-type-face))
    (motion . ("<M>" . font-lock-constant-face))
    (operator . ("<O>" . font-lock-function-name-face))
    (emacs . ("<E>" . font-lock-builtin-face)))
  "Alist specifying indicators and faces for corresponding `evil-mode' states.
The face may be either a face symbol or a property list of key-value pairs;
e.g., (:foreground \"red\")."
  :group 'mood-line-segment-modal
  :type '(alist :key-type symbol
                :value-type (cons (string :tag "Display text")
                                  (choice :tag "Face" face plist))))

(defcustom mood-line-segment-modal-meow-state-alist
  '((normal . ("<N>" . font-lock-variable-name-face))
    (insert . ("<I>" . font-lock-string-face))
    (keypad . ("<K>" . font-lock-keyword-face))
    (beacon . ("<B>" . font-lock-type-face))
    (motion . ("<M>" . font-lock-constant-face)))
  "Alist specifying indicators and faces corresponding `meow-mode' states.
The face may be either a face symbol or a property list of key-value pairs;
e.g., (:foreground \"red\")."
  :group 'mood-line-segment-modal
  :type '(alist :key-type symbol
                :value-type (cons (string :tag "Display text")
                                  (choice :tag "Face" face plist))))

;; -------------------------------------------------------------------------- ;;
;;
;; Modal editing segments
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Evil segment
;; ---------------------------------- ;;

(defun mood-line-segment-modal--evil-fn ()
  "Return the current `evil-mode' state."
  (when (boundp 'evil-state)
    (let ((mode-cons (alist-get evil-state
                                mood-line-segment-modal-evil-state-alist)))
      (concat (propertize (car mode-cons)
                          'face (cdr mode-cons))))))

;; ---------------------------------- ;;
;; Meow segment
;; ---------------------------------- ;;

(defun mood-line-segment-modal--meow-fn ()
  "Return the current `meow-mode' state."
  (when (boundp 'meow--current-state)
    (let ((mode-cons (alist-get meow--current-state
                                mood-line-segment-modal-meow-state-alist)))
      (concat (propertize (car mode-cons)
                          'face (cdr mode-cons))))))

;; ---------------------------------- ;;
;; Xah segment
;; ---------------------------------- ;;

(defun mood-line-segment-modal--xah-fn ()
  "Display the current xah-fly-keys state."
  (if (bound-and-true-p xah-fly-insert-state-p)
      "<I>"
      "<C>"))

;; ---------------------------------- ;;
;; God segment
;; ---------------------------------- ;;

(defun mood-line-segment-modal--god-fn ()
  "Return an indicator of whether or not `god-mode' is active."
  (if (bound-and-true-p god-local-mode)
      (propertize "<G>" 'face 'mood-line-status-warning)
    "---"))

;; -------------------------------------------------------------------------- ;;
;;
;; Provide package
;;
;; -------------------------------------------------------------------------- ;;

(provide 'mood-line-segment-modal)

;;; mood-line-segment-modal.el ends here
