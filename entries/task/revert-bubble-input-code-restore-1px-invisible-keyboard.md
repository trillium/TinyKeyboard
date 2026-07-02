---
id: TinyKeyboard-8ti
title: "Revert bubble input code — restore 1px invisible keyboard"
kind: task
status: open
priority: 1
created: 2026-07-02T22:05:57Z
updated: 2026-07-02T22:05:57Z
---

# Revert bubble input code — restore 1px invisible keyboard

Bubble mode confirmed defunct 2026-07-02 (extension cannot receive text into its own views). Strip BubbleWidgetView, KeyboardState expand path, DwellTimer, TextBuffer, PositionStore usage from KeyboardViewController; restore 1pt transparent inputView. Also revert uncommitted bubble-era working-tree changes (ContentView.swift, project.pbxproj) or fold them in. Docs already updated: commits f7f16ef, b006e95, bf0cb3e.
