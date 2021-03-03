/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

package org.ballerinalang.stdlib.time.util;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.math.BigDecimal;
import java.time.DateTimeException;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoField;
import java.time.temporal.TemporalAccessor;
import java.time.zone.ZoneRulesException;
import java.util.Arrays;
import java.util.Date;
import java.util.TimeZone;

import static org.ballerinalang.stdlib.time.util.Constants.RECORD_UTC;
import static org.ballerinalang.stdlib.time.util.Constants.SECONDS_PER_DAY;

/**
 * A util class for the time package's native implementation.
 *
 * @since 0.95.4
 */
public class TimeValueHandler {
    static TupleType UTC_TUPLE_TYPE = TypeCreator.createTupleType(
    Arrays.asList(PredefinedTypes.TYPE_INT, PredefinedTypes.TYPE_DECIMAL));

    public static BArray createUtc(Instant instant) {
        long days = instant.getEpochSecond()/SECONDS_PER_DAY;
        BigDecimal seconds = new BigDecimal(instant.getNano());
        BArray utcTuple = ValueCreator.createTupleValue(UTC_TUPLE_TYPE);
        utcTuple.add(0, days);
        utcTuple.add(1, ValueCreator.createDecimalValue(seconds));
        return utcTuple;
    }

    public static BError createError(Errors errorType, String errorMsg, String details) {
        return ErrorCreator.createError(TypeCreator.createErrorType(errorType.name(), ModuleUtils.getModule()),
                StringUtils.fromString(errorMsg), StringUtils.fromString(details));
    }
    public static BError createError(Errors errorType, String errorMsg) {
        return ErrorCreator.createError(TypeCreator.createErrorType(errorType.name(), ModuleUtils.getModule()),
                StringUtils.fromString(errorMsg), StringUtils.fromString(""));
//        return ErrorCreator.createDistinctError(errorType.name(), ModuleUtils.getModule(), StringUtils.fromString(errorMsg));
    }



}
