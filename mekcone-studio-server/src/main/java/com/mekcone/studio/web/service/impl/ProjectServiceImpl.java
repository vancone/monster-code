package com.mekcone.studio.web.service.impl;

import com.mekcone.studio.web.entity.Project;
import com.mekcone.studio.web.mapper.ProjectMapper;
import com.mekcone.studio.web.repository.ProjectRepository;
import com.mekcone.studio.web.service.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletResponse;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Service
public class ProjectServiceImpl implements ProjectService {

    @Autowired
    private ProjectRepository projectRepository;

    @Autowired
    private ProjectMapper projectMapper;

    @Override
    public void exportProject(HttpServletResponse response, String fileType, String projectId) {
        response.setContentType("application/force-download");
        response.addHeader("Content-Disposition", "attachment;fileName=" + projectId + ".xml");
        try {
            OutputStream outputStream = response.getOutputStream();
            Project project = projectRepository.find(projectId);
            if (project != null) {
                outputStream.write(project.toString().getBytes(StandardCharsets.UTF_8));
            }
            outputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public Project retrieve(String projectId) {
        return projectRepository.find(projectId);
    }

    @Override
    public List<Project> retrieveList() {
//        return projectRepository.findAll();
        return projectMapper.retrieveList();
    }

    @Override
    public void saveProject(Project project) {
        Date date = new Date();
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        project.setModifiedTime(simpleDateFormat.format(date));
        projectRepository.saveProject(project);
    }

    @Override
    public void deleteProject(String projectId) {
        projectRepository.delete(projectId);
    }
}
