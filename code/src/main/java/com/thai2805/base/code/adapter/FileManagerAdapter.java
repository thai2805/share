package com.thai2805.base.code.adapter;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@FeignClient(name = "filemanager", url = "${internal.filemanager.endpoint.url:}")
public interface FileManagerAdapter {

    @RequestMapping(method = RequestMethod.GET, path = "${internal.filemanager.endpoint.getInfoS3:}", produces = {MediaType.APPLICATION_JSON_VALUE})
    String getInfoS3(@RequestParam String fileName, @RequestHeader Map<String, String> headers);

    @RequestMapping(method = RequestMethod.GET, path = "${internal.filemanager.endpoint.getUrlS3:}", produces = {MediaType.APPLICATION_JSON_VALUE})
    String getUrlS3(@RequestParam String objectKey, @RequestHeader Map<String, String> headers);
}
