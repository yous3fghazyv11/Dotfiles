;;; mood-line-segment-vc.el --- A vc-mode info segment for mood-line -*- lexical-binding: t; -*-
;;
;; Author: Jessie Hildebrandt <jessieh.net>
;; Homepage: https://gitlab.com/jessieh/mood-line
;;
;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; This segment displays the current status of vc-mode.

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
;; Helper functions
;;
;; -------------------------------------------------------------------------- ;;

(defun mood-line-segment-vc--rev (vc-mode-str backend)
  "Return name of current file's revision for BACKEND according to `vc-mode'.
VC-MODE-STR is expected to be the value of `vc-mode' in the current buffer.
If `vc-display-status' is nil, return the name of BACKEND."
  (or (unless vc-display-status
        (symbol-name backend))
      (pcase backend
        ('Git (substring-no-properties vc-mode-str 5))
        ('Hg (substring-no-properties vc-mode-str 4)))
      (ignore-errors
        (substring (vc-working-revision buffer-file-name backend) 0 7))
      "???"))

;; -------------------------------------------------------------------------- ;;
;;
;; VC segment
;;
;; -------------------------------------------------------------------------- ;;

(defvar-local mood-line-segment-vc--text nil
  "Mode line segment string indicating the current state of `vc-mode'.")

(defun mood-line-segment-vc--update (&rest _args)
  "Update `mood-line-segment-vc--text' against the current VCS state."
  (setq mood-line-segment-vc--text
        (when-let* ((vc-active (and vc-mode buffer-file-name))
                    (backend (vc-backend buffer-file-name))
                    (state (vc-state buffer-file-name))
                    (rev (mood-line-segment-vc--rev vc-mode backend)))
          (cond
           ((memq state '(edited added))
            (format #("%s %s"
                      0 2 (face mood-line-status-info))
                    (mood-line--get-glyph :vc-added)
                    rev))
           ((eq state 'needs-merge)
            (format #("%s %s"
                      0 2 (face mood-line-status-warning))
                    (mood-line--get-glyph :vc-needs-merge)
                    rev))
           ((eq state 'needs-update)
            (format #("%s %s"
                      0 2 (face mood-line-status-warning))
                    (mood-line--get-glyph :vc-needs-update)
                    rev))
           ((memq state '(removed conflict unregistered))
            (format #("%s %s"
                      0 2 (face mood-line-status-error))
                    (mood-line--get-glyph :vc-conflict)
                    rev))
           (t
            (format #("%s %s"
                      0 5 (face mood-line-status-neutral))
                    (mood-line--get-glyph :vc-good)
                    rev))))))

;; -------------------------------------------------------------------------- ;;
;;
;; Provide package
;;
;; -------------------------------------------------------------------------- ;;

(provide 'mood-line-segment-vc)

;;; mood-line-segment-vc.el ends here
