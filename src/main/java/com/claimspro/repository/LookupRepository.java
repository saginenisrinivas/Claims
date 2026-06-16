package com.claimspro.repository;

import com.claimspro.model.LookupValue;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LookupRepository extends JpaRepository<LookupValue, Long> {
    List<LookupValue> findByCategoryAndActiveTrueOrderBySortOrderAsc(String category);
}
