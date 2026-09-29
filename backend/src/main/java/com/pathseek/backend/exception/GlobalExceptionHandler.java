package com.pathseek.backend.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiErrorResponse> handleValidation(MethodArgumentNotValidException exception) {
        List<ApiFieldError> errors = exception.getBindingResult().getFieldErrors().stream()
                .map(error -> new ApiFieldError(error.getField(), error.getDefaultMessage()))
                .toList();

        return ResponseEntity.badRequest().body(new ApiErrorResponse(
                "VALIDATION_ERROR",
                "Los datos enviados no son válidos",
                errors));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    ResponseEntity<ApiErrorResponse> handleUnreadableMessage(HttpMessageNotReadableException exception) {
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                "INVALID_REQUEST",
                "El cuerpo de la petición no es válido"));
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    ResponseEntity<ApiErrorResponse> handleTypeMismatch(MethodArgumentTypeMismatchException exception) {
        return ResponseEntity.badRequest().body(ApiErrorResponse.of(
                "INVALID_REQUEST",
                "Uno de los parámetros de la petición no es válido"));
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    ResponseEntity<ApiErrorResponse> handleNotFound(ResourceNotFoundException exception) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiErrorResponse.of("RESOURCE_NOT_FOUND", exception.getMessage()));
    }

    @ExceptionHandler(BusinessConflictException.class)
    ResponseEntity<ApiErrorResponse> handleConflict(BusinessConflictException exception) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiErrorResponse.of(exception.getCode(), exception.getMessage()));
    }

    @ExceptionHandler(BusinessRuleException.class)
    ResponseEntity<ApiErrorResponse> handleBusinessRule(BusinessRuleException exception) {
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_CONTENT)
                .body(ApiErrorResponse.of(exception.getCode(), exception.getMessage()));
    }

    @ExceptionHandler(ApiAuthenticationException.class)
    ResponseEntity<ApiErrorResponse> handleAuthentication(ApiAuthenticationException exception) {
        return ResponseEntity.status(exception.getStatus())
                .body(ApiErrorResponse.of(exception.getCode(), exception.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ApiErrorResponse> handleUnexpected(Exception exception) {
        LOGGER.error("Error inesperado al procesar la petición", exception);
        return ResponseEntity.internalServerError().body(ApiErrorResponse.of(
                "INTERNAL_ERROR",
                "Ocurrió un error inesperado"));
    }
}
