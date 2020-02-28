import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
   
    static func page(for page: Page, on site: Blog) -> Node {
        return .pageContent(
            .h2(
                .class("post-title"),
                .text(page.title)
            ),
            .div(
                .class("post-description"),
                .div(
                    .contentBody(page.body)
                )
            )
        )
    }
}

