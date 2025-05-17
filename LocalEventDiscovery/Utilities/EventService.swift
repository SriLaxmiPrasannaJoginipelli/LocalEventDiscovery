
//
//  EventService.swift
//  LocalEventDiscovery
//
//  Created by Srilu Rao on 5/14/25.
//

import Foundation

final class EventService {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchEvents(from urlString: String, completion: @escaping (Result<EventsResponse, Error>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
        }.resume()
    }
    
}
