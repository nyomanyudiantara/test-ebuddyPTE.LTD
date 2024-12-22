//
//  UsersClass.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Users: Identifiable {
    var id: Int
    var ge: Int
    var uid: String
}

enum Gender: Int, CaseIterable {
    case female = 0
    case male = 1
}

struct User: Identifiable {
    var index: String
    var id: String
    var email: String
    var phoneNumber: String
    var servicePrice: String
    var rating: String
    var gender: Gender?
}

class UsersClass: ObservableObject {
    @Published var users = [Users]()
    @Published var specificUser = [User]()
    
    private var db = Firestore.firestore()
    private let usersCollection = "USERS"
    
    func fetchData() {
        db.collection(usersCollection).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.users = documents.compactMap { queryDocumentSnapshot -> Users? in
                let data = queryDocumentSnapshot.data()
                let documentID = queryDocumentSnapshot.documentID
                let id = data["id"] as? Int ?? 0 /// Providing a default value of 0
                let ge = data["ge"] as? Int ?? 0
                let uid = data["uid"] as? String ?? ""
                
//                print("users data: \(data)")

                return Users(id: id, ge: ge, uid: uid)
                
            }
        }
    }
    
    func fetchAllUsers(uid: String) {
        guard !uid.isEmpty else {
            print("Error: uid is empty.")
            return
        }
        
        print("uid: \(uid)")
        
        db.collection(usersCollection).document(uid).collection(uid).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.specificUser = documents.compactMap { queryDocumentSnapshot -> User? in
                let data = queryDocumentSnapshot.data()
                
                let index = data["index"] as? String ?? ""
                let id = data["id"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let phoneNumber = data["phoneNumber"] as? String ?? ""
                let servicePrice = data["servicePrice"] as? String ?? ""
                let rating = data["rating"] as? String ?? ""

                let genderRawValue = data["gender"] as? Int
                
//                print("users data all: \(data)")

                return User(
                    index: index,
                    id: id,
                    email: email,
                    phoneNumber: phoneNumber,
                    servicePrice: servicePrice,
                    rating: rating,
                    gender: genderRawValue.flatMap { Gender(rawValue: $0) }
                )
            }
        }
    }
    
    func fetchSpecificUser(uid: String, index: String) async {
        guard !index.isEmpty && !uid.isEmpty else {
            print("Error: index and uid are empty.")
            return
        }

        let subdocumentRef = db.collection(usersCollection).document(uid).collection(uid).document(index)

        do {
            let document = try await subdocumentRef.getDocument()
            if document.exists, let data = document.data() {
                // Create the temporary event list
                let tempEventList = [createUserDetail(index: index, from: data)]

                // Update the @Published property on the main queue
                DispatchQueue.main.async {
                    self.specificUser = tempEventList
                }
            } else {
                print("Document does not exist for uid: \(uid) index: \(index)")
            }
        } catch let error as NSError where error.domain == FirestoreErrorDomain {
            print("Firestore error: \(error.localizedDescription)")
        } catch {
            print("Other error: \(error)")
        }
    }
    
    func createUserDetail(index: String, from data: [String: Any]) -> User {
        let index = index
        let id = data["id"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let phoneNumber = data["phoneNumber"] as? String ?? ""
        let servicePrice = data["servicePrice"] as? String ?? ""
        let rating = data["rating"] as? String ?? ""
        guard let genderRawValue = data["gender"] as? Int else {
            // Handle missing or invalid gender value
            return User(index: index, id: id, email: email, phoneNumber: phoneNumber, servicePrice: servicePrice, rating: rating, gender: nil)
        }

        guard let gender = Gender(rawValue: genderRawValue) else {
            // Handle invalid gender value
            return User(index: index, id: id, email: email, phoneNumber: phoneNumber, servicePrice: servicePrice, rating: rating, gender: nil)
        }

        return User(index: index, id: id, email: email, phoneNumber: phoneNumber, servicePrice: servicePrice, rating: rating, gender: gender)
    }
    
}
