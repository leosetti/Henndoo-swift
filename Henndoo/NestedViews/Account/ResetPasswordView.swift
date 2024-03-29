//
//  ResetPasswordView.swift
//  Henndoo
//
//  Created by Leandro Setti de Almeida on 2022-09-04.
//

import SwiftUI

struct ResetPasswordView: View {
    var label: LocalizedStringKey = "password_reset_request"
    @State var isActive: Bool = false
    @State var token: String = ""
    
    var body: some View {
        VStack{
            ResetText()
            NavView(content: {RequestPasswordTokenView()}, text: label, isActive: isActive).padding(.bottom, 20)
            ResetForm(token:token).onDisappear(){
                token = ""
            }
        }.padding()
    }
    
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}

fileprivate struct ResetText: View {
    var title: LocalizedStringKey = "password_reset_title"
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 10)

    }
}

fileprivate struct ResetForm: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userManager: UserLoader
    @EnvironmentObject var popUpObject: PopUpObject
    
    @State var token: String = ""
    @State var password: String = ""
    
    var label: LocalizedStringKey = "password_reset_label"
    var title: LocalizedStringKey = "password_reset_token"
    var passwordtitle: LocalizedStringKey = "password_reset_newpassword"
    var passwordlabel: LocalizedStringKey = "new_password"
    
    var body: some View {
        Text(label)
            .font(.body)
            .fontWeight(.regular)
            .padding(.bottom, 20)
        TextField(title, text: $token)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
        Text(passwordtitle)
            .font(.body)
            .fontWeight(.regular)
            .padding(.top, 20)
        SecureField(passwordlabel, text: $password)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
        
        Button(action: {
            var body: [String: Any] = [:]
            body["token"] = token
            body["password"] = password
            
            userManager.resetUserPassword(withObject: body, then: {result in
                switch result {
                case .success :
                    DispatchQueue.main.async() {
                        popUpObject.type = .success
                        popUpObject.message = "popup_account_password_changed"
                        popUpObject.handler = {
                            viewRouter.currentScreen = .account
                        }
                        popUpObject.show.toggle()
                    }
                    break
                case .failure(_) :
                    DispatchQueue.main.async() {
                        popUpObject.type = .error
                        popUpObject.message = "popup_error_generic_message"
                        popUpObject.show.toggle()
                    }
                }
            })
        }) {
            GenericButtonView(label: "submit")
                .padding(.top, 20)
        }
    }
}
