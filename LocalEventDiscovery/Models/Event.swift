//
//  Event.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/14/25.
//

import Foundation

struct EventsResponse: Codable {
    let _embedded: EmbeddedEvents
}

struct EmbeddedEvents: Codable {
    let events: [Event]?
}

struct Event: Codable {
    let name: String?
    let type: String?
    let id: String?
    let test: Bool?
    let url: String?
    let locale: String?
    let externalLinks: ExternalLinks?
    let aliases: [String]?
    let images: [EventImage]
    let classifications: [Classification]
    let upcomingEvents: UpcomingEvents?
    let _links: EventLinks
    var isFavourite: Bool = false
    
    enum CodingKeys: String, CodingKey {
            case name, type, id, test, url, locale, externalLinks, aliases, images, classifications, upcomingEvents, _links
            //Letting Swift know only to decode these keys
        }
}

struct ExternalLinks: Codable {
    let twitter: [SocialLink]?
    let facebook: [SocialLink]?
    let wiki: [SocialLink]?
    let instagram: [SocialLink]?
    let homepage: [SocialLink]?
}

struct SocialLink: Codable {
    let url: String
}

struct EventImage: Codable {
    let ratio: String
    let url: String
    let width: Int
    let height: Int
    let fallback: Bool
}

struct Classification: Codable {
    let primary: Bool
    let segment: ClassificationType?
    let genre: ClassificationType?
    let subGenre: ClassificationType?
    let type: ClassificationType?
    let subType: ClassificationType?
    let family: Bool
}

struct ClassificationType: Codable {
    let id: String?
    let name: String?
}

struct UpcomingEvents: Codable {
    let tmr: Int?
    let ticketmaster: Int?
    let _total: Int?
    let _filtered: Int?
}

struct EventLinks: Codable {
    let `self`: Link
}

struct Link: Codable {
    let href: String
}

