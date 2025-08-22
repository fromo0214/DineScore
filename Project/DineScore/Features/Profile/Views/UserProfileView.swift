//
//  ProfileView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct UserProfileView: View {
    
    //profile details
    @State var firstName: String = "Fernando"
    @State var lastName: String = "Romo"
    @State var email: String = "fromo301@yahoo.com"
    @State var zipCode: String = "90247"
    @State var dob : Date = Date()
    
    @State var selectedTab: ProfileTab = .profile
    
    
    enum ProfileTab: String, CaseIterable, Identifiable{
        case profile = "Profile"
        case lists = "Lists"
        case reviews = "Reviews"
        case socials = "Socials"
        case likes = "Likes"
        var id: String {self.rawValue}
    }
    
    
    var body: some View {
        
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing:0){
                HStack{
                    navButton(title:"Profile", tab: .profile)
                    Spacer()
                    navButton(title:"Lists", tab:.lists)
                    Spacer()
                    navButton(title:"Reviews", tab:.reviews)
                    Spacer()
                    navButton(title:"Socials", tab:.socials)
                    Spacer()
                    navButton(title:"Likes", tab:.likes)
                }.shadow(radius: 5)
                    .frame(width:350, height:50)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(Color.textColor)
                
                
                
                Group{
                    switch selectedTab {
                    case .profile:
                        UserProfileContentView()
                    case .lists:
                        UserListsView()
                    case .reviews:
                        UserReviewView()
                    case .socials:
                        UserSocialsView()
                    case .likes:
                        UserLikesView()
                    }
                }
                
            }
        }
    }

    func navButton(title: String, tab: ProfileTab) -> some View {
            Button(action: {
                selectedTab = tab
            }) {
                Text(title)
                    .font(.system(size: 18))
                    .bold()
                    .background(RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(selectedTab == tab ? Color.backgroundColor : Color.clear)
                        .frame(width:70)
                    )
                    .foregroundColor(selectedTab == tab ? Color.textColor : .gray)
            }
        }
    
                              
}

#Preview {
    UserProfileView()
}
