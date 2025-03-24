(org-babel-load-file
 (expand-file-name
  "config.org"
  user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("64045b3416d83e5eac0718e236b445b2b3af02ff5bcd228e9178088352344a92" "cb8eb6d80c3908a53b0c8a98ab0cedd007c1f10593a5f0f1e2ee24eec241e3e0" "bbfccff82c1d35611cdf25339401a483875b32472fae7fcdaf14bd12c3a05b07" "6bdc4e5f585bb4a500ea38f563ecf126570b9ab3be0598bdf607034bb07a8875" "bf42a0e2b86f1789f5c49ab6ccd6251a018d96728794832b3035da80ed01e693" "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" default))
 '(helm-minibuffer-history-key "M-p")
 '(package-selected-packages
   '(hide-mode-line flyspell-correct-ivy mood-line dashboard consult pdf-tools solarized-dark-theme color-theme-sanityinc-tomorrow auctex web-mode tree-sitter tree-sitter-langs treesit-auto adwaita-dark-theme lsp-ui solarized-theme modus-themes cyberpunk-2019-theme cyberpunk-theme highlight-indent-guides parchment-theme leuven-theme solo-jazz-theme all-the-icons-nerd-fonts haki-theme spacemacs-theme night-owl-theme basic-theme atom-dark-theme atom-one-dark-theme nerd-icons-corfu beacon org-bullets toc-org corfu ligature ligatures company company-mode auto-complete vterm vterm-toggle all-the-icons-dired rainbow-mode all-the-icons-ivy-rich general all-the-icons helpful ivy-rich which-key rainbow-delimiters doom-themes counsel evil-collection evil ivy command-log-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-1 ((t (:inherit outline-1 :height 1.4))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.2))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.2))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.0)))))
(put 'dired-find-alternate-file 'disabled nil)
