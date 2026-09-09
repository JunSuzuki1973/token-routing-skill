# Token Routing Skill（日本語）

`token-routing`は、トークン節約ツールを常時まとめてONにするのではなく、
入力ごとに最も情報損失の少ない経路を選ぶAgent Skillです。

- ファイル・API応答・テスト出力・ブラウザ出力: **context-mode**
- 直接実行する対応CLIの大量出力: **RTK**
- 長い静的文書の要約・分類: 専用CLI子プロセス経由の**pxpipe**

同じ生出力へRTKとcontext-modeを二重に適用しません。コード編集、正確なID・
数値・引用・空白が必要な作業にはpxpipeを使いません。

## 導入

CodexにこのGitHubリポジトリの`skills/token-routing`を導入するよう依頼するか、
付属のSkillインストーラーで次を実行します。

```powershell
python <skill-installerへのパス>/install-skill-from-github.py `
  --repo JunSuzuki1973/token-routing-skill `
  --path skills/token-routing
```

導入後は新しいCodexターンから自動選択の候補になります。

## 現在の自動選択方針

| 条件 | 選択 |
|---|---|
| GPT-6 Astraで対応CLIの直接出力 | RTK |
| GPT-6 Astraで8,000文字以上の静的文書を要約・分類 | pxpipe専用CLI経路 |
| ファイル、API、ブラウザ、テストなど不定量出力 | context-mode |
| コード編集・厳密な文字列・通常のデスクトップ対話 | context-mode |
| GPT-5.6 Sol Highの対応CLI直接出力 | RTK（1回のGain実測で11.99%） |
| GPT-5.6 Solの長い静的文書 | context-mode。pxpipeは技術的候補であり自動ONしない |
| Solの他の推論設定、Terra、Luna、その他 | context-modeのみ |

GPT-6 AstraでRTKとpxpipeには品質ゲート付きの個別A/B実測があります。Sol Highの
RTKは、公開Skillを読む1回のレビューでGainを確認しただけで、総モデル入力や
品質ゲート付きA/Bの証明ではありません。pxpipeはSolが画像入力に対応するため
技術的には候補ですが、Sol向けの自動ONは行いません。

## ライセンスと依存関係

このリポジトリはルーティングSkillと補助スクリプトだけをMITライセンスで配布します。
context-mode、RTK、pxpipeの本体は同梱していません。各プロダクトの導入、ライセンス、
設定は各公式リポジトリを確認してください。
