package com.claimspro.repository;

import com.claimspro.model.ClaimDocument;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ClaimDocumentRepository extends JpaRepository<ClaimDocument, Long> {
    List<ClaimDocument> findByClaimIdOrderByUploadedAtDesc(String claimId);
}
