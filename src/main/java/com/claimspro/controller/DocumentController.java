package com.claimspro.controller;

import com.claimspro.dto.ApiResponse;
import com.claimspro.model.ClaimDocument;
import com.claimspro.repository.ClaimDocumentRepository;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/documents")
public class DocumentController {

    private static final List<String> ALLOWED_TYPES = Arrays.asList(
            "Death Certificate", "Registration Form", "ID Proof", "Bank Proof", "Other");
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(
            "pdf", "jpg", "jpeg", "png", "docx", "doc");
    private static final long MAX_FILE_BYTES = 10L * 1024 * 1024;

    private final ClaimDocumentRepository repo;

    public DocumentController(ClaimDocumentRepository repo) {
        this.repo = repo;
    }

    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<ClaimDocument>> upload(
            @RequestParam("claimId") String claimId,
            @RequestParam("docType") String docType,
            @RequestParam("file") MultipartFile file,
            HttpSession session) throws IOException {

        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("No file selected."));
        }
        if (!ALLOWED_TYPES.contains(docType)) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Please select a valid document type."));
        }
        if (file.getSize() > MAX_FILE_BYTES) {
            return ResponseEntity.badRequest().body(ApiResponse.error("File exceeds 10 MB limit."));
        }

        String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file";
        String ext = extension(originalName).toLowerCase();
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            return ResponseEntity.badRequest().body(
                    ApiResponse.error("Unsupported file type. Allowed: PDF, JPG, PNG, DOCX."));
        }

        @SuppressWarnings("unchecked")
        Map<String, String> user = (Map<String, String>) session.getAttribute("currentUser");
        String uploader = user != null ? user.getOrDefault("name", "Unknown") : "Unknown";

        String storedName = UUID.randomUUID() + "_" + originalName;

        ClaimDocument doc = new ClaimDocument();
        doc.setClaimId(claimId);
        doc.setDocType(docType);
        doc.setOriginalName(originalName);
        doc.setStoredName(storedName);
        doc.setContentType(file.getContentType());
        doc.setFileSize(file.getSize());
        doc.setUploadedAt(LocalDateTime.now());
        doc.setUploadedBy(uploader);
        doc.setFileData(file.getBytes());

        return ResponseEntity.ok(ApiResponse.ok("Document uploaded successfully.", repo.save(doc)));
    }

    @GetMapping("/claim/{claimId}")
    public ResponseEntity<ApiResponse<List<ClaimDocument>>> list(@PathVariable String claimId) {
        return ResponseEntity.ok(ApiResponse.ok(repo.findByClaimIdOrderByUploadedAtDesc(claimId)));
    }

    @GetMapping("/{id}/download")
    public ResponseEntity<Resource> download(@PathVariable Long id) {
        ClaimDocument doc = repo.findById(id).orElse(null);
        if (doc == null || doc.getFileData() == null) {
            return ResponseEntity.notFound().build();
        }

        String ct = doc.getContentType() != null ? doc.getContentType() : "application/octet-stream";
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(ct))
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + doc.getOriginalName() + "\"")
                .body(new ByteArrayResource(doc.getFileData()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        if (!repo.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        repo.deleteById(id);
        return ResponseEntity.ok(ApiResponse.ok("Document deleted.", null));
    }

    private String extension(String filename) {
        int dot = filename.lastIndexOf('.');
        return dot >= 0 ? filename.substring(dot + 1) : "";
    }
}
