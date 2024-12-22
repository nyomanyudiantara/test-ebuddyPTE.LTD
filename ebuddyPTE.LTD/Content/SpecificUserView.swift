//
//  SpecificUserView.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import SwiftUI

struct SpecificUserView: View {
    var uid: String
    var index: String
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @ObservedObject private var usersClass: UsersClass = UsersClass()
    
    @State private var isShowingAvailableStatus: Bool = false
    @State private var isFetchingUserGender: Int = 0
    
    var body: some View {
        ScrollView(showsIndicators: false, content: {
            VStack(spacing: 16, content: {
                ForEach(usersClass.specificUser, id: \.index, content: { user in
                    UserCard(user: user)
                    
                    /// New by me
                    VStack(alignment: .leading, spacing: 8, content: {
                        SpecificUserInformation(icon: "phone.fill", information: user.phoneNumber)
                        
                        if let gender = user.gender {
                            switch gender {
                            case .female:
                                SpecificUserInformation(icon: "figure.stand.dress", information: "Female")
                            case .male:
                                SpecificUserInformation(icon: "figure.stand", information: "Male")
                            }
                        }
                        
                        SpecificUserInformation(icon: "touchid", information: user.index)
                    })
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(34)
                    .navigationTitle(user.email)
                    
                })
            })
            .padding(.horizontal, 16)
            .task({
                Task(operation: {
                    await usersClass.fetchSpecificUser(uid: uid, index: index)
                })
            })
        })
    }
}

extension SpecificUserView {
    @ViewBuilder
    private func UserCard(user: User) -> some View {
        VStack(spacing: 16, content: {
            Header()
            
            InnerBody(user: user)
            
            Footer(user: user)
        })
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(34)
    }
    
    @ViewBuilder
    private func Footer(user: User) -> some View {
        VStack(spacing: 16, content: {
            HStack(spacing: 16, content: {
                VStack(alignment: .center, content: {
                    Image("star")
                        .resizable()
                        .scaledToFit()
                })
                .frame(width: 90, alignment: .center)
                
                Text("\(user.rating)")
                    .font(.system(size: 52, weight: .bold)) + Text(" (6.1)")
                    .font(.system(size: 52, weight: .regular))
                    .foregroundColor(Color.secondary)
            })
            
            HStack(spacing: 16, content: {
                VStack(alignment: .center, content: {
                    Image("fire")
                        .resizable()
                        .scaledToFit()
                })
                .frame(width: 100, alignment: .center)
                
                Text("\(user.servicePrice)")
                    .font(.system(size: 52, weight: .bold)) + Text(".00/1Hr")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundColor(Color.secondary)
            })
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 32)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func InnerBody(user: User) -> some View {
        VStack(content: {
            if let gender = user.gender {
                switch gender {
                case .female:
                    AsyncImage(url: URL(string: "https://images.pexels.com/photos/2913125/pexels-photo-2913125.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"), content: { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .cornerRadius(34)
                            .onTapGesture(perform: {
                                withAnimation(.smooth(duration: 0.3), {
                                    isShowingAvailableStatus.toggle()
                                })
                            })
                            .overlay(alignment: .top, content: {
                                if isShowingAvailableStatus {
                                    HStack(spacing: 10, content: {
                                        Image(systemName: "bolt")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 44)
                                            .foregroundColor(Color.white)
                                        
                                        Text("Available today!")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(Color.white)
                                    })
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .padding(16)
                                }
                            })
                    }, placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .cornerRadius(34)
                    })
                    .frame(maxWidth: .infinity, maxHeight: 500)
                    .cornerRadius(34)
                case .male:
                    AsyncImage(url: URL(string: "https://images.pexels.com/photos/4947458/pexels-photo-4947458.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"), content: { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .cornerRadius(34)
                            .onTapGesture(perform: {
                                withAnimation(.smooth(duration: 0.3), {
                                    isShowingAvailableStatus.toggle()
                                })
                            })
                            .overlay(alignment: .top, content: {
                                if isShowingAvailableStatus {
                                    HStack(spacing: 10, content: {
                                        Image(systemName: "bolt")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 44)
                                            .foregroundColor(Color.white)
                                        
                                        Text("Available today!")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(Color.white)
                                    })
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                                    .padding(16)
                                }
                            })
                    }, placeholder: {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .cornerRadius(34)
                    })
                    .frame(maxWidth: .infinity, maxHeight: 500)
                    .cornerRadius(34)
                }
            }
            
        })
        .frame(maxWidth: .infinity, maxHeight: 500)
        .overlay(alignment: .bottomTrailing, content: {
            if isShowingAvailableStatus {
                VStack(content: {
                    Image(systemName: "waveform")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 30)
                        .foregroundColor(Color.white)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
                .padding(16)
                .background(LinearGradient(colors: [.purple, .pink], startPoint: .bottomLeading, endPoint: .topLeading))
                .clipShape(Circle())
                .padding(.horizontal, 16)
                .offset(y: 26)
            }
        })
        .overlay(alignment: .bottomLeading, content: {
            HStack(spacing: -32, content: {
                Image("call-of-duty")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .background(.ultraThickMaterial)
                    .clipShape(Circle())
                
                Image("mobile-legends-1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .background(.ultraThickMaterial)
                    .clipShape(Circle())
                    .zIndex(1)
            })
            .padding(.horizontal, 16)
            .offset(y: 22)
        })
    }
    
    @ViewBuilder
    private func Header() -> some View {
        HStack(spacing: 16, content: {
            Text("Zynx")
                .font(.system(size: 34, weight: .bold))
            
            Image(systemName: "largecircle.fill.circle")
                .resizable()
                .scaledToFit()
                .frame(height: 16)
                .foregroundColor(Color.green)
            
            Spacer()
            
            HStack(spacing: 16, content: {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 34)
                    .foregroundColor(Color.blue)
                
                Button(action: {
                    openURL(URL(string: "https://www.instagram.com") ?? URL(fileURLWithPath: ""))
                }, label: {
                    Image("instagram")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 34)
                        .foregroundColor(Color.primary)
                })
            })
        })
        .padding(.top, 16)
    }
}

private struct SpecificUserInformation: View {
    var icon: String
    var information: String
    
    var body: some View {
        HStack(spacing: 10, content: {
            VStack(content: {
                Image(systemName: icon)
            })
            .frame(width: 36)
            
            Text(information)
                .font(.system(size: 14, weight: .light))
        })
    }
}

struct SpecificUserView_Previews: PreviewProvider {
    
    static var previews: some View {
        SpecificUserView(uid: "oLCYgopnN1q1c6Fb2h1l", index: "5Fxbyks6t9QJ9y68Ofe8")
    }
}
