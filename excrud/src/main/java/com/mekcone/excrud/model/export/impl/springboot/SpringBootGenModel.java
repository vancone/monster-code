package com.mekcone.excrud.model.export.impl.springboot;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlElementWrapper;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import com.mekcone.excrud.constant.basic.ExportType;
import com.mekcone.excrud.controller.parser.PropertiesParser;
import com.mekcone.excrud.model.export.GenModel;
import com.mekcone.excrud.model.export.impl.springboot.component.*;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
public class SpringBootGenModel implements GenModel {

    @JsonIgnore
    private String groupId;

    @JsonIgnore
    private String artifactId;

    @JacksonXmlElementWrapper(localName = "extensions")
    @JacksonXmlProperty(localName = "extension")
    private List<SpringBootExtension> extensions = new ArrayList<>();

    private SpringBootProperties properties;

    @JacksonXmlProperty(isAttribute = true)
    private boolean use;

    @JsonIgnore
    private ProjectObjectModel projectObjectModel;

    @JsonIgnore
    private PropertiesParser applicationPropertiesParser = new PropertiesParser();

    @JsonIgnore
    private List<SpringBootComponent> configs = new ArrayList<>();

    @JsonIgnore
    private List<SpringBootComponent> controllers = new ArrayList<>();

    @JsonIgnore
    private List<SpringBootDataClass> entities = new ArrayList<>();

    @JsonIgnore
    private List<SpringBootComponent> mybatisMappers = new ArrayList<>();

    @JsonIgnore
    private List<SpringBootComponent> services = new ArrayList<>();

    @JsonIgnore
    private List<SpringBootComponent> serviceImpls = new ArrayList<>();

    public void addController(SpringBootComponent springBootComponent) {
        controllers.add(springBootComponent);
    }

    public void addEntity(SpringBootDataClass springBootDataClass) {
        entities.add(springBootDataClass);
    }

    public void addMybatisMapper(SpringBootComponent springBootComponent) {
        mybatisMappers.add(springBootComponent);
    }

    public void addService(SpringBootComponent springBootComponent) {
        services.add(springBootComponent);
    }

    public void addServiceImpl(SpringBootComponent springBootComponent) {
        serviceImpls.add(springBootComponent);
    }

    @Override
    public String type() {
        return ExportType.SPRING_BOOT;
    }

}
