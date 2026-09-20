;;; build.el --- Org-mode HTML Builder with org-id / CUSTOM_ID link support -*- lexical-binding: t; -*-

(require 'package)
(setq package-enable-at-startup nil)

(require 'org)
(require 'ox-html)
(require 'org-id)

;; 1. CUSTOM_ID を HTML の id 属性や #CUSTOM_ID リンクとして優先利用する
(setq org-html-prefer-user-labels t)

;; 2. ビルド対象のディレクトリ内の全 Org ファイルから ID データベースを再構築する
(message "=== Updating org-id locations ===")
(setq org-id-extra-files (directory-files-recursively "." "\\.org$"))
(org-id-update-id-locations org-id-extra-files)

;; 3. id: 形式のリンクを HTML エクスポート時に正しい相対パス (ファイル名.html#ID) に書き換える処理
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
                            (org-entry-get nil "CUSTOM_ID")))))))
          (anchor (or custom-id id))
          (target-html (if file
                           (concat (file-name-base file) ".html")
                         "")))
     (cond
      ((eq format 'html)
       (format "<a href=\"%s#%s\">%s</a>" target-html anchor (or description path)))
      (t (or description path))))))

;; 4. 全 Org ファイルの一括 HTML 変換処理
(defun build-website ()
  (interactive)
  (message "=== Exporting Org files to HTML ===")
  (dolist (file (directory-files-recursively "." "\\.org$"))
    ;; ドットで始まる隠しファイル・バックアップファイル等を除外
    (unless (string-match-p "/\\." file)
      (message "Processing: %s" file)
      (with-current-buffer (find-file-noselect file)
        (org-html-export-to-html)))))

;; コマンドラインからの実行時に自動呼び出し
(build-website)
