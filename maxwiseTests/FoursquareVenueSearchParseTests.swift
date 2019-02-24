//
//  FoursquareVenueSearchParseTests.swift
//  maxwiseTests
//
//  Created by Mindaugas Jucius on 2/24/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import XCTest
@testable import maxwise

class FoursquareVenueSearchParseTests: XCTestCase {
    
    private let fullResultString = "{\"meta\":{\"code\":200,\"requestId\":\"5c7275511ed2196e46cb700d\"},\"response\":{\"venues\":[{\"id\":\"4d05d93830a58cfaf4a4a7e7\",\"name\":\"SEB\",\"contact\":{},\"location\":{\"address\":\"J.Balčikonio 3\",\"lat\":54.719569420915,\"lng\":25.28566446120864,\"labeledLatLngs\":[{\"label\":\"display\",\"lat\":54.719569420915,\"lng\":25.28566446120864}],\"distance\":108,\"postalCode\":\"07004\",\"cc\":\"LT\",\"city\":\"Vilnius\",\"state\":\"Vilnius County\",\"country\":\"Lithuania\",\"formattedAddress\":[\"J.Balčikonio 3\",\"07004 Vilnius\",\"Lithuania\"]},\"categories\":[{\"id\":\"4bf58dd8d48988d10a951735\",\"name\":\"Bank\",\"pluralName\":\"Banks\",\"shortName\":\"Bank\",\"icon\":{\"prefix\":\"https:\\/\\/ss3.4sqi.net\\/img\\/categories_v2\\/shops\\/financial_\",\"suffix\":\".png\"},\"primary\":true}],\"verified\":false,\"stats\":{\"tipCount\":0,\"usersCount\":0,\"checkinsCount\":0,\"visitsCount\":0},\"beenHere\":{\"count\":0,\"lastCheckinExpiredAt\":0,\"marked\":false,\"unconfirmedCount\":0},\"hereNow\":{\"count\":0,\"summary\":\"Nobody here\",\"groups\":[]},\"referralId\":\"v-1551005009\",\"venueChains\":[],\"hasPerk\":false}],\"confident\":true}}"
    
    func testParsesFullVenueResult() {
        parse(string: fullResultString)
    }
    
    private let noLocationResultString = "{\"meta\":{\"code\":200,\"requestId\":\"5c7275511ed2196e46cb700d\"},\"response\":{\"venues\":[{\"id\":\"4d05d93830a58cfaf4a4a7e7\",\"name\":\"SEB\",\"contact\":{},\"location\":{},\"categories\":[{\"id\":\"4bf58dd8d48988d10a951735\",\"name\":\"Bank\",\"pluralName\":\"Banks\",\"shortName\":\"Bank\",\"icon\":{\"prefix\":\"https:\\/\\/ss3.4sqi.net\\/img\\/categories_v2\\/shops\\/financial_\",\"suffix\":\".png\"},\"primary\":true}],\"verified\":false,\"stats\":{\"tipCount\":0,\"usersCount\":0,\"checkinsCount\":0,\"visitsCount\":0},\"beenHere\":{\"count\":0,\"lastCheckinExpiredAt\":0,\"marked\":false,\"unconfirmedCount\":0},\"hereNow\":{\"count\":0,\"summary\":\"Nobody here\",\"groups\":[]},\"referralId\":\"v-1551005009\",\"venueChains\":[],\"hasPerk\":false}],\"confident\":true}}"
 
    func testParsesVenueResultNoLocation() {
        parse(string: noLocationResultString)
    }
    
    private let noCategoryResultString = "{\"meta\":{\"code\":200,\"requestId\":\"5c7275511ed2196e46cb700d\"},\"response\":{\"venues\":[{\"id\":\"4d05d93830a58cfaf4a4a7e7\",\"name\":\"SEB\",\"contact\":{},\"location\":{},\"categories\":[],\"verified\":false,\"stats\":{\"tipCount\":0,\"usersCount\":0,\"checkinsCount\":0,\"visitsCount\":0},\"beenHere\":{\"count\":0,\"lastCheckinExpiredAt\":0,\"marked\":false,\"unconfirmedCount\":0},\"hereNow\":{\"count\":0,\"summary\":\"Nobody here\",\"groups\":[]},\"referralId\":\"v-1551005009\",\"venueChains\":[],\"hasPerk\":false}],\"confident\":true}}"
    
    func testParsesVenueResultNoCategory() {
        parse(string: noCategoryResultString)
    }
    
    func parse(string: String) {
        guard let resultData = string.data(using: .utf8) else {
            XCTFail("failed to get data")
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let _ = try decoder.decode(VenuesSearch.self, from: resultData)
            XCTAssert(true)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
