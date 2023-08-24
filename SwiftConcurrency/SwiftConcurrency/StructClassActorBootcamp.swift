//
//  StructClassActorBootcamp.swift
//  SwiftConcurrency
//
//  Created by Manish Parihar on 22.08.23.
//

import SwiftUI


/*
 -----------------------------------------------------------
// VALUE TYPES:
 - We pass Values
 - Stores in Stack
 - Faster
 - Thread Safe
 - When you assign or pass value type a new copy of data is stored
 - modifying the data does not affects the original
 - Does not require any initialization
 - Does not have inheritance, lightweight, better performance
 - struct, Enum, String, Tuple, struct String, struct Array (Set, Dictionary)
 - objective C (int)
 -----------------------------------------------------------
 
// REFERENCE TYPES:
 - We pass copy of data or References of original instance (its pointed same object in the heap)
 - Stores in Heap
 - Slower than Stack, but synchronized
 - Not thread safe
 - When you assign or pass reference tpye a new reference to original instance will be created (pointer)
 - modifying the data affects the original
 - It requires initialization
 - Class, Funtion, Heap
 
 -----------------------------------------------------------
 STACK:
 - Stored Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast.
 - Each thread has its own stack
 
 HEAP:
 - Stores Reference types
 - Sharad across threads
 -----------------------------------------------------------
 STRUCT:
 - Based on VALUESs
 - Can me mutated
 - Stored in stack
 
 CLASS:
 - Based on REFERENCE (INSTANCESS)
 - Stored in the HEAP
 - Inherit from other classes
 
 ACTORS: (Same as class but THREAD SAFE)
 - Based on REFERENCE (INSTANCESS)
 - Stored in the HEAP
 - Inherit from other classes
 -----------------------------------------------------------
 When to use which one ?
 Struct: Data Models, Views
 Classes: ViewModels
 Actors: Shared 'Manager' and 'Data Store'
 -----------------------------------------------------------

 Example of when to use actor - when you want to access the class with many other instance or from many thread / places
 
 actor MyDataManager {
    func getDataFromDatabase () {
    }
 }
 -----------------------------------------------------------
 
 
 
 
 -----------------------------------------------------------


 
 
 IOS App is running on multithreading
 Every Thread has its own Stack, but all the other code like function or class has common Heap memory thatswhy it is slower than Stack.
 
// What is ARC in Swift (Automatic Reference Counting) - its done automatically in swift
 - Arc is only for the Heap
 - such as Classes and Actors
 - value type which stores in sstack memory such as struct and enums are  not affected by ARC
 - ARC -  to track and manage the app memory usage.
 - If count is greater than 0 then object is in memory otherwise it release from memory.
  
 */

struct StructClassActorBootcamp: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                runTest()
            }
    }
}

struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp()
    }
}

struct MyStruct {
    var title : String
    
    // in struct we dont need to create init its by default take in the form of below line
    //  let objectA = MyStruct(title: "Starting title")
}


extension StructClassActorBootcamp {
    private func runTest() {
        print("Test started!")
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        actorTest1()
        // structTest2()
        
        // classTest2()
    }
    
    private func structTest1() {
        let objectA = MyStruct(title: "Starting title")
        print("Object A:", objectA.title)
        
        print("Pass the Value of objectA to objectB")
        var objectB = objectA
        print("Object B:", objectB.title)
        
        objectB.title = "Second Title"
        print("ObjectB title changed")
        
        print("Object A:", objectA.title)
        print("Object B:", objectB.title)
    }
    
    private func printDivider() {
        print("""
            -----------------------------
        """)
    }
    
    private func classTest1() {
        let objectA = MyClass(title: "Starting title")
        print("Object A:", objectA.title)
        
        print("Pass the Reference of objectA to objectB")
        var objectB = objectA
        print("Object B:", objectB.title)
        
        objectB.title = "Second Title"
        print("Object B:", objectB.title)

        print("Object A:", objectA.title)
        print("Object B:", objectB.title)

    }
    
    private func actorTest1() {
        // without asyn shows error of Actor-isolated property 'title' can not be referenced from a non-isolated context.
        // so we need to make code async
        // Or we can make it with Task {}
        Task {
            let objectA = MyActor(title: "Starting title")
            await print("Object A:", objectA.title)
            
            print("Pass the Reference of objectA to objectB")
            var objectB = objectA
            await print("Object B:", objectB.title)
            
            await objectB.updateTitle(newTitle: "Second Title")
            await print("Object B:", objectB.title)

            await print("Object A:", objectA.title)
            await print("Object B:", objectB.title)
        }

    }
}

// Immutable struct
struct CustomStruct {
    // In immutable struct title original value is not going to change,
    let title : String
    
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

struct MutatingStruct {
    // we can privately set it only inside the struct so we can get it wherever we want
   private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    // when we change the title from let to variable, we need to add mutating - it means we are change complet object not only variable
    mutating func updateTitle(newTitle: String) {
       title =  newTitle
    }
}


extension StructClassActorBootcamp {
    
    private func structTest2 () {
        print("StructTest2")
        // why we need to make var instead of let
        var struct1 = MyStruct(title: "Title1")
        print("Struct1:", struct1.title)
        struct1.title = "Title2"
        print("Struct1:", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2:", struct2.title)
        
        struct2 = CustomStruct(title: "Title2")
        print("Struct2:", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3:", struct3.title)
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("Struct3:", struct3.title)

        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4:", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4:", struct4.title)

    }
}


class MyClass {
    
    var title: String
    
    // in class we have to create init
    init(title: String) {
        self.title = title
    }
    
    
    func updateTitle(newTitle: String) {
       title =  newTitle
    }
}

extension StructClassActorBootcamp {
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title2")
        print("Class2: ", class2.title)
        class2.updateTitle(newTitle: "Title2")
        print("Class2: ", class2.title)
    }
}

// Instead of class we created actor, more like similar concept
actor MyActor {
    
    var title: String
    
    // in class we have to create init
    init(title: String) {
        self.title = title
    }
    
    
    func updateTitle(newTitle: String) {
       title =  newTitle
    }
}
