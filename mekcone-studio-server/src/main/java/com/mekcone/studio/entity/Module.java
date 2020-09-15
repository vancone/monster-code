package com.mekcone.studio.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
 * Author: Tenton Lien
 * Date: 9/12/2020
 */

@Data
@Entity
@GenericGenerator(name = "jpa-uuid", strategy = "uuid")
@JsonInclude(JsonInclude.Include.NON_NULL)
@Table(name = "module")
public class Module {

    @Id
    @GeneratedValue(generator = "jpa-uuid")
    private String id;

    private String type;

    private String name;

    @JsonManagedReference
    @OneToMany(mappedBy = "module", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    private List<Extension> extensions;

    @JsonBackReference
    @ManyToOne(cascade = { CascadeType.MERGE, CascadeType.REFRESH }, optional = false)
    @JoinColumn(name = "project_id")
    private Project project;

    @JsonIgnore
    private String propertiesJson;

    @Transient
    private Map<String, String> properties = new HashMap<>();
}
