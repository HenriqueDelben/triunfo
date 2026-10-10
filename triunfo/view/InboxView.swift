//
//  InboxView.swift
//  triunfo
//
//  Created by Henrique Delben on 28/09/26.
//
import SwiftUI
import Foundation


/*
 TODO - configurable list styles for InboxView
 I'm thinking of a canonical "inset", second by "capsule" (inlineGrouped with spacing between rows) and apple notes style "inlineGrouped" basically
 */
struct InboxView: View {
    @Environment(InboxManager.self) private var inboxManager

    var body: some View {
        NavigationStack {
            if inboxManager.entries.isEmpty {
                Text("Inbox is empty")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
                    .navigationTitle("Inbox")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea(.all)
            } else {
                List {
                    ForEach(inboxManager.entries, id: \.self) { entry in
                        withEntry(entry: entry)
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Inbox")
                .navigationSubtitle(inboxManager.entries.isEmpty ? "" : "\(inboxManager.entries.count) entries")
            }
        }
    }

    @ViewBuilder
    private func withEntry(entry: Entry) -> some View {
        let formattedDate = entry.lastUpdatedDate.formatted(.dateTime.day().month(.abbreviated))
        InboxEntryView(
            title: entry.title,
            content: entry.content ?? "",
            formattedDate: formattedDate
        )
    }
}

struct InboxEntryView: View {
    let title: String
    let content: String
    let formattedDate: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if !content.isEmpty {
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            HStack {
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    let store = PreviewStore(entries: [
        Entry(
                title: "Reunião de Alinhamento com Time de Engenharia",
                content: "Discutir arquitetura dos microserviços e migração para Swift 6.",
                lastUpdatedDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 28)) ?? Date()
                ),
                Entry(
                    title: "Artigo: Melhores Práticas de Triage no GTD",
                    content: "Referência importante sobre a regra dos 2 minutos e caixas de incubação.",
                    lastUpdatedDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 28)) ?? Date()
                ),
                Entry(
                    title: "Renovação de Licença de Software de Design",
                    content: "Aprovar pedido de compras e gerar recibo com departamento financeiro.",
                    lastUpdatedDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 28)) ?? Date()
                ),
                Entry(
                    title: "Snippet de Código: Regex para validação de E-mail",
                    content: "Guarde para usar nos formulários de cadastro do checkout.",
                    lastUpdatedDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 25)) ?? Date()
                ),
                Entry(
                    title: "Enviar Declaração Anual de Imposto",
                    content: "Reunir informes de rendimentos bancários e comprovantes de despesas médicas antes do prazo final.",
                    lastUpdatedDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 24)) ?? Date()
                ),
                Entry(
                    title: "Comprar Café em Grãos",
                    content: nil,
                    lastUpdatedDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 20)) ?? Date()
                )
    ])
    let manager = InboxManager(store: store)
    manager.loadEntries()

    return InboxView()
        .environment(manager)
        .preferredColorScheme(.dark)
}

private struct PreviewStore: Store {
    let entries: [Entry]
    func save(capture: String) throws {}
    func load() throws -> [Entry] { entries }
}
