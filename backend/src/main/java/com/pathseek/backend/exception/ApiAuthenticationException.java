package com.pathseek.backend.exception;

import org.springframework.http.HttpStatus;

public class ApiAuthenticationException extends RuntimeException {

    private final String code;
    private final HttpStatus status;

    public ApiAuthenticationException(String code, String message, HttpStatus status) {
        super(message);
        this.code = code;
        this.status = status;
    }

    public String getCode() {
        return code;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
