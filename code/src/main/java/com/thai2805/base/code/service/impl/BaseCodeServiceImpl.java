package com.thai2805.base.code.service.impl;

import com.thai2805.base.code.adapter.FileManagerAdapter;
import com.thai2805.base.code.service.BaseCodeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class BaseCodeServiceImpl implements BaseCodeService {

    @Autowired
    private FileManagerAdapter fileManagerAdapter;

    @Override
    public String getInfoS3(String fileName, Map<String, String> headers) {
        return fileManagerAdapter.getInfoS3(fileName, headers);
    }
}
