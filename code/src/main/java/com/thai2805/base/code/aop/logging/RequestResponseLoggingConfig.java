package com.thai2805.base.code.aop.logging;

import com.google.gson.Gson;
import com.thai2805.base.code.config.Constants;
import com.thai2805.base.code.dto.LogWrapperDTO;
import com.thai2805.base.code.utils.Utils;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.MethodParameter;
import org.springframework.http.HttpInputMessage;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.RequestBodyAdvice;
import org.springframework.web.servlet.mvc.method.annotation.RequestBodyAdviceAdapter;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

import javax.servlet.http.HttpServletRequest;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
@Slf4j
public class RequestResponseLoggingConfig extends RequestBodyAdviceAdapter implements RequestBodyAdvice, ResponseBodyAdvice<Object> {

    public static final String START_TIME = "startTimeRR";
    public static final String REQUEST = "ENTER";
    public static final String RESPONSE = "EXIT";
    @Autowired
    private HttpServletRequest httpServletRequest;

    @Autowired
    private Gson gson;

    @Override
    public boolean supports(MethodParameter methodParameter, Type targetType, Class<? extends HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType, Class<? extends HttpMessageConverter<?>> selectedConverterType, ServerHttpRequest request, ServerHttpResponse response) {
        String requestId = Utils.valueOf(httpServletRequest.getHeader(Constants.REQUEST_ID));

        LogWrapperDTO logWrapperDto = LogWrapperDTO.builder().requestId(requestId).type(RESPONSE).functionName("beforeBodyWrite").message(body).build();
        //Set time handle
        try {
            long startTime = Long.parseLong(Utils.valueOf(httpServletRequest.getAttribute(START_TIME)));
            long elapsedTime = System.currentTimeMillis() - startTime;
            logWrapperDto.setTimeHandle(elapsedTime);
        } catch (Exception e) {
            log.warn("Calculator time handle is error : {}", ExceptionUtils.getStackTrace(e));
        }

        log.info(gson.toJson(logWrapperDto));
        return body;
    }

    @Override
    public Object afterBodyRead(Object body, HttpInputMessage inputMessage, MethodParameter parameter, Type targetType, Class<? extends HttpMessageConverter<?>> converterType) {
        //Check request id
        String requestId = Utils.valueOf(httpServletRequest.getHeader(Constants.REQUEST_ID));
        long startTime = System.currentTimeMillis();
        try {
            httpServletRequest.setAttribute(START_TIME, startTime);
        } catch (Exception e) {
            log.warn("Add start time is error : {}", ExceptionUtils.getStackTrace(e));
        }

        Map<String, Object> data = new HashMap<>();
        data.put("body", body);
        data.put("parameter", httpServletRequest.getParameterMap().toString());

        LogWrapperDTO logWrapperDto = LogWrapperDTO.builder().requestId(requestId).type(REQUEST).method(httpServletRequest.getMethod()).functionName("afterBodyRead").message(data).path(httpServletRequest.getPathInfo()).url(httpServletRequest.getRequestURI()).addressRemote(httpServletRequest.getRemoteAddr()).build();
        log.info(gson.toJson(logWrapperDto));
        return super.afterBodyRead(body, inputMessage, parameter, targetType, converterType);
    }
}
