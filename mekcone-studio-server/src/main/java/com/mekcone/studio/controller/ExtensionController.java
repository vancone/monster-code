package com.mekcone.studio.controller;

import com.mekcone.studio.entity.Extension;
import com.mekcone.studio.service.ExtensionService;
import com.mekcone.webplatform.common.model.Response;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

/*
 * Author: Tenton Lien
 * Date: 9/14/2020
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/studio/extension", produces = MediaType.APPLICATION_JSON_VALUE)
public class ExtensionController {

    @Autowired
    private ExtensionService extensionService;

    @PostMapping
    public Response create(@RequestBody Extension extension) {
        extensionService.create(extension);
        return Response.success();
    }

    @GetMapping("/{extensionId}")
    public Response findById(@PathVariable String extensionId) {
        Extension extension = extensionService.findById(extensionId);
        log.info("Retrieve extension: {}", extension.toString());
        return Response.success(extension);
    }

    @GetMapping
    public Response findAll(@RequestParam(value = "pageNo", defaultValue = "0") int pageNo,
                            @RequestParam(value = "pageSize", defaultValue = "5") int pageSize) {
        return Response.success(extensionService.findAll(pageNo, pageSize));
    }

    @PutMapping
    public Response update(@RequestBody Extension extension) {
        extensionService.save(extension);
        return Response.success();
    }

    @DeleteMapping("/{extensionId}")
    public Response delete(@PathVariable String extensionId) {
        extensionService.delete(extensionId);
        return Response.success();
    }
}
