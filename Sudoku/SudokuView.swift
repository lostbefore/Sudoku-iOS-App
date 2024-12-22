import SwiftUI

struct SudokuView: View {
    @StateObject private var viewModel = SudokuViewModel()

    var body: some View {
        VStack {
            // 难度选择器
            Picker("Select Difficulty", selection: $viewModel.difficulty) {
                Text("Easy").tag(Difficulty.easy)
                Text("Medium").tag(Difficulty.medium)
                Text("Hard").tag(Difficulty.hard)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // 数独棋盘视图
            GridView(board: $viewModel.board, initialBoard: viewModel.initialBoard)
                .padding()

            // 检查按钮
            Button(action: {
                if viewModel.checkUserInput() {
                    print("Correct!")
                } else {
                    print("Incorrect!")
                }
            }) {
                Text("Check Answer")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
}

struct SudokuView_Previews: PreviewProvider {
    static var previews: some View {
        SudokuView()
    }
}

