import SwiftUI
import CoreData

struct ContentView: View {
    let cdService = CoreDataService()
    @State var sdService: SwiftDataService? = nil

    @State private var resultText: String = "Результаты появятся здесь"
    
    // Новые переменные для ввода данных из Instruments и хранения отчета
    @State private var inputCPU: String = ""
    @State private var lastFramework: String = ""
    @State private var lastCount: Int = 0
    @State private var lastDuration: Double = 0.0
    
    // Структура для таблицы отчета
    struct BenchmarkResult: Identifiable {
        let id = UUID()
        let framework: String
        let count: String
        let time: String
        let cpu: String
    }
    
    @State private var reportTable: [BenchmarkResult] = []

    var body: some View {
        ScrollView { // Добавили скролл, чтобы таблица поместилась на экране
            VStack(spacing: 15) {
                Text("Бенчмарк хранилищ")
                    .font(.title)
                    .bold()
                    .padding(.top)

                Text(resultText)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6)) // Поменял на системный серый, чтобы на черном фоне текст не пропадал
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Панель фиксации данных из Instruments
                if lastDuration > 0 {
                    VStack(spacing: 8) {
                        Text("Введи пик CPU из Instruments (%)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            TextField("Например: 160", text: $inputCPU)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .frame(width: 120)
                            
                            Button("Добавить в отчет") {
                                let cpuValue = inputCPU.isEmpty ? "—" : "\(inputCPU)%"
                                let newResult = BenchmarkResult(
                                    framework: lastFramework,
                                    count: "\(lastCount)",
                                    time: String(format: "%.1f мс", lastDuration),
                                    cpu: cpuValue
                                )
                                reportTable.append(newResult)
                                // Сброс
                                inputCPU = ""
                                lastDuration = 0.0
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                // Кнопки управления
                VStack(spacing: 10) {
                    Text("Core Data пакетом:")
                        .font(.subheadline).bold()
                    HStack {
                        Button("1 000")  { runCoreDataTest(count: 1_000) }
                        Button("10 000") { runCoreDataTest(count: 10_000) }
                        Button("50 000") { runCoreDataTest(count: 50_000) }
                    }.buttonStyle(.borderedProminent)

                    Divider().padding(.vertical, 5)

                    Text("SwiftData пакетом:")
                        .font(.subheadline).bold()
                    HStack {
                        Button("1 000")  { runSwiftDataTest(count: 1_000) }
                        Button("10 000") { runSwiftDataTest(count: 10_000) }
                        Button("50 000") { runSwiftDataTest(count: 50_000) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }

                // Сводная таблица результатов для статьи
                if !reportTable.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Итоговый отчет для статьи:")
                            .font(.headline)
                            .padding(.top)
                        
                        // Заголовки
                        HStack {
                            Text("Стек").frame(width: 80, alignment: .leading)
                            Text("Объем").frame(width: 70, alignment: .trailing)
                            Text("Время").frame(width: 90, alignment: .trailing)
                            Text("Пик CPU").frame(width: 70, alignment: .trailing)
                        }
                        .font(.caption).bold()
                        .foregroundColor(.secondary)
                        
                        Divider()
                        
                        // Строки таблицы
                        ForEach(reportTable) { row in
                            HStack {
                                Text(row.framework).frame(width: 80, alignment: .leading)
                                Text(row.count).frame(width: 70, alignment: .trailing)
                                Text(row.time).frame(width: 90, alignment: .trailing)
                                Text(row.cpu).frame(width: 70, alignment: .trailing)
                            }
                            .font(.system(.footnote, design: .monospaced))
                            Divider()
                        }
                        
                        Button("Очистить таблицу") {
                            reportTable.removeAll()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            sdService = SwiftDataService()
        }
    }

    // MARK: — Core Data
    func runCoreDataTest(count: Int) {
        resultText = "Запись Core Data в фоне..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            let duration = cdService.saveBatch(count: count)

            DispatchQueue.main.async {
                self.resultText = "🟢 Core Data:\n\(count) объектов за\n\(String(format: "%.2f", duration)) мс"
                // Сохраняем метаданные для таблицы
                self.lastFramework = "Core Data"
                self.lastCount = count
                self.lastDuration = duration
            }
        }
    }

    // MARK: — SwiftData
    func runSwiftDataTest(count: Int) {
        guard let sdService = sdService else { return }
        resultText = "Запись SwiftData в фоне..."

        let container = sdService.container
        let handler   = BackgroundDataHandler(modelContainer: container)

        Task.detached(priority: .userInitiated) {
            let duration = await handler.saveBatchBackground(count: count)

            await MainActor.run {
                self.resultText = "🟠 SwiftData:\n\(count) объектов за\n\(String(format: "%.2f", duration)) мс"
                // Сохраняем метаданные для таблицы
                self.lastFramework = "SwiftData"
                self.lastCount = count
                self.lastDuration = duration
            }
        }
    }
}
