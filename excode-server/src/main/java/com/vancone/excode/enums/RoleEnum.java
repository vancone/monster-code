package com.vancone.excode.enums;


import java.util.HashMap;
import java.util.Map;

/**
 * @author Tenton Lien
 * @date 10/1/2020
 */
public enum RoleEnum {

    NORMAL(1, "NORMAL"),
    VIP(2, "VIP"),
    ADMIN(3, "ADMIN");

    int code;
    String name;

    RoleEnum(int code, String name) {
        this.code = code;
        this.name = name;
    }

    private static final Map<Integer, RoleEnum> keyMap = new HashMap<>();

    static {
        for (RoleEnum item : RoleEnum.values()) {
            keyMap.put(item.getCode(), item);
        }
    }

    public static RoleEnum fromCode(Integer code) {
        return keyMap.get(code);
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRoleName() {
        return "ROLE_" + name;
    }

}
