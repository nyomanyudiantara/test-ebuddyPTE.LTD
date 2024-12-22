//
//  UserView.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import SwiftUI

struct UserView: View {
    var uid: String
    
    @ObservedObject private var usersClass: UsersClass = UsersClass()
    
    @State private var sortedByGender: Bool = false
    @State private var sortedByMaleOrFemale: Bool = false
    @State private var displayByAllGender: Bool = false
    @State private var showDisplayByAllGenderButton: Bool = true
    @State private var sortedByRating: Bool = false
    @State private var sortedByServicePrice: Bool = false
    
    var body: some View {
        VStack(content: {
            ScrollView(showsIndicators: false, content: {
                VStack(spacing: 6, content: {
                    ForEach(usersClass.specificUser.sorted(by: { lhs, rhs in
                        // Sort by gender first
                        if let lhsGender = lhs.gender?.rawValue, let rhsGender = rhs.gender?.rawValue {
                            if lhsGender != rhsGender {
                                return sortedByGender ? lhsGender < rhsGender : lhsGender > rhsGender
                            }
                        }

                        // Sort by rating (convert to Double for accurate comparison)
                        if let lhsRating = Double(lhs.rating), let rhsRating = Double(rhs.rating) {
                            if lhsRating != rhsRating {
                                return sortedByRating ? lhsRating < rhsRating : lhsRating > rhsRating
                            }
                        }

                        // Sort by servicePrice (convert to Int for accurate comparison)
                        if let lhsPrice = Int(lhs.servicePrice), let rhsPrice = Int(rhs.servicePrice) {
                            return sortedByServicePrice ? lhsPrice < rhsPrice : lhsPrice > rhsPrice
                        }

                        // Fallback: Maintain original order if all criteria are equal
                        return false
                        
                    }).filter({ user in
                        // Include all users if `displayByAllGender` is true
                        if displayByAllGender {
                            return true
                        } else {
                            guard let gender = user.gender else { return false } // Exclude users without a gender
                            // Filter based on `sortedByMaleOrFemale` value
                            return sortedByMaleOrFemale ? gender == .male : gender == .female
                        }
                    }), id: \.index, content: { users in
                        UserDetail(users: users)
                    })
                })
                .padding(.horizontal, 16)
            })
        })
        .navigationTitle("List of Users")
        .navigationBarTitleDisplayMode(.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task({
            usersClass.fetchAllUsers(uid: uid)
        })
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing, content: {
                SortedByMenu()
            })
        })
        .overlay(alignment: .bottom, content: {
            if showDisplayByAllGenderButton {
                VStack(content: {
                    Button(action: {
                        withAnimation(.smooth(duration: 0.3), {
                            displayByAllGender = true
                            showDisplayByAllGenderButton = false
                        })
                    }, label: {
                        Text("Show all gender")
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .font(.system(size: 16, weight: .semibold))
                            .background(.ultraThinMaterial)
                            .cornerRadius(34)
                            .padding(.horizontal, 16)
                    })
                })
            }
        })
        
    }
}

extension UserView {
    @ViewBuilder
    private func UserDetail(users: User) -> some View {
        NavigationLink(destination: {
            SpecificUserView(uid: uid, index: users.index)
        }, label: {
            HStack(content: {
                VStack(alignment: .leading, spacing: 8, content: {
                    HStack(spacing: 10, content: {
                        Image("star")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                        
                        Text(users.rating)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.primary)
                    })
                    
                    if users.email.isEmpty {
                        Text("email isn't available")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color.secondary)
                    } else {
                        Text(users.email)
                            .font(.system(size: 24, weight: .semibold))
                    }
                    
                    if users.phoneNumber.isEmpty {
                        Text("Phone number isn't available")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(Color.secondary)
                    } else {
                        Text(users.phoneNumber)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.primary)
                    }
                    
                    if let gender = users.gender {
                        switch gender {
                        case .female:
                            Text("Female")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(Color.primary)
                        case .male:
                            Text("Male")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(Color.primary)
                        }
                    } else {
                        Text("Gender not specified") /// Handle optional gender
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(Color.primary)
                    }
                    
                    Text(users.index)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    Text(Int(users.servicePrice) ?? 0, format: .currency(code: "USD"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.primary)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack(content: {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .padding(16)
                        .frame(width: 100)
                        .background(.ultraThinMaterial)
                        .foregroundColor(Color.primary)
                        .cornerRadius(24)
                })
            })
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(34)
        })
    }
    
    @ViewBuilder
    private func SortedByMenu() -> some View {
        Menu(content: {
            Button(action: {
                sortedByMaleOrFemale.toggle()
                showDisplayByAllGenderButton = true
                displayByAllGender = false
            }, label: {
                Label("Show \(sortedByMaleOrFemale ? "Female" : "Male") only", systemImage: sortedByMaleOrFemale ? "figure.stand.dress" : "figure.stand")
            })
            
            Button(action: {
                sortedByGender = false
            }, label: {
                Label("Sort by gender: Male", systemImage: "figure.stand")
            })
            
            Button(action: {
                sortedByGender = true
            }, label: {
                Label("Sort by gender: Female", systemImage: "figure.stand.dress")
            })
            
            Button(action: {
                sortedByRating.toggle()
            }, label: {
                Label("Sort by rating: \(sortedByRating ? "High" : "Low")", systemImage: sortedByRating ? "star.fill" : "star.leadinghalf.filled")
            })
            
            Button(action: {
                sortedByServicePrice.toggle()
            }, label: {
                Label("Sort by service price: \(sortedByServicePrice ? "Low" : "High")", systemImage: sortedByServicePrice ? "chevron.down" : "chevron.up")
            })
        }, label: {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .rotationEffect(Angle(degrees: 90))
        })
    }
}

struct UserView_Previews: PreviewProvider {
    
    static var previews: some View {
        UserView(uid: "oLCYgopnN1q1c6Fb2h1l")
    }
}
