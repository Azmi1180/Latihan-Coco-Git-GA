//
//  ActivityVerificationService.swift
//  Coco
//
//  Created by Azmi on 26/08/25.
//

import Foundation

protocol ActivityVerificationServiceProtocol {
    func isActivityVerified(activityId: Int) async -> Bool
    func getActivityTags(activityId: Int) async -> [Tag]
    func getVerifiedProviderTag() async -> Tag?
    func getWhatsIncludedData(activityId: Int) async -> ActivityDetailDataModel.WhatsIncluded
}

final class ActivityVerificationService: ActivityVerificationServiceProtocol {
    private let tagFetcher: TagFetcherProtocol
    private var cachedFirebaseData: FirebaseData?
    
    init(tagFetcher: TagFetcherProtocol = TagFetcher()) {
        self.tagFetcher = tagFetcher
    }
    
    private func getFirebaseData() async -> FirebaseData? {
        if let cachedData = cachedFirebaseData {
            return cachedData
        }
        
        do {
            let data = try await tagFetcher.fetchFirebaseData()
            cachedFirebaseData = data
            return data
        } catch {
            print("Error fetching Firebase data: \(error)")
            return nil
        }
    }
    
    func isActivityVerified(activityId: Int) async -> Bool {
        guard let firebaseData = await getFirebaseData() else {
            return false
        }
        
        // Get tag activities for this activity
        let activityTags = firebaseData.tagActivities.filter { $0.activityID == activityId }
        
        // Get the "Verified Provider" tag (id: 1 based on the hierarchy you provided)
        let verifiedProviderTagId = 1
        
        // Check if this activity has the verified provider tag
        return activityTags.contains { $0.tagID == verifiedProviderTagId }
    }
    
    func getActivityTags(activityId: Int) async -> [Tag] {
        guard let firebaseData = await getFirebaseData() else {
            return []
        }
        
        // Get tag activities for this activity
        let activityTagIds = firebaseData.tagActivities
            .filter { $0.activityID == activityId }
            .map { $0.tagID }
        
        // Get the actual tags
        return firebaseData.tag.filter { tag in
            guard let tagId = tag.id else { return false }
            return activityTagIds.contains(tagId)
        }
    }
    
    func getVerifiedProviderTag() async -> Tag? {
        guard let firebaseData = await getFirebaseData() else {
            return nil
        }
        
        // Return the "Verified Provider" tag (id: 1)
        return firebaseData.tag.first { $0.id == 1 }
    }
    
    func getWhatsIncludedData(activityId: Int) async -> ActivityDetailDataModel.WhatsIncluded {
        guard let firebaseData = await getFirebaseData() else {
            // Return default data if Firebase is not available
            return ActivityDetailDataModel.WhatsIncluded(
                providerAndSafety: ["Verified Provider", "Certified Guide", "First Aid Ready"],
                equipment: ["All Size Available"],
                services: ["Free food and Drinks", "Island Leisure"],
                guideLanguage: ["Bahasa Indonesia"]
            )
        }
        
        // Get activity tags
        let activityTags = await getActivityTags(activityId: activityId)
        
        // If no tags found, return default data
        if activityTags.isEmpty {
            return ActivityDetailDataModel.WhatsIncluded(
                providerAndSafety: ["Verified Provider", "Certified Guide", "First Aid Ready"],
                equipment: ["All Size Available"],
                services: ["Free food and Drinks", "Island Leisure"],
                guideLanguage: ["Bahasa Indonesia"]
            )
        }
        
        // Categorize tags based on tag_category_id
        var providerAndSafety: [String] = []
        var equipment: [String] = []
        var services: [String] = []
        var guideLanguage: [String] = []
        
        for tag in activityTags {
            guard let categoryId = tag.tagCategoryID else { continue }
            
            switch categoryId {
            case 1: // Provider & Safety
                providerAndSafety.append(tag.name)
            case 2: // Services
                services.append(tag.name)
            case 3: // Equipment
                equipment.append(tag.name)
            case 4: // Trip Guide Language
                guideLanguage.append(tag.name)
            case 5: // Badges - could be added to provider & safety or as separate section
                providerAndSafety.append(tag.name)
            default:
                break
            }
        }
        
        // Ensure we have at least some default content if categories are empty
        if providerAndSafety.isEmpty {
            providerAndSafety = ["Provider Available"]
        }
        if guideLanguage.isEmpty {
            guideLanguage = ["Guide Available"]
        }
        
        return ActivityDetailDataModel.WhatsIncluded(
            providerAndSafety: providerAndSafety,
            equipment: equipment,
            services: services,
            guideLanguage: guideLanguage
        )
    }
}
