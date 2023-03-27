//
//  SubtitleRow.swift
//  
//
//  Created by Alsey Coleman Miller on 3/26/23.
//

import Foundation
import SwiftUI

internal struct SubtitleRow: View {
    
    let title: Text
    
    let subtitle: Text?
    
    init(title: Text, subtitle: Text? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    static func verbatim(title: String, subtitle: String? = nil) -> some View {
        SubtitleRow(
            title: Text(verbatim: title),
            subtitle: subtitle.flatMap { Text(verbatim: $0) }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            title
            if let subtitle = subtitle {
                subtitle
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#if DEBUG
struct SubtitleRow_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            SubtitleRow.verbatim(
                title: "MPPSolar"
            )
            SubtitleRow.verbatim(
                title: "Accessory",
                subtitle: "Solar Panel"
            )
            SubtitleRow.verbatim(
                title: "Service",
                subtitle: "Solar Panel"
            )
            SubtitleRow.verbatim(
                title: "180A",
                subtitle: "Device Information"
            )
        }
    }
}
#endif
