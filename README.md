# 数独游戏开发报告

## 项目概述

本项目为补偿同济大学2024移动应用开发课程App Development with Swift认证考试的项目。

### 项目名称

Sudoku-iOS-App

### 项目简介

本项目是一个基于 SwiftUI 和 MVVM 架构的 iOS 数独游戏应用。用户可以通过该应用体验经典数独游戏，支持选择多种难度（简单、中等、困难）。游戏具备生成合法数独棋盘、展示部分初始数字、用户输入验证等功能。

------

## 开发环境

### 技术栈

- **开发语言**：Swift
- **框架**：SwiftUI
- **架构模式**：MVVM
- **工具**：Xcode
- **目标设备**：iPhone
- **最低支持版本**：iOS 15.0

### 开发工具

- **Xcode 版本**：15.0 或以上
- **Git 版本控制**：用于代码管理和上传至 GitHub。

------

## 功能设计

### 核心功能

1. **数独棋盘生成**
   - 通过回溯算法生成一个合法的完整数独棋盘。
   - 根据选定难度（简单、中等、困难），随机删除部分数字以生成唯一解的数独题目。
2. **用户输入与验证**
   - 用户可以在空格处填写数字，填写数字后系统实时更新棋盘。
   - 提供检查按钮，用于验证用户输入是否符合数独规则。
3. **难度选择**
   - 提供简单、中等、困难三种难度。
   - 不同难度对应不同数量的初始数字：
     - 简单：展示更多初始数字。
     - 困难：展示最少的初始数字，确保有唯一解。
4. **界面交互**
   - 提供直观的用户界面，数字输入框支持禁用初始数字编辑。
   - 显示错误提示和正确完成提示。

------

## 核心代码

### 1. 数独模型

负责生成合法数独棋盘，并支持用户输入验证。

```swift
struct SudokuModel {
    var board: [[Int]]  // 当前游戏棋盘，0 表示空格
    var initialBoard: [[Int]]  // 保存初始棋盘

    init() {
        self.board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        self.initialBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generatePuzzle()
    }

    mutating func generatePuzzle() {
        var filledBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        solveSudoku(&filledBoard)  // 生成完整棋盘
        self.initialBoard = filledBoard

        let cellsToRemove = getCellsToRemove(for: .easy)
        for cell in cellsToRemove {
            let row = cell / 9
            let col = cell % 9
            filledBoard[row][col] = 0
        }
        self.board = filledBoard
    }

    private func solveSudoku(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 {
                    for num in 1...9 {
                        if isValidMove(row: row, col: col, number: num, board: board) {
                            board[row][col] = num
                            if solveSudoku(&board) {
                                return true
                            }
                            board[row][col] = 0
                        }
                    }
                    return false
                }
            }
        }
        return true
    }
}
```

### 2. 视图模型

负责数据管理和与视图的交互。

```swift
class SudokuViewModel: ObservableObject {
    @Published var board: [[Int]]
    @Published var initialBoard: [[Int]]
    @Published var difficulty: Difficulty = .easy {
        didSet { generatePuzzle() }
    }

    init() {
        self.board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        self.initialBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generatePuzzle()
    }

    func generatePuzzle() {
        var filledBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        solveSudoku(&filledBoard)
        self.initialBoard = filledBoard
        self.board = applyDifficulty(filledBoard, difficulty: difficulty)
    }

    private func applyDifficulty(_ board: [[Int]], difficulty: Difficulty) -> [[Int]] {
        let numberOfCellsToRemove = difficulty == .easy ? 30 : difficulty == .medium ? 45 : 55
        var puzzle = board
        for _ in 0..<numberOfCellsToRemove {
            let row = Int.random(in: 0..<9)
            let col = Int.random(in: 0..<9)
            puzzle[row][col] = 0
        }
        return puzzle
    }
}
```

### 3. 视图

负责展示棋盘并与用户交互。

```swift
struct GridView: View {
    @Binding var board: [[Int]]
    var initialBoard: [[Int]]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<9, id: \ .self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<9, id: \ .self) { col in
                        TextField("", value: $board[row][col], formatter: NumberFormatter())
                            .frame(width: 40, height: 40)
                            .background(initialBoard[row][col] == 0 ? Color.white : Color.gray.opacity(0.5))
                            .cornerRadius(5)
                            .disabled(initialBoard[row][col] != 0)
                    }
                }
            }
        }
    }
}
```

------

## 界面设计

- **主界面布局**：
  - 顶部是难度选择器，通过 `Picker` 控件实现，支持动态切换难度。
  - 中间是数独棋盘，由 `GridView` 组件实现。
  - 底部是按钮，用于检查用户输入。
- **交互细节**：
  - 初始数字为灰色背景，用户无法编辑。
  - 用户输入空格后，实时更新棋盘。

------

## 测试

### 测试目标

- 验证棋盘生成逻辑是否正确。
- 测试用户输入与验证功能是否正常。
- 测试不同难度的初始数字数量是否符合预期。

### 测试结果

- 棋盘生成：所有难度下均能生成唯一解的数独棋盘。
- 用户输入：空格可编辑，初始数字不可修改。
- 难度切换：切换后重新生成棋盘，数量符合预期。

------

