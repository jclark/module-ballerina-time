// Copyright (c) 2017 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/jballerina.java;

public type Seconds decimal;
public type Utc readonly & [int, decimal];
public type Date record {
  // year 1 means AD 1
  // year 0 means 1 BC
  // year -1 means 2 BC
  int year;
  # month 1 is January, as in ISO 8601
  int month;
  # day 1 is first day of month
  int day;
};

public const int SUNDAY = 0;
public const int MONDAY = 1;
public const int TUESDAY = 2;
public const int WEDNESDAY = 3;
public const int THURSDAY = 4;
public const int FRIDAY = 5;
public const int SATURDAY = 6;

public type DayOfWeek SUNDAY|MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY;


public function utcNow(int? precision = ()) returns Utc {
    int precisionValue = -1;
    if (precision is int) {
        precisionValue = precision;
    }
    [int, Seconds] currentUtc = externUtcNow(precisionValue);
    return <Utc>currentUtc.cloneReadOnly();
}

public function monotonicNow() returns Seconds {
    return externMonotonicNow();
}

public function utcFromString(string str) returns Utc|Error {
    [int, Seconds]|Error utc = externUtcFromString(str);
    if (utc is [int, Seconds]) {
        return <Utc>utc.cloneReadOnly();
    } else {
         return utc;
    }
}

public function utcToString(Utc utc) returns string {
    return externUtcToString(utc);
}

public function utcAddSeconds(Utc utc, Seconds seconds) returns Utc {
    int secondsFromEpoch = utc[0];
    decimal lastSecondFraction = utc[1];

    secondsFromEpoch = secondsFromEpoch + <int>seconds.floor();
    lastSecondFraction = lastSecondFraction + (seconds - seconds.floor());
    if (lastSecondFraction >= 1) {
        secondsFromEpoch = secondsFromEpoch + <int>lastSecondFraction.floor();
        lastSecondFraction = lastSecondFraction - lastSecondFraction.floor();
    }
    return <Utc>([secondsFromEpoch, lastSecondFraction].cloneReadOnly());
}

public function utcDiffSeconds(Utc utc1, Utc utc2) returns Seconds {
    return externUtcDiffSeconds(utc1, utc2);
}

public function dateValidate(Date date) returns Error? {
    return externDateValidate(date);
}

public function dayOfWeek(Date date) returns DayOfWeek {
    int|Error dayNo = externDayOfWeek(date);
    if (dayNo is int) {
        match dayNo {
            0 => {
                return SUNDAY;
            }
            1 => {
                return MONDAY;
            }
            2 => {
                return TUESDAY;
            }
            3 => {
                return WEDNESDAY;
            }
            4 => {
                return THURSDAY;
            }
            5 => {
                return FRIDAY;
            }
            6 => {
                return SATURDAY;
            }
        }
    }
    panic <Error>dayNo;
}


function externUtcNow(int precision) returns [int, decimal] = @java:Method {
    name: "externUtcNow",
    'class: "org.ballerinalang.stdlib.time.nativeimpl.ExternMethods"
} external;

function externMonotonicNow() returns Seconds = @java:Method {
    name: "externMonotonicNow",
    'class: "org.ballerinalang.stdlib.time.nativeimpl.ExternMethods"
} external;

function externUtcFromString(string str) returns [int, decimal]|Error = @java:Method {
    name: "externUtcFromString",
    'class: "org.ballerinalang.stdlib.time.nativeimpl.ExternMethods"
} external;

function externUtcToString(Utc utc) returns string = @java:Method {
    name: "externUtcToString",
    'class: "org.ballerinalang.stdlib.time.nativeimpl.ExternMethods"
} external;

function externUtcDiffSeconds(Utc utc1, Utc utc2) returns Seconds = @java:Method {
    name: "externUtcDiffSeconds",
    'class: "org.ballerinalang.stdlib.time.nativeimpl.ExternMethods"
} external;

function externDateValidate(Date date) returns Error? = @java:Method {
    name: "externDateValidate",
    'class: "org.ballerinalang.stdlib.time.nativeimpl.ExternMethods"
} external;

function externDayOfWeek(Date date) returns int|Error = @java:Method {
    name: "externDayOfWeek",
    'class: "org.ballerinalang.stdlib.time.nativeimpl.ExternMethods"
} external;