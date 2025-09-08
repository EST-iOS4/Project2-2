//
//  NavioTests.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Navio
import Testing
import ToolBox


// MARK: Tests
@Suite("Navio")
struct NavioTests {
    struct SetUp {
        let navioRef: Navio
        init() async throws {
            self.navioRef = await Navio()
        }
        
        @Test func createHomeBoard() async throws {
            // given
            try await #require(navioRef.homeBoard == nil)
            
            // when
            await navioRef.setUp()
            
            // then
            let homeBoard = try #require(await navioRef.homeBoard)
            await #expect(homeBoard.isExist == true)
        }
        @Test func createMapBoard() async throws {
            // given
            try await #require(navioRef.mapBoard == nil)
            
            // when
            await navioRef.setUp()
            
            // then
            let mapBoard = try #require(await navioRef.mapBoard)
            await #expect(mapBoard.isExist == true)
        }
        @Test func createSetting() async throws {
            // given
            try await #require(navioRef.setting == nil)
            
            // when
            await navioRef.setUp()
            
            // then
            let setting = try #require(await navioRef.setting)
            await #expect(setting.isExist == true)
        }
        
        @Test func whenAlreadySetUp() async throws {
            // given
            await navioRef.setUp()
            
            let oldHomeBoard = try #require(await navioRef.homeBoard)
            let oldMapBoard = try #require(await navioRef.mapBoard)
            let oldSetting = try #require(await navioRef.setting)
            
            // when
            await navioRef.setUp()
            
            // then
            await #expect(navioRef.homeBoard == oldHomeBoard)
            await #expect(navioRef.mapBoard == oldMapBoard)
            await #expect(navioRef.setting == oldSetting)
        }
    }
}
