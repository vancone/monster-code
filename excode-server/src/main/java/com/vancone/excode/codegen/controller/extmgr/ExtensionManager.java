package com.vancone.excode.codegen.controller.extmgr;

import com.vancone.excode.codegen.controller.generator.Generator;

/**
 * @author Tenton Lien
 * @date 6/25/2020
 */
public class ExtensionManager {
    private Generator generator;

    public ExtensionManager() {
        String callerClassName = Thread.currentThread().getStackTrace()[3].getClassName();
        System.out.println(callerClassName);
    }
}
