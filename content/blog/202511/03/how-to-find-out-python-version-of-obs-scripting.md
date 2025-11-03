---
title: "OBS Python Scriptingで利用できるPythonバージョンの調べ方"
date: 2025-11-03T09:26:32+09:00
tags: ["obs", "python"]
draft: false
---

- [Which version of python works on Obs 30.2.3 ? | OBS Forums](https://obsproject.com/forum/threads/which-version-of-python-works-on-obs-30-2-3.181517/post-688250)

より。
[shared/obs-scripting/obs-scripting-python-import.c](https://github.com/obsproject/obs-studio/blob/master/shared/obs-scripting/obs-scripting-python-import.c) を見れば良さそうです。
この記事を書いている時点ではは 3.12 までのようですね。
現在の最新安定版が 3.14 なのでちょっと注意する必要があります。
