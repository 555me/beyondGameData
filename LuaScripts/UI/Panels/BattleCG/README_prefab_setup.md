# BattleCGPanel.prefab 收尾说明

## 当前状态

prefab 已创建：`Assets/Beyond/DynamicAssets/Gameplay/UI/Prefabs/Battle/BattleCGPanel.prefab`

是从 `Assets/Beyond/DynamicAssets/Gameplay/UI/Prefabs/Common/CGPanel.prefab` 复制而来，**保留了完整的 panel 框架接线**：

- 根节点 `BattleCGPanel` 含 `LuaReference` / `InputBindingGroupMonoTarget` / `DestroySelfOnAwake`
- `UIRoot` Canvas + `UICanvasScaleHelper`
- `UIRoot/BattleCGPanel` 内层 `LuaPanel` + `LuaReference` + `LuaCustomConfig` + `NotchAdapter` + 动画相关组件
- `UIRoot/BattleCGPanel/Main/Image/VideoImage` 上挂 `CriManaMovieControllerForUI`（CG 视频显示节点）
- `WorldUIRoot` / `DisabledUIRoot`（框架要求）

LuaReference 已暴露的 refDict keys（继承自 CGPanel）：
`image, movieController, subtitlePanel, subtitleController, exUINode, bigLogoComp, bigLogoMain, stretchImageMain, stretchImageTop, nameImg, stretchImageBottom, videoDebugNode, bigLogo`

`BattleCGCtrl.lua` 实际只用 `image`（用作 video container 模板，运行时 clone N 份独立 CriMana 解码器，每份 CG 一个）。`movieController` 也存在但只用 `image` 子节点 clone 出来的实例上的那个。

## 你需要在 Unity Editor 里做的事

MCP 的 `manage_prefabs.modify_contents` 在含 `DestroySelfOnAwake` 的 panel 上跑不通（实例化时根被销毁），所以这一步必须人工。

### 步骤

1. 双击 `BattleCGPanel.prefab` 打开 Prefab Edit 模式
2. 删除以下子节点（CG 战斗用不到的叙事系统残留）：
   - `UIRoot/BG`（静态黑底，CG 视频会盖满整屏，不需要）
   - `UIRoot/BattleCGPanel/Main/VideoDebugNode`（debug 文字节点）
   - `UIRoot/BattleCGPanel/Main/ExUINode`（带 Skip 按钮 + KeyHint，战斗 CG 不让跳过）
   - `UIRoot/BattleCGPanel/UISubtitle`（字幕容器）
   - `UIRoot/BattleCGPanel/SubtitleController`（FMVController for 字幕）
   - `UIRoot/BattleCGPanel/FMVDirector`（PlayableDirector for 字幕时间线）
   - `UIRoot/BattleCGPanel/BigLogo`（大 logo 立绘叠加）
3. 检查 `UIRoot/BattleCGPanel` 上的 `LuaReference` 组件 refDict，**只需保留 `image` 这个 key**（其它残留 key 删了也没事，BattleCGCtrl 只用它）
4. **可选：sortingOrder 调整**：内层 `UIRoot/BattleCGPanel` 上有 Canvas + override sorting，确保它的 sortingOrder 高于战斗 HUD（BattleAction 等）但低于系统级 Loading 黑屏 / Pause 弹窗。如果 CGPanel 当前默认值已合适（叙事 CG 也是同样要求），保持即可。
5. 保存 prefab

### 关键设计踩坑（仅供后续维护参考，已经在 BattleCGCtrl.lua 顶部注释里写了）

`BattleCGCtrl.lua` 必须做以下三件事来对抗 panel framework 的怪行为：

1. **常驻协程把 view.gameObject 拽住 SetActive(true)** —— 否则 `useCanvasHide=true + preOpen` 模式下 framework 会把 view SetActive(false) 但不再恢复，CriMana 解码器不 tick，Play 卡黑屏
2. **slot.go 永远 SetActive(true)，可见性纯靠各 slot 自己的 CanvasGroup.alpha** —— 同样原因
3. **`mc:Stop()` 是异步的，必须等 status=Stop:0 再 SetFile+Prepare** —— 否则被 CriMana 在 StopProcessing 状态吞掉，下次 Play 黑屏

## 不要做的事

- **不要建** `BattleCGModel.lua` —— 让框架走默认 UIModel
- **不要改** `VideoPlayer.lua` widget / `VideoPlayer.prefab`（虽然之前提到过，最终方案没用它）
- **不要改** `CGCtrl.lua` / `CGPanel.prefab`（叙事 CG 完全独立）
- **不要改** PanelConfig 里 `freezeWorld = true`（战斗冻结由 PlayBattleCgAction 自己 timeScale=0 管）

## P4

prefab 已 `p4 add`，提交时请放在和 BattleCG 系统同一个 changelist 里（`6757782`）。
