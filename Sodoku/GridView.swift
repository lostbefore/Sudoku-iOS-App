import SwiftUI

struct GridView: View {
    @Binding var board: [[Int]]
    var initialBoard: [[Int]]

    let gridSize = 9

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        cellView(row: row, col: col)
                    }
                }
            }
        }
    }

    private func cellView(row: Int, col: Int) -> some View {
        let cellValue = board[row][col]
        let isInitial = initialBoard[row][col] != 0

        return TextField("", value: $board[row][col], formatter: NumberFormatter())
            .padding()
            .frame(width: 40, height: 40)
            .background(isInitial ? Color.gray.opacity(0.3) : Color.white)
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .disabled(isInitial) // 禁用已填充的格子
            .foregroundColor(cellValue == 0 ? Color.clear : Color.black)  // 如果是空格，隐藏文字
            .background(cellValue == 0 ? Color.white : Color.clear) // 空格背景设置为白色
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        // 默认的示例数据
        GridView(board: .constant(Array(repeating: Array(repeating: 0, count: 9), count: 9)),
                 initialBoard: Array(repeating: Array(repeating: 0, count: 9), count: 9))
    }
}

