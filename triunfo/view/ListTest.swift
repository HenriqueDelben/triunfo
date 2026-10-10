//
//  ListTest.swift
//  triunfo
//
//  Created by Henrique Delben on 08/10/26.
//
import SwiftUI


struct Ocean: Identifiable, Hashable {
    let name: String
    let id = UUID()
    let stats: [String: String]
    var fixed: Bool = false
 }


 @Observable class OceanStore {
     var oceans: [Ocean] = [
         Ocean(name: "Atlantic", stats: [:]),
         Ocean(name: "Indian", stats: [:]),
         Ocean(name: "Pacific", stats: [:], fixed: true)
     ]
     func loadStats() async {
         // Load statistics asynchronously.
     }
 }


struct MyList: View {
    @State private var store: OceanStore = OceanStore()
    @State private var selection: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List(store.oceans) { ocean in
                HStack {
                    Text(ocean.name)
                    Text("something else")
                }
            }
            .refreshable {
                await store.loadStats()
            }
            .toolbar {
                EditButton()
            }
            .navigationTitle("Oceans")
        }
    }
}
// lista com onMove()
struct MyListWithForEach: View {
    @State private var store: OceanStore = OceanStore()
    @State private var selection: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List() {
                ForEach(store.oceans, id: \.self) { ocean in
                    HStack {
                        Text(ocean.name)
                        Text("something else")
                    }.moveDisabled(ocean.fixed)
                }
                .onDelete { indexSet in
                    store.oceans.remove(atOffsets: indexSet)
                }
                .onMove { from, to in
                    store.oceans.move(fromOffsets: from, toOffset: to)
                }
            }
            .refreshable {
                await store.loadStats()
            }
            .toolbar {
                EditButton()
            }
            .navigationTitle("Oceans")
        }
    }
}

struct MyForEach: View {
    @State private var store: OceanStore = OceanStore()
    @State private var selection: Set<UUID> = []
    var body: some View {
        NavigationStack {
            ForEach(store.oceans, id: \.self) { ocean in
                HStack {
                    Text(ocean.name)
                    Text("something else")
                }.moveDisabled(ocean.fixed)
            }
            .onDelete { indexSet in
                store.oceans.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                store.oceans.move(fromOffsets: from, toOffset: to)
            }
            .toolbar {
                EditButton()
            }
        }
        .navigationTitle("ForEach")
    }
}

#Preview {
    MyForEach()
}
