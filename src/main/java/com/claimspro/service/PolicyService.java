package com.claimspro.service;

import com.claimspro.dto.PolicyInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@Service
public class PolicyService {

    private static final Logger log = LoggerFactory.getLogger(PolicyService.class);

    private static final String SOAP_URL =
            "http://10.1.114.176:7058/ls/services/WebBCPService";

    private static final String POLICY_ELEMENT =
            "com.ebao.ls.blil.bcp.PolicyListByOmangVO";

    private final RestTemplate restTemplate;

    public PolicyService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<PolicyInfo> getPoliciesByIdNumber(String idNumber) {
        String soapRequest = buildSoapEnvelope(idNumber);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("text", "xml", StandardCharsets.UTF_8));
        headers.add("SOAPAction", "");

        HttpEntity<String> request = new HttpEntity<>(soapRequest, headers);
        String responseXml = restTemplate.postForObject(SOAP_URL, request, String.class);

        return parseResponse(responseXml);
    }

    // ── SOAP request builder ──────────────────────────────────────────

    private String buildSoapEnvelope(String idNumber) {
        return "<soapenv:Envelope " +
               "xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
               "xmlns:ser=\"http://service.esb.soa.pub.ebao.com/\">" +
               "<soapenv:Header/>" +
               "<soapenv:Body>" +
               "<ser:getPoliciesByOmangCustCarePortal>" +
               "<IDNumber>" + escapeXml(idNumber) + "</IDNumber>" +
               "</ser:getPoliciesByOmangCustCarePortal>" +
               "</soapenv:Body>" +
               "</soapenv:Envelope>";
    }

    private String escapeXml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    // ── Response XML parser ───────────────────────────────────────────

    private List<PolicyInfo> parseResponse(String xml) {
        List<PolicyInfo> result = new ArrayList<>();
        if (xml == null || xml.isBlank()) return result;

        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(false);
            factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new InputSource(new StringReader(xml)));

            NodeList nodes = doc.getElementsByTagName(POLICY_ELEMENT);
            for (int i = 0; i < nodes.getLength(); i++) {
                Element el = (Element) nodes.item(i);
                PolicyInfo p = new PolicyInfo();
                p.setPolicyNumber(text(el, "policyNumber"));
                p.setPolicyName(text(el, "policyName"));
                p.setPolicyHolderName(text(el, "policyHolderName"));
                p.setPolicyStatus(text(el, "policyStatus"));
                p.setPremium(text(el, "premium"));
                p.setNextDueDate(formatDate(text(el, "nextDueDate")));
                p.setRoleType(text(el, "roleType"));
                result.add(p);
            }
        } catch (Exception e) {
            log.error("Failed to parse SOAP response: {}", e.getMessage());
        }
        return result;
    }

    private String text(Element el, String tag) {
        NodeList nl = el.getElementsByTagName(tag);
        if (nl.getLength() > 0 && nl.item(0).getFirstChild() != null) {
            return nl.item(0).getFirstChild().getNodeValue().trim();
        }
        return "";
    }

    /** Trim timestamp portion from "2025-05-01 00:00:00.0" → "2025-05-01" */
    private String formatDate(String raw) {
        if (raw == null || raw.isBlank()) return "";
        int space = raw.indexOf(' ');
        return space > 0 ? raw.substring(0, space) : raw;
    }
}
