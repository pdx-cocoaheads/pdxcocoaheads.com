//
//  Topic.swift
//  pdxcocoaheads.com
//
//  Created by Ryan Arana on 7/27/16.
//
//

import Foundation

struct Topic: ModelType {
    let id: Int?
    let title: String
    let description: String
    let submitter: String
    let submissionDate: Date
    let votes: UInt
    let presenter: String?
    let presentationDate: Date?
    let approved: Bool
}
