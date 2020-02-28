//
//  File.swift
//  
//
//  Created by Pedro Carrasco on 28/02/2020.
//

import Foundation

struct SocialLink {
    let title: String
    let url: String
    let icon: String
}

extension SocialLink {

    static var linkedIn: SocialLink {
        .init(
            title: "LinkedIn",
            url: "https://www.linkedin.com/in/pedrommcarrasco/",
            icon: "fab fa-linkedin"
        )
    }
    
    static var email: SocialLink {
        .init(
            title: "Email",
            url: "mailto:pedrommcarrasco@gmail.com",
            icon: "fas fa-envelope-open-text"
        )
    }
    
    static var github: SocialLink {
        .init(
            title: "GitHub",
            url: "https://github.com/pedrommcarrasco",
            icon: "fab fa-github-square"
        )
    }
    
    static var twitter: SocialLink {
        .init(
            title: "Twitter",
            url: "https://twitter.com/pedrommcarrasco",
            icon: "fab fa-twitter-square"
        )
    }
}
