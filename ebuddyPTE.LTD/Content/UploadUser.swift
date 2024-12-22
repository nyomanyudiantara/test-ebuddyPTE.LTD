//
//  UploadUser.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct UploadUser: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var usersClass: UsersClass = UsersClass()
    @ObservedObject private var allViewReceiver: AllViewReceiver = AllViewReceiver.shared
    
    @State private var email: String = ""
    @State private var isEmailValid: Bool = true
    @State private var phoneNumber: String = ""
    @State private var isPhoneNumberValid: Bool = true
    @State private var phoneNumberCountryCode: String = ""
    @State private var servicePrice: String = ""
    @State private var rating: String = ""
    @State private var gender: String = ""
    @State private var profilePicture: String = ""
    
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var isShowingImageLibrary: Bool = false
    @State private var isUploading: Bool = false
    
    private var buttonTextColor: Color {
        return colorScheme == .dark ? Color.black : Color.white
    }
    
    @FocusState private var focusedField: Field?
    
    func uploadImage() {
        
        guard let inputImage = inputImage else { return }

        // Check if the image is in JPG or PNG format
        guard let imageData = inputImage.jpegData(compressionQuality: 1.0) ?? inputImage.pngData() else {
            print("Only JPG and PNG formats are supported.")
            return
        }
        
        var compressionQuality: CGFloat = 1.0
        var compressedData: Data? = inputImage.jpegData(compressionQuality: compressionQuality)
        
        while let data = compressedData, data.count > 200_000 && compressionQuality > 0 {
            compressionQuality -= 0.1
            compressedData = inputImage.jpegData(compressionQuality: compressionQuality)
        }
        
        guard let finalImageData = compressedData else {
            print("Unable to compress image to the desired size.")
            return
        }
        
        /// Set the storage reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("ebuddy/userImages/\(email).jpg")
        
        /// Upload data
        isUploading = true
        
        let uploadTask = imageRef.putData(finalImageData, metadata: nil) { metadata, error in
            isUploading = false
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return
            }
            
            print("Image uploaded successfully")

            /// Get download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    return
                }
                
                profilePicture = url?.absoluteString ?? ""
                
                print("Download URL: \(url?.absoluteString ?? "No URL")")
            }
        }
        
        /// Monitor upload progress
