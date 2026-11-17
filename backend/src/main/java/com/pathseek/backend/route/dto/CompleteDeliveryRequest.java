package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.OffsetDateTime;

public record CompleteDeliveryRequest(@JsonProperty("entregado_en") OffsetDateTime entregadoEn) {}
