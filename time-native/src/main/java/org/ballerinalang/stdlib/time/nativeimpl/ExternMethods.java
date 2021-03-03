/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.ballerinalang.stdlib.time.nativeimpl;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.stdlib.time.util.Constants;
import org.ballerinalang.stdlib.time.util.Errors;
import org.ballerinalang.stdlib.time.util.TimeValueHandler;

import java.math.BigDecimal;
import java.time.DateTimeException;
import java.time.Instant;
import java.time.LocalDate;

/**
 * Extern methods used in Ballerina Time library.
 *
 * @since 1.1.0
 */
public class ExternMethods {
    private ExternMethods() {}

    public static BArray externUtcNow(int precision) {
        Instant currentUtcTimeInstant = Instant.now();
        int precisionValue = 9;
        if (precision > 0 && precision <= 9) {
            precisionValue = precision;
        }
        return TimeValueHandler.createUtcFromInstant(currentUtcTimeInstant, precisionValue);
    }

    public static BDecimal externMonotonicNow() {
        long time = System.nanoTime();
        return ValueCreator.createDecimalValue(new BigDecimal(time).divide(Constants.ANALOG_GIGA));
    }

    public static Object externUtcFromString(BString str) {
        try {
            Instant utcTimeInstant = Instant.parse(str.getValue());
            return TimeValueHandler.createUtcFromInstant(utcTimeInstant);
        } catch (DateTimeException e) {
            return TimeValueHandler.createError(Errors.FormatError,
            "Provided '" + str.getValue() + "' is not adhere to the expected format '2007-12-03T10:15:30.00Z'");
        }
    }

    public static BString externUtcToString(BArray utc) {
        Instant time = TimeValueHandler.createInstantFromUtc(utc);
        return StringUtils.fromString(time.toString());
    }

    public static BDecimal externUtcDiffSeconds(BArray utc1, BArray utc2) {
        Instant time1 = TimeValueHandler.createInstantFromUtc(utc1);
        Instant time2 = TimeValueHandler.createInstantFromUtc(utc2);
        time1 = time1.minusNanos(time2.getNano());
        time1 = time1.minusSeconds(time2.getEpochSecond());
        BigDecimal nanoSeconds = new BigDecimal(time1.getNano()).divide(Constants.ANALOG_GIGA);
        BigDecimal seconds = new BigDecimal(time1.getEpochSecond()).add(nanoSeconds);
        return ValueCreator.createDecimalValue(seconds);
    }

    public static Object externDateValidate(BMap date) {
        int year = Math.toIntExact(date.getIntValue(StringUtils.fromString("year")));
        int month = Math.toIntExact(date.getIntValue(StringUtils.fromString("month")));
        int day = Math.toIntExact(date.getIntValue(StringUtils.fromString("day")));
        try {
            LocalDate.of(year, month, day);
            return null;
        } catch (DateTimeException e) {
            return TimeValueHandler.createError(Errors.FormatError, e.getMessage());
        }
    }

    public static Object externDayOfWeek(BMap date) {
        int year = Math.toIntExact(date.getIntValue(StringUtils.fromString("year")));
        int month = Math.toIntExact(date.getIntValue(StringUtils.fromString("month")));
        int day = Math.toIntExact(date.getIntValue(StringUtils.fromString("day")));
        try {
            return ((LocalDate.of(year, month, day).getDayOfWeek().getValue())%7);
        } catch (DateTimeException e) {
            return TimeValueHandler.createError(Errors.FormatError, e.getMessage());
        }
    }

}
