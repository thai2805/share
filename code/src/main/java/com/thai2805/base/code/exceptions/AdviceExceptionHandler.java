package com.thai2805.base.code.exceptions;

import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.exc.InvalidDefinitionException;
import com.google.gson.Gson;
import com.thai2805.base.code.dto.BasicControllerResponse;
import feign.FeignException;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.beans.TypeMismatchException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageConversionException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.util.CollectionUtils;
import org.springframework.validation.ObjectError;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingMatrixVariableException;
import org.springframework.web.bind.MissingPathVariableException;
import org.springframework.web.bind.MissingRequestCookieException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.MissingRequestValueException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import javax.validation.ConstraintDeclarationException;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@ControllerAdvice
@Slf4j
public class AdviceExceptionHandler {
    @Autowired
    private Gson gson;

    @ExceptionHandler({RuntimeException.class, Exception.class})
    public ResponseEntity handleRuntimeException(Exception e) {
        log.error("Runtime error: {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler({HttpMediaTypeNotSupportedException.class})
    public ResponseEntity handleUnsupportedMediaTypeException(Exception e) {
        log.error("handleUnsupportedMediaTypeException: {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.UNSUPPORTED_MEDIA_TYPE.getReasonPhrase(), HttpStatus.UNSUPPORTED_MEDIA_TYPE);
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity handleMaxUploadException(MaxUploadSizeExceededException e) {
        log.error("Upload file too lager.. {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.PAYLOAD_TOO_LARGE.getReasonPhrase(), HttpStatus.PAYLOAD_TOO_LARGE);
    }


    @ExceptionHandler(FeignException.class)
    public ResponseEntity handleFeignException(FeignException fe) {
        log.error("FeignException : {}", ExceptionUtils.getStackTrace(fe));
        return wrapperResponse(fe.responseBody(), fe.status());
    }

    @ExceptionHandler({MethodArgumentNotValidException.class})
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex) {
        List<ObjectError> listErr = ex.getBindingResult().getAllErrors();
        if (CollectionUtils.isEmpty(listErr)) {
            log.error("MethodArgumentNotValidException : {}", listErr.stream().map(ObjectError::getDefaultMessage).collect(Collectors.joining()));
            return wrapperResponse(HttpStatus.BAD_REQUEST.getReasonPhrase(), HttpStatus.BAD_REQUEST);
        }
        return wrapperResponse(listErr.stream().findFirst().orElse(new ObjectError("MethodArgumentNotValidException", "MethodArgumentNotValidException")).getDefaultMessage(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler({MissingMatrixVariableException.class,
            MissingPathVariableException.class,
            MissingRequestCookieException.class,
            MissingRequestHeaderException.class,
            MissingRequestValueException.class,
            MissingServletRequestParameterException.class,
            ConstraintDeclarationException.class,
            InvalidDefinitionException.class,
            JsonMappingException.class,
            HttpMessageConversionException.class})
    protected ResponseEntity<Object> handleMethodArgumentNotValid(Exception e) {
        log.error("handleMethodArgumentNotValid : {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.BAD_REQUEST.getReasonPhrase(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler({IllegalArgumentException.class})
    protected ResponseEntity<Object> handleIllegalArgumentException(IllegalArgumentException e) {
        log.error("handleIllegalArgumentException : {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.BAD_REQUEST.getReasonPhrase(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity handleMethodNotSupported(HttpRequestMethodNotSupportedException e) {
        log.error("handleMethodNotSupported : {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.METHOD_NOT_ALLOWED.getReasonPhrase(), HttpStatus.METHOD_NOT_ALLOWED);
    }


    @ExceptionHandler(TypeMismatchException.class)
    protected ResponseEntity<Object> handleTypeMismatch(TypeMismatchException e) {
        log.error("TypeMismatchException : {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.BAD_REQUEST.getReasonPhrase(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity handleAllOtherErrors(HttpMessageNotReadableException e) {
        log.error("HttpMessageNotReadableException : {}", ExceptionUtils.getStackTrace(e));
        return wrapperResponse(HttpStatus.BAD_REQUEST.getReasonPhrase(), HttpStatus.BAD_REQUEST);
    }

    private ResponseEntity wrapperResponse(String errorCode, HttpStatus httpStatus) {
        return new ResponseEntity(BasicControllerResponse.builder()
                .data(httpStatus.toString())
                .errorCode(errorCode)
                .build(),
                HttpStatus.OK);
    }

    private ResponseEntity wrapperResponse(Optional<ByteBuffer> body, Integer httpStatus) {
        String response = new String(body.isPresent() ? body.get().array() : "Empty".getBytes(), StandardCharsets.UTF_8);
        try {
            return new ResponseEntity(gson.fromJson(response, BasicControllerResponse.class), HttpStatus.OK);
        } catch (Exception e) {
            log.error("Can not convert object to BasicControllerResponse: {}", response);
        }
        return wrapperResponse(response, HttpStatus.valueOf(httpStatus));
    }
}
