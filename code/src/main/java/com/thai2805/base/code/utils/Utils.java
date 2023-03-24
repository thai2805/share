package com.thai2805.base.code.utils;

import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.http.HttpStatus;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Random;

@Slf4j
public class Utils {
    private static Random random = new Random();

    private Utils() {
    }

    public static String generateRequestId(){
        Date currentDate = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String requestId = sdf.format(currentDate);
        Integer tmpRd =  random.nextInt(998) + 1;
        if(tmpRd < 10){
            requestId += "00" + tmpRd;
        }else if(tmpRd >= 10 && tmpRd < 100){
            requestId += "0" + tmpRd;
        }else {
            requestId += tmpRd;
        }
        return requestId;
    }

    public static String valueOf(Object var0) {
        return var0 == null ? null : var0.toString();
    }

    private static HttpStatus standardizeErrorCodes (HttpStatus httpStatus) {
        if (httpStatus == null) {
            return HttpStatus.INTERNAL_SERVER_ERROR;
        }
        if (httpStatus.value() == HttpStatus.UNAUTHORIZED.value()) {
            return HttpStatus.FORBIDDEN;
        }
        return httpStatus;
    }

    public static HttpStatus standardizeErrorCodesOfValue(String value) {
        try {
            return standardizeErrorCodes(HttpStatus.valueOf(Integer.parseInt(value)));
        } catch (Exception e) {
            log.warn("standardizeErrorCodes is error : {}", ExceptionUtils.getStackTrace(e));
        }
        return HttpStatus.INTERNAL_SERVER_ERROR;
    }

    public static boolean isNullOrEmpty(String input) {
        return StringUtils.isEmpty(input) && StringUtils.isBlank(input);
    }

    public static boolean isNotNullOrEmpty(String input) {
        return StringUtils.isNotEmpty(input) && StringUtils.isNotBlank(input);
    }
}

