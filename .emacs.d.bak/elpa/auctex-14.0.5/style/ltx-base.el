;;; ltx-base.el --- AUCTeX style for basic LaTeX commands.  -*- lexical-binding: t; -*-

;; Copyright (C) 2004--2024 Free Software Foundation, Inc.

;; Author: Frank Küster <frank@kuesterei.ch>
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

;; This file adds general support for basic LaTeX commands used for
;; writing LaTeX class files (.cls), style files (.sty) and package
;; files (.dtx).  Most of the macros are taken from clsguide.pdf and
;; fntguide.pdf

;;; Code:

(require 'tex)
(require 'latex)

;; Silence the compiler:
(declare-function font-latex-add-keywords
                  "font-latex"
                  (keywords class))

(defvar LaTeX-property-list '("abspage" "page" "pagenum" "label"
                              "title" "target" "pagetarget"
                              "counter" "xpos" "ypos")
  "List of properties predefined in LaTeX kernel.")

(TeX-add-style-hook
 "ltx-base"
 (lambda ()

   ;; Macros from clsguide.pdf
   (TeX-add-symbols

    ;; 4.1 Identification.  Other '\Provide*' macros are available in
    ;; latex.el
    '("NeedsTeXFormat" "Format" [ "Release date" ])

    ;; 4.2 Loading files
    ;; \RequirePackage is provided in latex.el
    '("RequirePackageWithOptions" "Package" [ "Release information" ])

    '("LoadClass" [ "Options" ] "Class" [ "Release information" ])
    '("LoadClassWithOptions"    "Class" [ "Release information" ])

    ;; 4.3 Delaying code
    '("AtEndOfPackage" t)
    '("AtEndOfClass" t)
    '("AtBeginDocument" t)
    '("AtEndDocument" t)
    ;; Marked as legacy LaTeX code:
    ;; '("AtBeginDvi" t)


    ;; 4.4 Creating and using keyval option:
    '("DeclareKeys" ["Family"] t)
    '("DeclareUnknownKeyHandler" ["Family"] t)
    '("ProcessKeyOptions" ["Family"])
    '("SetKeys" ["Family"] t)

    ;; 4.5 Passing options around
    '("PassOptionsToPackage" "Option(s) list" "Package")
    '("PassOptionsToClass" "Option(s) list" "Class")

    ;; 4.6 Safe file commands
    '("IfFileExists" "File" 2)
    '("InputIfFileExists" "File" 2)


    ;; 4.7 Reporting errors, etc
    '("ClassError" "Class name" "Error text" t)
    '("PackageError" "Package name" "Error text" t)

    '("ClassWarning" "Class name" t)
    '("PackageWarning" "Package name" t)
    '("ClassWarningNoLine" "Class name" t)
    '("PackageWarningNoLine" "Package name" t)

    '("ClassInfo" "Class name" t)
    '("PackageInfo" "Package name" t)

    '("MessageBreak" 0)
    '("message" "Log Message")

    ;; 5.1 Layout parameters
    ;; \paperheight & \paperwidth are in latex.el

    ;; 5.2 Case changing
    ;; \MakeUppercase, \MakeLowercase & \MakeTitlecase are in latex.el

    ;; 5.3 Better user-defined math display environments
    "ignorespacesafterend"

    ;; 5.4 Normalising spacing
    "normalsfcodes"

    ;; 5.5 Querying localisation: TBD

    ;; 5.6 Extended and expandable references of properties
    '("RecordProperties" "Label"
      (TeX-arg-completing-read-multiple LaTeX-property-list "Property"))
    '("RefProperty" "Label"
      (TeX-arg-completing-read LaTeX-property-list "Property"))
    '("RefUndefinedWarn" "Label"
      (TeX-arg-completing-read LaTeX-property-list "Property"))

    '("NewProperty" "Name"
      (TeX-arg-completing-read ("now" "shipout") "Setpoint")
      "Default" t)
    '("SetProperty" "Name"
      (TeX-arg-completing-read ("now" "shipout") "Setpoint")
      "Default" t)

    ;; 5.7 Preparing link targets
    '("MakeLinkTarget" ["Prefix"] TeX-arg-counter)
    '("MakeLinkTarget*" "Target name")

    '("LinkTargetOn" 0)
    '("LinkTargetOff" 0)
    '("NextLinkTarget" "Target name")

    ;; 6.1 Defining commands
    '("DeclareRobustCommand"
      TeX-arg-define-macro [ TeX-arg-define-macro-arguments ] t)
    '("DeclareRobustCommand*"
      TeX-arg-define-macro [ TeX-arg-define-macro-arguments ] t)

    '("CheckCommand" TeX-arg-macro [ TeX-arg-define-macro-arguments ] t)
    '("CheckCommand*" TeX-arg-macro [ TeX-arg-define-macro-arguments ] t)

    ;; 6.2 Option declaration
    '("DeclareOption" "Option" t)
    '("DeclareOption*" t)

    ;; 6.3 Commands within option code
    '("CurrentOption" 0)
    '("OptionNotUsed" 0)

    ;; 6.4 Option processing
    '("ProcessOptions" (TeX-arg-literal "\\relax"))
    "ProcessOptions*"
    '("ExecuteOptions" "Option list")

    ;; Some general macros not mentioned in clsguide.pdf
    '("@addtoreset" TeX-arg-counter (TeX-arg-counter "Within counter"))
    '("addpenalty" "Penalty")
    '("@ifundefined" TeX-arg-macro 2)
    '("@ifnextchar" (TeX-arg-literal " ") (TeX-arg-free "Character") 2)
    '("expandafter" 0) )

   ;; Run the style hook so we can use `LaTeX-fontenc-package-options':
   (TeX-run-style-hooks "fontenc")

   ;; Macros from fntguide.pdf
   (TeX-add-symbols

    ;; 2.5 Special font declaration commands
    '("DeclareFixedFont" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      4)
    '("DeclareTextFontCommand" TeX-arg-define-macro t)
    '("DeclareOldFontCommand" TeX-arg-define-macro 2)

    ;; 3.3 Declaring math versions
    '("DeclareMathVersion" "Version")

    ;; 3.4 Declaring math alphabets
    '("DeclareMathAlphabet" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      3)
    '("SetMathAlphabet" TeX-arg-define-macro
      "Version"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      3)

    ;; 3.5 Declaring symbol fonts
    '("DeclareSymbolFont" "Symbol font"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      3)
    '("SetSymbolFont" "Symbol font" "Version"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      3)
    '("DeclareSymbolFontAlphabet" TeX-arg-define-macro "Symbol font")

    ;; 3.6 Declaring math symbols
    '("DeclareMathSymbol" "Symbol"
      (TeX-arg-completing-read ("0" "1" "2" "3" "4" "5" "6" "7"
                                "\\marthord" "\\mathop" "\\mathbin"
                                "\\mathrel" "\\mathopen" "\\mathclose"
                                "\\mathpunct" "\\mathalph")
                               "Type")
      2)
    '("DeclareMathDelimiter" "Symbol"
      (TeX-arg-completing-read ("0" "1" "2" "3" "4" "5" "6" "7"
                                "\\marthord" "\\mathop" "\\mathbin"
                                "\\mathrel" "\\mathopen" "\\mathclose"
                                "\\mathpunct" "\\mathalph")
                               "Type")
      4)
    '("DeclareMathAccent" TeX-arg-define-macro
      (TeX-arg-completing-read ("0" "1" "2" "3" "4" "5" "6" "7"
                                "\\marthord" "\\mathop" "\\mathbin"
                                "\\mathrel" "\\mathopen" "\\mathclose"
                                "\\mathpunct" "\\mathalph")
                               "Type")
      2)
    '("DeclareMathRadical" TeX-arg-define-macro 4)

    ;; 3.7 Declaring math sizes
    '("DeclareMathSizes" 4)

    ;; 4.2 Font definition file commands
    '("DeclareFontFamily"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      2)
    '("DeclareFontShape"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      5)
    '("DeclareSizeFunction" 2)

    ;; 5.2 Encoding definition file commands
    '("DeclareFontEncoding" "Encoding" 2)
    '("DeclareTextCommand" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      [TeX-arg-define-macro-arguments] t)
    '("ProvideTextCommand" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      [TeX-arg-define-macro-arguments] t)
    '("DeclareTextSymbol" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      "Slot")
    '("DeclareTextAccent" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      "Slot")
    '("DeclareTextComposite" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      2)
    '("DeclareTextCompositeCommand" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      2)
    "LastDeclaredEncoding"

    ;; 5.3 Default definitions
    '("DeclareTextCommandDefault" TeX-arg-define-macro t)
    '("DeclareTextAccentDefault" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding"))
    '("DeclareTextSymbolDefault" TeX-arg-define-macro
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding"))
    '("ProvideTextCommandDefault" TeX-arg-define-macro t)

    ;; 5.4 Encoding defaults
    '("DeclareFontEncodingDefaults" 2)
    '("DeclareFontSubstitution"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      3)

    ;; 6.1 Font substitution
    '("DeclareErrorFont")
    "fontsubfuzz"

    ;; 6.2 Preloading
    '("DeclarePreloadSizes"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      4)

    ;; 6.6 Font series defaults per document family
    '("DeclareFontSeriesDefault"
      [TeX-arg-completing-read ("rm" "sf" "tt") "Meta family"]
      (TeX-arg-completing-read ("bf" "md") "Meta series")
      "Series value")

    ;; 6.7 Handling of current and requested font series and shape
    '("DeclareFontSeriesChangeRule" 4)
    '("DeclareFontShapeChangeRule"  4)

    ;; 6.8 Handling of nested emphasis
    '("DeclareEmphSequence"
      (TeX-arg-completing-read-multiple (lambda ()
                                          (mapcar (lambda (x)
                                                    (concat TeX-esc x))
                                                  LaTeX-font-shape))
                                        "Font declarations"))

    ;; 6.9 Providing font family substitutions
    '("DeclareFontFamilySubstitution"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      2)

    ;; 7 Additional text symbols - textcomp
    '("DeclareEncodingSubset"
      (TeX-arg-completing-read LaTeX-fontenc-package-options "Encoding")
      2) )

   ;; Fontification
   (when (and (featurep 'font-latex)
              (eq TeX-install-font-lock 'font-latex-setup))
     (font-latex-add-keywords '(("NeedsTeXFormat"       "{[")
                                ("RequirePackageWithOptions" "{[")
                                ("LoadClass"            "[{[")
                                ("LoadClassWithOptions" "{[")
                                ;; Don't fontify the second argument
                                ;; which will contain code:
                                ("DeclareOption"         "*{")
                                ("CurrentOption"         "")
                                ("OptionNotUsed"         "")
                                ("PassOptionsToPackage"  "{{")
                                ("PassOptionsToClass"    "{{")

                                ("AtEndOfPackage"  "")
                                ("AtEndOfClass"    "")
                                ("AtBeginDocument" "")
                                ("AtEndDocument"   "")

                                ("DeclareKeys"              "[{")
                                ("DeclareUnknownKeyHandler" "[{")
                                ("ProcessKeyOptions"        "[")
                                ("SetKeys"                  "[{")

                                ("RefUndefinedWarn" "{{")
                                ("NewProperty" "{{{{")
                                ("SetProperty" "{{{{")

                                ("MakeLinkTarget" "*[{")
                                ("LinkTargetOn" "")
                                ("LinkTargetOff" "")
                                ("NextLinkTarget" "")

                                ("ProcessOptions" "*")
                                ("ExecuteOptions" "{")
                                ("DeclareRobustCommand" "*|{\\[[{")
                                ("CheckCommand"         "*|{\\[[{")

                                ("DeclareFixedFont"       "|{\\{{{{{")
                                ("DeclareTextFontCommand" "|{\\|{\\")
                                ("DeclareOldFontCommand"  "|{\\|{\\|{\\")

                                ("DeclareMathVersion"   "{")
                                ("DeclareMathAlphabet"  "|{\\{{{{")
                                ("SetMathAlphabet"      "|{\\{{{{{")

                                ("DeclareSymbolFont"         "{{{{{")
                                ("SetSymbolFont"             "{{{{{{")
                                ("DeclareSymbolFontAlphabet" "|{\\{")

                                ("DeclareMathSymbol"    "|{\\|{\\{{")
                                ("DeclareMathDelimiter" "|{\\|{\\{{{{")
                                ("DeclareMathAccent"    "|{\\{{{")
                                ("DeclareMathRadical"   "|{\\{{{{")

                                ("DeclareMathSizes"     "{{{{")

                                ("DeclareFontFamily"  "{{{")
                                ("DeclareFontShape"   "{{{{{{")

                                ("DeclareFontEncoding"         "{{{")
                                ("DeclareTextCommand"          "|{\\{[[{")
                                ("ProvideTextCommand"          "|{\\{[[{")
                                ("DeclareTextSymbol"           "|{\\{{")
                                ("DeclareTextAccent"           "|{\\{{")
                                ("DeclareTextComposite"        "|{\\{{{")
                                ("DeclareTextCompositeCommand" "|{\\{{{")

                                ("DeclareTextCommandDefault" "|{\\|{\\")
                                ("DeclareTextAccentDefault"  "|{\\{")
                                ("DeclareTextSymbolDefault"  "|{\\{")
                                ("ProvideTextCommandDefault" "|{\\|{\\")

                                ("DeclareFontEncodingDefaults" "{{")
                                ("DeclareFontSubstitution"     "{{{{")

                                ("DeclareErrorFont" "{{{{")

                                ("DeclarePreloadSizes" "{{{{{")

                                ("DeclareFontSeriesDefault" "[{{")

                                ("DeclareFontSeriesChangeRule" "{{{{")
                                ("DeclareFontShapeChangeRule " "{{{{")

                                ("DeclareEmphSequence" "{")

                                ("DeclareFontFamilySubstitution" "{{{")

                                ("DeclareEncodingSubset"       "{{{"))
                              'function)
     (font-latex-add-keywords '(("RecordProperties" "{{")
                                ("RefProperty" "{{"))
                              'reference) ))
 TeX-dialect)

;; Local Variables:
;; coding: utf-8
;; End:

;;; ltx-base.el ends here
