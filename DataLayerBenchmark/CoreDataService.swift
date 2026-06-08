import Foundation
import CoreData

class CoreDataService {

    // MARK: — Контейнер
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Ошибка инициализации Core Data: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: — Пакетная запись (используется напрямую, если нужна из сервиса)
    // Таймер стартует ДО цикла, чтобы охват совпадал со SwiftData
    @discardableResult
    func saveBatch(count: Int) -> Double {
        let context = persistentContainer.newBackgroundContext()
        var duration: Double = 0

        context.performAndWait {

            // ← Старт ЗДЕСЬ, до вставки объектов
            let startTime = CFAbsoluteTimeGetCurrent()

            for i in 0..<count {
                let item = NSEntityDescription.insertNewObject(forEntityName: "CDItem", into: context)
                item.setValue(UUID(),                          forKey: "id")
                item.setValue("Синтетический элемент \(i)",   forKey: "title")
                item.setValue(Date(),                         forKey: "timestamp")
                item.setValue(Double.random(in: 0.0...100.0), forKey: "value")
            }

            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print("🔴 CORE DATA ОШИБКА: \(error)")
            }

            duration = (CFAbsoluteTimeGetCurrent() - startTime) * 1_000
            print("🟢 CORE DATA: \(count) объектов за \(String(format: "%.2f", duration)) мс")
        }

        return duration
    }
}
