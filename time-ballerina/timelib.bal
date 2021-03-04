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

// Phase 1

type Error distinct error;
type Seconds decimal;

// UTC time

// should handle all RFC timestamps
// two-part structure especially to handles discontinuities,
// which are distinctive feature of UTC
# Point on UTC time-scale.
# This is represented by a tuple of length 2.
# The tuple is an ordered type and so the values can be
# compared using the Ballerina <, <=, >, >= operators.
# First member of tuple is int representing integral number of
# seconds from the epoch.
# Epoch is traditional Unix epoch of 1970-01-01T00:00:00Z
# Second member of tuple is decimal giving the fraction of
# a second.
# For times before the epoch, n is negative and f is
# non-negative. In other words, the UTC time represented
# is on or after the second specified by n.
# Leap seconds are handled as follows. The first member
# of the tuple ignores leap seconds: it assumes that every day
# has 86400 seconds. The second member of the tuple is >= 0.
# and is < 1 except during positive leaps seconds in which it
# is >= 1 and < 2. So given a tuple [n,f] after the epoch,
# n / 86400 gives the day number, and (n % 86400) + f gives the
# time in seconds since midnight UTC (for which the limit is
# 86401 on day with a positive leap second).
// XXX need to think about valid range for int
// should at least be able to represent
type Utc readonly & [int,decimal];

# Returns Utc representing current time.
# `precision` specifies number of zeros after decimal point
# for seconds e.g. 3 would give millisecond precision
# nil means native precision of clock
function utcNow(int? precision = ()) returns Utc;

// converts from RFC 3339 timestamp to Utc
function utcFromString(string str) returns Utc|Error;
function utcToString(Utc utc) returns string;

// Returns Utc time that occurs seconds after `utc`.
// This assumes that all days have 86400 seconds, except when
// utc represents a time during a positive leap
// second, in which case the corresponding day will be assumed
// to have 86401 seconds.
function utcAddSeconds(Utc utc, Seconds seconds) returns Utc;

// Returns difference in seconds between utc1 and utc2.
// This will be positive if utc1 occurs after utc2
// This assumes that all days have 86400 seconds, except when
// utc1 or utc2 represents a time during a positive leap
// second, in which case the corresponding day will be assumed
// to have 86401 seconds.
function utcDiffSeconds(Utc utc1, Utc utc2) returns Seconds;



// Monotonic time

// seconds from some unspecified epoch
function monotonicNow() returns Seconds;

// Civil time

# date in proleptic Gregorian calendar
type Date record {
  // year 1 means AD 1
  // year 0 means 1 BC
  // year -1 means 2 BC
  int year;
  # month 1 is January, as in ISO 8601
  int month;
  # day 1 is first day of month
  int day;
};

function dateValidate(Date date) returns Error? {
  // check that days and months are within range
  // per Gregorian calendar rules
}

// Need to decide whether SUNDAY or MONDAY is first day of week
// ISO (and logic) says Monday; US convention is Sunday
const int SUNDAY = 0;
// etc

type DayOfWeek SUNDAY|MONDAY|...|SATURDAY;

// panic if date is not valid
function dayOfWeek(Date date) returns DayOfWeek {
}

# Time within a day
# Not always duration from midnight,
type TimeOfDay record {
  // this is "hour" not "hours" because
  // consistency with year/month/day
  // it is not the same as hours from midnight for a local time
  // because of daylight savings time discontinuities
  int hour;
  int minute;
  // it is very common for seconds to not be specified
  // Should this be "seconds"?
  Seconds second?;
};

// This is closed so it is a subtype of Delta
// Fields can negative
// if any of the three fields are > 0, then all must be >= 0
// if any of the three fields are < 0, then all must be <= 0
// Semantic is that durations should be left out
type ZoneOffset readonly & record {|
  int hours;
  int minutes = 0;
  # IETF zone files have historical zones that are offset by
  # integer seconds; we use Seconds type so that this is a subtype
  # of Delta
  Seconds seconds?;
|};

const ZoneOffset Z = { hours: 0 };

type ZERO_OR_ONE 0|1;

# Time within some region relative to a
# time scale stipulated by civilian authorities
// This is relatively loose type;
// we can have other types that are tighter.
// Similar to struct tm in C.
// Module is called time so this is time:Civil
type Civil record {
  // the date time in that region
  *Date;
  *TimeOfDay;
  // offset of the date time in that region at that time
  // from Utc
  // positive means the local time is ahead of UTC
  ZoneOffset utcOffset?;

  # if present, abbreviation for the local time (e.g. EDT, EST)
  # in effect at the time represented by this record;
  # this is quite the same as the name of a time zone
  # one time zone can have two abbreviations: one for
  # standard time and one for daylight savings time
  string timeAbbrev?;
  // when the clocks are put back at the end of DST,
  // one hour's worth of times occur twice
  // i.e. the local time is ambiguous
  // this says which of those two times is meant
  // same as fold field in Python
  // see https://www.python.org/dev/peps/pep-0495/
  // is_dst has similar role in struct tm,
  // but with confusing semantics
  ZERO_OR_ONE which?;
};


function utcToCivil(Utc utc) returns Civil;
// error if civilTime.utcOffset is missing
function utcFromCivil(Civil civilTime) returns Utc|Error;

// The string format used by civilFromString and civilToString
// is ISO 8601 but with more flexibility that RFC 3339 as follows:
// missing utcOffset field represented by missing time zone offset
// missing seconds in time represented by missing second
// field in TimeOfDay

function civilFromString(string str) returns Utc|Error;
// Returns ISO8601 string
function civilToString(Civil civilTime) returns string;
function utcTimeOfDay(Utc utc) returns TimeOfDay;
// XXX function to return Seconds since midnight
function utcDate(Utc utc) returns Date;

// Phase 2

// Time zones

type Zone readonly & object {
  // if always at a fixed offset from Utc, then this
  // function returns it; otherwise nil
  function fixedOffset() returns ZoneOffset?;
  // this does not pay attention to timeZoneOffset nor dayOfWeek
  // it does pay attention to utc
  function utcFromCivil(Civil civilTime) returns Utc|Error;
  function utcToCivil(Utc utc) returns Civil;
};

final Zone systemZone = check loadSystemZone();

// Get a time zone from Ballerina's internal database
// of time zones.
// id is  of form "Continent/City"
function getZone(string id) returns Zone?;

// Human-oriented time differences

// This is not quite a nominal duration,
// because durations are positive
// Python uses the word Delta, which is good
type Delta record {|
  int years?;
  int months?;
  int weeks?;
  int days?;
  int hours?;
  int minutes?;
  Seconds seconds?;
|};
