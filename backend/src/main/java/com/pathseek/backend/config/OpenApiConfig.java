package com.pathseek.backend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    OpenAPI pathSeekOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("PathSeek API")
                        .version("v1")
                        .description("API para la gestión logística de PathSeek"));
    }
}
