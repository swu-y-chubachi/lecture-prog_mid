;;; build.el --- ox-publish HTML Build Script with ID Link & CJK Space Filter Fixes -*- lexical-binding: t; -*-
;; CI環境用に ~/.emacs.d ディレクトリを事前に作成する
(make-directory "~/.emacs.d/" t)

(require 'package)
(setq package-enable-at-startup nil)

(require 'org)
(require 'ox-publish)
(require 'ox-html)
(require 'org-id)

;; 1. CUSTOM_ID を優先して HTML アンカー・ラベルとして使用する
(setq org-html-prefer-user-labels t)

;; 2. 日本語（CJK）改行時の余分な空白削除フィルター
(defun my/org-export-remove-cjk-spaces (text backend info)
  "HTML エクスポート時に CJK 文字間の改行（および空白）を削除して余計なスペースが入らないようにする。"
  (if (org-export-derived-backend-p backend 'html)
      (let ((cjk "\\(?:\\cc\\|\\ck\\|\\ch\\|\\cA\\|\\cK\\|\\cC\\|\\cH\\|\\cj\\)"))
        (replace-regexp-in-string
         (format "\\(%s\\)\n[ \t]*\\(%s\\)" cjk cjk)
         "\\1\\2" text))
    text))

(add-to-list 'org-export-filter-plain-text-functions
             'my/org-export-remove-cjk-spaces)

;; 3. org-id のデータベースを ./src/ 配下の全 Org ファイルから再構築
(message "=== Updating Org ID Database ===")
(setq org-id-extra-files (directory-files-recursively "./src/" "\\.org$"))
(org-id-update-id-locations org-id-extra-files)

;; 4. id: 形式の内部リンクを HTML エクスポート時に正しい相対パス (ファイル名.html#ID) に置換
(org-link-set-parameters
 "id"
 :export
 (lambda (path description format _channel)
   (let* ((id path)
          (file (org-id-find-id-file id))
          (custom-id (when file
                       (with-current-buffer (find-file-noselect file)
                         (org-with-wide-buffer
                          (goto-char (point-min))
                          (when (re-search-forward (format ":\\(?:ID\\|CUSTOM_ID\\):[ \t]+%s" (regexp-quote id)) nil t)
                            (org-entry-get nil "CUSTOM_ID"))))))
          (anchor (or custom-id id))
          (target-html (if file
                           (concat (file-name-base file) ".html")
                         "")))
     (cond
      ((eq format 'html)
       (format "<a href=\"%s#%s\">%s</a>" target-html anchor (or description path)))
      (t (or description path))))))

;; 5. ox-publish のプロジェクト設定
(setq org-publish-project-alist
      `(("website-org"
         :base-directory "./src/"
         :publishing-directory "./public/"
         :publishing-function org-html-publish-to-html
         :recursive t
         ;; テーマ: ReadTheOrg (https://github.com/fniessen/org-html-themes)
         :html-head ,(concat
                     ;; 日本語フォント: Zen Kaku Gothic New (Google Fonts)
                     "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\"/>"
                     "<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin/>"
                     "<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css2?family=Zen+Kaku+Gothic+New:wght@400;700&display=swap\"/>"
                     "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://fniessen.github.io/org-html-themes/src/readtheorg/css/htmlize.css\"/>"
                     "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://fniessen.github.io/org-html-themes/src/readtheorg/css/readtheorg.css\"/>"
                     "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://fniessen.github.io/org-html-themes/src/readtheorg/css/code-copy.css\"/>"
                     "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://fniessen.github.io/org-html-themes/src/readtheorg/css/search.css\"/>"
                     "<script type=\"text/javascript\" src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>"
                     "<script type=\"text/javascript\" src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>"
                     "<script type=\"text/javascript\" src=\"https://fniessen.github.io/org-html-themes/src/vendor/stickytableheaders/jquery.stickytableheaders.min.js\"></script>"
                     "<script type=\"text/javascript\" src=\"https://fniessen.github.io/org-html-themes/src/readtheorg/js/search.js\"></script>"
                     "<script type=\"text/javascript\" src=\"https://fniessen.github.io/org-html-themes/src/readtheorg/js/readtheorg.js\"></script>"
                     "<script type=\"text/javascript\" src=\"https://fniessen.github.io/org-html-themes/src/readtheorg/js/code-copy.js\"></script>"
                     "<style>body, h1, h2, h3, h4, h5, h6, p, table, ul, ol, li, #table-of-contents { font-family: \"Zen Kaku Gothic New\", -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Hiragino Sans\", \"Hiragino Kaku Gothic ProN\", \"Meiryo\", sans-serif !important; }</style>")
         :html-head-include-default-style nil
         :with-toc t
         :section-numbers t)
        ("website-static"
         :base-directory "./src/"
         :publishing-directory "./public/"
         :publishing-function org-publish-attachment
         :recursive t
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|svg\\|pdf")
        ("website" :components ("website-org" "website-static"))))

;; 6. 全ファイルの強制パブリッシュ実行
(message "=== Publishing Website ===")
(org-publish-all t)
