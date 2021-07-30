//
//  HomeView.swift
//  ScrolltoHide (iOS)
//
//  Created by Michele Manniello on 30/07/21.
//

import SwiftUI
@available(iOS 15.0, *)
struct HomeView: View {
    @State var showSheet : Bool = false
    var body: some View {
        NavigationView{
            Button {
                showSheet.toggle()
            } label: {
                Text("Present Sheet")
            }
            .navigationTitle("Half Modal Sheet")
            .halfSheet(showSheet: $showSheet) {
//                Your half Sheet View...
                ZStack{
                    Color.red
                    VStack {
                        Text("Ciao Michele")
                            .font(.title.bold())
                          .foregroundColor(.white)
                        Button {
                            showSheet.toggle()
                        } label: {
                            Text("Close From Sheet")
                                .foregroundColor(.white)
                        }
                        .padding()

                    }
                }
                .ignoresSafeArea()
               
            }onEnd: {
                print("Dismissed")
            }

        }
    }
}
@available(iOS 15.0, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
@available(iOS 15.0, *)
//Custom Half Sheet Modifier...
extension View{
//    Binding Show Variabile...
    func halfSheet<SheetView : View>(showSheet: Binding<Bool>,@ViewBuilder sheetView : @escaping ()-> SheetView, onEnd: @escaping ()->()) -> some View{
//        Using overlay or background..
//        Because it will automatically use the swiftui frame Size only...
        return self
            .background(
               
                HalfSheetHelper(sheetView: sheetView(),showSheet: showSheet, onEnd: onEnd)
            )
    }
}

//UIKit Integration...
struct HalfSheetHelper<SheetView : View> : UIViewControllerRepresentable {
    var sheetView : SheetView
    @Binding var showSheet : Bool
    var onEnd : ()->()
    
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet{
//            presenting Modal View...
//            let sheetController = CustomHostingController(rootView: sheetView)
            if #available(iOS 15.0, *) {
                let sheetController = CustomHostingController(rootView: sheetView)
                sheetController.presentationController?.delegate = context.coordinator
                uiViewController.present(sheetController, animated: true)
            } else {
                // Fallback on earlier versions
            }
        }else{
//            closing view when showSheet toggled again..
            uiViewController.dismiss(animated: true)
        }
    }
//    On Dismiss..
    class Coordinator: NSObject,UISheetPresentationControllerDelegate {
        var parent : HalfSheetHelper
        init(parent : HalfSheetHelper) {
            self.parent = parent
        }
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
}
@available(iOS 15.0, *)
// Custom UIHostingController for halfSheet....
class CustomHostingController<Content : View>:UIHostingController<Content>{
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
//        setting presentation controller properties...
        if let presentationController = presentationController as? UISheetPresentationController{
            presentationController.detents = [
                .medium(),
                .large()
            ]
            
//            to show grab protion...
            presentationController.prefersGrabberVisible = true
        }
    }
}
