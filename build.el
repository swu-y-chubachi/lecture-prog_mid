(require 'ox-publish)

;; 日本語改行時の余分な空白削除フィルター
(defun my/org-export-remove-cjk-spaces (text backend info)
  (when (org-export-derived-backend-p backend 'html)
    (let ((cjk "\\(?:\\cc\\|\\ck\\|\\ch\\|\\cA\\|\\cK\\|\\cC\\|\\cH\\)"))
      (replace-regexp-in-string
       (format "\\(%s\\)\n[ \t]*\\(%s\\)" cjk cjk)
       "\\1\\2" text))))

(add-to-list 'org-export-filter-plain-text-functions
             'my/org-export-remove-cjk-spaces)

;; パブリッシュ設定
(setq org-publish-project-alist
      '(("website"
         :base-directory "./src/"
         :publishing-directory "./public/"
         :publishing-function org-html-publish-to-html
         :recursive t
         :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://gongzhitaao.org/orgcss/org.css\" /><style>body, h1, h2, h3, h4, h5, h6, p, table, ul, ol { font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Hiragino Sans\", \"Hiragino Kaku Gothic ProN\", \"Meiryo\", sans-serif !important; }</style>"
         :html-head-include-default-style nil)))

;; 全ファイルを強制ビルド
(org-publish-all t)
