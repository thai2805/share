package com.thai2805.base.code.config;

import com.thai2805.base.code.dto.HeaderMapRequestWrapper;
import com.thai2805.base.code.utils.Utils;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
@Slf4j
public class TFilter implements Filter {

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HeaderMapRequestWrapper headerMap = new HeaderMapRequestWrapper((HttpServletRequest) servletRequest);
        String requestId = headerMap.getHeader(Constants.REQUEST_ID);
        if (StringUtils.isEmpty(requestId)) {
            requestId = Utils.generateRequestId();
            headerMap.addHeader(Constants.REQUEST_ID, requestId);
        }
        filterChain.doFilter(headerMap, servletResponse);
    }
}