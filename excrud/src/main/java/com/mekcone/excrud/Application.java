package com.mekcone.excrud;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.mekcone.excrud.loader.ProjectLoader;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Slf4j
public class Application {
    public static String description = "Generated by MekCone ExCRUD at " + new Date();

    public static void main(String[] args) {
        var commandArgument = new CommandArgument();
        var jCommander = JCommander.newBuilder()
                .addObject(commandArgument)
                .build();
        jCommander.setProgramName("excrud");
        jCommander.parse(args);

        if (commandArgument.isHelp()) {
            jCommander.usage();
            System.exit(0);
        }

        var projectLoader = new ProjectLoader();

        if (commandArgument.isGen()) {
            projectLoader.load(System.getProperty("user.dir") + "/excrud.xml");
            projectLoader.generate();
        }

        if (commandArgument.isBuild()) {
            projectLoader.build();
        }
    }

    @Data
    static class CommandArgument {
        @Parameter
        private List<String> parameters = new ArrayList<>();

        @Parameter(names={"build"}, description = "Build application")
        private boolean build;

        @Parameter(names={"clean"}, description = "Clean all outputs last time")
        private boolean clean;

        @Parameter(names={"gen"}, description = "Generate applications")
        private boolean gen;

        @Parameter(names={"help"}, description = "Help options", help = true)
        private boolean help;
    }

    public static String getHomeDirectory() {
        return System.getenv("EXCRUD_HOME");
    }
}