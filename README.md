# FishingRodGODO

Удочка для 3D-рыбалки на **Godot 4.7**: собрана из встроенных примитивов
(`CylinderMesh`, `TorusMesh`, `SphereMesh`, `BoxMesh`), без внешних ассетов,
с тремя анимациями и скриптом управления.

## Файлы

| Файл | Назначение |
| --- | --- |
| `FishingRod.tscn` | Сцена удочки: корневой `Node3D` со всеми частями + `AnimationPlayer` |
| `FishingRod.gd` | Скрипт: ЛКМ — заброс, ПКМ — подсечка, по умолчанию покой |
| `Main.tscn` | Демо-сцена (земля, свет, камера, подсказка) — необязательна |
| `project.godot` | Минимальные настройки проекта, главная сцена — `Main.tscn` |

## Управление

| Действие | Анимация |
| --- | --- |
| ЛКМ | `cast` — замах назад и резкий хлёст вперёд (1.0 с) |
| ПКМ | `reel` — короткая резкая подсечка вверх (0.3 с) |
| ничего | `idle` — зацикленное покачивание удилища (2.0 с) |

Во время `cast`/`reel` повторные нажатия игнорируются (`is_busy()`), после
завершения удочка сама возвращается в `idle`.

## Дерево узлов `FishingRod.tscn`

```
FishingRod (Node3D)                 — корень, на нём FishingRod.gd
├── Rod (Node3D)                    — пивот удилища (вращается при забросе)
│   ├── Grip (MeshInstance3D)       — CylinderMesh, рукоять
│   ├── Butt (MeshInstance3D)       — CylinderMesh, комель
│   ├── Whip (Node3D)               — пивот хлыстика (второй сустав)
│   │   ├── Mid (MeshInstance3D)    — CylinderMesh
│   │   ├── Tip (MeshInstance3D)    — CylinderMesh, тонкий кончик
│   │   ├── Ring1..Ring3 (Node3D)   — TorusMesh + ножка-цилиндр
│   │   └── Float (Node3D)          — поплавок на леске
│   │       ├── FloatLine (MeshInstance3D) — CylinderMesh, леска
│   │       └── FloatBall (MeshInstance3D) — SphereMesh
│   └── Reel (Node3D)               — катушка
│       ├── ReelFoot (MeshInstance3D)  — BoxMesh
│       └── Wheel (Node3D)             — вращающийся ротор
│           ├── ReelBody (MeshInstance3D) — CylinderMesh, диск
│           ├── ReelHandle (MeshInstance3D) — BoxMesh, ручка
│           └── ReelKnob (MeshInstance3D)   — SphereMesh, набалдашник
└── AnimationPlayer                 — библиотека: idle, cast, reel
```

Начало координат — там, где удилище выходит из рукояти (рукоять назад по −X,
удилище вперёд по **+X**, в покое приподнято на 10°). Чтобы «держать» удочку,
вращайте узел `FishingRod` или вешайте его на `BoneAttachment3D`/руку персонажа.

## Как открыть

1. Скачать папку и открыть её в Godot 4.7 (Import → выбрать `project.godot`).
2. Нажать **F5** — запустится `Main.tscn`, сцена с удочкой на земле.
3. ЛКМ / ПКМ — проверить заброс и подсечку.

Если у вас уже есть свой проект, достаточно скопировать `FishingRod.tscn`
и `FishingRod.gd` (они самодостаточны, зависимостей нет).
