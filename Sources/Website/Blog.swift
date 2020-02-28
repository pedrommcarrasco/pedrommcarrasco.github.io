import Foundation
import Publish
import Plot

struct Blog: Website {
    
    enum SectionID: String, WebsiteSectionID {
        case posts
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        var excerpt: String
    }

    let url = URL(string: "https://pedrommcarrasco.github.io")!
    var title = "staskus.io"
    let name = "Pedro Carrasco"
    let description = "iOS Engineer"
    let language: Language = .english
    let imagePath: Path? = nil
    let socialMediaLinks = [SocialLink.email, .linkedIn, .github, .twitter]
}
