;;; mood-line.el --- A minimal mode line inspired by doom-modeline -*- lexical-binding: t; -*-
;;
;; Author: Jessie Hildebrandt <jessieh.net>
;; Homepage: https://gitlab.com/jessieh/mood-line
;; Keywords: mode-line faces
;; Version: 3.1.0
;; Package-Requires: ((emacs "26.1"))
;;
;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; mood-line is a lightweight, drop-in replacement for the default mode line.
;;
;; Features offered:
;; * Clean, informative design
;; * Customizable, modular segment format
;; * Customizable glyph sets
;; * Lazy-loaded extensions
;; * Lightweight, no dependencies
;;
;; To activate mood-line:
;; (mood-line-mode)
;;
;; For information on customizing mood-line:
;; M-x customize-group mood-line

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
  (require 'cl-lib))

;; ---------------------------------- ;;
;; External variable defs
;; ---------------------------------- ;;

(eval-when-compile
  (defvar anzu--cached-count)
  (defvar anzu--current-position)
  (defvar anzu--overflow-p)
  (defvar anzu--total-matched))

;; ---------------------------------- ;;
;; External function decls
;; ---------------------------------- ;;

(eval-when-compile
  (declare-function mc/num-cursors "multiple-cursors")
  (declare-function string-blank-p "subr-x"))

;; -------------------------------------------------------------------------- ;;
;;
;; Macros
;;
;; -------------------------------------------------------------------------- ;;

(defmacro mood-line--deflazy (name)
  "Define dummy function NAME to `require' its module and call actual function."
  (let ((module (intern (car (split-string (symbol-name name) "--")))))
    `(defun ,name (&rest args)
       "Not yet loaded."
       (fmakunbound (quote ,name))
       (require (quote ,module))
       (apply (function ,name) args))))

(defmacro mood-line-defformat (&rest spec)
  "Format :left and :right segment lists of plist SPEC for `mood-line-format'.

A segment may be a string, a cons cell of the form (FUNCTION . SEPARATOR),
 or any expression that evaluates to a string or nil.

Strings will be collected into the format sequence unaltered.

Cons cells of the form (FUNCTION . SEPARATOR) will expand into the format
 sequence as FUNCTION, followed by SEPARATOR.

All other expressions will expand into the format sequence unaltered,
 followed by an empty string. This prevents accidental elision of the
 following segment should the expression evaluate to nil.

An optional key :padding may be provided, the value of which will be used as
 the padding for either side of the mode line. If :padding is nil, \"\s\" will
 be used as a default."
  (let* ((padding (or (plist-get spec :padding) "\s"))
         (left (append (list padding) (plist-get spec :left)))
         (right (append (plist-get spec :right) (list padding))))
    `(quote ,(mapcar
              (lambda (segments)
                (cl-loop for seg in segments
                         if (nlistp (cdr-safe seg)) append (list (car seg)
                                                                 (cdr seg))
                         else if (stringp seg) collect seg
                         else append (list seg "")))
              (list left right)))))

;; -------------------------------------------------------------------------- ;;
;;
;; Constants
;;
;; -------------------------------------------------------------------------- ;;

(defconst mood-line-glyphs-ascii
  '((:checker-info . ?i)
    (:checker-issues . ?+)
    (:checker-good . ?-)
    (:checker-checking . ?~)
    (:checker-errored . ?x)
    (:checker-interrupted . ?=)

    (:vc-added . ?+)
    (:vc-needs-merge . ?>)
    (:vc-needs-update . ?v)
    (:vc-conflict . ?x)
    (:vc-good . ?-)

    (:buffer-narrowed . ?v)
    (:buffer-modified . ?*)
    (:buffer-read-only . ?#)

    (:frame-client . ?@)

    (:count-separator . ?*))
  "Set of ASCII glyphs for use with mood-line.")

(defconst mood-line-glyphs-fira-code
  '((:checker-info . ?↳)
    (:checker-issues . ?→)
    (:checker-good . ?✓)
    (:checker-checking . ?⟳)
    (:checker-errored . ?x)
    (:checker-interrupted . ?=)

    (:vc-added . ?+)
    (:vc-needs-merge . ?⟷)
    (:vc-needs-update . ?↓)
    (:vc-conflict . ?x)
    (:vc-good . ?✓)

    (:buffer-narrowed . ?◢)
    (:buffer-modified . ?●)
    (:buffer-read-only . ?■)

    (:frame-client . ?)

    (:count-separator . ?×))
  "Set of Fira Code-compatible glyphs for use with mood-line.")

(defconst mood-line-glyphs-unicode
  '((:checker-info . ?🛈)
    (:checker-issues . ?⚑)
    (:checker-good . ?✔)
    (:checker-checking . ?🗘)
    (:checker-errored . ?✖)
    (:checker-interrupted . ?⏸)

    (:vc-added . ?🞤)
    (:vc-needs-merge . ?⟷)
    (:vc-needs-update . ?↓)
    (:vc-conflict . ?✖)
    (:vc-good . ?✔)

    (:buffer-narrowed . ?▼)
    (:buffer-modified . ?●)
    (:buffer-read-only . ?■)

    (:frame-client . ?⇅)

    (:count-separator . ?✕))
  "Set of Unicode glyphs for use with mood-line.")

(defconst mood-line-format-default
  (mood-line-defformat
   :left
   (((mood-line-segment-modal)                  . " ")
    ((or (mood-line-segment-buffer-status) " ") . " ")
    ((mood-line-segment-buffer-name)            . "  ")
    ((mood-line-segment-anzu)                   . "  ")
    ((mood-line-segment-multiple-cursors)       . "  ")
    ((mood-line-segment-cursor-position)        . " ")
    (mood-line-segment-scroll))
   :right
   (((mood-line-segment-vc)         . "  ")
    ((mood-line-segment-major-mode) . "  ")
    ((mood-line-segment-misc-info)  . "  ")
    ((mood-line-segment-checker)    . "  ")
    ((mood-line-segment-process)    . "  ")))
  "Default format for mood-line.")

(defconst mood-line-format-default-extended
  (mood-line-defformat
   :left
   (((mood-line-segment-modal)            . " ")
    ((or (mood-line-segment-buffer-status)
         (mood-line-segment-client)
         " ")                             . " ")
    ((mood-line-segment-project)          . "/")
    ((mood-line-segment-buffer-name)      . "  ")
    ((mood-line-segment-anzu)             . "  ")
    ((mood-line-segment-multiple-cursors) . "  ")
    (mood-line-segment-cursor-position)
    #(":" 0 1 (face mood-line-unimportant))
    ((mood-line-segment-cursor-point)     . " ")
    ((mood-line-segment-region)           . " ")
    (mood-line-segment-scroll))
   :right
   (((mood-line-segment-indentation) . "  ")
    ((mood-line-segment-eol)         . "  ")
    ((mood-line-segment-encoding)    . "  ")
    ((mood-line-segment-vc)          . "  ")
    ((mood-line-segment-major-mode)  . "  ")
    ((mood-line-segment-misc-info)   . "  ")
    ((mood-line-segment-checker)     . "  ")
    ((mood-line-segment-process)     . "  ")))
  "Extended default format for mood-line showcasing all included segments.")

;; -------------------------------------------------------------------------- ;;
;;
;; Custom definitions
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Group definitions
;; ---------------------------------- ;;

(defgroup mood-line nil
  "A minimal mode line configuration."
  :group 'mode-line)

(defgroup mood-line-faces nil
  "Faces used by mood-line."
  :group 'mood-line
  :group 'faces)

;; ---------------------------------- ;;
;; Variable definitions
;; ---------------------------------- ;;

(defcustom mood-line-glyph-alist mood-line-glyphs-ascii
  "Alist mapping glyph names to characters used to draw some mode line segments.

mood-line includes several sets of glyphs by default:

 `mood-line-glyphs-ascii'     | Basic ASCII character glyphs
 `mood-line-glyphs-fira-code' | Fira Code-compatible glyphs
 `mood-line-glyphs-unicode'   | Fancy unicode glyphs

Note that if a character provided by a glyph set is not included in your default
 font, the editor will render it with a fallback font.  If your fallback font is
 not the same height as your default font, the mode line may unexpectedly grow
 or shrink.

Keys are names for different mode line glyphs, values are characters for that
 glyph.  Glyphs used by mood-line include:

 :checker-info        | Syntax checker reports notes
 :checker-issues      | Syntax checker reports issues
 :checker-good        | Syntax checker reports no issues
 :checker-checking    | Syntax checker is running
 :checker-errored     | Syntax checker is stopped due to an error
 :checker-interrupted | Syntax checker is paused

 :vc-added            | VC backend reports additions/changes
 :vc-needs-merge      | VC backend reports required merge
 :vc-needs-update     | VC backend reports upstream is ahead of local
 :vc-conflict         | VC backend reports conflict
 :vc-good             | VC backend has nothing to report

 :buffer-narrowed     | File-backed buffer is narrowed
 :buffer-modified     | File-backed buffer is modified
 :buffer-read-only    | File-backed buffer is read-only

 :frame-client        | Frame is a client for an Emacs daemon

 :count-separator     | Separates some indicator names from numerical counts

`mood-line-glyphs-ascii' will be used as a fallback whenever a glyph is found
 to be missing in `mood-line-glyph-alist'."
  :group 'mood-line
  :type '(alist :tag "Character map alist"
                :key-type (symbol :tag "Glyph name")
                :value-type (character :tag "Character to use")))

(defcustom mood-line-format mood-line-format-default
  "List providing left and right lists of segments to format as the mode line.

The list should be of the form (L-SEGMENTS R-SEGMENTS), where L-SEGMENTS is a
 list of segments to be left-aligned, and R-SEGMENTS is a list of segments to
 be right-aligned. Lists are processed from first to last, and segments are
 displayed from left to right.

A segment may be any expression that evaluates to a string, or nil.
 Segment expressions evaluating to nil are not displayed.

When a segment evaluates to nil, the following segment will be skipped and not
 processed or displayed. This behavior may be used to, e.g., conditionally
 display separating whitespace after a segment.

Examples: `mood-line-format-default' and `mood-line-format-default-extended'

See `mood-line-defformat' for a helpful formatting macro."
  :group 'mood-line
  :type '(list :tag "Mode line segments"
               (repeat :tag "Left side" sexp)
               (repeat :tag "Right side" sexp)))

;; ---------------------------------- ;;
;; Face definitions
;; ---------------------------------- ;;

(defface mood-line-buffer-name
  '((t (:inherit mode-line-buffer-id)))
  "Face used for displaying the value of `buffer-name'."
  :group 'mood-line-faces)

(defface mood-line-buffer-status-modified
  '((t (:inherit error :weight normal)))
  "Face used for the ':buffer-modified' buffer status indicator."
  :group 'mood-line-faces)

(defface mood-line-buffer-status-read-only
  '((t (:inherit shadow :weight normal)))
  "Face used for the ':buffer-read-only' buffer status indicator."
  :group 'mood-line-faces)

(defface mood-line-buffer-status-narrowed
  '((t (:inherit font-lock-doc-face :weight normal)))
  "Face used for the ':buffer-narrowed' buffer status indicator."
  :group 'mood-line-faces)

(defface mood-line-frame-status-client
  '((t (:inherit mood-line-unimportant)))
  "Face used for the :frame-client frame status indicator.")

(defface mood-line-major-mode
  '((t (:inherit bold)))
  "Face used for the major mode indicator."
  :group 'mood-line-faces)

(defface mood-line-status-neutral
  '((t (:inherit mood-line-unimportant)))
  "Face used for neutral or inactive status indicators."
  :group 'mood-line-faces)

(defface mood-line-status-info
  '((t (:inherit font-lock-keyword-face :weight normal)))
  "Face used for generic status indicators."
  :group 'mood-line-faces)

(defface mood-line-status-success
  '((t (:inherit success :weight normal)))
  "Face used for success status indicators."
  :group 'mood-line-faces)

(defface mood-line-status-warning
  '((t (:inherit warning :weight normal)))
  "Face for warning status indicators."
  :group 'mood-line-faces)

(defface mood-line-status-error
  '((t (:inherit error :weight normal)))
  "Face for error status indicators."
  :group 'mood-line-faces)

(defface mood-line-encoding
  '((t (:inherit mood-line-unimportant)))
  "Face used for buffer/file encoding information."
  :group 'mood-line-faces)

(defface mood-line-unimportant
  '((t (:inherit shadow :weight normal)))
  "Face used for less important mode line elements."
  :group 'mood-line-faces)

;; -------------------------------------------------------------------------- ;;
;;
;; Helper functions
;;
;; -------------------------------------------------------------------------- ;;

(defvar mood-line--escape-buffer (get-buffer-create " *mood-line*")
  "Buffer used by `mood-line--escape'.")

(defun mood-line--escape (&rest strings)
  "Escape all mode line constructs in STRINGS."
  (with-current-buffer mood-line--escape-buffer
    (erase-buffer)
    (apply #'insert strings)
    (while (search-backward "%" nil t)
      (goto-char (match-beginning 0))
      (insert-char ?% 1 t)
      (goto-char (- (point) 1)))
    (buffer-string)))

(defun mood-line--get-glyph (glyph)
  "Return character from `mood-line-glyph-alist' for GLYPH.
If a character could not be found for the requested glyph, a fallback will be
returned from `mood-line-glyphs-ascii'."
  (char-to-string (or (alist-get glyph mood-line-glyph-alist)
                      (alist-get glyph mood-line-glyphs-ascii))))

(defun mood-line--process-segments (segments)
  "Process list of segments SEGMENTS, returning a string.
Segments are processed according to the rules described in the documentation
for `mood-line-format', which see."
  (cl-loop with last = t
           for seg in segments
           if last do (setq last (eval seg)) and concat last
           else do (setq last t)))

(defun mood-line--process-format (format)
  "Format and return a mode line string according to FORMAT.
Returned string is padded in the center to fit the width of the window.
Left and right segment lists of FORMAT will be processed according to the rules
described in the documentation for `mood-line-format', which see."
  (let ((right-str (mood-line--process-segments (cadr format))))
    (mood-line--escape
     (mood-line--process-segments (car format))
     " "
     (propertize " "
                 'display `((space :align-to (- right (- 0 right-margin)
                                                ,(length right-str)))))
     right-str)))

;; -------------------------------------------------------------------------- ;;
;;
;; Optional/lazy-loaded segments
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Modal editing
;; ---------------------------------- ;;

(mood-line--deflazy mood-line-segment-modal--evil-fn)
(mood-line--deflazy mood-line-segment-modal--meow-fn)
(mood-line--deflazy mood-line-segment-modal--xah-fn)
(mood-line--deflazy mood-line-segment-modal--god-fn)

(defun mood-line-segment-modal ()
  "Return the correct mode line segment for the first active modal mode found.
Modal editing modes checked, in order:
`evil-mode', `meow-mode', `xah-fly-keys', `god-mode'"
  (cond
   ((bound-and-true-p evil-mode)
    (mood-line-segment-modal--evil-fn))
   ((bound-and-true-p meow-mode)
    (mood-line-segment-modal--meow-fn))
   ((bound-and-true-p xah-fly-keys)
    (mood-line-segment-modal--xah-fn))
   ((or (bound-and-true-p god-local-mode)
        (bound-and-true-p god-global-mode))
    (mood-line-segment-modal--god-fn))))

;; ---------------------------------- ;;
;; Indentation style
;; ---------------------------------- ;;

(mood-line--deflazy mood-line-segment-indentation)

;; ---------------------------------- ;;
;; Version control
;; ---------------------------------- ;;

(mood-line--deflazy mood-line-segment-vc--update)

(defvar-local mood-line-segment-vc--text nil)

(defun mood-line-segment-vc ()
  "Return color-coded version control information."
  mood-line-segment-vc--text)

;; ---------------------------------- ;;
;; Checker status
;; ---------------------------------- ;;

(mood-line--deflazy mood-line-segment-checker--flycheck-update)
(mood-line--deflazy mood-line-segment-checker--flymake-update)

(defvar-local mood-line-segment-checker--flycheck-text nil)
(defvar-local mood-line-segment-checker--flymake-text nil)

(defun mood-line-segment-checker ()
  "Return status information for flycheck or flymake, if active."
  (cond
   ((bound-and-true-p flycheck-mode)
    mood-line-segment-checker--flycheck-text)
   ((bound-and-true-p flymake-mode)
    mood-line-segment-checker--flymake-text)))

;; -------------------------------------------------------------------------- ;;
;;
;; Client segment
;;
;; -------------------------------------------------------------------------- ;;

(defun mood-line-segment-client ()
  "Return an indicator representing the client status of the current frame."
  (when (frame-parameter nil 'client)
    (propertize (mood-line--get-glyph :frame-client)
                'face 'mood-line-frame-status-client)))

;; -------------------------------------------------------------------------- ;;
;;
;; Project segment
;;
;; -------------------------------------------------------------------------- ;;

(defun mood-line-segment-project ()
  "Return project name from project.el or Projectile, if any."
  (or
   (and (fboundp 'project-name)
        (project-current)
        (project-name (project-current)))
   (and (fboundp 'projectile-project-name)
        (projectile-project-name))))

;; -------------------------------------------------------------------------- ;;
;;
;; anzu segment
;;
;; -------------------------------------------------------------------------- ;;

(defun mood-line-segment-anzu ()
  "Return color-coded anzu status information."
  (when (bound-and-true-p anzu--state)
    (cond
     ((eq anzu--state 'replace-query)
      (format #("Replace%s%d"
                7 10 (face mood-line-status-info))
              (mood-line--get-glyph :count-separator)
              anzu--cached-count))
     (anzu--overflow-p
      (format #("%d/%d+"
                0 2 (face mood-line-status-info)
                3 6 (face mood-line-status-error))
              anzu--current-position anzu--total-matched))
     (t
      (format #("%d/%d"
                0 2 (face mood-line-status-info))
              anzu--current-position anzu--total-matched)))))

;; -------------------------------------------------------------------------- ;;
;;
;; multiple-cursors segment
;;
;; -------------------------------------------------------------------------- ;;

(defun mood-line-segment-multiple-cursors ()
  "Return the number of active multiple-cursors."
  (when (bound-and-true-p multiple-cursors-mode)
    (format #("MC%s%d"
              2 5 (face mood-line-status-info))
            (mood-line--get-glyph :count-separator)
            (mc/num-cursors))))

;; -------------------------------------------------------------------------- ;;
;;
;; Buffer information segments
;;
;; -------------------------------------------------------------------------- ;;

;; ---------------------------------- ;;
;; Buffer status segment
;; ---------------------------------- ;;

(defun mood-line-segment-buffer-status ()
  "Return an indicator representing the status of the current buffer."
  (if (buffer-file-name (buffer-base-buffer))
      (cond
       ((and (buffer-narrowed-p)
             (buffer-modified-p))
        (propertize (mood-line--get-glyph :buffer-narrowed)
                    'face 'mood-line-buffer-status-modified))
       ((and (buffer-narrowed-p)
             buffer-read-only)
        (propertize (mood-line--get-glyph :buffer-narrowed)
                    'face 'mood-line-buffer-status-read-only))
       ((buffer-narrowed-p)
        (propertize (mood-line--get-glyph :buffer-narrowed)
                    'face 'mood-line-buffer-status-narrowed))
       ((buffer-modified-p)
        (propertize (mood-line--get-glyph :buffer-modified)
                    'face 'mood-line-buffer-status-modified))
       (buffer-read-only
        (propertize (mood-line--get-glyph :buffer-read-only)
                    'face 'mood-line-buffer-status-read-only)))
    (when (buffer-narrowed-p)
      (propertize (mood-line--get-glyph :buffer-narrowed)
                  'face 'mood-line-buffer-status-narrowed))))

;; ---------------------------------- ;;
;; Buffer name segment
;; ---------------------------------- ;;

(defun mood-line-segment-buffer-name ()
  "Return the name of the current buffer."
  (format-mode-line "%b" 'mood-line-buffer-name))

;; ---------------------------------- ;;
;; Cursor position segment
;; ---------------------------------- ;;

(defun mood-line-segment-cursor-position ()
  "Return the position of the cursor in the current buffer."
  (format-mode-line "%l:%c"))

;; ---------------------------------- ;;
;; Cursor point segment
;; ---------------------------------- ;;

(defun mood-line-segment-cursor-point ()
  "Return the value of `point' in the current buffer."
  (format #("%d"
            0 2 (face mood-line-unimportant))
          (point)))

;; ---------------------------------- ;;
;; Region segment
;; ---------------------------------- ;;

(defun mood-line-segment-region ()
  "Return the size of the active region in the current buffer, if any."
  (when (use-region-p)
    (format #("%sL:%sC"
              0 7 (face mood-line-unimportant))
            (count-lines (region-beginning)
                         (region-end))
            (- (region-end) (region-beginning)))))

;; ---------------------------------- ;;
;; Scroll segment
;; ---------------------------------- ;;

(defun mood-line-segment-scroll ()
  "Return the relative position of the viewport in the current buffer."
  (format-mode-line "%o" 'mood-line-unimportant))

;; ---------------------------------- ;;
;; EOL segment
;; ---------------------------------- ;;

(defun mood-line-segment-eol ()
  "Return the EOL type for the coding system of the current buffer."
  (when buffer-file-coding-system
    (pcase (coding-system-eol-type buffer-file-coding-system)
      (0 "LF")
      (1 "CRLF")
      (2 "CR"))))

;; ---------------------------------- ;;
;; Encoding segment
;; ---------------------------------- ;;

(defun mood-line-segment-encoding ()
  "Return the name of the coding system of the current buffer."
  (when buffer-file-coding-system
    (let ((coding-system (coding-system-plist buffer-file-coding-system)))
      (cond
       ((memq (plist-get coding-system :category)
              '(coding-category-undecided coding-category-utf-8))
        "UTF-8")
       (t
        (upcase (symbol-name (plist-get coding-system :name))))))))

;; ---------------------------------- ;;
;; Major mode segment
;; ---------------------------------- ;;

(defun mood-line-segment-major-mode ()
  "Return the name of the major mode of the current buffer."
  (propertize (substring-no-properties (format-mode-line mode-name))
              'face 'mood-line-major-mode))

;; ---------------------------------- ;;
;; Misc. info segment
;; ---------------------------------- ;;

(defun mood-line-segment-misc-info ()
  "Return the current value of `mode-line-misc-info'."
  (let ((misc-info (format-mode-line mode-line-misc-info)))
    (unless (string-blank-p misc-info)
      (propertize (string-trim misc-info)
                  'face 'mood-line-unimportant))))

;; ---------------------------------- ;;
;; Process segment
;; ---------------------------------- ;;

(defun mood-line-segment-process ()
  "Return the current value of `mode-line-process'."
  (let ((process-info (format-mode-line mode-line-process)))
    (unless (string-blank-p process-info)
      (string-trim process-info))))

;; -------------------------------------------------------------------------- ;;
;;
;; mood-line-mode
;;
;; -------------------------------------------------------------------------- ;;

(defconst mood-line--hooks-alist
  '((mood-line-segment-checker--flycheck-update
     . (flycheck-mode-hook
        flycheck-status-changed-functions))
    (mood-line-segment-vc--update
     . (find-file-hook
        after-save-hook)))
  "Alist of update functions and their corresponding hooks.")

(defconst mood-line--advice-alist
  '((mood-line-segment-checker--flymake-update
     . (flymake-start
        flymake--handle-report))
    (mood-line-segment-vc--update
     . (vc-refresh-state)))
  "Alist of update functions and their corresponding advised functions.")

(defconst mood-line--settings-alist
  '((anzu-cons-mode-line-p
     . nil)
    (mode-line-format
     . (:eval (mood-line--process-format mood-line-format))))
  "Alist providing symbol names and their desired values.
These settings are applied by `mood-line--activate' when `mood-line-mode'
is activated. The original value of each symbol will be stored in
`mood-line--settings-backup-alist' until `mood-line--deactivate' is called.")

(defvar mood-line--settings-backup-alist nil
  "Alist storing symbol names and their original values.
Populated by `mood-line--activate', and emptied by `mood-line--deactivate'.")

;; ---------------------------------- ;;
;; Activation
;; ---------------------------------- ;;

(defun mood-line--activate ()
  "Activate mood-line, installing hooks and setting `mode-line-format'."
  ;; Install hooks and advice
  (cl-loop for (update-fn . hooks) in mood-line--hooks-alist
           do (dolist (hook hooks)
                (add-hook hook update-fn)))
  (cl-loop for (update-fn . advised-fns) in mood-line--advice-alist
           do (dolist (advised-fn advised-fns)
                (advice-add advised-fn :after update-fn)))
  ;; Install configuration, backing up original values
  (cl-loop for (var . new-val) in mood-line--settings-alist
           when (boundp var) do (push (cons var (eval var))
                                      mood-line--settings-backup-alist)
           do (set-default (intern (symbol-name var)) new-val)))

;; ---------------------------------- ;;
;; Deactivation
;; ---------------------------------- ;;

(defun mood-line--deactivate ()
  "Deactivate mood-line, uninstalling hooks and restoring `mode-line-format'."
  ;; Destroy hooks and advice
  (cl-loop for (update-fn . hooks) in mood-line--hooks-alist
           do (dolist (hook hooks)
                (remove-hook hook update-fn)))
  (cl-loop for (update-fn . advised-fns) in mood-line--advice-alist
           do (dolist (advised-fn advised-fns)
                (advice-remove advised-fn update-fn)))
  ;; Restore original configuration values
  (cl-loop for (var . old-val) in mood-line--settings-backup-alist
           do (set-default (intern (symbol-name var)) old-val)))

;; ---------------------------------- ;;
;; Mode definition
;; ---------------------------------- ;;

;;;###autoload
(define-minor-mode mood-line-mode
  "Toggle mood-line on or off."
  :group 'mood-line
  :global t
  :lighter nil
  (if mood-line-mode
      (mood-line--activate)
    (mood-line--deactivate)))

;; -------------------------------------------------------------------------- ;;
;;
;; Provide package
;;
;; -------------------------------------------------------------------------- ;;

(provide 'mood-line)

;;; mood-line.el ends here
