import Vapor


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    router.post("insString"){
        req -> String in
        var result = "none"
        do {try req.content.decode(InsOriginalInfo.self).map(to:HTTPStatus.self){ insOriginalInfo in
            print(insOriginalInfo.text)
            let processor = InsProcessor()
            result = processor.organizer(insOriginalInfo.text)
            result = processor.startOutput()
            return .ok
        }
            return result
        }catch{
            
        }
        return result
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
