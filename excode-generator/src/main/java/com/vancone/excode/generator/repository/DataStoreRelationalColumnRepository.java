package com.vancone.excode.generator.repository;

import com.vancone.excode.generator.entity.DataStoreRelationalColumn;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * @author Tenton Lien
 * @since 2022/05/09
 */
public interface DataStoreRelationalColumnRepository extends JpaRepository<DataStoreRelationalColumn, String> {
}
