package com.mekcone.studio.service;


import com.mekcone.studio.entity.Module;
import org.springframework.data.domain.Page;

/*
 * Author: Tenton Lien
 * Date: 9/15/2020
 */

public interface ModuleService {
    Module findById(String moduleId);
    Page<Module> findAll(int pageNo, int pageSize);
    void save(Module module);
    void delete(String moduleId);
}
