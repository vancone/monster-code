package com.vancone.excode.config.property;

/**
 * @author Tenton Lien
 * @date 10/1/2020
 */
public class CookieConfig {

    public static String getName() {
        return "exam";
    }

    public static Integer getInterval() {
        return 30 * 24 * 60 * 60;
    }
}
