import Foundation

enum Difficulty {
    case easy
    case medium
    case hard
}

class SudokuViewModel: ObservableObject {
    @Published var board: [[Int]]
    @Published var initialBoard: [[Int]]
    @Published var difficulty: Difficulty = .easy {
        didSet {
            generatePuzzle() // 每次难度改变时重新生成棋盘
        }
    }

    init() {
        self.board = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        self.initialBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generatePuzzle() // 初始时生成棋盘
    }

    func generatePuzzle() {
        var filledBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        var isValid = false

        // 生成一个有效的棋盘
        while !isValid {
            filledBoard = Array(repeating: Array(repeating: 0, count: 9), count: 9)
            if solveSudoku(&filledBoard) {
                isValid = true
            }
        }

        // 保存完全填充的数独棋盘
        self.initialBoard = filledBoard

        // 随机删除部分数字以生成题目
        var puzzle = filledBoard
        let numberOfCellsToRemove = getNumberOfCellsToRemove(for: difficulty)
        var cellsToRemove = Set<Int>()
        
        // 随机选择需要删除的格子
        while cellsToRemove.count < numberOfCellsToRemove {
            let cell = Int.random(in: 0..<81)
            cellsToRemove.insert(cell)
        }

        // 删除格子
        for cell in cellsToRemove {
            let row = cell / 9
            let col = cell % 9
            puzzle[row][col] = 0
        }

        // 设置新的棋盘
        self.board = puzzle
    }

    // 获取根据难度删除的格子数量
    private func getNumberOfCellsToRemove(for difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy:
            return 30 // 简单：删除30个格子
        case .medium:
            return 45 // 中等：删除45个格子
        case .hard:
            return 55 // 困难：删除55个格子
        }
    }

    // 回溯法求解数独
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

    // 判断数字是否合法
    private func isValidMove(row: Int, col: Int, number: Int, board: [[Int]]) -> Bool {
        // 检查行
        for c in 0..<9 {
            if board[row][c] == number {
                return false
            }
        }

        // 检查列
        for r in 0..<9 {
            if board[r][col] == number {
                return false
            }
        }

        // 检查3x3的子宫格
        let startRow = (row / 3) * 3
        let startCol = (col / 3) * 3
        for r in startRow..<startRow + 3 {
            for c in startCol..<startCol + 3 {
                if board[r][c] == number {
                    return false
                }
            }
        }

        return true
    }

    // 判断用户输入的棋盘与初始生成的棋盘是否一致
    func checkUserInput() -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] != initialBoard[row][col] && initialBoard[row][col] != 0 {
                    return false
                }
            }
        }
        return true
    }
}

