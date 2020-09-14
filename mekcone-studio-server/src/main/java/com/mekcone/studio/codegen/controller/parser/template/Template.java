package com.mekcone.studio.codegen.controller.parser.template;

/*
 * Author: Tenton Lien
 */

public interface Template {
    boolean insert(String tag, String replacement);
    boolean insertOnce(String tag, String replacement);
    boolean remove(String tag);
}
