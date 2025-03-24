;;; wasysym.el --- AUCTeX style for `wasysym.sty' (v2.4)  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Free Software Foundation, Inc.

;; Author: Arash Esbati <arash@gnu.org>
;; Maintainer: auctex-devel@gnu.org
;; Created: 2023-05-02
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

;; This file adds support for `wasysym.sty' (v2.4) from 2020/01/19.

;;; Code:

(require 'tex)
(require 'latex)

(TeX-add-style-hook
 "wasysym"
 (lambda ()
   (TeX-add-symbols
    ;; General symbols
    "male"
    "female"
    "cent"
    "wasyeuro"
    "currency"
    "phone"
    "recorder"
    "clock"
    "lightning"
    "diameter"
    "invdiameter"
    "varangle"
    "wasylozenge"
    "kreuz"
    "smiley"
    "frownie"
    "blacksmiley"
    "sun"
    "checked"
    "bell"
    "ataribox"
    "permil"
    "brokenvert"
    "wasytherefore"
    "Bowtie"
    "agemO"
    "wasyparagraph"
    "Paragraph"
    "wasycmd"
    "applecmd"

    ;; Electrical and physical symbols
    "AC"
    "HF"
    "VHF"
    "photon"
    "gluon"

    ;; Polygons and stars
    "Square"
    "XBox"
    "CheckedBox"
    "hexagon"
    "varhexagon"
    "pentagon"
    "octagon"
    "hexstar"
    "varhexstar"
    "davidsstar"

    ;; Music notes
    "eighthnote"
    "quarternote"
    "halfnote"
    "fullnote"
    "twonotes"

    ;; Various circles
    "Circle"
    "CIRCLE"
    "Leftcircle"
    "LEFTCIRCLE"
    "Rightcircle"
    "RIGHTCIRCLE"
    "LEFTcircle"
    "RIGHTcircle"
    "leftturn"
    "rightturn"

    ;; Arrows
    "pointer"
    "RIGHTarrow"
    "LEFTarrow"
    "UParrow"
    "DOWNarrow"

    ;; Phonetic symbols
    "thorn"
    "Thorn"
    "openo"
    "inve"

    ;; Astronomical symbols
    "vernal"
    "ascnode"
    "descnode"
    "fullmoon"
    "newmoon"
    "leftmoon"
    "rightmoon"
    "astrosun"
    "mercury"
    "venus"
    "earth"
    "mars"
    "jupiter"
    "saturn"
    "uranus"
    "neptune"
    "pluto"

    ;; Astrological symbols and the zodiacal symbols
    "aries"
    "taurus"
    "gemini"
    "cancer"
    "leo"
    "virgo"
    "libra"
    "scorpio"
    "sagittarius"
    "capricornus"
    "aquarius"
    "pisces"
    "conjunction"
    "opposition"

    ;; APL symbols
    "APLstar"
    "APLlog"
    "APLbox"
    "APLup"
    "APLdown"
    "APLinput"
    "APLcomment"
    "APLinv"
    "APLuparrowbox"
    "APLdownarrowbox"
    "APLleftarrowbox"
    "APLrightarrowbox"
    "notbackslash"
    "notslash"
    "APLnot"
    "APLvert"
    "APLcirc"
    "APLminus")

   ;; \euro is available unless `noeuro' option is specified:
   (unless (LaTeX-provided-package-options-member "wasysym" "noeuro")
     (TeX-add-symbols "euro")))
 TeX-dialect)

(defvar LaTeX-wasysym-package-options
  '("integrals" "nointegrals" "compat1" "noeuro")
  "Package options for the wasysym package.")

;;; wasysym.el ends here
