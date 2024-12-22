//
//  MainView.swift
//  ebuddyPTE.LTD
//
//  Created by a mutant on 21/12/24.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var usersClass: UsersClass = UsersClass()
    @AppStorage("EBUDDY-darkmode") private var isSwitchingDarkMode: Bool = false
    
    var body: some View {
        NavigationStack(root: {
            VStack(spacing: 16, content: {
                Text("EBUDDY PTE.LTD")
                    .font(.system(size: 36, weight: .semibold))
                    .minimumScaleFactor(0.7)
                
                MyName()
                
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(content: {
                Image("gradient-background-1")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .ignoresSafeArea(.all)
            })
            .overlay(alignment: .bottomTrailing, content: {
                VStack(spacing: 16, content: {
                    if let user = usersClass.users.first(where: { $0.uid == "oLCYgopnN1q1c6Fb2h1l" }) {
                        NavigationLink(destination: UserView(uid: user.uid), label: {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .padding(16)
                                .frame(width: 80)
                                .foregroundColor(Color.blue)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        })
                    } else {
                        NavigationLink(destination: UserView(uid: "oLCYgopnN1q1c6Fb2h1l"), label: {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .padding(16)
                                .frame(width: 80)
                                .foregroundColor(Color.blue)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        })
                    }
                    
                    NavigationLink(destination: UploadUser(), label: {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .padding(16)
                            .frame(width: 80)
                            .foregroundColor(Color.blue)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    })
                })
            })
            .padding(.horizontal, 16)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing, content: {
                    Toggle(isOn: $isSwitchingDarkMode, label: {
                        Image(systemName: isSwitchingDarkMode ? "sun.max.fill" : "moon.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                    })
                    .toggleStyle(.automatic)
                    .padding(.horizontal, 16)
                })
            })
        })
        .task({
            usersClass.fetchData()
        })
    }
}

extension MainView {
    @ViewBuilder
    private func MyName() -> some View {
        VStack(alignment: .leading, spacing: 16, content: {
            Yudi(placeholder: "Full Name", value: "I Nyoman Yudiantara")
            Yudi(placeholder: "Apply for", value: "Remote iOS Developer")
        })
        .padding(.horizontal, 16)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(34)
    }
}

private struct Yudi: View {
    var placeholder: String
    var value: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, content: {
            Text("\(placeholder)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.7)
            Text(":")
            Text("\(value)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.7)
        })
    }
}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView()
    }
}
