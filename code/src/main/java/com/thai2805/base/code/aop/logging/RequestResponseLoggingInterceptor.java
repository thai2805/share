package com.thai2805.base.code.aop.logging;

import com.google.gson.Gson;
import com.thai2805.base.code.config.Constants;
import com.thai2805.base.code.dto.LogWrapperDTO;
import com.thai2805.base.code.utils.Utils;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.DispatcherType;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

@Component
@Slf4j
public class RequestResponseLoggingInterceptor implements HandlerInterceptor {

    @Autowired
    private Gson gson = new Gson();

    @Override
    public boolean preHandle(HttpServletRequest httpServletRequest, HttpServletResponse response, Object handler) {

        if (DispatcherType.REQUEST.name().equals(httpServletRequest.getDispatcherType().name()) && httpServletRequest.getMethod().equals(HttpMethod.GET.name())) {
            String requestId = Utils.valueOf(httpServletRequest.getHeader(Constants.REQUEST_ID));
            long startTime = System.currentTimeMillis();
            try {
                httpServletRequest.setAttribute(RequestResponseLoggingConfig.START_TIME, startTime);
            } catch (Exception e) {
                log.warn("Add start time is error : {}", ExceptionUtils.getStackTrace(e));
            }

            Map<String, Object> data = new HashMap<>();
            data.put("parameter", gson.toJson(httpServletRequest.getParameterMap()));

            LogWrapperDTO logWrapperDto = LogWrapperDTO.builder().requestId(requestId).type(RequestResponseLoggingConfig.REQUEST).method(httpServletRequest.getMethod()).functionName("preHandle").message(data).path(httpServletRequest.getPathInfo()).url(httpServletRequest.getRequestURI()).addressRemote(httpServletRequest.getRemoteAddr()).build();
            log.info(gson.toJson(logWrapperDto));
        }
        return true;
    }

}
