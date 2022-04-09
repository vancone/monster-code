package com.vancone.excode.generator.controller;

import com.vancone.cloud.common.model.Response;
import com.vancone.excode.generator.constant.LanguageType;
import com.vancone.excode.generator.service.DocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Tenton Lien
 */
@RestController
@RequestMapping("/api/excode/document")
public class DocumentController {

    @Autowired
    private DocumentService documentService;

    @GetMapping
    public Response createOfficialDocument(@RequestParam String projectId,
                                           @RequestParam(defaultValue = LanguageType.ENGLISH) String language) {
        documentService.generatePdf(projectId, language);
        return Response.success();
    }
}
