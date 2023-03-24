package com.thai2805.base.code.dto;

import lombok.Builder;
import lombok.Data;

import java.io.Serializable;

@Builder
@Data
public class LogWrapperDTO implements Serializable {
    private String requestId;
    private String type;
    private String method;
    private String functionName;
    private Object message;
    private String httpCode;
    private Long timeHandle;
    private String path;
    private String url;
    private String addressRemote;
}
