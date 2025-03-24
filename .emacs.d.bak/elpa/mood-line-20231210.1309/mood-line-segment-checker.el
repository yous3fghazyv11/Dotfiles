;;; mood-line-segment-checker.el --- A checker status segment for mood-line -*- lexical-binding: t; -*-
;;
;; Author: Jessie Hildebrandt <jessieh.net>
;; Homepage: https://gitlab.com/jessieh/mood-line
;;
;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; This segment displays the current status of any active checker.

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
;; Required features
;; ---------------------------------- ;;

(eval-when-compile
  (require 'flymake))

;; ---------------------------------- ;;
;; External variable defs
;; ---------------------------------- ;;

(eval-when-compile
  (defvar flycheck-current-errors))

;; ---------------------------------- ;;
;; External function decls
;; ---------------------------------- ;;

(eval-when-compile
  (declare-function mood-line--get-glyph "mood-line")
  (declare-function flycheck-count-errors "flycheck")
  (declare-function flymake-running-backends "flymake")
  (declare-function flymake-reporting-backends "flymake")
  (declare-function flymake--lookup-type-property "flymake"))

;; -------------------------------------------------------------------------- ;;
;;
;; Helper functions
;;
;; -------------------------------------------------------------------------- ;;

(defun mood-line-segment-checker--format-status (status error warning note)
  "Format STATUS into a segment string with ERROR, WARNING, and NOTE counts."
  (pcase status
    ('running
     (format #("%s Checking"
               0 11 (face mood-line-status-neutral))
             (mood-line--get-glyph :checker-checking)))
    ('errored
     (format #("%s Error"
               0 2 (face mood-line-status-error))
             (mood-line--get-glyph :checker-errored)))
    ('interrupted
     (format #("%s Paused"
               0 9 (face mood-line-status-neutral))
             (mood-line--get-glyph :checker-interrupted)))
    ('finished
     (cond
      ((> error 0)
       (let ((issues (+ error warning)))
         (format #("%s %s Issue%s"
                   0 2 (face mood-line-status-error))
                 (mood-line--get-glyph :checker-issues)
                 issues
                 (if (> issues 1) "s" ""))))
      ((> warning 0)
       (format #("%s %s Issue%s"
                 0 2 (face mood-line-status-warning))
               (mood-line--get-glyph :checker-issues)
               warning
               (if (> warning 1) "s" "")))
      ((> note 0)
       (format #("%s %s Note%s"
                 0 2 (face mood-line-status-info))
               (mood-line--get-glyph :checker-info)
               note
               (if (> note 1) "s" "")))
      (t
       (format #("%s No Issues"
                 0 12 (face mood-line-status-neutral))
               (mood-line--get-glyph :checker-good)))))))

;; -------------------------------------------------------------------------- ;;
;;
;; Flycheck update handler
;;
;; -------------------------------------------------------------------------- ;;

(defvar-local mood-line-segment-checker--flycheck-text nil
  "Mode line segment string indicating the current state of `flycheck-mode'.")

(defun mood-line-segment-checker--flycheck-update (&optional status)
  "Update `mood-line-segment-checker--flycheck-text' with flycheck's STATUS."
  (setq mood-line-segment-checker--flycheck-text
        (let-alist (flycheck-count-errors flycheck-current-errors)
          (when-let* ((valid-statuses '(finished running errored interrupted))
                      (status-valid (member status valid-statuses))
                      (error (or .error 0))
                      (warning (or .warning 0))
                      (note (or .info 0)))
            (mood-line-segment-checker--format-status
             status error warning note)))))

;; -------------------------------------------------------------------------- ;;
;;
;; Flymake update handler
;;
;; -------------------------------------------------------------------------- ;;

(defvar-local mood-line-segment-checker--flymake-text nil
  "Mode line segment string indicating the current state of `flymake-mode'.")

(defun mood-line-segment-checker--flymake-count (type)
  "Return count of current flymake reports of TYPE."
  (cl-loop for diag in (flymake-diagnostics)
           as diag-type = (flymake-diagnostic-type diag)
           count (eq (flymake--lookup-type-property diag-type 'severity)
                     (flymake--lookup-type-property type 'severity))))

(defun mood-line-segment-checker--flymake-update (&rest _args)
  "Update `mood-line-segment-checker--flymake-state' with flymake's status."
  (setq mood-line-segment-checker--flymake-text
        (when-let ((flymake-active (and (fboundp 'flymake-is-running)
                                        (flymake-is-running)))
                   (status (if (seq-difference (flymake-running-backends)
                                               (flymake-reporting-backends))
                               'running 'finished))
                   (error (mood-line-segment-checker--flymake-count :error))
                   (warning (mood-line-segment-checker--flymake-count :warning))
                   (note (mood-line-segment-checker--flymake-count :note)))
          (mood-line-segment-checker--format-status
           status error warning note))))

;; -------------------------------------------------------------------------- ;;
;;
;; Provide package
;;
;; -------------------------------------------------------------------------- ;;

(provide 'mood-line-segment-checker)

;;; mood-line-segment-checker.el ends here
