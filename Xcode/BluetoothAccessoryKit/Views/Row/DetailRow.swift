//
//  DetailRow.swift
//
//
//  Created by Alsey Coleman Miller on 9/24/23.
//

import Foundation
import SwiftUI

internal struct DetailRow <Detail: View>: View {
    
    let title: Text
    
    let detail: Detail
    
    init(title: Text, detail: Detail) {
        self.title = title
        self.detail = detail
    }
    
    init(title: LocalizedStringKey, detail: Detail) {
        self.title = Text(title)
        self.detail = detail
    }
    
    static func verbatim(title: String, detail: String) -> DetailRow<Text> {
        DetailRow<Text>(
            title: Text(verbatim: title),
            detail: Text(verbatim: detail)
        )
    }
    
    var body: some View {
        HStack(spacing: 8) {
            title
            Spacer()
            detail
        }
    }
}

#if DEBUG
struct DetailRow_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            DetailRow(
                title: Text("MPPSolar"),
                detail: EmptyView()
            )
            DetailRow<Text>.verbatim(
                title: "Accessory",
                detail: "Solar Panel"
            )
            DetailRow<Text>.verbatim(
                title: "Service",
                detail: "Solar Panel"
            )
            DetailRow<Text>.verbatim(
                title: "180A",
                detail: "Device Information"
            )
        }
    }
}
#endif
