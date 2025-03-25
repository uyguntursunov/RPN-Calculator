//
//  DataPersistencyManager.swift
//  RPN Calculator
//
//  Created by Uygun Tursunov on 10/03/25.
//

import UIKit
import CoreData

enum DatabaseError: Error {
    case failedToSaveData
    case failedToFetchData
    case failedToDeleteData
}

class DataPersistencyManager {
    
    static let shared = DataPersistencyManager()
    
    private init() { }
    
    func saveCalculation(model: CalculatorModel, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = CalculationEntity(context: context)
        entity.result = String(model.result)
        entity.expression = model.expression.joined()
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToSaveData))
        }
    }
    
    func fetchCalculationsFromDatabase(completion: @escaping(Result<[CalculationEntity], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<CalculationEntity> = CalculationEntity.fetchRequest()
        do {
            let calculations = try context.fetch(request)
            completion(.success(calculations))
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteCalculation(model: CalculationEntity, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(model)
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
}
