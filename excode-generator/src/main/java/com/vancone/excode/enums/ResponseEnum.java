package com.vancone.excode.enums;

import com.vancone.web.common.exception.BaseEnum;
import lombok.Getter;
import lombok.Setter;

/**
 * @author Tenton Lien
 * @since 2021/11/19
 */
public enum ResponseEnum implements BaseEnum {

    /**
     * Project (10001 ~ 11000)
     */
    PROJECT_GENERATE_TASK_ALREADY_EXIST(10001, "There has been a running task"),

    /**
     * Data Store (11001 ~ 12000)
     */
    DATA_STORE_PROJECT_REQUIRED(11001, "Project ID required"),

    /**
     * Microservice: Spring Boot (12001 ~13000)
     */
    ORM_TYPE_REQUIRED(12001, "ORM type required");

    @Getter
    @Setter
    private int code;

    @Getter @Setter
    private String message;

    ResponseEnum(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
