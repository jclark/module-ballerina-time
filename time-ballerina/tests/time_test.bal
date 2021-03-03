// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

@test:Config {}
function testUtcNow() {
    Utc|Error oldUtc = utcFromString("2007-12-03T10:15:30.00Z");
    Utc currentUtc = utcNow();
    if(oldUtc is Utc) {
        test:assertTrue(currentUtc[0] > oldUtc[0]);
    } else {
        test:assertFail(msg = oldUtc.message());
    }
}

@test:Config {}
function testUtcNowWithPrecision() {
    Utc currentUtc1 = utcNow();
    // length(str(0.123456789)) => 11
    test:assertEquals(currentUtc1[1].toString().length(), 11);

    Utc currentUtc2 = utcNow(6);
    // length(str(0.123456)) => 8
    test:assertEquals(currentUtc2[1].toString().length(), 8);

    Utc currentUtc3 = utcNow(3);
    // length(str(0.123)) => 5
    test:assertEquals(currentUtc3[1].toString().length(), 5);
}

@test:Config {}
function testMonotonicNow() {
    Seconds time1 = monotonicNow();
    Seconds time2 = monotonicNow();
    test:assertTrue(time2 >= time1);
}

@test:Config {}
function testUtcFromString() {
    Utc|Error utc = utcFromString("2007-12-03T10:15:30.00Z");
    if(utc is Utc) {
        test:assertEquals(utc[0], 1196676930);
        test:assertEquals(utc[1], <decimal>0.0);
    } else {
        test:assertFail(msg = utc.message());
    }
}

@test:Config {}
function testUtcFromStringWithInvalidFormat() {
    Utc|Error utc = utcFromString("2007-12-0310:15:30.00Z");
    if(utc is Utc) {
        test:assertFail("Expected time:Error not found");
    } else {
        test:assertEquals(utc.message(), "Provided '2007-12-0310:15:30.00Z' is not adhere to the expected format '2007-12-03T10:15:30.00Z'");
    }
}

@test:Config {}
function testUtcToString() {
    Utc|Error utc = utcFromString("1985-04-12T23:20:50.520Z");
    int expectedSecondsFromEpoch = 482196050;
    decimal expectedSecondFraction = 0.52;
    if(utc is Utc) {
        test:assertEquals(utc[0], expectedSecondsFromEpoch);
        test:assertEquals(utc[1], expectedSecondFraction);
        string utcString = utcToString(utc);
        test:assertEquals(utcString, "1985-04-12T23:20:50.520Z");
    } else {
        test:assertFail(msg = utc.message());
    }
}

@test:Config {}
function testUtcAddSeconds() {
    Utc|Error utc1 = utcFromString("2021-04-12T23:20:50.520Z");
    if(utc1 is Utc) {
        Utc utc2 = utcAddSeconds(utc1, 20.900);
        string utcString = utcToString(utc2);
        test:assertEquals(utcString, "2021-04-12T23:21:11.420Z");
    } else {
        test:assertFail(msg = utc1.message());
    }
}


@test:Config {}
function testUtcDiffSeconds() {
    Utc|Error utc1 = utcFromString("2021-04-12T23:20:50.520Z");
    Utc|Error utc2 = utcFromString("2021-04-11T23:20:50.520Z");
    decimal expectedSeconds1 = 86400;
    if(utc1 is Utc && utc2 is Utc) {
        test:assertEquals(utcDiffSeconds(utc1, utc2), expectedSeconds1);
    } else if (utc1 is Error){
        test:assertFail(msg = utc1.message());
    } else if (utc2 is Error){
        test:assertFail(msg = utc2.message());
    } else {
        test:assertFail("Unknown error");
    }

    Utc|Error utc3 = utcFromString("2021-04-12T23:20:50.520Z");
    Utc|Error utc4 = utcFromString("2021-04-11T23:20:55.640Z");
    decimal expectedSeconds2 = 86394.88;
    if(utc3 is Utc && utc4 is Utc) {
        test:assertEquals(utcDiffSeconds(utc3, utc4), expectedSeconds2);
    } else if (utc3 is Error){
        test:assertFail(msg = utc3.message());
    } else if (utc4 is Error){
        test:assertFail(msg = utc4.message());
    } else {
        test:assertFail("Unknown error");
    }

    Utc|Error utc5 = utcFromString("2021-04-12T23:20:50.520Z");
    Utc|Error utc6 = utcFromString("2021-04-11T23:20:55.640Z");
    decimal expectedSecond3 = -86394.88;
    if(utc5 is Utc && utc6 is Utc) {
        test:assertEquals(utcDiffSeconds(utc6, utc5), expectedSecond3);
    } else if (utc5 is Error){
        test:assertFail(msg = utc5.message());
    } else if (utc6 is Error){
        test:assertFail(msg = utc6.message());
    } else {
        test:assertFail("Unknown error");
    }
}

@test:Config {}
function testDateValidateUsingValidDate() {
    Date date = {year: 1994, month: 11, day: 7};
    Error? err = dateValidate(date);
    if(err is Error) {
        test:assertFail(msg = err.message());
    }
}

@test:Config {}
function testDateValidateUsingInvalidDate() {
    // Invalid number of days for a leap year
    Date date1 = {year: 1994, month: 2, day: 29};
    Error? err1 = dateValidate(date1);
    if(err1 is Error) {
        test:assertEquals(err1.message(), "Invalid date 'February 29' as '1994' is not a leap year");
    } else {
        test:assertFail("Expected error not found");
    }

    // Out of range month
    Date date2 = {year: 1994, month: 50, day: 10};
    Error? err2 = dateValidate(date2);
    if(err2 is Error) {
        test:assertEquals(err2.message(), "Invalid value for MonthOfYear (valid values 1 - 12): 50");
    } else {
        test:assertFail("Expected error not found");
    }

    // Out of range day
    Date date3 = {year: 1994, month: 4, day: 60};
    Error? err3 = dateValidate(date3);
    if(err3 is Error) {
        test:assertEquals(err3.message(), "Invalid value for DayOfMonth (valid values 1 - 28/31): 60");
    } else {
        test:assertFail("Expected error not found");
    }
}

@test:Config {}
function testDayOfWeekUsingValidDate() {
    Date date = {year: 1994, month: 11, day: 7};
    test:assertEquals(dayOfWeek(date), MONDAY);
}

@test:Config {}
function testDayOfWeekUsingInvalidDate() {
    Date date = {year: 1994, month: 2, day: 29};
    DayOfWeek|error err = trap dayOfWeek(date);
    if(err is Error) {
        test:assertEquals(err.message(), "Invalid date 'February 29' as '1994' is not a leap year");
    } else {
        test:assertFail("Expected panic did not occur");
    }
}


