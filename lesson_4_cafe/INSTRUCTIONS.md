# Инструкция по созданию проекта "Кафе" в Godot

## Шаг 1: Создание нового проекта в Godot

1. Откройте Godot
2. Нажмите "New Project"
3. В поле "Project Path" выберите папку: `lesson_4_cafe`
4. Нажмите "Create & Edit"

## Шаг 2: Настройка проекта

1. Откройте Project → Project Settings
2. В разделе Application → Run установите Main Scene: `res://cafe.tscn`
3. В разделе Input Map добавьте новое действие `interact`:
   - Нажмите "+" для добавления нового действия
   - Введите название: `interact`
   - Нажмите "+" рядом с `interact`
   - Нажмите на кнопку с "..." и выберите клавишу E
4. Проверьте, что есть стандартные действия:
   - `ui_left`, `ui_right`, `ui_up`, `ui_down` (стрелки и WASD)
   - `ui_accept` (пробел или Enter для прыжка)

## Шаг 3: Создание основной сцены (cafe.tscn)

1. Создайте новую сцену (Scene → New Scene)
2. Выберите "3D Scene"
3. Сохраните как `cafe.tscn`

### Добавление базовой структуры:

1. **Node3D (назовите "Cafe")** - корневой узел
   - **Node3D (назовите "Floor")** - пол
     - Добавьте дочерний узел **MeshInstance3D**
     - В Inspector → Mesh выберите "New PlaneMesh"
     - В Mesh → Size установите (20, 20)
     - Добавьте **StaticBody3D** как дочерний
       - В StaticBody3D добавьте **CollisionShape3D**
       - В CollisionShape3D → Shape выберите "New BoxShape3D"
       - Установите Size: (20, 0.1, 20)

2. **DirectionalLight3D** - освещение
   - Rotation: (-45, 45, 0)
   - Energy: 1.0

3. **CharacterBody3D (назовите "Player")** - игрок с камерой от первого лица
   - Position: (0, 1, 0)
   - Добавьте скрипт: `Player.gd`
   - Добавьте **MeshInstance3D** (опционально, так как вид от первого лица)
     - Mesh: New CapsuleMesh
     - Радиус: 0.5, Высота: 2
   - Добавьте **CollisionShape3D**
     - Shape: New CapsuleShape3D
     - Радиус: 0.5, Высота: 2
   - Добавьте **Node3D** (назовите "CameraPivot")
     - В CameraPivot добавьте **Camera3D**
     - Position: (0, 1.6, 0) - высота глаз
     - Установите "Current" в true

**Управление:** WASD - движение, Мышь - поворот камеры, Пробел - прыжок

## Шаг 4: Добавление кассира

1. В сцене Cafe добавьте **Area3D** (назовите "Cashier")
   - Position: (5, 1, 0)
   - Добавьте скрипт: `Cashier.gd`
   - Добавьте **MeshInstance3D** (куб для кассира)
     - Mesh: New BoxMesh
     - Size: (1, 2, 1)
   - Добавьте **CollisionShape3D**
     - Shape: New BoxShape3D
     - Size: (2, 2, 2)

## Шаг 5: Добавление монеток

1. Создайте сцену монетки:
   - Создайте новую сцену "3D Scene"
   - Сохраните как `coin.tscn`
   - Добавьте **Area3D** (корневой узел)
     - Добавьте скрипт: `Coin.gd`
     - Добавьте **MeshInstance3D**
       - Mesh: New CylinderMesh
       - Радиус: 0.3, Высота: 0.1
     - Добавьте **CollisionShape3D**
       - Shape: New CylinderShape3D
       - Радиус: 0.3, Высота: 0.1

2. В основной сцене cafe.tscn:
   - Добавьте несколько экземпляров coin.tscn (Instance Child Scene)
   - Разместите их в разных местах на полу

## Шаг 6: Добавление еды на прилавке

1. Создайте сцену еды:
   - Создайте новую сцену "3D Scene"
   - Сохраните как `food.tscn`
   - Добавьте **Area3D** (корневой узел)
     - Добавьте скрипт: `Food.gd`
     - Добавьте **MeshInstance3D** (для визуализации)
       - Mesh: New BoxMesh
       - Size: (0.5, 0.3, 0.5)
     - Добавьте **CollisionShape3D**
       - Shape: New BoxShape3D
       - Size: (1, 1, 1)

2. В основной сцене:
   - Создайте **Node3D** (назовите "Counter") - прилавок
     - Position: (-5, 0.8, 0)
     - Добавьте **MeshInstance3D** (сам прилавок)
       - Mesh: New BoxMesh
       - Size: (4, 0.5, 1)
     - Добавьте **StaticBody3D** с **CollisionShape3D**
   
   - Добавьте 3 экземпляра food.tscn на прилавок
     - Food1: Position (-6, 1.2, 0), в скрипте: food_name="Бургер", price=5
     - Food2: Position (-5, 1.2, 0), в скрипте: food_name="Пицца", price=7
     - Food3: Position (-4, 1.2, 0), в скрипте: food_name="Напиток", price=3

## Шаг 7: Добавление UI

1. В сцене cafe.tscn добавьте **CanvasLayer**
   - Назовите "UI"
   - Добавьте скрипт: `UIManager.gd`
   - Добавьте **Control** (назовите "Control")
     - Установите Anchors: Full Rect
   - В Control добавьте **VBoxContainer**
     - Anchors: Top-Left
     - Margin: (20, 20, 0, 0)
   - В VBoxContainer добавьте:
     - **Label** (назовите "CoinLabel")
       - Text: "Монет: 0"
       - Font Size: 24
     - **Label** (назовите "MessageLabel")
       - Text: ""
       - Font Size: 20

## Шаг 8: Глобальный скрипт

1. Создайте папку "Global" в FileSystem
2. Создайте скрипт `Global/Game.gd`
3. В Project Settings → Autoload добавьте:
   - Path: `res://Global/Game.gd`
   - Node Name: `Game`

## Шаг 9: Тестирование

1. Нажмите F5 или Play для запуска
2. Проверьте:
   - Управление WASD работает
   - Монетки собираются
   - Можно поговорить с кассиром (E)
   - Можно купить еду (E возле еды)

## Дополнительные улучшения (опционально):

- Добавьте стены вокруг кафе
- Добавьте столы и стулья
- Добавьте анимации для персонажа
- Добавьте звуковые эффекты
- Добавьте больше мебели для атмосферы

