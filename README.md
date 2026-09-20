# 2026年度前期・後期「プログラミング中級（DI1A）」受講生用ポータル＆Web資料サイト

本リポジトリは、Emacs Org-mode (`ox-publish`) および `build.el` を使用して、授業資料ポータルサイトを一括ビルド・公開するためのWebソースプロジェクトです。

---

## 📁 ディレクトリ構造

```text
.
├── build.el                       # ox-publish 一括HTMLビルド＆ID/CUSTOM_IDリンク自動解決スクリプト
├── README.md                      # 本プロジェクトの概要・ビルド手順書
├── public/                        # (自動生成) HTMLビルド出力先ディレクトリ（GitHub Pages等で公開）
└── src/                           # Orgソースファイル配置ディレクトリ
    ├── index.org                  # 授業ポータルサイトトップページ (ガイダンス・3大セクション)
    ├── guidance.org               # 学習目標・目的・計画（ガイダンス詳細）
    ├── github-account-and-org.org # セクション1: GitHubアカウント作成・学割申請・Org参加ガイド
    ├── repository-and-codespaces.org # セクション2&3: テンプレートからのリポジトリ作成・Codespaces起動・コミット
    ├── syllabus.org               # 全15回改訂版シラバス
    │
    ├── guides/                    # 学生向け各種サポート・デバッグガイド
    │   ├── troubleshooting.org    # トラブルシューティングガイド（環境構築・画面レイアウト調整・エラー対処）
    │   └── f12-debugging.org      # F12デベロッパーツール＆Copilot Chat対話型デバッグ実演ガイド
    │
    ├── evaluation/                # 評価基準・セルフチェック用資料
    │   ├── rubric.org             # 成績評価用ルーブリック表（プロンプト思考・コード解読・デバッグ評価）
    │   └── self-checklist.org     # 課題提出時セルフチェックシート
    │
    ├── prompts/                   # 講義・演習用プロンプト集
    │   └── copilot-prompts.org    # 全15回 Copilot Chat 用プロンプト集（各回3パターン・全45例）
    │
    └── teacher/                   # 教員・TA向け運営資料
        ├── orientation-slides.org # 初回オリエンテーションスライド構成案
        └── teacher-guidance.org   # 教員向け 授業運営補足説明ペーパー
```

---

## 🚀 ローカルビルド手順

### Emacs (`ox-publish`) でのビルド
ターミナルから以下のコマンドを実行します：

```bash
emacs --batch -l build.el
```

### ビルドの仕組みと特徴
1. **Org ID / CUSTOM_ID 自動リンク解決**: `build.el` 内の `org-link-set-parameters` フックにより、複数ファイル間に跨る `id:` 形式の内部リンクを正しい相対URL（`path/file.html#id`）へ書き換えます。
2. **CJK改行スペース自動削除**: 日本語文章の改行時に発生する余計な半角スペースをHTML変換時に自動削除します。
3. **静的アセット同期**: `./src/` 配下の画像（PNG/JPG/SVG）やCSS・PDFファイルも同時に `./public/` へコピーされます。

---

## 🌐 デプロイ (GitHub Pages)

本プロジェクトを GitHub リポジトリの `main` ブランチへプッシュすると、GitHub Actions ワークフロー等を通じて `./public/` ディレクトリの内容が自動的に GitHub Pages へ公開されます。