//        uploadTask.observe(.progress) { snapshot in
//            uploadProgress = Double(snapshot.progress?.fractionCompleted ?? 0)
//            print("Upload progress: \(uploadProgress * 100)%")
//            print("Upload progress 2: \(String(describing: snapshot.progress?.fractionCompleted))")
//            
//            if snapshot.progress?.fractionCompleted == 1.0 {
//                DispatchQueue.main.async {
//                    allViewClass.uploadProfilePicture(photoURL: uploadImageURL)
//                    print("Profile picture updated!")
//                }
//            }
//        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        uploadImage()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = "^[0-9+\\-() ]{7,15}$" // Allows digits, +, -, (, ), and spaces with a length between 7 and 15.
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberPredicate.evaluate(with: phoneNumber)
    }
    
    private func validateServicePrice(_ newValue: String) {
        // Remove non-numeric characters
        let filtered = newValue.filter { $0.isNumber }

        // Convert to an integer
        if let price = Int(filtered) {
            if price <= 200 {
                servicePrice = "\(price)" // Assign the valid price
            } else {
                servicePrice = "200" // Cap the value at 200
                allViewReceiver.isShowingAFailedAlertToast = true
                allViewReceiver.isShowingAFailedAlertToastMessage = "The maximum price is USD 200"
            }
        } else if filtered.isEmpty {
            servicePrice = ""
        }
    }
    
    func isCreatingUser() async {
        let users = "USERS"
        
        if let user = usersClass.users.first(where: { $0.uid == "oLCYgopnN1q1c6Fb2h1l" }) {
            let db = Firestore.firestore()
            let documentRef = db.collection(users).document(user.uid).collection(user.uid).document()
            
            let documentID = documentRef.documentID
            
            let dataToSave: [String: Any] = [
                "index": documentID,
                "uid": UUID().uuidString,
                "email": email,
                "phoneNumber": "+\(phoneNumberCountryCode.isEmpty ? "62" : phoneNumberCountryCode)\(phoneNumber)",
                "servicePrice": servicePrice,
                "rating": rating,
                "gender": Int(gender) ?? 0
            ]
            
            do {
                try await documentRef.setData(dataToSave)
                
                allViewReceiver.isShowingASuccessfulAlertToast = true
                allViewReceiver.isShowingASuccessfulAlertToastMessage = "Successfully creating an user"
                
                print("Data saved successfully!")
            } catch {
                allViewReceiver.isShowingAFailedAlertToast = true
                allViewReceiver.isShowingAFailedAlertToastMessage = "Failed to create an user"
                
                print("Error saving the data: \(error)")
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false, content: {
            VStack(content: {
                Button(action: {
                    isShowingImageLibrary = true
                }, label: {
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .padding(16)
                            .frame(width: 140)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                })
                .accentColor(Color.secondary)
                
                VStack(content: {
                    UserInformation(placeholder: "email", value: $email, phoneNumberCountryCode: $phoneNumberCountryCode, category: "email")
                        .focused($focusedField, equals: .email)
                        .onChange(of: email) { oldValue, newValue in
                            isEmailValid = isValidEmail(newValue)
                        }
                    UserInformation(placeholder: "Phone Number", value: $phoneNumber, phoneNumberCountryCode: $phoneNumberCountryCode, category: "number")
                        .focused($focusedField, equals: .phoneNumber)
                        .onChange(of: phoneNumber) { oldValue, newValue in
                            isPhoneNumberValid = isValidPhoneNumber(newValue)
                        }
                    UserInformation(placeholder: "Service Price", value: $servicePrice, phoneNumberCountryCode: $phoneNumberCountryCode, category: "price")
                        .focused($focusedField, equals: .price)
                        .onChange(of: servicePrice) { oldValue, newValue in
                            if let price = Int(newValue) {
                                if price >= 25 && price < 50 {
                                    rating = "2.0"
                                } else if price >= 50 && price < 75 {
                                    rating = "3.0"
                                } else if price >= 75 && price < 100 {
                                    rating = "4.0"
                                } else if price >= 100 {
                                    rating = "5.0"
                                } else {
                                    // Handle cases where price is less than 250000
                                    rating = "1.0" // Or any other default rating
                                }
                            }
                            
                            validateServicePrice(newValue)
                        }
                })
                .onSubmit({
                    if focusedField == .email {
                        focusedField = .phoneNumber
                    }
                })
                
                Menu(content: {
                    VStack(content: {
                        Button(action: {
                            withAnimation(.smooth(duration: 0.3), {
                                gender = "1"
                            })
                        }, label: {
                            Label("Male", systemImage: "figure.stand")
                        })
                        
                        Button(action: {
                            withAnimation(.smooth(duration: 0.3), {
                                gender = "0"
                            })
                        }, label: {
                            Label("Female", systemImage: "figure.stand.dress")
                        })
                    })
                }, label: {
                    Text("\(!gender.isEmpty ? "\(gender == "1" ? "Male" : "Female")" : "Select Gender →")")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.slide)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                    .frame(height: 34)
                
                Button(action: {
                    Task(operation: {
                        if isValidEmail(email) && isValidPhoneNumber(phoneNumber) {
                            await isCreatingUser()
                        } else {
                            allViewReceiver.isShowingAFailedAlertToast = true
                            allViewReceiver.isShowingAFailedAlertToastMessage = isValidEmail(email)
                                ? "Your phone number is not valid"
                                : "Your email is wrong"
                        }
                    })
                }, label: {
                    Text("Create User")
                        .padding(16)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(buttonTextColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(email.isEmpty || phoneNumber.isEmpty || gender.isEmpty ? Color.secondary : Color.primary)
                        .cornerRadius(34)
                })
                .disabled(email.isEmpty || phoneNumber.isEmpty || gender.isEmpty)
            })
            .navigationTitle("Create User")
            .navigationBarTitleDisplayMode(.large)
            .padding(.horizontal, 16)
            .onChange(of: inputImage, { oldValue, newValue in
                loadImage()
            })
            .toolbar(content: {
                ToolbarItem(placement: .keyboard, content: {
                    HStack(spacing: 32, content: {
                        Button(action: {
                            focusPreviousField()
                        }, label: {
                            Image(systemName: "chevron.up")
                        })
                        .disabled(!canFocusPreviousField()) // remove this to loop through fields
                        Button(action: {
                            focusNextField()
                        }, label: {
                            Image(systemName: "chevron.down")
                        })
                        .disabled(!canFocusNextField()) // remove this to loop through fields
                        Spacer()
                        Button(action: {
                            focusedField = nil
                        }, label: {
                            Text("Close")
                                .font(.system(size: 16, weight: .semibold))
                        })
                    })

                })
            })
            .sheet(isPresented: $isShowingImageLibrary, content: {
                ImagePicker(image: $inputImage)
                    .presentationDragIndicator(.automatic)
            })
            .task({
                usersClass.fetchData()
            })
        })
    }
}

private struct UserInformation: View {
    @State var placeholder: String
    @Binding var value: String
    @Binding var phoneNumberCountryCode: String
    @State var category: String
    
    var body: some View {
        VStack(content: {
            if category == "text" {
                TextField(placeholder, text: $value)
                    .padding(16)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(34)
            } else if category == "email" {
                TextField(placeholder, text: $value)
                    .padding(16)
                    .font(.system(size: 18, weight: .semibold))
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.none)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(34)
                    .submitLabel(.next)
            } else if category == "price" {
                TextField(placeholder, text: $value)
                    .padding(16)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .keyboardType(.numberPad)
                    .cornerRadius(34)
                    .overlay(alignment: .trailing, content: {
                        VStack(content: {
                            Text("USD")
                                .font(.system(size: 24, weight: .semibold))
                                 + Text("/Hr")
                                .font(.system(size: 18, weight: .regular))
                        })
                        .padding(.trailing, 16)
                    })
            } else {
                TextField(placeholder, text: $value)
                    .padding(16)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .keyboardType(.phonePad)
                    .cornerRadius(34)
                    .overlay(alignment: .trailing, content: {
                        Menu(content: {
                            CountryListPhoneCodes(selectedCountryPhoneCode: $phoneNumberCountryCode)
                        }, label: {
                            Text(!phoneNumberCountryCode.isEmpty ? "+\(phoneNumberCountryCode)" : "+62")
                                .font(.system(size: 18, weight: .semibold))
                                .minimumScaleFactor(0.7)
                        })
                        .padding(.trailing, 16)
                    })
            }
        })
    }
}

extension UploadUser {
    
    private enum Field: Int, CaseIterable {
        case email, phoneNumber, price
    }
    
    private func focusPreviousField() {
        if let currentField = focusedField,
           let previousField = Field(rawValue: currentField.rawValue - 1) {
            focusedField = previousField
        }
    }

    private func focusNextField() {
        if let currentField = focusedField,
           let nextField = Field(rawValue: currentField.rawValue + 1) {
            focusedField = nextField
        }
    }

    private func canFocusPreviousField() -> Bool {
        guard let currentFocusedField = focusedField else {
            return false
        }
        return currentFocusedField.rawValue > 0
    }

    private func canFocusNextField() -> Bool {
        guard let currentFocusedField = focusedField else {
            return false
        }
        return currentFocusedField.rawValue < Field.allCases.count - 1
    }
}

struct UploadUserView_Previews: PreviewProvider {
    
    static var previews: some View {
        UploadUser()
    }
}
