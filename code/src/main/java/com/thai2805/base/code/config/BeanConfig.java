package com.thai2805.base.code.config;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.DispatcherServlet;

@Configuration
public class BeanConfig {

    @Bean
    public Gson gson() {
        return new GsonBuilder().disableHtmlEscaping()
                .setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Bean
    public DispatcherServlet dispatcherServlet() {
        DispatcherServlet dispatcherServlet = new DispatcherServlet();
        dispatcherServlet.setThreadContextInheritable(true);
        dispatcherServlet.setThrowExceptionIfNoHandlerFound(true);
        return dispatcherServlet;
    }
}