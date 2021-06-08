//
//  ContentView.swift
//  SwiftNotes
//
//  Created by Smital on 08/06/21.
//
//

import SwiftUI

struct ContentView: View {
    @State var items: [NoteItem] = {
        guard let data = UserDefaults.standard.data(forKey: "notes") else {
            return []
        }
        if let json = try? JSONDecoder().decode([NoteItem].self, from: data) {
            return json
        }
        return []
    }()

    @State private var notesText: String = ""
    @State private var showAlert: Bool = false
    @State var noteToDelete: NoteItem?

    var body: some View {
        VStack {
            HStack {
                TextField("Write a note ...", text: $notesText)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .clipped()
                Button(action: didTapAddTask, label: { Text("Add") }).padding(8)
            }

            List {
                ForEach(items, id: \.self) { item in
                    VStack(alignment: .leading) {
                        Text(item.dateText).font(.headline)
                        Text(item.text).lineLimit(nil).multilineTextAlignment(.leading)
                    }.onLongPressGesture {
                        noteToDelete = item
                        showAlert = true
                    }
                }
            }
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Hey!"),
                    message: Text("Are you sure you want to delete this item?"),
                    primaryButton: .destructive(Text("Delete"), action: deleteNote),
                    secondaryButton: .cancel())
        }
    }

    func didTapAddTask() {
       let id = items.reduce(0) { (result: Int, item: NoteItem) in
           max(result, item.id)
       } + 1

       items.insert(NoteItem(id: id, text: notesText), at: 0)
       notesText = ""
       save()
    }

    func deleteNote() {
        guard let noteToDelete = noteToDelete else {
            return
        }
        items = items.filter { item in item != noteToDelete }
        save()
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: "notes")
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
