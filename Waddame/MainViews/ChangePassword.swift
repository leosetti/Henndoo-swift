//
//  ChangePassword.swift
//  Waddame
//
//  Created by Leandro Setti de Almeida on 2022-08-10.
//

import SwiftUI

struct ChangePassword: View {
    @Binding var rootIsActive : Bool
    
    @EnvironmentObject var viewRouter: ViewRouter
    @StateObject private var userObject = UserObject()
    
    var signuplabel: LocalizedStringKey = "signup"
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack {
                    TitleText()
                    PasswordForm(rootIsActive:$rootIsActive)
                }.padding()
            }
        }.environmentObject(userObject)
    }
}

struct ChangePassword_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

fileprivate struct TitleText: View {
    var label: LocalizedStringKey = "change_password"
    var body: some View {
        Text(label)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

fileprivate struct PasswordForm: View {
    @Binding var rootIsActive : Bool
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userManager: UserLoader
    @EnvironmentObject var popUpObject: PopUpObject
    
    @State var oldpassword: String = ""
    @State var newpassword: String = ""
    
    var oldpwdlabel: LocalizedStringKey = "old_password"
    var pwdlabel: LocalizedStringKey = "new_password"
    
    @State var errorMesageString: LocalizedStringKey = "popup_error"
    
    enum Field: Hashable {
        case oldpassword
        case newpassword
    }
    @FocusState private var focusedField: Field?
    
    @State var oldpasswordError: LocalizedStringKey = "form_password_error"
    @State var viewError1: Bool = false
    @State var passwordError: LocalizedStringKey = "form_password_error"
    @State var viewError2: Bool = false
    
    var body: some View {
        VStack{
            Section{
                TextField(oldpwdlabel, text: $oldpassword)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(5.0)
                    .border((errorMesageString == "form_oldpassword_error" || viewError1) ? .red : .clear, width: 1)
                    .focused($focusedField, equals: .oldpassword)
                    .onSubmit {
                        if oldpassword.count < 3 {
                            viewError1 = true
                            oldpasswordError = "form_password_error_1"
                            focusedField = .oldpassword
                        }else if oldpassword.count > 30 {
                            viewError1 = true
                            oldpasswordError = "form_password_error_2"
                            focusedField = .oldpassword
                        }else {
                            viewError1 = false
                            focusedField = .newpassword
                        }
                    }
                Text(oldpasswordError)
                    .isHidden(!viewError1)
                    .frame(maxHeight: viewError1 ? 30 : 0)
                    .foregroundColor(.red)
                TextField(pwdlabel, text: $newpassword)
                    .padding()
                        .background(lightGreyColor)
                    .cornerRadius(5.0)
                    .border((errorMesageString == "form_password_error" || viewError2) ? .red : .clear, width: 1)
                    .focused($focusedField, equals: .newpassword)
                    .onSubmit {
                        if newpassword.count < 3 {
                            viewError2 = true
                            passwordError = "form_password_error_1"
                            focusedField = .newpassword
                        }else if newpassword.count > 30 {
                            viewError2 = true
                            passwordError = "form_password_error_2"
                            focusedField = .newpassword
                        }else {
                            viewError2 = false
                        }
                    }
                Text(passwordError)
                    .isHidden(!viewError2)
                    .frame(maxHeight: viewError2 ? 30 : 0)
                    .foregroundColor(.red)
            }
            Section{
                Button(action: {
                    let body: [String: Any] = [
                        "oldpassword": oldpassword,
                        "newpassword": newpassword
                    ]
                    
                    func treatError (with error:Error){
                        viewError1 = false
                        viewError2 = false
                        if AppUtil.isInDebugMode {
                            print(error.localizedDescription)
                        }
                        switch error {
                            case UserLoader.UserError.data(let path):
                                switch path {
                                case "oldpassword":
                                    errorMesageString = "form_oldpassword_error"
                                    focusedField = .oldpassword
                                    viewError1 = true
                                    viewError2 = false
                                    break
                                case "password":
                                    errorMesageString = "form_password_error"
                                    focusedField = .newpassword
                                    viewError2 = true
                                    viewError1 = false
                                    break
                                default:
                                    break
                                }
                            case UserLoader.UserError.unauthorized:
                            errorMesageString = "form_login_unauthorized"
                            break
                            
                            default:
                            errorMesageString = "form_password_error"
                            }
                        
                    
                        DispatchQueue.main.async() {
                            popUpObject.title = "popup_error"
                            popUpObject.message = errorMesageString
                            popUpObject.show.toggle()
                        }
                    }
                    
                    userManager.changeUserPassword(withObject: body, then: {result in
                        switch result {
                        case .success :
                            viewError1 = false
                            viewError2 = false
                            errorMesageString = "popup_error"
                            DispatchQueue.main.async() {
                                popUpObject.title = "popup_account_success"
                                popUpObject.message = "popup_account_password_changed"
                                popUpObject.handler = {rootIsActive = false}
                                popUpObject.show.toggle()
                            }
                            break
                        case .failure(let error) :
                            treatError(with: error)
                        }
                    })
                    
                }) {
                    ButtonContent()
                }
            }
        }.onAppear() {
            focusedField = .oldpassword
        }
    }
}

fileprivate struct ButtonContent: View {
    var loginlabel: LocalizedStringKey = "change_action"
    
    var body: some View {
        Text(loginlabel)
            .textCase(.uppercase)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}
