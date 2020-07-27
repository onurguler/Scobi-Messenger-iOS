//
//  APIService.swift
//  Scobi-Messenger-iOS
//
//  Created by Onur Osman Güler on 25.07.2020.
//  Copyright © 2020 Design X. All rights reserved.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    let baseUrl = "http://localhost:8000/api"
    
    public func signIn(with username: String, password: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/accounts/auth/login/") else {
            completion(.failure(APIServiceError.failedToCreateURL))
            return
        }
        
        var request = prepareRequest(with: url, method: "POST", useToken: false, useJSON: true)
        
        do {
            let params = ["username": username, "password": password]
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                if let error = error {
                    print("Failed to login: \(error)")
                    completion(.failure(APIServiceError.failedRequest))
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    completion(.failure(APIServiceError.failedGetResponseData))
                    return
                }
                
                
                let stringData = String(data: data, encoding: .utf8) ?? ""
                
                guard let json = self?.convertJSONStringToDict(text: stringData) else {
                    completion(.failure(APIServiceError.failedConverStringToJSONDict))
                    return
                }
                
                let result: [String: Any] = [
                    "status": response.statusCode,
                    "data": json
                ]
                
                completion(.success(result))
            }.resume()
        } catch {
            print("in catch")
            completion(.failure(APIServiceError.failedParamsSerialization))
        }
    }
    
    public func fetchAuthenticatedUser(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/accounts/auth/") else {
            completion(.failure(APIServiceError.failedToCreateURL))
            return
        }
        
        let request = prepareRequest(with: url, method: "GET", useToken: true, useJSON: false)
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil else {
                if let error = error {
                    print("Failed to get authenticated user: \(error)")
                }
                completion(.failure(APIServiceError.failedRequest))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(APIServiceError.failedGetResponseData))
                return
            }
            
            
            let stringData = String(data: data, encoding: .utf8) ?? ""
            
            guard let json = self?.convertJSONStringToDict(text: stringData) else {
                completion(.failure(APIServiceError.failedConverStringToJSONDict))
                return
            }
            
            let result: [String: Any] = [
                "status": response.statusCode,
                "data": json
            ]
            
            completion(.success(result))
        }.resume()
    }
    
    public func fetchConversations(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/chat/conversations/") else {
            completion(.failure(APIServiceError.failedToCreateURL))
            return
        }
        
        let request = prepareRequest(with: url, method: "GET", useToken: true, useJSON: false)
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil else {
                if let error = error {
                    print("Failed to get authenticated user: \(error)")
                }
                completion(.failure(APIServiceError.failedRequest))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(APIServiceError.failedGetResponseData))
                return
            }
            
            let stringData = String(data: data, encoding: .utf8) ?? ""
            
            guard let json = self?.converJSONArrayStringToDict(text: stringData) else {
                completion(.failure(APIServiceError.failedConverStringToJSONDict))
                return
            }
            
            let result: [String: Any] = [
                "status": response.statusCode,
                "data": json
            ]
            
            completion(.success(result))
        }.resume()
    }
    
}

extension APIService {
    
    private func prepareRequest(with url: URL, method: String, useToken: Bool, useJSON: Bool) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if useToken {
            guard let token = UserDefaults.standard.string(forKey: "token") else {
                return request
            }
            
            request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if useJSON {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        return request
    }
    
    private func convertJSONStringToDict(text: String) -> [String: AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something when wrong to convert string to json dict")
            }
        }
        return nil
    }
    
    private func converJSONArrayStringToDict(text: String) -> [[String: AnyObject]]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [[String:AnyObject]]
                return json
            } catch {
                print("Something when wrong to convert string to json dict")
            }
        }
        return nil
    }
    
    public enum APIServiceError: Error {
        case failedToCreateURL
        case failedRequest
        case failedGetResponseData
        case failedConverStringToJSONDict
        case failedParamsSerialization
    }
    
    struct Conversation {
        var uuid: String
        var displayName: String
        var participants: [Participant]
        var lastMessage: ConversationLastMessage
        var createdAt: String
        var updatedAt: String
    }
    
    struct Participant {
        var uuid: String
        var username: String
        var firstName: String
        var lastName: String
    }
    
    struct ConversationLastMessage {
        var owner: Participant
        var text: String
        var createdAt: String
        var updatedAt: String
    }
}
