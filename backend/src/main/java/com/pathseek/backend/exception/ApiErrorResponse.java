package com.pathseek.backend.exception;

import java.util.List;

public record ApiErrorResponse(String code, String message, List<ApiFieldError> errors) {

    public static ApiErrorResponse of(String code, String message) {
        return new ApiErrorResponse(code, message, List.of());
    }
}
