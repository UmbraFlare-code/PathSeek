package com.pathseek.backend.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record UserPageResponse(List<UserResponse> contenido, int pagina,
        @JsonProperty("total_paginas") int totalPaginas,
        @JsonProperty("total_elementos") long totalElementos) {}
