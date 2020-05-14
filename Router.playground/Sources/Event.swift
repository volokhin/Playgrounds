import Foundation

public final class Event<Args> {
    // Тут живут подписчики на событие и их обработчики этого события
    private var handlers: [Weak<AnyObject>: (Args) -> Void] = [:]
    
    public init() {
        
    }

    public func subscribe<Subscriber: AnyObject>(
        _ subscriber: Subscriber,
        handler: @escaping (Subscriber, Args) -> Void) {
        
        // Формируем ключ
        let key = Weak<AnyObject>(subscriber)
        // Почистим массив обработчиков от мёртвых объектов, чтобы не засорять память
        handlers = handlers.filter { $0.key.isAlive }
        // Создаём обработчик события
        handlers[key] = {
            [weak subscriber] args in
            // Захватывает подписчика слабой ссылкой и вызываем обработчик,
            // только если подписчик жив
            guard let subscriber = subscriber else { return }
            handler(subscriber, args)
        }
    }

    public func unsubscribe(_ subscriber: AnyObject) {
        // Отписываемся от события, удаляя соответствующий обработчик из словаря
        let key = Weak<AnyObject>(subscriber)
        handlers[key] = nil
    }
    
    public func raise(_ args: Args) {
        // Получаем список обработчиоков с живыми подписчиками
        let aliveHandlers = handlers.filter { $0.key.isAlive }
        // Для всех живых подписчиков выполняем код обработчиков событий
        aliveHandlers.forEach { $0.value(args) }
    }
}

public extension Event where Args == Void {
    func subscribe<Subscriber: AnyObject>(
        _ subscriber: Subscriber,
        handler: @escaping (Subscriber) -> Void) {

        subscribe(subscriber) { this, _ in
            handler(this)
        }
    }

    func raise() {
        raise(())
    }
}
