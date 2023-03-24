package com.thai2805.base.code.aop.logging;

import com.google.gson.Gson;
import com.thai2805.base.code.config.Constants;
import com.thai2805.base.code.dto.HeaderMapRequestWrapper;
import com.thai2805.base.code.dto.LogWrapperDTO;
import com.thai2805.base.code.utils.Utils;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.builder.ReflectionToStringBuilder;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;

@Aspect
@Configuration
@Slf4j
public class FeignLoggingConfig {

    public static final String START_TIME = "startTimeF";
    public static final String REQUEST = "ENTER_FEIGN";
    public static final String RESPONSE = "EXIT_FEIGN";
    public static final String EXCEPTION = "EXCEPTION_FEIGN";

    @Pointcut("within(@org.springframework.cloud.openfeign.FeignClient *)")
    public void feignClient() {
    }

    @Pointcut("execution(* *.*(..))")
    protected void allMethod() {
    }

    @Autowired
    private HttpServletRequest httpServletRequest;
    @Autowired
    private Gson gson;

    @Autowired
    private Environment env;

    @Before("feignClient() && allMethod()")
    public void writeLogBefore(JoinPoint joinPoint) throws NoSuchMethodException {
        HeaderMapRequestWrapper headerMap = new HeaderMapRequestWrapper(httpServletRequest);
        //Check request id
        String requestId = Utils.valueOf(httpServletRequest.getHeader(Constants.REQUEST_ID));
        long startTime = System.currentTimeMillis();
        try {
            headerMap.addHeader(Constants.REQUEST_ID, requestId);
            httpServletRequest.setAttribute(START_TIME, startTime);
        } catch (Exception e) {
            log.warn("Add start time is error : {}", ExceptionUtils.getStackTrace(e));
        }

        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        Method method = methodSignature.getMethod();
        RequestMapping requestMapping = method.getAnnotation(RequestMapping.class);
        String url = "";
        String path = "";
        List<Object> data = Collections.emptyList();
        try {
            StringBuilder sb = new StringBuilder("");
            sb.append(joinPoint.getTarget().toString());
            url = sb.substring(sb.toString().indexOf("url=") + 4, sb.toString().length() - 1);
            path = Arrays.toString(requestMapping.path());
            path = env.getProperty(path.substring("[${".length(), path.length() - "}]".length()));

            // Remove all header in log.
            data = Arrays.stream(joinPoint.getArgs()).filter(o -> !(o instanceof LinkedHashMap)).collect(Collectors.toList());
        } catch (Exception e) {
            log.warn("Get url & path is error : {}", ExceptionUtils.getStackTrace(e));
        }
        LogWrapperDTO logWrapperDTO = LogWrapperDTO.builder().requestId(requestId).type(REQUEST).method(Arrays.toString(requestMapping.method())).functionName(joinPoint.getSignature().getName()).path(path).url(url).message(data.toString()).build();
        log.info(gson.toJson(logWrapperDTO));
    }

    @AfterReturning(pointcut = "feignClient() && allMethod() && @annotation(org.springframework.web.bind.annotation.RequestMapping)", returning = "result")
    public void writeLogAfterReturn(JoinPoint joinPoint, Object result) throws NoSuchMethodException {
        String requestId = Utils.valueOf(httpServletRequest.getHeader(Constants.REQUEST_ID));
        LogWrapperDTO logWrapperDto = LogWrapperDTO.builder().requestId(requestId).type(RESPONSE).functionName(joinPoint.getSignature().getName()).message(this.getValue(result)).build();
        //Set time handle
        try {
            long startTime = Long.parseLong(Utils.valueOf(httpServletRequest.getAttribute(START_TIME)));
            long elapsedTime = System.currentTimeMillis() - startTime;
            logWrapperDto.setTimeHandle(elapsedTime);
        } catch (Exception e) {
            log.warn("Calculator time handle is error : {}", ExceptionUtils.getStackTrace(e));
        }

        //Get http code
        HttpServletResponse response = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getResponse();
        logWrapperDto.setHttpCode(Utils.valueOf(response != null ? response.getStatus() : null));


        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        Method method = methodSignature.getMethod();
        RequestMapping requestMapping = method.getAnnotation(RequestMapping.class);
        String url = "";
        String path = "";
        try {
            StringBuilder sb = new StringBuilder();
            sb.append(joinPoint.getTarget().toString());
            url = sb.substring(sb.toString().indexOf("url=") + 4, sb.toString().length() - 1);
            path = Arrays.toString(requestMapping.path());
            path = env.getProperty(path.substring("[${".length(), path.length() - "}]".length()));
        } catch (Exception e) {
            log.warn("Standard value of log, {}", ExceptionUtils.getStackTrace(e));
        }
        logWrapperDto.setMethod(Arrays.toString(requestMapping.method()));
        logWrapperDto.setPath(path);
        logWrapperDto.setUrl(url);
        log.info(gson.toJson(logWrapperDto));
    }

    @AfterThrowing(pointcut = "feignClient() && allMethod()", throwing = "exception")
    public void writeLogAfterThrow(JoinPoint joinPoint, Throwable exception) {
        String requestId = Utils.valueOf(httpServletRequest.getHeader(Constants.REQUEST_ID));

        LogWrapperDTO logWrapperDto = LogWrapperDTO.builder().type(EXCEPTION).requestId(requestId).functionName(joinPoint.getSignature().getName()).build();

        //Set time handle
        try {
            long startTime = Long.parseLong(Utils.valueOf(httpServletRequest.getAttribute(START_TIME)));
            long elapsedTime = System.currentTimeMillis() - startTime;
            logWrapperDto.setTimeHandle(elapsedTime);
        } catch (Exception e) {
            log.warn("Calculator time handle is error : {}", ExceptionUtils.getStackTrace(e));
        }

        logWrapperDto.setMessage(exception.toString());
        log.info(gson.toJson(logWrapperDto));
    }

    private String getValue(Object result) {
        String returnValue = null;
        if (null != result) {
            if (result.toString().endsWith("@" + Integer.toHexString(result.hashCode()))) {
                returnValue = ReflectionToStringBuilder.toString(result);
            } else {
                returnValue = result.toString();
            }
        }
        return returnValue;
    }
}
