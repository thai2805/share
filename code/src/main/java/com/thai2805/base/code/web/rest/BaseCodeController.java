package com.thai2805.base.code.web.rest;

import com.thai2805.base.code.service.BaseCodeService;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.tags.Tags;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/v1/base-code")
//@SecurityScheme(name = "Authorization", bearerFormat = "JWT", scheme = "bearer", type = SecuritySchemeType.HTTP, in = SecuritySchemeIn.HEADER)
@OpenAPIDefinition(info = @Info(title = "Base code API", version = "1.0", description = "Base code Information"))
@Tags(@Tag(name = "Base-code"))
@Validated
public class BaseCodeController {

    @Autowired
    private BaseCodeService baseCodeService;

    @GetMapping("/healthCheck")
    public ResponseEntity<String> Test() {
        return ResponseEntity.ok("Rating And Feedback service is live");
    }

    @Operation(summary = "Get information of url S3",
            security = @SecurityRequirement(name = "Authorization"),
            responses = {
                    @ApiResponse(responseCode = "200", description = "Success"),
                    @ApiResponse(responseCode = "400", description = "Validation Exception"),
                    @ApiResponse(responseCode = "401", description = "Authentication Exception"),
                    @ApiResponse(responseCode = "403", description = "Permission Exception"),
                    @ApiResponse(responseCode = "404", description = "Not Found Exception"),
                    @ApiResponse(responseCode = "500", description = "Internal Server Error")
            }
    )
    @GetMapping(value = "/getUrlS3", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<String> getUrlS3(@RequestParam String objectKey, @RequestHeader Map<String, String> headers) {
        return ResponseEntity.ok(baseCodeService.getInfoS3(objectKey, headers));
    }
}
