package com.claimspro.service;

import com.claimspro.model.Claim;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

@Service
public class ClaimRegistrationSoapService {

    private static final Logger log = LoggerFactory.getLogger(ClaimRegistrationSoapService.class);
    private static final String SOAP_URL =
            "http://10.1.114.176:7058/ls/services/WebBCPService/registerClaim";
    private static final DateTimeFormatter BCP_DATE_FMT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH);

    private final RestTemplate restTemplate;

    public ClaimRegistrationSoapService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    // ── Result VO ─────────────────────────────────────────────────────

    public static class SoapResult {
        private final boolean success;
        private final String caseNumber;
        private final String caseStatus;
        private final String errorMessage;

        private SoapResult(boolean success, String caseNumber, String caseStatus, String errorMessage) {
            this.success      = success;
            this.caseNumber   = caseNumber;
            this.caseStatus   = caseStatus;
            this.errorMessage = errorMessage;
        }

        public static SoapResult ok(String caseNumber, String caseStatus) {
            return new SoapResult(true, caseNumber, caseStatus, null);
        }

        public static SoapResult failure(String errorMessage) {
            return new SoapResult(false, null, null, errorMessage);
        }

        public boolean isSuccess()      { return success; }
        public String getCaseNumber()   { return caseNumber; }
        public String getCaseStatus()   { return caseStatus; }
        public String getErrorMessage() { return errorMessage; }
    }

    // ── Main entry point ──────────────────────────────────────────────

    public SoapResult registerClaim(Claim claim) {
        try {
            String soapBody = buildSoapEnvelope(claim);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(new MediaType("text", "xml", StandardCharsets.UTF_8));
            headers.add("SOAPAction", "registerClaim");

            String responseXml = restTemplate.postForObject(
                    SOAP_URL, new HttpEntity<>(soapBody, headers), String.class);

            log.debug("registerClaim SOAP response for {}: {}", claim.getId(), responseXml);
            return parseResponse(responseXml, claim.getId());

        } catch (Exception ex) {
            log.error("SOAP registerClaim failed for claim {}: {}", claim.getId(), ex.getMessage());
            return SoapResult.failure("BCP registration service is unavailable. Please try again later.");
        }
    }

    // ── SOAP envelope builder ──────────────────────────────────────────

    private String buildSoapEnvelope(Claim claim) {
        String accidentTime = claim.getEventDate() != null
                ? claim.getEventDate().format(BCP_DATE_FMT) : "";

        return "<soapenv:Envelope " +
               "xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
               "xmlns:ser=\"http://service.esb.soa.pub.ebao.com/\">" +
               "<soapenv:Header/>" +
               "<soapenv:Body>" +
               "<ser:registerClaim>" +
               "<registerClaimPortalInputVO>" +
               tag("accidentTime",   accidentTime)                 +
               tag("accierGender",   claim.getGender())            +
               tag("accierIdNumber", claim.getIdNo())              +
               tag("accierIdType",   claim.getIdType())            +
               tag("accierName",     claim.getLifeAssuredName())   +
               tag("address1",       claim.getAddressLine1())      +
               tag("branchCode",     "101")                        +
               tag("causeOfDeath",   claim.getCauseOfDeath())      +
               tag("claimNature",    claim.getClaimNature())       +
               tag("claimType",      claim.getClaimType())         +
               tag("insuredId",      claim.getIdNo())              +
               tag("policyCode",     claim.getPolicyNumber())      +
               tag("reporter",       claim.getReporterId())        +
               tag("rptrEmail",      claim.getEmail())             +
               tag("rptrMp",         claim.getPhone())             +
               tag("rptrName",       claim.getReporterName())      +
               tag("rptrRelation",   claim.getRelation())          +
               tag("rptrTel",        claim.getPhone())             +
               tag("rptrZip",        claim.getPostalCode())        +
               "</registerClaimPortalInputVO>" +
               "</ser:registerClaim>" +
               "</soapenv:Body>" +
               "</soapenv:Envelope>";
    }

    private String tag(String name, String value) {
        return "<" + name + ">" + esc(value) + "</" + name + ">";
    }

    // ── Response parser ────────────────────────────────────────────────

    private SoapResult parseResponse(String xml, String claimId) {
        if (xml == null || xml.isBlank()) {
            return SoapResult.failure("Empty response from BCP registration service.");
        }
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(false);
            factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new InputSource(new StringReader(xml)));

            String successFlag = textOf(doc, "successFlag");
            String caseNumber  = textOf(doc, "caseNumber");
            String caseStatus  = textOf(doc, "caseStatus");

            if ("1".equals(successFlag) && caseNumber != null && !caseNumber.isBlank()) {
                log.info("BCP registration successful for {}: caseNumber={}, status={}",
                        claimId, caseNumber, caseStatus);
                return SoapResult.ok(caseNumber, caseStatus);
            }

            String appException = textOf(doc, "appException");
            String errorMsg = cleanErrorMessage(appException);
            log.warn("BCP registration rejected for {}: successFlag={}, error={}",
                    claimId, successFlag, errorMsg);
            return SoapResult.failure(errorMsg);

        } catch (Exception ex) {
            log.error("Failed to parse registerClaim SOAP response: {}", ex.getMessage());
            return SoapResult.failure("Invalid response received from BCP registration service.");
        }
    }

    private String cleanErrorMessage(String appException) {
        if (appException == null || appException.isBlank()) {
            return "BCP system rejected the claim registration. Please verify the submitted data.";
        }
        String firstLine = appException.split("\n")[0].trim();
        int colonIdx = firstLine.indexOf(": ");
        return colonIdx >= 0 ? firstLine.substring(colonIdx + 2) : firstLine;
    }

    private String textOf(Document doc, String tagName) {
        NodeList nl = doc.getElementsByTagName(tagName);
        if (nl.getLength() > 0 && nl.item(0).getFirstChild() != null) {
            return nl.item(0).getFirstChild().getNodeValue().trim();
        }
        return null;
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }
}
