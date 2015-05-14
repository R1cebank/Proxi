//
//  ModelTests.swift
//  Proxi
//
//  Created by Siyuan Gao on 5/8/15.
//  Copyright (c) 2015 Siyuan Gao. All rights reserved.
//

import Foundation
import Quick
import Nimble

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("the 'Documentation' directory") {
            it("has everything you need to get started") {
                expect(1).to(equal(1))
            }
            
            context("if it doesn't have what you're looking for") {
                it("needs to be updated") {
                    expect(1).to(equal(0))
                }
            }
        }
    }
}