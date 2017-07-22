---
layout: post
title: batch-rename
---

```
M:\Media\Videos\ShadowReplay\Ori of the Blind Forest
λ  dir


    Directory: M:\Media\Videos\ShadowReplay\Ori of the Blind Forest


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        6/17/2017  10:34 PM       12703402 Desktop 06.17.2017 - 22.34.02.01.mp4
-a----        6/17/2017  10:34 PM       35428409 Desktop 06.17.2017 - 22.34.08.02.mp4
-a----        6/17/2017  11:17 PM     9577413897 Desktop 06.17.2017 - 22.34.20.03.mp4
-a----        6/17/2017  11:42 PM     3334538663 Desktop 06.17.2017 - 23.27.34.04.mp4
-a----        6/18/2017   5:45 PM      393400675 Desktop 06.18.2017 - 17.43.46.06.mp4
-a----        6/18/2017   7:28 PM    11495026977 Desktop 06.18.2017 - 17.45.55.07_edit.mp4
-a----        6/20/2017  10:57 PM     8260360971 Desktop 06.20.2017 - 22.20.52.08.mp4
-a----        6/20/2017  11:27 PM     4990625171 Desktop 06.20.2017 - 23.05.37.09.mp4
-a----        7/16/2017   9:11 AM     6219993333 Desktop 06.21.2017 - 21.12.37.10.mp4


M:\Media\Videos\ShadowReplay\Ori of the Blind Forest
λ  dir | Rename-Item -NewName {$_.name -replace "Desktop","Ori of the Blind Forest"}
M:\Media\Videos\ShadowReplay\Ori of the Blind Forest
λ  cd ..
M:\Media\Videos\ShadowReplay
λ  cd .\Discord\
M:\Media\Videos\ShadowReplay\Discord
λ  dir | Rename-Item -NewName {$_.name -replace "Discord","Ori of the Blind Forest"}
```

