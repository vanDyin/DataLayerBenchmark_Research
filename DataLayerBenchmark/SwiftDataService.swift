import Foundation
import SwiftData

// MARK: — Фоновый актор SwiftData
@ModelActor
public actor BackgroundDataHandler {

    /// Пакетная запись.
    /// Таймер запускается внутри актора — до цикла вставки.
    /// Возвращает время выполнения в миллисекундах (такой же охват, как у Core Data).
    public func saveBatchBackground(count: Int) -> Double {
        modelContext.autosaveEnabled = false

        // ← Старт ЗДЕСЬ, до вставки объектов
        let startTime = CFAbsoluteTimeGetCurrent()

        for i in 0..<count {
            let item = SDItem(
                title: "Синтетический элемент \(i)",
                value: Double.random(in: 0.0...100.0)
            )
            modelContext.insert(item)
        }

        do {
            try modelContext.save()
        } catch {
            print("🔴 SwiftData ошибка сохранения: \(error)")
        }

        let duration = (CFAbsoluteTimeGetCurrent() - startTime) * 1_000
        print("🟠 SWIFTDATA: \(count) объектов за \(String(format: "%.2f", duration)) мс")
        return duration
    }
}

// MARK: — Основной сервис (вызывается из UI)
@MainActor
class SwiftDataService {
    let container: ModelContainer

    init() {
        do {
            self.container = try ModelContainer(for: SDItem.self)
        } catch {
            fatalError("🔴 SWIFTDATA КРИТИЧЕСКАЯ ОШИБКА: \(error)")
        }
    }
}
