//
//  NetworkManager.swift
//  election-app-template
//
//  Created by Kate Halushka on 3/27/20.
//

import Foundation
import Alamofire

class NetworkManager {
    //replace YOUR_API_KEY with your api key from airtable
    let headers: HTTPHeaders = ["Authorization": "Bearer YOUR_API_KEY"]
    //replace YOUR_BASE_ID with the URL ending provided by airtable
    let baseURL = "https://api.airtable.com/v0/YOUR_BASE_ID/"
    var records: [Record] = []
    var votingID: String = ""
    var names: [String] = []
    var position = 0
    
    func getCandidates() {
        let url = baseURL + "Positions?view=Positions"
        request(url, method: .get, headers: headers).responseJSON { response in
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(Response.self, from: response.data!)
                self.records.append(contentsOf: decodedData.records)
                self.fetchCandidateNames(ids: self.records[self.position].fields.Candidates)
                return
            } catch {
                print(error)
                return
            }
        }
    }

    //Create a dispatch queue
    let dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)

    //Create a semaphore
    let semaphore = DispatchSemaphore(value: 0)
    
    func fetchCandidateNames(ids: [String]?) {
        if ids == nil {
            return
        }
        dispatchQueue.async {
            for id in ids! {
                let url = self.baseURL + "Candidates/\(id)"
                request(url, method: .get, headers: self.headers).responseJSON { response in
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(Record.self, from: response.data!)
                        self.names.append(decodedData.fields.Name!)
                        // Signals that the 'current' API request has completed
                        self.semaphore.signal()
                        return
                    } catch {
                        print(error)
                        return
                    }
                }
                // Wait until the previous API request completes
                self.semaphore.wait()
            }
        }
    }
    
    func castVote(with id: String, and position: String) {
        let url = baseURL + "Voting"
        var request = URLRequest(url: URL(string: url)!)
        let body = "{\"fields\": {\"Position\": \"\(position)\",\"VotingID\": \"\(votingID)\",\"Candidate\": [\"\(id)\"]}}"
        let data = body.data(using: .utf8)! as Data
        request.httpBody = data
        request.httpMethod = HTTPMethod.post.rawValue
        //replace YOUR_API_KEY with the same api key from before
        request.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(request)
        names = []
    }

}
