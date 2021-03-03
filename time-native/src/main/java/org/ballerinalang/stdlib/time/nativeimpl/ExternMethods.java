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

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.stdlib.time.util.Errors;
import org.ballerinalang.stdlib.time.util.ModuleUtils;
import org.ballerinalang.stdlib.time.util.TimeValueHandler;

import java.time.DateTimeException;
import java.time.Instant;

/**
 * Extern methods used in Ballerina Time library.
 *
 * @since 1.1.0
 */
public class ExternMethods {
    private ExternMethods() {}

    public static BArray externUtcNow() {
        Instant currentUtcTimeInstant = Instant.now();
        return TimeValueHandler.createUtc(currentUtcTimeInstant);
    }

    public static Object externUtcFromString(BString str) {
        try {
            Instant utcTimeInstant = Instant.parse(str.getValue());
            return TimeValueHandler.createUtc(utcTimeInstant);
        } catch (DateTimeException e) {
            return TimeValueHandler.createError(Errors.FormatError,
            "Provided '" + str.getValue() + "' is not adhere to the expected format '2007-12-03T10:15:30.00Z'");
        }
    }

}
