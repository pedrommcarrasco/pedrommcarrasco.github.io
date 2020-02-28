import Publish
import Plot

extension Node where Context == HTML.BodyContext {
   
    static func pageContent(_ nodes: Node...) -> Node {
        return .div(
            .class("content pure-u-1 pure-u-md-3-5 pure-u-xl-6-10"),
            .group(nodes)
        )
    }
}
