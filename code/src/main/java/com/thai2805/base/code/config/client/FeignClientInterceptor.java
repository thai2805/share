package com.thai2805.base.code.config.client;

import com.thai2805.base.code.config.Constants;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;

@Component
public class FeignClientInterceptor implements RequestInterceptor {

    @Autowired
    private HttpServletRequest httpServletRequest;

    @Override
    public void apply(RequestTemplate template) {
        // Forward token
        // SecurityUtils.getCurrentUserJWT().ifPresent(s -> template.header(AUTHORIZATION_HEADER, String.format("%s %s", BEARER, s)));

        // Forward request id
        template.header(Constants.REQUEST_ID, httpServletRequest.getHeader(Constants.REQUEST_ID));
    }
}
