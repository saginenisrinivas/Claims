package com.claimspro.repository;

import com.claimspro.model.Claim;
import com.claimspro.model.ClaimStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface ClaimRepository extends JpaRepository<Claim, String> {

    @Query("SELECT c FROM Claim c WHERE " +
           "(:status IS NULL OR c.status = :status) AND " +
           "(:claimType IS NULL OR LOWER(c.claimType) = LOWER(:claimType)) AND " +
           "(:query IS NULL OR (" +
           "  LOWER(c.id) LIKE CONCAT('%', LOWER(:query), '%') OR " +
           "  LOWER(c.lifeAssuredName) LIKE CONCAT('%', LOWER(:query), '%') OR " +
           "  LOWER(c.reporterName) LIKE CONCAT('%', LOWER(:query), '%') OR " +
           "  LOWER(c.claimType) LIKE CONCAT('%', LOWER(:query), '%')" +
           ")) ORDER BY c.submittedAt DESC")
    List<Claim> search(@Param("query")     String query,
                       @Param("status")    ClaimStatus status,
                       @Param("claimType") String claimType);

    List<Claim> findAllByOrderBySubmittedAtDesc();

    long countByStatus(ClaimStatus status);

    @Query("SELECT COALESCE(SUM(c.approvedAmount), 0) FROM Claim c WHERE c.status = 'APPROVED'")
    BigDecimal sumApprovedAmounts();

    @Query(value = "SELECT nextval('claim_seq')", nativeQuery = true)
    Long nextSequenceValue();
}
