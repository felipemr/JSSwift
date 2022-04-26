//
//  ContentView.swift
//  JSSwift
//
//  Created by Felipe Marques on 25/04/22.
//

import SwiftUI
import JavaScriptCore

struct StyleButton: ButtonStyle {
    let bgColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 175, height: 50, alignment: .center)
            .background(bgColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct ContentView: View {

    @State private var consoleOutput: String = "Console Output: \n"

    var body: some View {
        VStack {
            Button("Send from Swift") {
                sendSwift()
            }
            .buttonStyle(StyleButton(bgColor: .blue))
            Button("Retrieve from JS") {
                retrieveJS()
            }
            .buttonStyle(StyleButton(bgColor: .blue))
            Button("Run external script") {
                runScript()
            }
            .buttonStyle(StyleButton(bgColor: .blue))
            Button("Make Error") {
                error()
            }
            .buttonStyle(StyleButton(bgColor: .yellow))
            Button("Run JS VM") {
                vmJS()
            }
            .buttonStyle(StyleButton(bgColor: .red))
            ZStack{
                Color.black
                Text(consoleOutput)
                    .foregroundColor(.green)
            }
        }

    }

    
    func sendSwift(){
//        How to send variable to JSContext
//        if let context = JSContext() {
//            let swiftVariable = 2 + 3
//            context.setObject(swiftVariable,
//                               forKeyedSubscript: "swiftValue" as NSString)
//            let result = context.evaluateScript(" swiftValue + 2 ")
//        }

//        How to send function to JSContext
//        if let context = JSContext() {
//            let addBlock: @convention(block) (Int, Int) -> Int = { (first, second) in
//                return first + second
//            }
//            context.setObject(addBlock,
//                              forKeyedSubscript: "add" as NSString)
//            let result = context.evaluateScript("add(2,3)")
//            print(result?.toInt32())
//        }

//        How to send a complex object created on Swift
        if let context = JSContext() {

//            Creates the Class inside JSContext
            context.setObject(Monster.self,
                              forKeyedSubscript: "Monster" as NSString)
//            Creates the object
            let result = context.evaluateScript("""
                   orc = Monster.create("Orc",20,10);
                   orc.printMonster();
            """)
            printOnConsole(result)
        }
    }

    func retrieveJS(){
//        How to retrieve variable from JSContext
//        if let context = JSContext() {
//            context.evaluateScript(" jsValue = 5 + 1 ")
//            let resultValue = context.objectForKeyedSubscript("jsValue")
//            returneddValue = resultValue?.toString() ?? "Err"
//        }

//        How to retrieve function from JSContext
//        if let context = JSContext() {
//            context.evaluateScript("""
//                function add(first, second) {
//                    return first + second;
//                }
//                """)
//            let addFunctionJS = context.objectForKeyedSubscript("add")
//            let result = addFunctionJS?.call(withArguments: [2,3])
//            print(result?.toInt32())
//        }

//        How to retrieve a complex object from JSContext
        if let context = JSContext() {

//            Creates a block and set an object inside JSContext to call the swift function
            let printBlock: @convention(block) (JSValue) -> Void = { (obj) in
                printFullName(obj)
            }
            context.setObject(printBlock,
                              forKeyedSubscript: "printName" as NSString)

            let dictionaryBlock: @convention(block) (JSValue) -> Void = { (obj) in
                    dictionaryExample(obj)
                }
                context.setObject(dictionaryBlock,
                                  forKeyedSubscript: "dictionary" as NSString)

            
            let _ = context.evaluateScript("""
                    var person = new Object();
                    person.name = "Felipe";
                    person.lastName = "Marques";
                    person.age = 27;
                    printName(person);
                """)
        }
    }

    func vmJS() { // This Crashes
        let vm = JSVirtualMachine()
        let vm2 = JSVirtualMachine()

        let context1 = JSContext(virtualMachine: vm)
        context1?.setObject(Monster.self,
                          forKeyedSubscript: "Monster" as NSString)

        let result = context1?.evaluateScript("""
                   orc = Monster.create("Orc",20,10);
                   orc.printMonster();
                   orc
            """)

        // FIXME:   Use vm1 to make it work
//         We can't share an object from oone VM to another
        let context2 = JSContext(virtualMachine: vm2)

        context2?.setObject(result,
                            forKeyedSubscript: "orc" as NSString)

        let _ = context2?.evaluateScript("""
                orc.printMonster();
            """)
    }

    func error() {
        if let context = JSContext() {

            context.exceptionHandler = { (context, exception) in
                print("JS Error: \(exception?.toString() ?? "No error")")
            }

            context.evaluateScript("nonExistingVariable")

        }
    }

    func runScript() {
//         Getting the script from bundle
        if let javascriptUrl = Bundle.main.url(forResource: "script", withExtension: "js") {
            guard let stringFromUrl = try? String(contentsOf: javascriptUrl) else {return}
            if let context = JSContext() {
//                 evaluating it
                context.evaluateScript(stringFromUrl)

//                Calling a function created there
                let result = context.evaluateScript("createPerson();")
                printFullName(result)
            }

        }
    }
}

extension ContentView {
    func printFullName(_ jsobj: JSValue?){
        guard let obj = jsobj else {return}
        if obj.isObject {
            if obj.hasProperty("name") && obj.hasProperty("lastName"),
               let name = obj.forProperty("name")?.toString(),
               let lastName = obj.forProperty("lastName")?.toString() {
                printOnConsole("Name: \(lastName), \(name)")
            }
        }
    }

    func dictionaryExample(_ value: JSValue) {
        if let dictionary = value.toDictionary() {
            print(dictionary)
        }
    }

    func printOnConsole(_ value: JSValue?){
        consoleOutput += (value?.description ?? "Nil") + "\n"

    }
    func printOnConsole(_ value: String?){
        consoleOutput += (value ?? "Nil") + "\n"

    }
}
