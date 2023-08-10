//
//  TestFlightUpdateReminder.swift
//  ProMind
//
//  Created by HAIKUO YU on 5/8/23.
//

import Foundation
import AppStoreConnect_Swift_SDK


class TestFlightUpdateReminder {
    private let appleId: String
    
    init(appleId: String) {
        self.appleId = appleId
    }
    
    private func getConfigurationForProMind() -> APIConfiguration? {
        do {
            return try APIConfiguration(issuerID: "563ee51a-b3fc-483d-b980-09a1eadd3d84", privateKeyID: "737ZL8KK3W", privateKey: "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgIlz7Dk+3Wwz7hQuQubsub0f3kTdP9m3Z3KyxfQJbfvygCgYIKoZIzj0DAQehRANCAAQhWQSNM50pF5WzE/EQyOqRWmvfh7MYZQLlWhgBf/uoP5SwBZXXbi6E9iJ52ogMS0pmU4DaAcHHtnIv0EsbPCOf")
        } catch let error {
            print("Error happended when generating APIConfiguration!")
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func fetchAllPreReleaseVersion() async -> [PreReleaseVersion]? {
        guard let configuration = getConfigurationForProMind() else {
            return nil
        }
        
        let request = APIEndpoint
            .v1
            .preReleaseVersions
            .get(parameters: .init(
                filterPlatform: [.ios],
                filterApp: [appleId],
                sort: [.version],
                limit: 10,
                include: [.app, .builds]
                // fieldsPreReleaseVersions: [.builds, .app, .version],
                // fieldsApps: [.appInfos, .name, .bundleID, .builds]
                // fieldsBuilds: [.app]
            ))
        lazy var provider: APIProvider = APIProvider(configuration: configuration)
        
        do {
            let records = try await provider.request(request).data
            print("Successfully fetched \(records.count) preReleaseVersion records for ProMind!")
            return records
        } catch let error {
            print("Error happened when fetching AppStore Connect API request for preReleaseVersion!")
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func getLatestLocalAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public func getLatestLocalBuildNumber() -> String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    public func getLatestTestFlightAppVersion(preReleaseVersions: [PreReleaseVersion]) -> String? {
        return preReleaseVersions.last?.attributes?.version
    }
    
    public func getLatestTestFlightBuildNumber(preReleaseVersions: [PreReleaseVersion]) -> String? {
        if let buildNumber = preReleaseVersions.last?.relationships?.builds?.meta?.paging.total {
            return String(buildNumber)
        } else {
            return nil
        }
    }
    
    public func localAppVersionIsLatest(preReleaseVersions: [PreReleaseVersion]) -> Bool {
        let localAppVersion = getLatestLocalAppVersion() ?? "0.0.0"
        let testFlightAppVersion = getLatestTestFlightAppVersion(preReleaseVersions: preReleaseVersions) ?? "0.0.0"
        return localAppVersion.compare(testFlightAppVersion, options: .numeric) == .orderedDescending || localAppVersion.compare(testFlightAppVersion, options: .numeric) == .orderedSame
    }
    
    public func localBuildNumberIsLatest(preReleaseVersions: [PreReleaseVersion]) -> Bool {
        let localBuildNumber = Int(getLatestLocalBuildNumber() ?? "0") ?? 0
        let testFlightBuildNumber = Int(getLatestTestFlightBuildNumber(preReleaseVersions: preReleaseVersions) ?? "0") ?? 0
        return localBuildNumber >= testFlightBuildNumber
    }
    
    public func localAppIsLatest(preReleaseVersions: [PreReleaseVersion]) -> Bool {
        if localAppVersionIsLatest(preReleaseVersions: preReleaseVersions) {
            return localBuildNumberIsLatest(preReleaseVersions: preReleaseVersions)
        } else {
            return false
        }
    }
    
    public func printAllInformation(preReleaseVersions: [PreReleaseVersion]) {
        let localAppVersion = getLatestLocalAppVersion() ?? "No Data"
        let testFlightAppVersion = getLatestTestFlightAppVersion(preReleaseVersions: preReleaseVersions) ?? "No Data"
        let localBuildNumber = getLatestLocalBuildNumber() ?? "No Data"
        let testFlightBuildNumber = getLatestTestFlightBuildNumber(preReleaseVersions: preReleaseVersions) ?? "No Data"
        
        print("------ TestFlight Update Reminder ------")
        print("Local App Version: \(localAppVersion)")
        print("TestFlight App Version: \(testFlightAppVersion)")
        print("Local Build Number: \(localBuildNumber)")
        print("TestFlight Build Number: \(testFlightBuildNumber)\n")
        print("Local App Version Is Latest: \(localAppVersionIsLatest(preReleaseVersions: preReleaseVersions))")
        print("Local Build Number Is Latest: \(localBuildNumberIsLatest(preReleaseVersions: preReleaseVersions))")
        print("Local App Is Latest: \(localAppIsLatest(preReleaseVersions: preReleaseVersions))\n")
        
//        print("Printing PreReleaseVersions...")
//        for preReleaseVersion in preReleaseVersions {
//            print(preReleaseVersion)
//            print()
//        }
    }
    
    private func convertOptionalNumberToString(number: Int) -> String {
        if number == 0 {
            return "No Data"
        } else {
            return String(number)
        }
    }
}
