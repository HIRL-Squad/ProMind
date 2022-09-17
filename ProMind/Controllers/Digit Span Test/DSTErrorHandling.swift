//
//  DSTErrorHandling.swift
//  ProMind
//
//  Created by HAIKUO YU on 25/4/22.
//

import Foundation

enum BellSoundPlayerError: Error {
    case audioFilePathNotFound
    case audioPlayerError
}

enum GifAnimationError: Error {
    case gifNotFound
    case errorLoadingGifImage
    case avatarImageViewUnexpectedlyReturnsNil
}

enum AVSpeechFullSentenceSpeakerError: Error {
    case failureCreatingAudioSession
    case failureDisablingAudioSession
    case unableToGetNumberOfDigits
}

enum SFSpeechDigitNumberRecognizerError: Error {
    case nilRecognizer
    case notAuthorizedToRecognize
    case notPermittedToRecord
    case recognizerIsUnavailable
    case unableToCreateBufferRecognitionRequestObject
    case nilDigitLabel
}

enum RecognitionTaskError: Error {
    case nilRecognitionTask
}

enum TimerError: Error {
    case illegalTimerCounter
    case nilTestType
}

enum DSTStatisticsError: Error {
    case illegalRoundInfo
    case illegalTestType
    case nilForwardSpanTestData
    case nilBackwardsSpanTestData
    case unableToFetchForwardSpanTestData
    case unableToFetchBackwardsSpanTestData
    case unableToLoadTestData
}
