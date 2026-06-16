package com.claimspro.controller;

import javax.servlet.http.HttpSession;
import java.util.Map;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PageController {

    @GetMapping("/")
    public String index() {
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String login(HttpSession session) {
        if (session.getAttribute("currentUser") != null) {
            return "redirect:/dashboard";
        }
        return "login";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session) {
        return requireAuth(session, "dashboard");
    }

    @GetMapping("/case-registration")
    public String caseRegistration(HttpSession session) {
        return requireRole(session, "case-registration", "Claims Officer");
    }

    @GetMapping("/case-acceptance")
    public String caseAcceptance(HttpSession session) {
        return requireRole(session, "case-acceptance", "Claims Officer");
    }

    @GetMapping("/case-evaluation")
    public String caseEvaluation(HttpSession session) {
        return requireRole(session, "case-evaluation", "Claims Officer");
    }

    @GetMapping("/case-approval")
    public String caseApproval(HttpSession session) {
        return requireRole(session, "case-approval", "Case Manager");
    }

    private String requireAuth(HttpSession session, String view) {
        if (session.getAttribute("currentUser") == null) {
            return "redirect:/login";
        }
        return view;
    }

    @SuppressWarnings("unchecked")
    private String requireRole(HttpSession session, String view, String... allowedRoles) {
        Map<String, String> user = (Map<String, String>) session.getAttribute("currentUser");
        if (user == null) {
            return "redirect:/login";
        }
        String role = user.getOrDefault("role", "");
        for (String allowed : allowedRoles) {
            if (allowed.equals(role)) return view;
        }
        return "redirect:/dashboard";
    }
}
